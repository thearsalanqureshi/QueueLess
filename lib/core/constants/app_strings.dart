class AppStrings {
  static const String appName = 'QueueLess';
  static const String genericError = 'Something went wrong. Please try again.';
  static const String firebaseUnavailable =
      'Firebase is not configured yet. Live queue features are unavailable.';
  static const String authUnavailable =
      'Anonymous sign-in is not available yet. Queue ownership and live queue actions are unavailable.';
  static const String queueNotFound = 'Queue not found. Check the Queue ID.';
  static const String queueEnded = 'This queue has already ended.';
  static const String queuePaused = 'This queue is currently paused.';

  const AppStrings._();
}
