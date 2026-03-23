import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_constants.dart';
import '../core/utils/queue_math.dart';
import '../models/queue_status_model.dart';
import '../providers/app_providers.dart';

class QueueSessionArgs {
  const QueueSessionArgs({required this.queueId, required this.tokenId});

  final String queueId;
  final String tokenId;

  @override
  bool operator ==(Object other) {
    return other is QueueSessionArgs &&
        other.queueId == queueId &&
        other.tokenId == tokenId;
  }

  @override
  int get hashCode => Object.hash(queueId, tokenId);
}

final queueViewModelProvider = AsyncNotifierProvider.autoDispose
    .family<QueueViewModel, QueueStatusModel, QueueSessionArgs>(
      QueueViewModel.new,
    );

class QueueViewModel
    extends AutoDisposeFamilyAsyncNotifier<QueueStatusModel, QueueSessionArgs> {
  StreamSubscription? _queueSubscription;
  StreamSubscription? _tokenSubscription;
  var _notificationShown = false;
  var _sessionCleared = false;

  @override
  Future<QueueStatusModel> build(QueueSessionArgs arg) async {
    ref.onDispose(() {
      _queueSubscription?.cancel();
      _tokenSubscription?.cancel();
    });

    _queueSubscription = ref
        .read(queueRepositoryProvider)
        .watchQueue(arg.queueId)
        .listen((_) => _refreshState());

    _tokenSubscription = ref
        .read(tokenRepositoryProvider)
        .watchToken(arg.tokenId)
        .listen((_) => _refreshState());

    final initialState = await _composeState(arg);
    await _safeSyncActiveSession(initialState);
    return initialState;
  }

  Future<void> leaveQueue() async {
    final tokenId = arg.tokenId;
    await ref.read(tokenRepositoryProvider).leaveQueue(tokenId);
    try {
      await ref.read(userProfileRepositoryProvider).clearActiveCustomerSession();
    } catch (_) {}
    _sessionCleared = true;
  }

  Future<void> _refreshState() async {
    try {
      final nextState = await _composeState(arg);
      state = AsyncData(nextState);
      await _safeSyncActiveSession(nextState);
      await _maybeNotify(nextState);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  Future<QueueStatusModel> _composeState(QueueSessionArgs args) async {
    final queue = await ref
        .read(queueRepositoryProvider)
        .fetchQueue(args.queueId);
    final token = await ref
        .read(tokenRepositoryProvider)
        .fetchToken(args.tokenId);

    if (queue == null || token == null) {
      throw Exception('Queue session could not be loaded.');
    }

    final peopleAhead = QueueMath.peopleAhead(
      currentToken: queue.currentToken,
      userToken: token.tokenNumber,
    );
    final baseWaitMinutes = QueueMath.waitMinutes(
      currentToken: queue.currentToken,
      userToken: token.tokenNumber,
      avgServiceTime: queue.avgServiceTime,
    );
    final estimatedWaitMinutes =
        await ref
            .read(aiServiceProvider)
            .predictWaitTime(
              queue: queue,
              token: token,
              peopleAhead: peopleAhead,
              baseWaitMinutes: baseWaitMinutes,
            ) ??
        baseWaitMinutes;

    return QueueStatusModel(
      queue: queue,
      token: token,
      peopleAhead: peopleAhead,
      baseWaitMinutes: baseWaitMinutes,
      estimatedWaitMinutes: estimatedWaitMinutes,
      shouldNotifySoon: QueueMath.isNearTurn(
        currentToken: queue.currentToken,
        userToken: token.tokenNumber,
        threshold: AppConstants.nearTurnThreshold,
      ),
    );
  }

  Future<void> _maybeNotify(QueueStatusModel status) async {
    if (_notificationShown ||
        status.isCompleted ||
        status.isCancelled ||
        status.isQueueEnded ||
        !status.shouldNotifySoon) {
      return;
    }

    _notificationShown = true;
    await ref
        .read(notificationServiceProvider)
        .showTurnAlert(
          queueName: status.queue.name,
          tokenNumber: status.token.tokenNumber,
          peopleAhead: status.peopleAhead,
        );
  }

  Future<void> _syncActiveSession(QueueStatusModel status) async {
    final userProfileRepository = ref.read(userProfileRepositoryProvider);

    if (status.isCancelled || status.isCompleted || status.isQueueEnded) {
      if (_sessionCleared) {
        return;
      }

      _sessionCleared = true;
      await userProfileRepository.clearActiveCustomerSession();
      return;
    }

    _sessionCleared = false;
    await userProfileRepository.setActiveCustomerSession(
      queueId: status.queue.queueId,
      tokenId: status.token.tokenId,
    );
  }

  Future<void> _safeSyncActiveSession(QueueStatusModel status) async {
    try {
      await _syncActiveSession(status);
    } catch (_) {}
  }
}
