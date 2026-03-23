import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:queueless/core/services/ai_service.dart';
import 'package:queueless/core/services/firebase_service.dart';
import 'package:queueless/core/services/hive_service.dart';
import 'package:queueless/core/services/user_identity_service.dart';
import 'package:queueless/models/queue_history_entry.dart';
import 'package:queueless/models/queue_insight_model.dart';
import 'package:queueless/models/queue_model.dart';
import 'package:queueless/models/token_model.dart';
import 'package:queueless/models/user_profile_model.dart';
import 'package:queueless/providers/app_providers.dart';
import 'package:queueless/repositories/analytics_repository.dart';
import 'package:queueless/repositories/history_repository.dart';
import 'package:queueless/repositories/queue_repository.dart';
import 'package:queueless/repositories/token_repository.dart';
import 'package:queueless/repositories/user_profile_repository.dart';
import 'package:queueless/storage/token_history_storage.dart';
import 'package:queueless/viewmodels/admin_analytics_viewmodel.dart';
import 'package:queueless/viewmodels/admin_queue_viewmodel.dart';
import 'package:queueless/viewmodels/join_queue_viewmodel.dart';

class _FakeHiveService extends HiveService {}

class _FakeFirebaseService extends FirebaseService {}

class _FakeUserIdentityService extends UserIdentityService {
  _FakeUserIdentityService(this.userId)
    : super(_FakeFirebaseService(), _FakeHiveService());

  final String userId;

  @override
  Future<String> getOrCreateUserId() async => userId;
}

class _FakeQueueRepository extends QueueRepository {
  _FakeQueueRepository({this.fetchQueueResult, this.createQueueResult})
    : super(_FakeFirebaseService());

  final QueueModel? fetchQueueResult;
  final QueueModel? createQueueResult;

  @override
  Future<QueueModel?> fetchQueue(String queueId) async => fetchQueueResult;

  @override
  Future<QueueModel> createQueue({
    required String name,
    required int avgServiceTime,
    required String adminId,
  }) async {
    return createQueueResult ??
        QueueModel(
          queueId: 'QUEUE1',
          adminId: adminId,
          name: name,
          avgServiceTime: avgServiceTime,
          currentToken: 0,
          lastIssuedToken: 0,
          status: QueueLifecycleStatus.active,
          createdAt: DateTime(2026, 3, 23, 10),
          updatedAt: DateTime(2026, 3, 23, 10),
        );
  }
}

class _FakeTokenRepository extends TokenRepository {
  _FakeTokenRepository({this.joinedToken, this.tokensForQueue = const []})
    : super(_FakeFirebaseService());

  final TokenModel? joinedToken;
  final List<TokenModel> tokensForQueue;

  @override
  Future<TokenModel> joinQueue({
    required String queueId,
    required String userId,
  }) async {
    return joinedToken ??
        TokenModel(
          tokenId: 'token-1',
          queueId: queueId,
          tokenNumber: 6,
          status: TokenStatus.waiting,
          createdAt: DateTime(2026, 3, 23, 10, 5),
          userId: userId,
        );
  }

  @override
  Future<List<TokenModel>> fetchTokensForQueue(String queueId) async {
    return tokensForQueue;
  }
}

class _FakeHistoryRepository extends HistoryRepository {
  _FakeHistoryRepository({
    this.entries = const [],
    this.throwOnSaveJoined = false,
    this.throwOnSaveCreated = false,
  }) : super(TokenHistoryStorage(_FakeHiveService()));

  final List<QueueHistoryEntry> entries;
  final bool throwOnSaveJoined;
  final bool throwOnSaveCreated;
  final List<String> savedIds = [];

  @override
  Future<void> saveJoinedQueue({
    required QueueModel queue,
    required TokenModel token,
  }) async {
    savedIds.add(token.tokenId);
    if (throwOnSaveJoined) {
      throw Exception('history save failed');
    }
  }

  @override
  Future<void> saveCreatedQueue({required QueueModel queue}) async {
    savedIds.add(queue.queueId);
    if (throwOnSaveCreated) {
      throw Exception('history save failed');
    }
  }

  @override
  List<QueueHistoryEntry> getEntries({String? role, int? limit}) {
    final filtered = entries
        .where((entry) => role == null || entry.role == role)
        .toList(growable: false);

    if (limit == null || filtered.length <= limit) {
      return filtered;
    }

    return filtered.take(limit).toList(growable: false);
  }
}

class _FakeUserProfileRepository extends UserProfileRepository {
  _FakeUserProfileRepository({
    this.profile,
    this.throwOnSetActive = false,
    this.throwOnSetLastAdminQueue = false,
  }) : super(_FakeFirebaseService());

  final UserProfileModel? profile;
  final bool throwOnSetActive;
  final bool throwOnSetLastAdminQueue;
  String? activeQueueId;
  String? activeTokenId;
  String? lastAdminQueueId;

  @override
  Future<UserProfileModel?> fetchCurrentProfile() async => profile;

  @override
  Future<void> setActiveCustomerSession({
    required String queueId,
    required String tokenId,
  }) async {
    activeQueueId = queueId;
    activeTokenId = tokenId;
    if (throwOnSetActive) {
      throw Exception('profile sync failed');
    }
  }

  @override
  Future<void> setLastAdminQueue(String queueId) async {
    lastAdminQueueId = queueId;
    if (throwOnSetLastAdminQueue) {
      throw Exception('profile sync failed');
    }
  }
}

class _FakeAnalyticsRepository extends AnalyticsRepository {
  _FakeAnalyticsRepository(this.insight)
    : super(_FakeTokenRepository(), AiService());

