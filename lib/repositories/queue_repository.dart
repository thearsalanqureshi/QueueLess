import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants/app_strings.dart';
import '../core/services/firebase_service.dart';
import '../models/queue_model.dart';
import '../models/token_model.dart';

class QueueRepository {
  QueueRepository(this._firebaseService);

  final FirebaseService _firebaseService;
  final Random _random = Random();

  CollectionReference<Map<String, dynamic>> get _queues =>
      _firebaseService.firestore.collection('queues');

  CollectionReference<Map<String, dynamic>> get _tokens =>
      _firebaseService.firestore.collection('tokens');

  Stream<QueueModel?> watchQueue(String queueId) {
    if (!_firebaseService.isAvailable) {
      return Stream<QueueModel?>.value(null);
    }

    return _queues.doc(queueId).snapshots().map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) {
        return null;
      }
      return QueueModel.fromMap(snapshot.data()!, documentId: snapshot.id);
    });
  }

  Future<QueueModel?> fetchQueue(String queueId) async {
    if (!_firebaseService.isAvailable) {
      return null;
    }

    final snapshot = await _queues.doc(queueId).get();
    if (!snapshot.exists || snapshot.data() == null) {
      return null;
    }

    return QueueModel.fromMap(snapshot.data()!, documentId: snapshot.id);
  }

  Future<QueueModel> createQueue({
    required String name,
    required int avgServiceTime,
    required String adminId,
  }) async {
    if (!_firebaseService.isAvailable) {
      throw StateError(AppStrings.firebaseUnavailable);
    }

    final now = DateTime.now();
    final queue = QueueModel(
      queueId: _generateQueueId(),
      adminId: adminId,
      name: name.trim(),
      avgServiceTime: avgServiceTime,
      currentToken: 0,
      lastIssuedToken: 0,
      status: QueueLifecycleStatus.active,
      createdAt: now,
      updatedAt: now,
    );

    await _queues.doc(queue.queueId).set(queue.toMap());
    return queue;
  }

  Future<void> setPaused(String queueId, {required bool paused}) async {
    if (!_firebaseService.isAvailable) {
      throw StateError(AppStrings.firebaseUnavailable);
    }

    await _queues.doc(queueId).update({
      'status': paused
          ? QueueLifecycleStatus.paused.name
          : QueueLifecycleStatus.active.name,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  Future<void> endQueue(String queueId) async {
    if (!_firebaseService.isAvailable) {
      throw StateError(AppStrings.firebaseUnavailable);
    }

    await _queues.doc(queueId).update({
      'status': QueueLifecycleStatus.ended.name,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  Future<void> serveNext(String queueId) async {
    if (!_firebaseService.isAvailable) {
      throw StateError(AppStrings.firebaseUnavailable);
    }

    final queueSnapshot = await _queues.doc(queueId).get();
    final queueData = queueSnapshot.data();
    if (!queueSnapshot.exists || queueData == null) {
      throw Exception(AppStrings.queueNotFound);
    }

    final queue = QueueModel.fromMap(queueData, documentId: queueSnapshot.id);
    if (queue.isEnded) {
      throw Exception(AppStrings.queueEnded);
    }
    if (queue.isPaused) {
      throw Exception('Resume the queue before serving the next token.');
    }
    if (queue.currentToken >= queue.lastIssuedToken) {
      return;
    }

    final nextToken = queue.currentToken + 1;

    await _queues.doc(queueId).update({
      'currentToken': nextToken,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });

    final tokenSnapshot = await _tokens
        .where('queueId', isEqualTo: queueId)
        .where('tokenNumber', isEqualTo: nextToken)
        .limit(1)
        .get();

    if (tokenSnapshot.docs.isNotEmpty) {
      await tokenSnapshot.docs.first.reference.update({
        'status': TokenStatus.served.name,
      });
    }
  }

  String _generateQueueId() {
    const alphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    return List.generate(
      6,
      (_) => alphabet[_random.nextInt(alphabet.length)],
    ).join();
  }
}
