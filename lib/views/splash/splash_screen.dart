import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_strings.dart';
import '../../viewmodels/splash_viewmodel.dart';
import '../../widgets/loading_indicator.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(splashRouteProvider, (_, next) {
      next.whenData((route) {
        if (context.mounted) {
          context.go(route);
        }
      });
    });

    return const Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _SplashBadge(),
                SizedBox(height: 20),
                Text(
                  AppStrings.appName,
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 12),
                Text(
                  'Digital queues with live updates and AI guidance.',
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24),
                LoadingIndicator(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SplashBadge extends StatelessWidget {
  const _SplashBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: Theme.of(context).colorScheme.primaryContainer,
      ),
      child: Icon(
        Icons.queue_rounded,
        size: 42,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
