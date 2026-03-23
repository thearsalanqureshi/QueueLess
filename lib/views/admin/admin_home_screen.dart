import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/time_utils.dart';
import '../../models/queue_history_entry.dart';
import '../../viewmodels/admin_home_viewmodel.dart';
import '../../widgets/app_error_view.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/primary_button.dart';

class AdminHomeScreen extends ConsumerWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(adminHomeViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Home'),
        actions: [
          IconButton(
            onPressed: () => context.push(AppRoutes.adminAnalytics),
            icon: const Icon(Icons.analytics_outlined),
            tooltip: 'Analytics & History',
          ),
        ],
      ),
      body: SafeArea(
        child: state.when(
          data: (data) => RefreshIndicator(
            onRefresh: () =>
                ref.read(adminHomeViewModelProvider.notifier).refresh(),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Manage live service queues',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Create queues, serve customers, monitor demand, and use QueueLess AI to optimize service flow.',
                        ),
                        if (data.startupWarning != null) ...[
                          const SizedBox(height: 18),
                          Text(
                            data.startupWarning!,
                            style: TextStyle(color: Colors.amber.shade900),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                if (data.lastManagedQueue != null) ...[
                  const SizedBox(height: 20),
                  Card(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Resume Admin Dashboard',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${data.lastManagedQueue!.name} - Queue ID ${data.lastManagedQueue!.queueId}',
                          ),
                          const SizedBox(height: 16),
                          PrimaryButton(
                            label: 'Open Dashboard',
                            icon: Icons.dashboard_customize_rounded,
                            onPressed: () => context.push(
                              AppRoutes.adminDashboardLocation(
                                queueId: data.lastManagedQueue!.queueId,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                _ActionCard(
                  title: 'Create Queue',
                  description:
                      'Start a new digital queue and share the generated QR code with customers.',
                  icon: Icons.add_business_rounded,
                  button: PrimaryButton(
                    label: 'Create Queue',
                    icon: Icons.add_circle_outline_rounded,
                    onPressed: () => context.push(AppRoutes.adminCreateQueue),
                  ),
                ),
                const SizedBox(height: 16),
                _ActionCard(
                  title: 'Analytics & History',
                  description:
                      'Review AI insights, recent queues, and live performance summaries.',
                  icon: Icons.analytics_rounded,
                  button: PrimaryButton(
                    label: 'Open Analytics',
                    icon: Icons.insights_rounded,
                    onPressed: () => context.push(AppRoutes.adminAnalytics),
                  ),
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Text(
                      'Recent Admin Queues',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const Spacer(),
                    if (data.recentHistory.isNotEmpty)
                      TextButton(
                        onPressed: () => context.push(AppRoutes.adminAnalytics),
                        child: const Text('View all'),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                if (data.recentHistory.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        'Your created queues will appear here once you start managing service flow.',
                      ),
                    ),
                  )
                else
                  ...data.recentHistory
                      .take(4)
                      .map(
                        (entry) => Card(
                          child: ListTile(
                            title: Text(entry.queueName),
                            subtitle: Text(formatDateTime(entry.createdAt)),
                            trailing: const Icon(Icons.chevron_right_rounded),
                            onTap: () => _openHistoryEntry(context, entry),
                          ),
                        ),
                      ),
              ],
            ),
          ),
          error: (error, _) => AppErrorView(
            error: error,
            onRetry: () => ref.invalidate(adminHomeViewModelProvider),
          ),
          loading: () => const LoadingIndicator(label: 'Loading admin home'),
        ),
      ),
    );
  }

  void _openHistoryEntry(BuildContext context, QueueHistoryEntry entry) {
    context.push(AppRoutes.adminDashboardLocation(queueId: entry.queueId));
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.button,
  });

  final String title;
  final String description;
  final IconData icon;
  final Widget button;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 30),
            const SizedBox(height: 16),
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(description),
            const SizedBox(height: 20),
            button,
          ],
        ),
      ),
    );
  }
}
