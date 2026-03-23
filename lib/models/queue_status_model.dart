import 'queue_model.dart';
import 'token_model.dart';

class QueueStatusModel {
  const QueueStatusModel({
    required this.queue,
    required this.token,
    required this.peopleAhead,
    required this.baseWaitMinutes,
    required this.estimatedWaitMinutes,
    required this.shouldNotifySoon,
  });

  final QueueModel queue;
  final TokenModel token;
  final int peopleAhead;
  final int baseWaitMinutes;
  final int estimatedWaitMinutes;
  final bool shouldNotifySoon;

  bool get isQueuePaused => queue.isPaused;
  bool get isQueueEnded => queue.isEnded;
  bool get isCancelled => token.isCancelled;
  bool get isCompleted =>
      token.isServed || token.tokenNumber <= queue.currentToken;
}
