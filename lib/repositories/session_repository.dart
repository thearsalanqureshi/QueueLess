import '../models/active_queue_session.dart';
import '../models/queue_history_entry.dart';
import '../models/queue_model.dart';
import '../models/token_model.dart';
import 'history_repository.dart';
import 'queue_repository.dart';
import 'token_repository.dart';
import 'user_profile_repository.dart';

class SessionRepository {
  SessionRepository(
    this._historyRepository,
    this._queueRepository,
    this._tokenRepository,
    this._userProfileRepository,
  );

  final HistoryRepository _historyRepository;
  final QueueRepository _queueRepository;
  final TokenRepository _tokenRepository;
  final UserProfileRepository _userProfileRepository;

  Future<ActiveQueueSession?> findLatestActiveCustomerSession() async {
    final profile = await _userProfileRepository.fetchCurrentProfile();
    if (profile != null && profile.hasActiveCustomerSession) {
      final activeSession = await _resolveCustomerSessionByIds(
        queueId: profile.activeCustomerQueueId!,
        tokenId: profile.activeCustomerTokenId!,
      );
      if (activeSession != null) {
        return activeSession;
      }
    }

    final customerEntries = _historyRepository.getEntries(
      role: QueueHistoryEntry.customerRole,
    );

    for (final entry in customerEntries) {
      final session = await resolveCustomerSession(entry);
      if (session != null) {
        return session;
      }
    }

    return null;
  }

  Future<ActiveQueueSession?> _resolveCustomerSessionByIds({
    required String queueId,
    required String tokenId,
  }) async {
    final queue = await _queueRepository.fetchQueue(queueId);
    final token = await _tokenRepository.fetchToken(tokenId);

    if (queue == null || token == null || token.queueId != queueId) {
      return null;
    }

    if (!_isRestorable(queue: queue, token: token)) {
      return null;
    }

    return ActiveQueueSession(
      queueId: queue.queueId,
      queueName: queue.name,
      tokenId: token.tokenId,
      tokenNumber: token.tokenNumber,
    );
  }

  Future<ActiveQueueSession?> resolveCustomerSession(
    QueueHistoryEntry entry, {
    bool includeInactive = false,
  }) async {
    if (!entry.isCustomerEntry) {
      return null;
    }

    final queue = await _queueRepository.fetchQueue(entry.queueId);
    final token = await _tokenRepository.fetchToken(entry.id);

    if (queue == null || token == null || token.queueId != entry.queueId) {
      return null;
    }

    if (!includeInactive && !_isRestorable(queue: queue, token: token)) {
      return null;
    }

    return ActiveQueueSession(
      queueId: queue.queueId,
      queueName: queue.name,
      tokenId: token.tokenId,
      tokenNumber: token.tokenNumber,
    );
  }

  bool _isRestorable({required QueueModel queue, required TokenModel token}) {
    return token.isWaiting && !queue.isEnded;
  }
}
