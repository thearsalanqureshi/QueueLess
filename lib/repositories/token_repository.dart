import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants/app_strings.dart';
import '../core/services/firebase_service.dart';
import '../models/queue_model.dart';
import '../models/token_model.dart';

class TokenRepository {
  TokenRepository(this._firebaseService);

  final FirebaseService _firebaseService;

  CollectionReference<Map<String, dynamic>> get _queues =>
      _firebaseService.firestore.collection('queues');

  CollectionReference<Map<String, dynamic>> get _tokens =>
      _firebaseService.firestore.collection('tokens');

  Future<TokenModel> joinQueue({
    required String queueId,
    required String userId,
  }) async {
    if (!_firebaseService.isAvailable) {
      throw StateError(AppStrings.firebaseUnavailable);
    }

    final queueRef = _queues.doc(queueId);
    final tokenRef = _tokens.doc();
    final now = DateTime.now();
    TokenModel? createdToken;

    await _firebaseService.firestore.runTransaction((transaction) async {
      final queueSnapshot = await transaction.get(queueRef);
      final queueData = queueSnapshot.data();

      if (!queueSnapshot.exists || queueData == null) {
        throw Exception(AppStrings.queueNotFound);
      }

      final queue = QueueModel.fromMap(queueData, documentId: queueSnapshot.id);
      if (queue.isEnded) {
        throw Exception(AppStrings.queueEnded);
      }

      final nextTokenNumber = queue.lastIssuedToken + 1;

      createdToken = TokenModel(
        tokenId: tokenRef.id,
        queueId: queue.queueId,
        tokenNumber: nextTokenNumber,
        status: TokenStatus.waiting,
        createdAt: now,
        userId: userId,
      );

      transaction.update(queueRef, {
        'lastIssuedToken': nextTokenNumber,
        'updatedAt': Timestamp.fromDate(now),
      });
      transaction.set(tokenRef, {
        ...createdToken!.toMap(),
        'nearTurnNotificationSentAt': null,
        'servedNotificationSentAt': null,
      });
    });

    return createdToken!;
  }

  Stream<TokenModel?> watchToken(String tokenId) {
    if (!_firebaseService.isAvailable) {
      return Stream<TokenModel?>.value(null);
    }

    return _tokens.doc(tokenId).snapshots().map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) {
        return null;
      }
      return TokenModel.fromMap(snapshot.data()!, documentId: snapshot.id);
    });
  }

  Stream<List<TokenModel>> watchWaitingTokens(String queueId) {
    if (!_firebaseService.isAvailable) {
      return Stream<List<TokenModel>>.value(const []);
    }

    return _tokens.where('queueId', isEqualTo: queueId).snapshots().map((
      snapshot,
    ) {
      final tokens =
          snapshot.docs
              .map((doc) => TokenModel.fromMap(doc.data(), documentId: doc.id))
              .where((token) => token.isWaiting)
              .toList()
            ..sort(
              (left, right) => left.tokenNumber.compareTo(right.tokenNumber),
            );
      return tokens;
    });
  }

  Future<TokenModel?> fetchToken(String tokenId) async {
    if (!_firebaseService.isAvailable) {
      return null;
    }

    final snapshot = await _tokens.doc(tokenId).get();
    if (!snapshot.exists || snapshot.data() == null) {
      return null;
    }

    return TokenModel.fromMap(snapshot.data()!, documentId: snapshot.id);
  }

  Future<List<TokenModel>> fetchTokensForQueue(String queueId) async {
    if (!_firebaseService.isAvailable) {
      return const [];
    }

    final snapshot = await _tokens.where('queueId', isEqualTo: queueId).get();
    final tokens =
        snapshot.docs
            .map((doc) => TokenModel.fromMap(doc.data(), documentId: doc.id))
            .toList()
          ..sort(
            (left, right) => left.tokenNumber.compareTo(right.tokenNumber),
          );
    return tokens;
  }

  Future<void> leaveQueue(String tokenId) async {
    if (!_firebaseService.isAvailable) {
      throw StateError(AppStrings.firebaseUnavailable);
    }

    await _tokens.doc(tokenId).update({'status': TokenStatus.cancelled.name});
  }
}
