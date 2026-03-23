import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/time_utils.dart';
import '../../viewmodels/customer_history_viewmodel.dart';
import '../../widgets/app_error_view.dart';
import '../../widgets/loading_indicator.dart';

class CustomerHistoryScreen extends ConsumerWidget {
  const CustomerHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(customerHistoryViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Queue History')),
      body: SafeArea(
        child: state.when(
          data: (entries) {
            if (entries.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'Join a queue to start building your customer history.',
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () =>
                  ref.read(customerHistoryViewModelProvider.notifier).refresh(),
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                itemBuilder: (context, index) {
                  final entry = entries[index];
                  return Card(
                    child: ListTile(
                      title: Text(entry.queueName),
                      subtitle: Text(
                        '${entry.statusLabel}\n${formatDateTime(entry.createdAt)}',
                      ),
                      isThreeLine: true,
                      trailing: Text(
                        'T${entry.tokenNumber ?? '-'}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      onTap: () => context.push(
                        AppRoutes.customerQueueStatusLocation(
                          queueId: entry.queueId,
                          tokenId: entry.id,
                        ),
                      ),
                    ),
                  );
                },
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemCount: entries.length,
              ),
            );
          },
          error: (error, _) => AppErrorView(
            error: error,
            onRetry: () => ref.invalidate(customerHistoryViewModelProvider),
          ),
          loading: () => const LoadingIndicator(label: 'Loading queue history'),
        ),
      ),
    );
  }
}
