import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../viewmodels/ai_assistant_viewmodel.dart';
import '../../viewmodels/queue_viewmodel.dart';
import '../../widgets/app_error_view.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/primary_button.dart';

class CustomerAiAssistantScreen extends ConsumerStatefulWidget {
  const CustomerAiAssistantScreen({
    super.key,
    required this.queueId,
    required this.tokenId,
  });

  final String queueId;
  final String tokenId;

  @override
  ConsumerState<CustomerAiAssistantScreen> createState() =>
      _CustomerAiAssistantScreenState();
}

class _CustomerAiAssistantScreenState
    extends ConsumerState<CustomerAiAssistantScreen> {
  final TextEditingController _messageController = TextEditingController();

  static const _quickQuestions = [
    'How long will I wait?',
    'When should I come back?',
  ];

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final queueState = ref.watch(
      queueViewModelProvider(
        QueueSessionArgs(queueId: widget.queueId, tokenId: widget.tokenId),
      ),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('AI Queue Assistant')),
      body: SafeArea(
        child: queueState.when(
          data: (queueStatus) {
            final assistantContext = QueueAssistantContext(
              queue: queueStatus.queue,
              token: queueStatus.token,
              peopleAhead: queueStatus.peopleAhead,
              estimatedWaitMinutes: queueStatus.estimatedWaitMinutes,
            );
            final assistantProvider = aiAssistantViewModelProvider(
              assistantContext,
            );
            final assistantState = ref.watch(assistantProvider);

            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ask about ${queueStatus.queue.name}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Token ${queueStatus.token.tokenNumber} with ${queueStatus.peopleAhead} turns ahead.',
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.separated(
                      itemCount: assistantState.messages.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final message = assistantState.messages[index];
                        final isUser = message.role.name == 'user';
                        return Align(
                          alignment: isUser
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            constraints: const BoxConstraints(maxWidth: 360),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              color: isUser
                                  ? Theme.of(
                                      context,
                                    ).colorScheme.primaryContainer
                                  : Theme.of(
                                      context,
                                    ).colorScheme.surfaceContainerHigh,
                            ),
                            child: Text(message.text),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _quickQuestions
                        .map(
                          (question) => ActionChip(
                            label: Text(question),
                            onPressed: () => _send(question, assistantContext),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _messageController,
                    minLines: 1,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Ask about your queue',
                      hintText: 'Type a question for the assistant',
                    ),
                  ),
                  const SizedBox(height: 12),
                  PrimaryButton(
                    label: 'Send',
                    icon: Icons.send_rounded,
                    isLoading: assistantState.isSending,
                    onPressed: () =>
                        _send(_messageController.text, assistantContext),
                  ),
                ],
              ),
            );
          },
          error: (error, _) => AppErrorView(error: error),
          loading: () => const LoadingIndicator(label: 'Loading AI assistant'),
        ),
      ),
    );
  }

  Future<void> _send(
    String question,
    QueueAssistantContext assistantContext,
  ) async {
    final trimmed = question.trim();
    if (trimmed.isEmpty) {
      return;
    }

    _messageController.clear();
    await ref
        .read(aiAssistantViewModelProvider(assistantContext).notifier)
        .sendMessage(trimmed);
  }
}
