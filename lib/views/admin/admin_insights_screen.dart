import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../viewmodels/admin_queue_viewmodel.dart';
import '../../widgets/app_error_view.dart';
import '../../widgets/loading_indicator.dart';
import '../ai_insights/insights_panel_widget.dart';

class AdminInsightsScreen extends ConsumerWidget {
  const AdminInsightsScreen({super.key, required this.queueId});

  final String queueId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = adminQueueViewModelProvider(queueId);
    final state = ref.watch(provider);

    return Scaffold(
      appBar: AppBar(title: const Text('AI Insights')),
      body: SafeArea(
        child: state.when(
          data: (data) => ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.queue.name,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 8),
                      Text('Queue ID: ${data.queue.queueId}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              InsightsPanelWidget(insights: data.insights),
              const SizedBox(height: 16),
              FilledButton.tonalIcon(
                onPressed: () => context.push(
                  AppRoutes.adminAnalyticsLocation(queueId: queueId),
                ),
                icon: const Icon(Icons.analytics_rounded),
                label: const Text('Open Analytics & History'),
              ),
            ],
          ),
          error: (error, _) => AppErrorView(
            error: error,
            onRetry: () => ref.invalidate(provider),
          ),
          loading: () => const LoadingIndicator(label: 'Loading AI insights'),
        ),
      ),
    );
  }
}
