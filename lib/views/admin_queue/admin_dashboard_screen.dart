import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/helpers.dart';
import '../../viewmodels/admin_queue_viewmodel.dart';
import '../../widgets/app_error_view.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/queue_info_card.dart';
import '../ai_insights/optimization_alert_widget.dart';
import 'queue_qr_widget.dart';
import 'serve_next_button.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key, required this.queueId});

  final String queueId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = adminQueueViewModelProvider(queueId);
    final state = ref.watch(provider);

    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: SafeArea(
        child: state.when(
          data: (data) {
            return ListView(
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
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            Chip(
                              label: Text(
                                data.queue.isEnded
                                    ? 'Ended'
                                    : data.queue.isPaused
                                    ? 'Paused'
                                    : 'Active',
                              ),
                            ),
                            Chip(
                              label: Text(
                                '${data.waitingTokens.length} waiting',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                QueueQrWidget(queueId: data.queue.queueId),
                const SizedBox(height: 16),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth > 720;
                    final cards = [
                      QueueInfoCard(
                        label: 'Current Token',
                        value: data.queue.currentToken.toString(),
                        icon: Icons.sync_alt_rounded,
                      ),
                      QueueInfoCard(
                        label: 'Waiting Customers',
                        value: data.waitingTokens.length.toString(),
                        icon: Icons.groups_rounded,
                      ),
                      QueueInfoCard(
                        label: 'Avg Service',
                        value: '${data.queue.avgServiceTime} min',
                        icon: Icons.timer_outlined,
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
                        for (var index = 0; index < cards.length; index++) ...[
                          Expanded(child: cards[index]),
                          if (index < cards.length - 1)
                            const SizedBox(width: 12),
                        ],
                      ],
                    );
                  },
                ),
                const SizedBox(height: 18),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        ServeNextButton(
                          isLoading: data.isMutating,
                          onPressed: data.queue.isEnded
                              ? null
                              : () => _runAdminAction(
                                  context,
                                  ref,
                                  () => ref.read(provider.notifier).serveNext(),
                                ),
                        ),
                        OutlinedButton.icon(
                          onPressed: data.queue.isEnded
                              ? null
                              : () => _runAdminAction(
                                  context,
                                  ref,
                                  () =>
                                      ref.read(provider.notifier).togglePause(),
                                ),
                          icon: Icon(
                            data.queue.isPaused
                                ? Icons.play_arrow_rounded
                                : Icons.pause_rounded,
                          ),
                          label: Text(
                            data.queue.isPaused
                                ? 'Resume Queue'
                                : 'Pause Queue',
                          ),
                        ),
                        FilledButton.tonalIcon(
                          onPressed: data.queue.isEnded
                              ? null
                              : () => _confirmEndQueue(context, ref),
                          icon: const Icon(Icons.stop_circle_outlined),
                          label: const Text('End Queue'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                OptimizationAlertWidget(
                  message: data.insights.optimizationSuggestion,
                ),
                const SizedBox(height: 16),
                FilledButton.tonalIcon(
                  onPressed: () => context.push(
                    AppRoutes.adminInsightsLocation(queueId: queueId),
                  ),
                  icon: const Icon(Icons.auto_graph_rounded),
                  label: const Text('Open AI Insights'),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => context.push(
                    AppRoutes.adminAnalyticsLocation(queueId: queueId),
                  ),
                  icon: const Icon(Icons.analytics_rounded),
                  label: const Text('Open Analytics & History'),
                ),
              ],
            );
          },
          error: (error, _) => AppErrorView(
            error: error,
            onRetry: () => ref.invalidate(provider),
          ),
          loading: () =>
              const LoadingIndicator(label: 'Loading admin dashboard'),
        ),
      ),
    );
  }

  Future<void> _confirmEndQueue(BuildContext context, WidgetRef ref) async {
    final shouldEnd =
        await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('End this queue?'),
              content: const Text(
                'Customers will stop receiving live updates and the queue will be marked as ended.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('End Queue'),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!shouldEnd) {
      return;
    }

    try {
      await ref.read(adminQueueViewModelProvider(queueId).notifier).endQueue();
    } catch (error) {
      if (context.mounted) {
        showAppSnackBar(context, friendlyError(error), isError: true);
      }
    }
  }

  Future<void> _runAdminAction(
    BuildContext context,
    WidgetRef ref,
    Future<void> Function() action,
  ) async {
    try {
      await action();
    } catch (error) {
      if (context.mounted) {
        showAppSnackBar(context, friendlyError(error), isError: true);
      }
    }
  }
}
