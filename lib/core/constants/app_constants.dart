class AppConstants {
  static const int onboardingPages = 3;
  static const int nearTurnThreshold = 2;
  static const int optimizationWaitThresholdMinutes = 45;
  static const int maxRecentHistoryItems = 12;
  static const String geminiModel = String.fromEnvironment(
    'GEMINI_MODEL',
    defaultValue: 'gemini-1.5-flash',
  );

  const AppConstants._();
}

class AppRoutes {
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String roleSelection = '/role-selection';
  static const String customerHome = '/customer/home';
  static const String customerJoinQueue = '/customer/join-queue';
  static const String customerQueueStatus = '/customer/queue-status';
  static const String customerAssistant = '/customer/assistant';
  static const String customerHistory = '/customer/history';
  static const String adminHome = '/admin/home';
  static const String adminCreateQueue = '/admin/create-queue';
  static const String adminDashboard = '/admin/dashboard';
  static const String adminInsights = '/admin/insights';
  static const String adminAnalytics = '/admin/analytics';

  static String customerQueueStatusLocation({
    required String queueId,
    required String tokenId,
  }) {
    return '$customerQueueStatus?queueId=$queueId&tokenId=$tokenId';
  }

  static String customerAssistantLocation({
    required String queueId,
    required String tokenId,
  }) {
    return '$customerAssistant?queueId=$queueId&tokenId=$tokenId';
  }

  static String adminDashboardLocation({required String queueId}) {
    return '$adminDashboard?queueId=$queueId';
  }

  static String adminInsightsLocation({required String queueId}) {
    return '$adminInsights?queueId=$queueId';
  }

  static String adminAnalyticsLocation({String? queueId}) {
    if (queueId == null || queueId.isEmpty) {
      return adminAnalytics;
    }
    return '$adminAnalytics?queueId=$queueId';
  }

  const AppRoutes._();
}