  final QueueInsightModel insight;

  @override
  Future<QueueInsightModel> buildInsights({
    required QueueModel queue,
    required List<TokenModel> waitingTokens,
  }) async {
    return insight;
  }
}

void main() {
  final queue = QueueModel(
    queueId: 'QUEUE1',
    adminId: 'admin-1',
    name: 'Main Branch',
    avgServiceTime: 6,
    currentToken: 2,
    lastIssuedToken: 8,
    status: QueueLifecycleStatus.active,
    createdAt: DateTime(2026, 3, 23, 10),
    updatedAt: DateTime(2026, 3, 23, 10),
  );
  final token = TokenModel(
    tokenId: 'token-1',
    queueId: 'QUEUE1',
    tokenNumber: 5,
    status: TokenStatus.waiting,
    createdAt: DateTime(2026, 3, 23, 10, 5),
    userId: 'user-1',
  );

  test('Join queue succeeds even if history and profile sync fail afterwards', () async {
    final historyRepository = _FakeHistoryRepository(throwOnSaveJoined: true);
    final profileRepository = _FakeUserProfileRepository(throwOnSetActive: true);
    final container = ProviderContainer(
      overrides: [
        userIdentityServiceProvider.overrideWithValue(
          _FakeUserIdentityService('user-1'),
        ),
        tokenRepositoryProvider.overrideWithValue(
          _FakeTokenRepository(joinedToken: token),
        ),
        queueRepositoryProvider.overrideWithValue(
          _FakeQueueRepository(fetchQueueResult: queue),
        ),
        historyRepositoryProvider.overrideWithValue(historyRepository),
        userProfileRepositoryProvider.overrideWithValue(profileRepository),
      ],
    );
    addTearDown(container.dispose);

    final joined = await container
        .read(joinQueueViewModelProvider.notifier)
        .joinQueue(' queue1 ');

    expect(joined.tokenId, 'token-1');
    expect(container.read(joinQueueViewModelProvider).hasValue, isTrue);
  });

  test('Create queue succeeds even if local history and profile sync fail afterwards', () async {
    final historyRepository = _FakeHistoryRepository(throwOnSaveCreated: true);
    final profileRepository = _FakeUserProfileRepository(
      throwOnSetLastAdminQueue: true,
    );
    final container = ProviderContainer(
      overrides: [
        userIdentityServiceProvider.overrideWithValue(
          _FakeUserIdentityService('admin-1'),
        ),
        queueRepositoryProvider.overrideWithValue(
          _FakeQueueRepository(createQueueResult: queue),
        ),
        historyRepositoryProvider.overrideWithValue(historyRepository),
        userProfileRepositoryProvider.overrideWithValue(profileRepository),
      ],
    );
    addTearDown(container.dispose);

    final created = await container
        .read(createQueueViewModelProvider.notifier)
        .createQueue(businessName: 'Main Branch', avgServiceTime: 6);

    expect(created.queueId, 'QUEUE1');
    expect(container.read(createQueueViewModelProvider).value?.queueId, 'QUEUE1');
  });

  test('Admin analytics loads the last managed queue and filters waiting tokens', () async {
    final insight = const QueueInsightModel(
      totalServedToday: 14,
      averageServiceMinutes: 6,
      peakHour: '2 PM',
      headline: 'Steady demand this afternoon.',
      suggestion: 'Open a second counter during lunch.',
      optimizationSuggestion: 'Add a second staff member for the next hour.',
    );
    final container = ProviderContainer(
      overrides: [
        historyRepositoryProvider.overrideWithValue(
          _FakeHistoryRepository(
            entries: [
              QueueHistoryEntry(
                id: 'queue_QUEUE1',
                queueId: 'QUEUE1',
                queueName: 'Main Branch',
                createdAt: DateTime(2026, 3, 23, 10),
                role: QueueHistoryEntry.adminRole,
                statusLabel: 'Created queue',
              ),
              QueueHistoryEntry(
                id: 'token-9',
                queueId: 'QUEUE9',
                queueName: 'Customer Queue',
                createdAt: DateTime(2026, 3, 23, 9),
                role: QueueHistoryEntry.customerRole,
                statusLabel: 'Joined queue',
              ),
            ],
          ),
        ),
        userProfileRepositoryProvider.overrideWithValue(
          _FakeUserProfileRepository(
            profile: const UserProfileModel(
              uid: 'admin-1',
              lastAdminQueueId: 'QUEUE1',
            ),
          ),
        ),
        queueRepositoryProvider.overrideWithValue(
          _FakeQueueRepository(fetchQueueResult: queue),
        ),
        tokenRepositoryProvider.overrideWithValue(
          _FakeTokenRepository(
            tokensForQueue: [
              token.copyWith(tokenNumber: 7, status: TokenStatus.waiting),
              token.copyWith(tokenNumber: 4, status: TokenStatus.waiting),
              token.copyWith(tokenNumber: 3, status: TokenStatus.served),
            ],
          ),
        ),
        analyticsRepositoryProvider.overrideWithValue(
          _FakeAnalyticsRepository(insight),
        ),
      ],
    );
    addTearDown(container.dispose);

    final state = await container.read(adminAnalyticsViewModelProvider(null).future);

    expect(state.queue?.queueId, 'QUEUE1');
    expect(state.recentHistory, hasLength(1));
    expect(state.waitingTokens.map((token) => token.tokenNumber).toList(), [4, 7]);
    expect(state.insights?.headline, insight.headline);
  });
}
