import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/queue_history_entry.dart';
import '../providers/app_providers.dart';

final customerHistoryViewModelProvider =
    AsyncNotifierProvider<CustomerHistoryViewModel, List<QueueHistoryEntry>>(
      CustomerHistoryViewModel.new,
    );

class CustomerHistoryViewModel extends AsyncNotifier<List<QueueHistoryEntry>> {
  @override
  Future<List<QueueHistoryEntry>> build() async {
    return _load();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = AsyncData(await _load());
  }

  Future<List<QueueHistoryEntry>> _load() async {
    return ref
        .read(historyRepositoryProvider)
        .getEntries(role: QueueHistoryEntry.customerRole);
  }
}
