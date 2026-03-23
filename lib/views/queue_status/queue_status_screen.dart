import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/helpers.dart';
import '../../core/utils/time_utils.dart';
import '../../models/queue_status_model.dart';
import '../../viewmodels/queue_viewmodel.dart';
import '../../widgets/app_error_view.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/queue_info_card.dart';
import '../../widgets/token_card.dart';
import 'queue_progress_widget.dart';

class QueueStatusScreen extends ConsumerWidget {
  const QueueStatusScreen({
    super.key,
    required this.queueId,
    required this.tokenId,
  });

  final String queueId;
  final String tokenId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = queueViewModelProvider(
      QueueSessionArgs(queueId: queueId, tokenId: tokenId),
    );
    final state = ref.watch(provider);

    return Scaffold(
      appBar: AppBar(title: const Text('Queue Status')),
      body: SafeArea(
        child: state.when(
          data: (data) {
            final progress = data.token.tokenNumber <= 0
                ? 0.0
                : data.queue.currentToken / data.token.tokenNumber;
            final isTerminal =
                data.isCancelled || data.isCompleted || data.isQueueEnded;
            final canLeaveQueue =
                !data.isCancelled && !data.isCompleted && !data.isQueueEnded;

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              children: [
                if (data.isQueuePaused || isTerminal)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Text(_statusText(data)),
                    ),
                  ),
                TokenCard(
                  queueName: data.queue.name,
                  tokenNumber: data.token.tokenNumber,
                  caption:
                      'Estimated wait: ${formatWaitMinutes(data.estimatedWaitMinutes)}',
                ),
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
                        label: 'People Ahead',
                        value: data.peopleAhead.toString(),
                        icon: Icons.groups_rounded,
                      ),
                      QueueInfoCard(
                        label: 'Wait Time',
                        value: formatWaitMinutes(data.estimatedWaitMinutes),
                        icon: Icons.schedule_rounded,
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
                const SizedBox(height: 16),
                QueueProgressWidget(progress: progress),
                const SizedBox(height: 16),
                PrimaryButton(
                  label: 'Open AI Assistant',
                  icon: Icons.auto_awesome_rounded,
                  onPressed: () => context.push(
                    AppRoutes.customerAssistantLocation(
                      queueId: queueId,
                      tokenId: tokenId,
                    ),
                  ),
                ),
                if (canLeaveQueue) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _confirmLeave(context, ref),
                      icon: const Icon(Icons.logout_rounded),
                      label: const Text('Leave Queue'),
                    ),
                  ),
                ],
                if (isTerminal) ...[
                  const SizedBox(height: 12),
                  PrimaryButton(
                    label: 'View Queue History',
                    icon: Icons.history_rounded,
                    onPressed: () => context.go(AppRoutes.customerHistory),
                  ),
                ],
                if (isTerminal) ...[
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => context.go(AppRoutes.customerHome),
                    child: const Text('Back to Customer Home'),
                  ),
                ],
              ],
            );
          },
          error: (error, _) => AppErrorView(
            error: error,
            onRetry: () => ref.invalidate(provider),
          ),
          loading: () => const LoadingIndicator(label: 'Loading queue status'),
        ),
      ),
    );
  }

  String _statusText(QueueStatusModel data) {
    if (data.isCancelled) {
      return 'This token is no longer active because you already left the queue.';
    }
    if (data.isCompleted) {
      return 'Your token has been served. You can review this session from your queue history.';
    }
    if (data.isQueueEnded) {
      return 'This queue has ended. Live updates have stopped for this session.';
    }
    if (data.isQueuePaused) {
      return 'The admin has paused this queue temporarily.';
    }
    return '';
  }

  Future<void> _confirmLeave(BuildContext context, WidgetRef ref) async {
    final shouldLeave =
        await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Leave this queue?'),
              content: const Text(
                'Your token will be marked as cancelled in Firestore.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Stay'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Leave'),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!shouldLeave) {
      return;
    }

    try {
      await ref
          .read(
            queueViewModelProvider(
              QueueSessionArgs(queueId: queueId, tokenId: tokenId),
            ).notifier,
          )
          .leaveQueue();
      if (context.mounted) {
        context.go(AppRoutes.customerHistory);
      }
    } catch (error) {
      if (context.mounted) {
        showAppSnackBar(context, friendlyError(error), isError: true);
      }
    }
  }
}
