import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_constants.dart';
import '../models/queue_history_entry.dart';
import '../models/queue_model.dart';
import '../providers/app_providers.dart';

class AdminHomeState {
  const AdminHomeState({
    required this.recentHistory,
    required this.lastManagedQueue,
    this.startupWarning,
  });

  final List<QueueHistoryEntry> recentHistory;
  final QueueModel? lastManagedQueue;
  final String? startupWarning;
}

final adminHomeViewModelProvider =
    AsyncNotifierProvider<AdminHomeViewModel, AdminHomeState>(
      AdminHomeViewModel.new,
    );

class AdminHomeViewModel extends AsyncNotifier<AdminHomeState> {
  @override
  Future<AdminHomeState> build() async {
    return _load();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = AsyncData(await _load());
  }

  Future<AdminHomeState> _load() async {
    final historyRepository = ref.read(historyRepositoryProvider);
    final profile = await ref
        .read(userProfileRepositoryProvider)
        .fetchCurrentProfile();

    QueueModel? lastManagedQueue;
    final lastAdminQueueId = profile?.lastAdminQueueId;
    if (lastAdminQueueId != null && lastAdminQueueId.isNotEmpty) {
      lastManagedQueue = await ref
          .read(queueRepositoryProvider)
          .fetchQueue(lastAdminQueueId);
    }

    return AdminHomeState(
      recentHistory: historyRepository.getEntries(
        role: QueueHistoryEntry.adminRole,
        limit: AppConstants.maxRecentHistoryItems,
      ),
      lastManagedQueue: lastManagedQueue,
      startupWarning: ref.read(startupWarningProvider),
    );
  }
}
