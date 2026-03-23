import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/queue_model.dart';
import '../models/token_model.dart';
import '../providers/app_providers.dart';

final joinQueueViewModelProvider =
    AsyncNotifierProvider<JoinQueueViewModel, void>(JoinQueueViewModel.new);

class JoinQueueViewModel extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<TokenModel> joinQueue(String rawQueueId) async {
    final normalizedQueueId = rawQueueId.trim().toUpperCase();
    state = const AsyncLoading();

    try {
      final userId = await ref
          .read(userIdentityServiceProvider)
          .getOrCreateUserId();
      final token = await ref
          .read(tokenRepositoryProvider)
          .joinQueue(queueId: normalizedQueueId, userId: userId);
      await _persistJoinArtifacts(normalizedQueueId, token);

      state = const AsyncData(null);
      return token;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  Future<void> _persistJoinArtifacts(String queueId, TokenModel token) async {
    QueueModel? queue;

    try {
      queue = await ref.read(queueRepositoryProvider).fetchQueue(queueId);
    } catch (_) {
      return;
    }

    if (queue == null) {
      return;
    }

    try {
      await ref
          .read(historyRepositoryProvider)
          .saveJoinedQueue(queue: queue, token: token);
    } catch (_) {}

    try {
      await ref
          .read(userProfileRepositoryProvider)
          .setActiveCustomerSession(queueId: queue.queueId, tokenId: token.tokenId);
    } catch (_) {}
  }
}
