import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../models/queue_insight_model.dart';
import '../../models/queue_model.dart';
import '../../models/token_model.dart';
import '../constants/app_constants.dart';

class AiService {
  static const String _apiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: String.fromEnvironment('MY_API_KEY'),
  );

  bool get isConfigured => _apiKey.isNotEmpty;

  Future<String> askQueueAssistant({
    required QueueModel queue,
    required TokenModel token,
    required String question,
    required int peopleAhead,
    required int estimatedWaitMinutes,
  }) async {
    final fallback = _buildQueueAssistantFallback(
      queue: queue,
      token: token,
      peopleAhead: peopleAhead,
      estimatedWaitMinutes: estimatedWaitMinutes,
    );

    if (!isConfigured) {
      return fallback;
    }

    final prompt =
        '''
You are QueueLess, a helpful queue assistant inside a mobile app.
Answer briefly in 1 to 2 sentences.

Queue name: ${queue.name}
Current token: ${queue.currentToken}
User token: ${token.tokenNumber}
People ahead: $peopleAhead
Average service time: ${queue.avgServiceTime} minutes
Estimated wait: $estimatedWaitMinutes minutes
User question: "$question"
''';

    final response = await _generateText(prompt);
    return response?.trim().isNotEmpty == true ? response!.trim() : fallback;
  }

  Future<int?> predictWaitTime({
    required QueueModel queue,
    required TokenModel token,
    required int peopleAhead,
    required int baseWaitMinutes,
  }) async {
    if (!isConfigured || peopleAhead <= 0) {
      return baseWaitMinutes;
    }

    final prompt =
        '''
Return only one integer. Estimate the wait time in minutes.
Queue average service time: ${queue.avgServiceTime}
Current token: ${queue.currentToken}
User token: ${token.tokenNumber}
People ahead: $peopleAhead
Base wait estimate: $baseWaitMinutes
''';

    final response = await _generateText(prompt);
    if (response == null) {
      return baseWaitMinutes;
    }

    final match = RegExp(r'(\d+)').firstMatch(response);
    if (match == null) {
      return baseWaitMinutes;
    }

    return int.tryParse(match.group(1)!);
  }

  Future<QueueInsightModel> generateInsights({
    required QueueModel queue,
    required int waitingCount,
    required int totalServedToday,
    required double averageServiceMinutes,
    required String peakHour,
    required int currentWaitMinutes,
  }) async {
    final fallback = _fallbackInsights(
      queue: queue,
      waitingCount: waitingCount,
      totalServedToday: totalServedToday,
      averageServiceMinutes: averageServiceMinutes,
      peakHour: peakHour,
      currentWaitMinutes: currentWaitMinutes,
    );

    if (!isConfigured) {
      return fallback;
    }

    final prompt =
        '''
You are an operations analyst for QueueLess.
Respond in valid JSON with keys "headline", "suggestion", and "optimizationSuggestion".

Queue: ${queue.name}
Waiting customers: $waitingCount
Current token: ${queue.currentToken}
Last issued token: ${queue.lastIssuedToken}
Total served today: $totalServedToday
Average service minutes: ${averageServiceMinutes.toStringAsFixed(1)}
Peak hour: $peakHour
Current estimated wait minutes: $currentWaitMinutes
Long wait threshold: ${AppConstants.optimizationWaitThresholdMinutes}
''';

    final response = await _generateText(prompt);
    if (response == null) {
      return fallback;
    }

    try {
      final decoded = jsonDecode(response) as Map<String, dynamic>;
      return QueueInsightModel(
        totalServedToday: totalServedToday,
        averageServiceMinutes: averageServiceMinutes,
        peakHour: peakHour,
        headline: (decoded['headline'] as String?)?.trim().isNotEmpty == true
            ? decoded['headline'] as String
            : fallback.headline,
        suggestion:
            (decoded['suggestion'] as String?)?.trim().isNotEmpty == true
            ? decoded['suggestion'] as String
            : fallback.suggestion,
        optimizationSuggestion:
            (decoded['optimizationSuggestion'] as String?)?.trim().isNotEmpty ==
                true
            ? decoded['optimizationSuggestion'] as String
            : fallback.optimizationSuggestion,
      );
    } catch (_) {
      return fallback;
    }
  }

  Future<String?> _generateText(String prompt) async {
    final uri = Uri.https(
      'generativelanguage.googleapis.com',
      '/v1beta/models/${AppConstants.geminiModel}:generateContent',
      {'key': _apiKey},
    );

    final response = await http.post(
      uri,
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {
            'role': 'user',
            'parts': [
              {'text': prompt},
            ],
          },
        ],
        'generationConfig': {'temperature': 0.3, 'maxOutputTokens': 200},
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      return null;
    }

    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    final candidates = payload['candidates'] as List<dynamic>?;
    if (candidates == null || candidates.isEmpty) {
      return null;
    }

    final content = candidates.first['content'] as Map<String, dynamic>?;
    final parts = content?['parts'] as List<dynamic>?;
    if (parts == null || parts.isEmpty) {
      return null;
    }

    return parts.first['text'] as String?;
  }

  String _buildQueueAssistantFallback({
    required QueueModel queue,
    required TokenModel token,
    required int peopleAhead,
    required int estimatedWaitMinutes,
  }) {
    if (peopleAhead <= 0) {
      return 'Token ${token.tokenNumber} is due now at ${queue.name}. Please head back to the counter.';
    }

    return 'You have about $peopleAhead turns ahead of token ${token.tokenNumber}. The current estimate is roughly $estimatedWaitMinutes minutes.';
  }

  QueueInsightModel _fallbackInsights({
    required QueueModel queue,
    required int waitingCount,
    required int totalServedToday,
    required double averageServiceMinutes,
    required String peakHour,
    required int currentWaitMinutes,
  }) {
    final optimizationSuggestion =
        currentWaitMinutes > AppConstants.optimizationWaitThresholdMinutes
        ? 'The queue is trending past ${AppConstants.optimizationWaitThresholdMinutes} minutes. Consider opening another service point or temporarily reducing service time.'
        : 'The queue is within the preferred wait window. Keep the current pace and monitor demand.';

    final headline = waitingCount >= 8
        ? 'Queue pressure is elevated.'
        : waitingCount >= 4
        ? 'Queue flow is steady.'
        : 'Queue load is light.';

    return QueueInsightModel(
      totalServedToday: totalServedToday,
      averageServiceMinutes: averageServiceMinutes,
      peakHour: peakHour,
      headline: headline,
      suggestion:
          'Peak activity is around $peakHour. Serving pace is averaging ${averageServiceMinutes.toStringAsFixed(1)} minutes per customer.',
      optimizationSuggestion: optimizationSuggestion,
    );
  }
}
