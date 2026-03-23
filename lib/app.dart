import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants/app_strings.dart';
import 'core/theme/app_theme.dart';
import 'providers/app_providers.dart';

class QueueLessApp extends ConsumerStatefulWidget {
  const QueueLessApp({super.key});

  @override
  ConsumerState<QueueLessApp> createState() => _QueueLessAppState();
}

class _QueueLessAppState extends ConsumerState<QueueLessApp> {
  @override
  void initState() {
    super.initState();
    Future.microtask(_initializeStartupServices);
  }

  @override
  void dispose() {
    ref.read(startupCoordinatorProvider).dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }

  Future<void> _initializeStartupServices() async {
    try {
      await ref.read(startupCoordinatorProvider).initialize();
    } catch (_) {}
  }
}
