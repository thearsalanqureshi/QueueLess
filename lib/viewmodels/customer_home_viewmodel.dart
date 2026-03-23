import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_constants.dart';
import '../models/active_queue_session.dart';
import '../models/queue_history_entry.dart';
import '../providers/app_providers.dart';

class CustomerHomeState {
  const CustomerHomeState({
    required this.recentHistory,
    required this.activeSession,
    this.startupWarning,
  });

  final List<QueueHistoryEntry> recentHistory;
  final ActiveQueueSession? activeSession;
  final String? startupWarning;
}

final customerHomeViewModelProvider =
    AsyncNotifierProvider<CustomerHomeViewModel, CustomerHomeState>(
      CustomerHomeViewModel.new,
    );

class CustomerHomeViewModel extends AsyncNotifier<CustomerHomeState> {
  @override
  Future<CustomerHomeState> build() async {
    return _load();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = AsyncData(await _load());
  }

  Future<CustomerHomeState> _load() async {
    final historyRepository = ref.read(historyRepositoryProvider);

    return CustomerHomeState(
      recentHistory: historyRepository.getEntries(
        role: QueueHistoryEntry.customerRole,
        limit: AppConstants.maxRecentHistoryItems,
      ),
      activeSession: await ref
          .read(sessionRepositoryProvider)
          .findLatestActiveCustomerSession(),
      startupWarning: ref.read(startupWarningProvider),
    );
  }
}
