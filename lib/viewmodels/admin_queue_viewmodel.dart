import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/queue_insight_model.dart';
import '../models/queue_model.dart';
import '../models/token_model.dart';
import '../providers/app_providers.dart';

final createQueueViewModelProvider =
    AsyncNotifierProvider<CreateQueueViewModel, QueueModel?>(
      CreateQueueViewModel.new,
    );

class CreateQueueViewModel extends AsyncNotifier<QueueModel?> {
  @override
  Future<QueueModel?> build() async => null;

  Future<QueueModel> createQueue({
    required String businessName,
    required int avgServiceTime,
  }) async {
    state = const AsyncLoading();

    try {
      final adminId = await ref
          .read(userIdentityServiceProvider)
          .getOrCreateUserId();
      final queue = await ref
          .read(queueRepositoryProvider)
          .createQueue(
            name: businessName,
            avgServiceTime: avgServiceTime,
            adminId: adminId,
          );
      await _persistCreatedQueueArtifacts(queue);
      state = AsyncData(queue);
      return queue;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  void reset() {
    state = const AsyncData(null);
  }

  Future<void> _persistCreatedQueueArtifacts(QueueModel queue) async {
    try {
      await ref.read(historyRepositoryProvider).saveCreatedQueue(queue: queue);
    } catch (_) {}

    try {
      await ref.read(userProfileRepositoryProvider).setLastAdminQueue(queue.queueId);
    } catch (_) {}
  }
}

class AdminDashboardState {
  const AdminDashboardState({
    required this.queue,
    required this.waitingTokens,
    required this.insights,
    required this.isMutating,
  });

  final QueueModel queue;
  final List<TokenModel> waitingTokens;
  final QueueInsightModel insights;
  final bool isMutating;

  AdminDashboardState copyWith({
    QueueModel? queue,
    List<TokenModel>? waitingTokens,
    QueueInsightModel? insights,
    bool? isMutating,
  }) {
    return AdminDashboardState(
      queue: queue ?? this.queue,
      waitingTokens: waitingTokens ?? this.waitingTokens,
      insights: insights ?? this.insights,
      isMutating: isMutating ?? this.isMutating,
    );
  }
}

final adminQueueViewModelProvider = AsyncNotifierProvider.autoDispose
    .family<AdminQueueViewModel, AdminDashboardState, String>(
      AdminQueueViewModel.new,
    );

class AdminQueueViewModel
    extends AutoDisposeFamilyAsyncNotifier<AdminDashboardState, String> {
  StreamSubscription? _queueSubscription;
  StreamSubscription? _waitingSubscription;

  @override
  Future<AdminDashboardState> build(String arg) async {
    ref.onDispose(() {
      _queueSubscription?.cancel();
      _waitingSubscription?.cancel();
    });

    await _safeRememberAdminQueue(arg);

    _queueSubscription = ref
        .read(queueRepositoryProvider)
        .watchQueue(arg)
        .listen((_) => _refreshState());

    _waitingSubscription = ref
        .read(tokenRepositoryProvider)
        .watchWaitingTokens(arg)
        .listen((_) => _refreshState());

    return _composeState(isMutating: false);
  }

  Future<void> serveNext() async {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }

    state = AsyncData(current.copyWith(isMutating: true));
    try {
      await ref.read(queueRepositoryProvider).serveNext(arg);
      await _refreshState();
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  Future<void> togglePause() async {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }

    state = AsyncData(current.copyWith(isMutating: true));
    try {
      await ref
          .read(queueRepositoryProvider)
          .setPaused(arg, paused: !current.queue.isPaused);
      await _refreshState();
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  Future<void> endQueue() async {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }

    state = AsyncData(current.copyWith(isMutating: true));
    try {
      await ref.read(queueRepositoryProvider).endQueue(arg);
      await _refreshState();
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  Future<void> refreshInsights() async {
    await _refreshState();
  }

  Future<void> _refreshState() async {
    try {
      final isMutating = state.valueOrNull?.isMutating ?? false;
      final nextState = await _composeState(isMutating: isMutating);
      state = AsyncData(nextState.copyWith(isMutating: false));
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  Future<AdminDashboardState> _composeState({required bool isMutating}) async {
    final queue = await ref.read(queueRepositoryProvider).fetchQueue(arg);
    if (queue == null) {
      throw Exception('Queue could not be loaded.');
    }

    final waitingTokens =
        (await ref.read(tokenRepositoryProvider).fetchTokensForQueue(arg))
            .where((token) => token.isWaiting)
            .toList()
          ..sort(
            (left, right) => left.tokenNumber.compareTo(right.tokenNumber),
          );

    final insights = await ref
        .read(analyticsRepositoryProvider)
        .buildInsights(queue: queue, waitingTokens: waitingTokens);

    return AdminDashboardState(
      queue: queue,
      waitingTokens: waitingTokens,
      insights: insights,
      isMutating: isMutating,
    );
  }

  Future<void> _safeRememberAdminQueue(String queueId) async {
    try {
      await ref.read(userProfileRepositoryProvider).setLastAdminQueue(queueId);
    } catch (_) {}
  }
}
