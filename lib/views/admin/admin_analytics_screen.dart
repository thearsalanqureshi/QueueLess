import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/time_utils.dart';
import '../../viewmodels/admin_analytics_viewmodel.dart';
import '../../widgets/app_error_view.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/queue_info_card.dart';

class AdminAnalyticsScreen extends ConsumerWidget {
  const AdminAnalyticsScreen({super.key, this.queueId});

  final String? queueId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = adminAnalyticsViewModelProvider(queueId);
    final state = ref.watch(provider);

    return Scaffold(
      appBar: AppBar(title: const Text('Analytics & History')),
      body: SafeArea(
        child: state.when(
          data: (data) => RefreshIndicator(
            onRefresh: () => ref.read(provider.notifier).refresh(),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              children: [
                if (data.queue != null && data.insights != null) ...[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data.queue!.name,
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 8),
                          Text('Queue ID: ${data.queue!.queueId}'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth > 720;
                      final cards = [
                        QueueInfoCard(
                          label: 'Waiting Customers',
                          value: data.waitingTokens.length.toString(),
                          icon: Icons.groups_rounded,
                        ),
                        QueueInfoCard(
                          label: 'Peak Hour',
                          value: data.insights!.peakHour,
                          icon: Icons.query_stats_rounded,
                        ),
                        QueueInfoCard(
                          label: 'Served Today',
                          value: data.insights!.totalServedToday.toString(),
                          icon: Icons.task_alt_rounded,
                        ),
                      ];

                      if (!isWide) {
                        return Column(
                          children: [
                            for (final card in cards) ...[
                              card,
                              const SizedBox(height: 12),
                            ],
                          ],
                        );
                      }

                      return Row(
                        children: [
                          for (
                            var index = 0;
                            index < cards.length;
                            index++
                          ) ...[
                            Expanded(child: cards[index]),
                            if (index < cards.length - 1)
                              const SizedBox(width: 12),
                          ],
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Analytics Snapshot',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 12),
                          Text(data.insights!.headline),
                          const SizedBox(height: 12),
                          Text(data.insights!.suggestion),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                Text(
                  'Recent Admin Queue History',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                if (data.recentHistory.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        'Your admin history will appear here after you create queues.',
                      ),
                    ),
                  )
                else
                  ...data.recentHistory.map(
                    (entry) => Card(
                      child: ListTile(
                        title: Text(entry.queueName),
                        subtitle: Text(formatDateTime(entry.createdAt)),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () => context.push(
                          AppRoutes.adminDashboardLocation(
                            queueId: entry.queueId,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          error: (error, _) => AppErrorView(
            error: error,
            onRetry: () => ref.invalidate(provider),
          ),
          loading: () =>
              const LoadingIndicator(label: 'Loading analytics and history'),
        ),
      ),
    );
  }
}
