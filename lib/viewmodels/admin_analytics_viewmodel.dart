import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/queue_history_entry.dart';
import '../models/queue_insight_model.dart';
import '../models/queue_model.dart';
import '../models/token_model.dart';
import '../providers/app_providers.dart';

class AdminAnalyticsState {
  const AdminAnalyticsState({
    required this.recentHistory,
    required this.queue,
    required this.insights,
    required this.waitingTokens,
  });

  final List<QueueHistoryEntry> recentHistory;
  final QueueModel? queue;
  final QueueInsightModel? insights;
  final List<TokenModel> waitingTokens;
}

final adminAnalyticsViewModelProvider = AsyncNotifierProvider.autoDispose
    .family<AdminAnalyticsViewModel, AdminAnalyticsState, String?>(
      AdminAnalyticsViewModel.new,
    );

class AdminAnalyticsViewModel
    extends AutoDisposeFamilyAsyncNotifier<AdminAnalyticsState, String?> {
  @override
  Future<AdminAnalyticsState> build(String? arg) async {
    return _load(arg);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = AsyncData(await _load(arg));
  }

  Future<AdminAnalyticsState> _load(String? requestedQueueId) async {
    final history = ref
        .read(historyRepositoryProvider)
        .getEntries(role: QueueHistoryEntry.adminRole);

    final profile = await ref
        .read(userProfileRepositoryProvider)
        .fetchCurrentProfile();
    final queueId = requestedQueueId?.trim().isNotEmpty == true
        ? requestedQueueId!.trim()
        : profile?.lastAdminQueueId;

    if (queueId == null || queueId.isEmpty) {
      return AdminAnalyticsState(
        recentHistory: history,
        queue: null,
        insights: null,
        waitingTokens: const [],
      );
    }

    final queue = await ref.read(queueRepositoryProvider).fetchQueue(queueId);
    if (queue == null) {
      return AdminAnalyticsState(
        recentHistory: history,
        queue: null,
        insights: null,
        waitingTokens: const [],
      );
    }

    final waitingTokens =
        (await ref.read(tokenRepositoryProvider).fetchTokensForQueue(queueId))
            .where((token) => token.isWaiting)
            .toList()
          ..sort(
            (left, right) => left.tokenNumber.compareTo(right.tokenNumber),
          );

    final insights = await ref
        .read(analyticsRepositoryProvider)
        .buildInsights(queue: queue, waitingTokens: waitingTokens);

    return AdminAnalyticsState(
      recentHistory: history,
      queue: queue,
      insights: insights,
      waitingTokens: waitingTokens,
    );
  }
}
