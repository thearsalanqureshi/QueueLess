import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../views/admin/admin_analytics_screen.dart';
import '../../views/admin/admin_home_screen.dart';
import '../../views/admin/admin_insights_screen.dart';
import '../../views/admin_queue/admin_dashboard_screen.dart';
import '../../views/admin_queue/create_queue_screen.dart';
import '../../views/customer/customer_ai_assistant_screen.dart';
import '../../views/customer/customer_history_screen.dart';
import '../../views/customer/customer_home_screen.dart';
import '../../views/join_queue/join_queue_screen.dart';
import '../../views/onboarding/onboarding_screen.dart';
import '../../views/queue_status/queue_status_screen.dart';
import '../../views/role_selection/role_selection_screen.dart';
import '../../views/splash/splash_screen.dart';
import '../constants/app_constants.dart';
import '../constants/app_strings.dart';

GoRouter buildAppRouter(Ref ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.roleSelection,
        builder: (context, state) => const RoleSelectionScreen(),
      ),
      GoRoute(
        path: AppRoutes.customerHome,
        builder: (context, state) => const CustomerHomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.customerJoinQueue,
        builder: (context, state) => const JoinQueueScreen(),
      ),
      GoRoute(
        path: AppRoutes.customerQueueStatus,
        builder: (context, state) {
          final queueId = state.uri.queryParameters['queueId'];
          final tokenId = state.uri.queryParameters['tokenId'];

          if (queueId == null || tokenId == null) {
            return const _RouterErrorScreen(
              message: 'Queue session is missing. Please join again.',
            );
          }

          return QueueStatusScreen(queueId: queueId, tokenId: tokenId);
        },
      ),
      GoRoute(
        path: AppRoutes.customerAssistant,
        builder: (context, state) {
          final queueId = state.uri.queryParameters['queueId'];
          final tokenId = state.uri.queryParameters['tokenId'];

          if (queueId == null || tokenId == null) {
            return const _RouterErrorScreen(
              message: 'AI assistant is missing a queue session.',
            );
          }

          return CustomerAiAssistantScreen(queueId: queueId, tokenId: tokenId);
        },
      ),
      GoRoute(
        path: AppRoutes.customerHistory,
        builder: (context, state) => const CustomerHistoryScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminHome,
        builder: (context, state) => const AdminHomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminCreateQueue,
        builder: (context, state) => const CreateQueueScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminDashboard,
        builder: (context, state) {
          final queueId = state.uri.queryParameters['queueId'];
          if (queueId == null) {
            return const _RouterErrorScreen(
              message: 'Admin dashboard is missing a queue id.',
            );
          }

          return AdminDashboardScreen(queueId: queueId);
        },
      ),
      GoRoute(
        path: AppRoutes.adminInsights,
        builder: (context, state) {
          final queueId = state.uri.queryParameters['queueId'];
          if (queueId == null) {
            return const _RouterErrorScreen(
              message: 'AI insights are missing a queue id.',
            );
          }

          return AdminInsightsScreen(queueId: queueId);
        },
      ),
      GoRoute(
        path: AppRoutes.adminAnalytics,
        builder: (context, state) =>
            AdminAnalyticsScreen(queueId: state.uri.queryParameters['queueId']),
      ),
    ],
    errorBuilder: (context, state) => _RouterErrorScreen(
      message: state.error?.toString() ?? AppStrings.genericError,
    ),
  );
}

class _RouterErrorScreen extends StatelessWidget {
  const _RouterErrorScreen({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(message, textAlign: TextAlign.center),
        ),
      ),
    );
  }
}
