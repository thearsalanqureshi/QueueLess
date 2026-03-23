import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/time_utils.dart';
import '../../models/queue_history_entry.dart';
import '../../viewmodels/customer_home_viewmodel.dart';
import '../../widgets/app_error_view.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/primary_button.dart';

class CustomerHomeScreen extends ConsumerWidget {
  const CustomerHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(customerHomeViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Home'),
        actions: [
          IconButton(
            onPressed: () => context.push(AppRoutes.customerHistory),
            icon: const Icon(Icons.history_rounded),
            tooltip: 'Queue History',
          ),
        ],
      ),
      body: SafeArea(
        child: state.when(
          data: (data) => RefreshIndicator(
            onRefresh: () =>
                ref.read(customerHomeViewModelProvider.notifier).refresh(),
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
                          'Track queues without waiting in line',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Join with a queue ID or QR code, track your live token, and use QueueLess AI to understand your wait time.',
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
                if (data.activeSession != null) ...[
                  const SizedBox(height: 20),
                  Card(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Resume Active Queue',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${data.activeSession!.queueName} - Token ${data.activeSession!.tokenNumber}',
                          ),
                          const SizedBox(height: 16),
                          PrimaryButton(
                            label: 'Open Queue Status',
                            icon: Icons.play_circle_outline_rounded,
                            onPressed: () => context.push(
                              AppRoutes.customerQueueStatusLocation(
                                queueId: data.activeSession!.queueId,
                                tokenId: data.activeSession!.tokenId,
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
                  title: 'Join Queue',
                  description:
                      'Enter a shared queue ID or scan a QR code to get your live token.',
                  icon: Icons.login_rounded,
                  button: PrimaryButton(
                    label: 'Join Queue',
                    icon: Icons.qr_code_scanner_rounded,
                    onPressed: () => context.push(AppRoutes.customerJoinQueue),
                  ),
                ),
                const SizedBox(height: 16),
                _ActionCard(
                  title: 'Queue History',
                  description:
                      'Review your recent queue sessions and reopen a live token when it is still active.',
                  icon: Icons.history_toggle_off_rounded,
                  button: PrimaryButton(
                    label: 'Open History',
                    icon: Icons.history_rounded,
                    onPressed: () => context.push(AppRoutes.customerHistory),
                  ),
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Text(
                      'Recent Queue History',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const Spacer(),
                    if (data.recentHistory.isNotEmpty)
                      TextButton(
                        onPressed: () =>
                            context.push(AppRoutes.customerHistory),
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
                        'Your customer queue history will appear here after you join a queue.',
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
                            subtitle: Text(
                              '${entry.statusLabel} - ${formatDateTime(entry.createdAt)}',
                            ),
                            trailing: Text(
                              'T${entry.tokenNumber ?? '-'}',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            onTap: () => _openHistoryEntry(context, entry),
                          ),
                        ),
                      ),
              ],
            ),
          ),
          error: (error, _) => AppErrorView(
            error: error,
            onRetry: () => ref.invalidate(customerHomeViewModelProvider),
          ),
          loading: () => const LoadingIndicator(label: 'Loading customer home'),
        ),
      ),
    );
  }

  void _openHistoryEntry(BuildContext context, QueueHistoryEntry entry) {
    context.push(
      AppRoutes.customerQueueStatusLocation(
        queueId: entry.queueId,
        tokenId: entry.id,
      ),
    );
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
