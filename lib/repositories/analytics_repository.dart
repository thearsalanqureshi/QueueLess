import '../core/services/ai_service.dart';
import '../core/utils/time_utils.dart';
import '../models/queue_insight_model.dart';
import '../models/queue_model.dart';
import '../models/token_model.dart';
import 'token_repository.dart';

class AnalyticsRepository {
  AnalyticsRepository(this._tokenRepository, this._aiService);

  final TokenRepository _tokenRepository;
  final AiService _aiService;

  String? _lastSignature;
  QueueInsightModel? _lastInsight;

  Future<QueueInsightModel> buildInsights({
    required QueueModel queue,
    required List<TokenModel> waitingTokens,
  }) async {
    final tokens = await _tokenRepository.fetchTokensForQueue(queue.queueId);
    final now = DateTime.now();
    final servedToday = tokens
        .where(
          (token) =>
              token.isServed &&
              token.createdAt.year == now.year &&
              token.createdAt.month == now.month &&
              token.createdAt.day == now.day,
        )
        .length;

    final peakHour = _calculatePeakHour(tokens);
    final signature =
        '${queue.queueId}:${queue.currentToken}:${queue.lastIssuedToken}:${waitingTokens.length}:$servedToday:$peakHour';

    if (_lastSignature == signature && _lastInsight != null) {
      return _lastInsight!;
    }

    final currentWaitMinutes = waitingTokens.length * queue.avgServiceTime;

    final insights = await _aiService.generateInsights(
      queue: queue,
      waitingCount: waitingTokens.length,
      totalServedToday: servedToday,
      averageServiceMinutes: queue.avgServiceTime.toDouble(),
      peakHour: peakHour,
      currentWaitMinutes: currentWaitMinutes,
    );

    _lastSignature = signature;
    _lastInsight = insights;
    return insights;
  }

  String _calculatePeakHour(List<TokenModel> tokens) {
    if (tokens.isEmpty) {
      return 'Not enough data yet';
    }

    final buckets = <int, int>{};
    for (final token in tokens) {
      buckets.update(
        token.createdAt.hour,
        (count) => count + 1,
        ifAbsent: () => 1,
      );
    }

    final busiestHour = buckets.entries.reduce(
      (left, right) => left.value >= right.value ? left : right,
    );

    return peakHourLabel(busiestHour.key);
  }
}
