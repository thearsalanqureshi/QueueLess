import '../core/services/hive_service.dart';
import '../models/queue_history_entry.dart';

class TokenHistoryStorage {
  TokenHistoryStorage(this._hiveService);

  final HiveService _hiveService;

  Future<void> saveEntry(QueueHistoryEntry entry) {
    return _hiveService.queueHistoryBox.put(entry.id, entry);
  }

  List<QueueHistoryEntry> getEntries() {
    return _hiveService.queueHistoryBox.values.toList(growable: false);
  }
}
