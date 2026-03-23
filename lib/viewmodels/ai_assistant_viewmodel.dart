import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/ai_message_model.dart';
import '../models/queue_model.dart';
import '../models/token_model.dart';
import '../providers/app_providers.dart';

class QueueAssistantContext {
  const QueueAssistantContext({
    required this.queue,
    required this.token,
    required this.peopleAhead,
    required this.estimatedWaitMinutes,
  });

  final QueueModel queue;
  final TokenModel token;
  final int peopleAhead;
  final int estimatedWaitMinutes;

  @override
  bool operator ==(Object other) {
    return other is QueueAssistantContext &&
        other.queue.queueId == queue.queueId &&
        other.token.tokenId == token.tokenId &&
        other.peopleAhead == peopleAhead &&
        other.estimatedWaitMinutes == estimatedWaitMinutes;
  }

  @override
  int get hashCode => Object.hash(
    queue.queueId,
    token.tokenId,
    peopleAhead,
    estimatedWaitMinutes,
  );
}

class AiAssistantState {
  const AiAssistantState({
    required this.messages,
    required this.isSending,
    this.errorMessage,
  });

  final List<AiMessageModel> messages;
  final bool isSending;
  final String? errorMessage;

  AiAssistantState copyWith({
    List<AiMessageModel>? messages,
    bool? isSending,
    String? errorMessage,
  }) {
    return AiAssistantState(
      messages: messages ?? this.messages,
      isSending: isSending ?? this.isSending,
      errorMessage: errorMessage,
    );
  }
}

final aiAssistantViewModelProvider = NotifierProvider.autoDispose
    .family<AiAssistantViewModel, AiAssistantState, QueueAssistantContext>(
      AiAssistantViewModel.new,
    );

class AiAssistantViewModel
    extends AutoDisposeFamilyNotifier<AiAssistantState, QueueAssistantContext> {
  @override
  AiAssistantState build(QueueAssistantContext arg) {
    return AiAssistantState(
      messages: [
        AiMessageModel(
          role: AiMessageRole.assistant,
          text: arg.peopleAhead <= 0
              ? 'You are up next for ${arg.queue.name}.'
              : 'You currently have ${arg.peopleAhead} turns ahead. Ask anything about your wait.',
          createdAt: DateTime.now(),
        ),
      ],
      isSending: false,
    );
  }

  Future<void> sendMessage(String question) async {
    final trimmed = question.trim();
    if (trimmed.isEmpty) {
      return;
    }

    final currentState = state;
    final userMessage = AiMessageModel(
      role: AiMessageRole.user,
      text: trimmed,
      createdAt: DateTime.now(),
    );

    final pendingMessages = [...currentState.messages, userMessage];
    state = currentState.copyWith(
      messages: pendingMessages,
      isSending: true,
      errorMessage: null,
    );

    try {
      final reply = await ref
          .read(aiServiceProvider)
          .askQueueAssistant(
            queue: arg.queue,
            token: arg.token,
            question: trimmed,
            peopleAhead: arg.peopleAhead,
            estimatedWaitMinutes: arg.estimatedWaitMinutes,
          );

      state = state.copyWith(
        messages: [
          ...pendingMessages,
          AiMessageModel(
            role: AiMessageRole.assistant,
            text: reply,
            createdAt: DateTime.now(),
          ),
        ],
        isSending: false,
      );
    } catch (error) {
      state = state.copyWith(
        messages: [
          ...pendingMessages,
          AiMessageModel(
            role: AiMessageRole.assistant,
            text: 'I could not refresh the assistant response right now.',
            createdAt: DateTime.now(),
          ),
        ],
        isSending: false,
        errorMessage: error.toString(),
      );
    }
  }
}
