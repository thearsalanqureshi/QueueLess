import 'package:flutter_test/flutter_test.dart';

import 'package:queueless/core/services/firebase_service.dart';
import 'package:queueless/core/services/hive_service.dart';
import 'package:queueless/models/active_queue_session.dart';
import 'package:queueless/models/app_role.dart';
import 'package:queueless/models/queue_history_entry.dart';
import 'package:queueless/models/queue_model.dart';
import 'package:queueless/models/token_model.dart';
import 'package:queueless/models/user_profile_model.dart';
import 'package:queueless/repositories/history_repository.dart';
import 'package:queueless/repositories/queue_repository.dart';
import 'package:queueless/repositories/session_repository.dart';
import 'package:queueless/repositories/token_repository.dart';
import 'package:queueless/repositories/user_profile_repository.dart';
import 'package:queueless/storage/token_history_storage.dart';

class _FakeHiveService extends HiveService {}

class _FakeFirebaseService extends FirebaseService {}

class _FakeHistoryRepository extends HistoryRepository {
  _FakeHistoryRepository(this.entries)
    : super(TokenHistoryStorage(_FakeHiveService()));

  final List<QueueHistoryEntry> entries;

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

class _FakeQueueRepository extends QueueRepository {
  _FakeQueueRepository(this.queues) : super(_FakeFirebaseService());

  final Map<String, QueueModel> queues;

  @override
  Future<QueueModel?> fetchQueue(String queueId) async => queues[queueId];
}

class _FakeTokenRepository extends TokenRepository {
  _FakeTokenRepository(this.tokens) : super(_FakeFirebaseService());

  final Map<String, TokenModel> tokens;

  @override
  Future<TokenModel?> fetchToken(String tokenId) async => tokens[tokenId];
}

class _FakeUserProfileRepository extends UserProfileRepository {
  _FakeUserProfileRepository(this.profile) : super(_FakeFirebaseService());

  final UserProfileModel? profile;

  @override
  Future<UserProfileModel?> fetchCurrentProfile() async => profile;
}

void main() {
  final activeQueue = QueueModel(
    queueId: 'QUEUE1',
    adminId: 'admin-1',
    name: 'Main Branch',
    avgServiceTime: 5,
    currentToken: 4,
    lastIssuedToken: 10,
    status: QueueLifecycleStatus.active,
    createdAt: DateTime(2026, 3, 23, 10),
    updatedAt: DateTime(2026, 3, 23, 10),
  );
  final activeToken = TokenModel(
    tokenId: 'token-1',
    queueId: 'QUEUE1',
    tokenNumber: 8,
    status: TokenStatus.waiting,
    createdAt: DateTime(2026, 3, 23, 10, 1),
    userId: 'user-1',
  );

  test('Session repository prefers the active customer session from profile', () async {
    final repository = SessionRepository(
      _FakeHistoryRepository([
        QueueHistoryEntry(
          id: 'token-history',
          queueId: 'QUEUE2',
          queueName: 'Other Queue',
          createdAt: DateTime(2026, 3, 23, 9),
          role: QueueHistoryEntry.customerRole,
          statusLabel: 'Joined queue',
          tokenNumber: 12,
        ),
      ]),
      _FakeQueueRepository({'QUEUE1': activeQueue}),
      _FakeTokenRepository({'token-1': activeToken}),
      _FakeUserProfileRepository(
        const UserProfileModel(
          uid: 'user-1',
          role: AppRole.customer,
          activeCustomerQueueId: 'QUEUE1',
          activeCustomerTokenId: 'token-1',
        ),
      ),
    );

    final session = await repository.findLatestActiveCustomerSession();

    expect(
      session,
      const ActiveQueueSession(
        queueId: 'QUEUE1',
        queueName: 'Main Branch',
        tokenId: 'token-1',
        tokenNumber: 8,
      ),
    );
  });

  test('Session repository falls back to restorable customer history entries', () async {
    final repository = SessionRepository(
      _FakeHistoryRepository([
        QueueHistoryEntry(
          id: 'token-1',
          queueId: 'QUEUE1',
          queueName: 'Main Branch',
          createdAt: DateTime(2026, 3, 23, 10, 1),
          role: QueueHistoryEntry.customerRole,
          statusLabel: 'Joined queue',
          tokenNumber: 8,
        ),
      ]),
      _FakeQueueRepository({'QUEUE1': activeQueue}),
      _FakeTokenRepository({'token-1': activeToken}),
      _FakeUserProfileRepository(null),
    );

    final session = await repository.findLatestActiveCustomerSession();

    expect(session?.queueId, 'QUEUE1');
    expect(session?.tokenId, 'token-1');
  });

  test('Session repository ignores inactive customer sessions', () async {
    final endedQueue = activeQueue.copyWith(status: QueueLifecycleStatus.ended);
    final servedToken = activeToken.copyWith(status: TokenStatus.served);
    final repository = SessionRepository(
      _FakeHistoryRepository([
        QueueHistoryEntry(
          id: 'token-1',
          queueId: 'QUEUE1',
          queueName: 'Main Branch',
          createdAt: DateTime(2026, 3, 23, 10, 1),
          role: QueueHistoryEntry.customerRole,
          statusLabel: 'Joined queue',
          tokenNumber: 8,
        ),
      ]),
      _FakeQueueRepository({'QUEUE1': endedQueue}),
      _FakeTokenRepository({'token-1': servedToken}),
      _FakeUserProfileRepository(
        const UserProfileModel(
          uid: 'user-1',
          role: AppRole.customer,
          activeCustomerQueueId: 'QUEUE1',
          activeCustomerTokenId: 'token-1',
        ),
      ),
    );

    final session = await repository.findLatestActiveCustomerSession();

    expect(session, isNull);
  });
}
