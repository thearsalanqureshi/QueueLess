import '../models/queue_history_entry.dart';
import '../models/queue_model.dart';
import '../models/token_model.dart';
import '../storage/token_history_storage.dart';

class HistoryRepository {
  HistoryRepository(this._storage);

  final TokenHistoryStorage _storage;

  Future<void> saveJoinedQueue({
    required QueueModel queue,
    required TokenModel token,
  }) {
    return _storage.saveEntry(
      QueueHistoryEntry(
        id: token.tokenId,
        queueId: queue.queueId,
        queueName: queue.name,
        tokenNumber: token.tokenNumber,
        createdAt: token.createdAt,
        role: QueueHistoryEntry.customerRole,
        statusLabel: 'Joined queue',
      ),
    );
  }

  Future<void> saveCreatedQueue({required QueueModel queue}) {
    return _storage.saveEntry(
      QueueHistoryEntry(
        id: 'queue_${queue.queueId}',
        queueId: queue.queueId,
        queueName: queue.name,
        createdAt: queue.createdAt,
        role: QueueHistoryEntry.adminRole,
        statusLabel: 'Created queue',
      ),
    );
  }

  List<QueueHistoryEntry> getRecentHistory({int limit = 12}) {
    return getEntries(limit: limit);
  }

  List<QueueHistoryEntry> getEntries({String? role, int? limit}) {
    final entries =
        _storage
            .getEntries()
            .where((entry) => role == null || entry.role == role)
            .toList()
          ..sort((left, right) => right.createdAt.compareTo(left.createdAt));

    if (limit == null || entries.length <= limit) {
      return entries;
    }

    return entries.take(limit).toList(growable: false);
  }
}
