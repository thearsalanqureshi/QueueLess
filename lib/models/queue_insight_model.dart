class QueueInsightModel {
  const QueueInsightModel({
    required this.totalServedToday,
    required this.averageServiceMinutes,
    required this.peakHour,
    required this.headline,
    required this.suggestion,
    required this.optimizationSuggestion,
  });

  final int totalServedToday;
  final double averageServiceMinutes;
  final String peakHour;
  final String headline;
  final String suggestion;
  final String optimizationSuggestion;
}
