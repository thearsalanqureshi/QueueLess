import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/app_role.dart';
import '../models/user_profile_model.dart';
import '../core/services/firebase_service.dart';

class UserProfileRepository {
  UserProfileRepository(this._firebaseService);

  final FirebaseService _firebaseService;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firebaseService.firestore.collection('users');

  String? get _uid => _firebaseService.uid;

  Future<void> ensureCurrentUserDocument({AppRole? role}) async {
    if (!_firebaseService.isAvailable || _uid == null) {
      return;
    }

    final docRef = _users.doc(_uid);
    final snapshot = await docRef.get();
    final payload = <String, dynamic>{
      'uid': _uid,
      if (role != null) 'role': role.storageValue,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (!snapshot.exists) {
      payload['createdAt'] = FieldValue.serverTimestamp();
    }

    await docRef.set(payload, SetOptions(merge: true));
  }

  Future<UserProfileModel?> fetchCurrentProfile() async {
    if (!_firebaseService.isAvailable || _uid == null) {
      return null;
    }

    final snapshot = await _users.doc(_uid).get();
    final data = snapshot.data();
    if (!snapshot.exists || data == null) {
      return null;
    }

    return UserProfileModel.fromMap(data, uid: snapshot.id);
  }

  Future<void> updateCurrentRole(AppRole role) async {
    if (!_firebaseService.isAvailable || _uid == null) {
      return;
    }

    await ensureCurrentUserDocument(role: role);
    await _users.doc(_uid).set({
      'role': role.storageValue,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> registerFcmToken(String token) async {
    if (!_firebaseService.isAvailable || _uid == null || token.trim().isEmpty) {
      return;
    }

    await ensureCurrentUserDocument();
    await _users.doc(_uid).set({
      'fcmTokens': FieldValue.arrayUnion([token.trim()]),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> setActiveCustomerSession({
    required String queueId,
    required String tokenId,
  }) async {
    if (!_firebaseService.isAvailable || _uid == null) {
      return;
    }

    await ensureCurrentUserDocument();
    await _users.doc(_uid).set({
      'activeCustomerQueueId': queueId,
      'activeCustomerTokenId': tokenId,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> clearActiveCustomerSession() async {
    if (!_firebaseService.isAvailable || _uid == null) {
      return;
    }

    await _users.doc(_uid).set({
      'activeCustomerQueueId': FieldValue.delete(),
      'activeCustomerTokenId': FieldValue.delete(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> setLastAdminQueue(String queueId) async {
    if (!_firebaseService.isAvailable || _uid == null) {
      return;
    }

    await ensureCurrentUserDocument();
    await _users.doc(_uid).set({
      'lastAdminQueueId': queueId,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
