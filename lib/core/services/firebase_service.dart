import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class FirebaseBootstrapResult {
  const FirebaseBootstrapResult({required this.isReady, this.error});

  final bool isReady;
  final Object? error;
}

class FirebaseService {
  FirebaseFirestore? _firestore;
  FirebaseAuth? _auth;
  Object? _error;

  bool get isAvailable => _firestore != null && _auth?.currentUser != null;

  FirebaseFirestore get firestore {
    final firestore = _firestore;
    if (firestore == null) {
      throw StateError('Firebase has not been initialized.');
    }
    return firestore;
  }

  FirebaseAuth get auth {
    final auth = _auth;
    if (auth == null) {
      throw StateError('Firebase Auth has not been initialized.');
    }
    return auth;
  }

  User? get currentUser => _auth?.currentUser;

  String? get uid => currentUser?.uid;

  Object? get error => _error;

  Future<FirebaseBootstrapResult> initialize() async {
    try {
      await Firebase.initializeApp();
      _auth = FirebaseAuth.instance;
      if (_auth!.currentUser == null) {
        await _auth!.signInAnonymously();
      }
      _firestore = FirebaseFirestore.instance;
      _error = null;
      return const FirebaseBootstrapResult(isReady: true);
    } catch (error) {
      _error = error;
      return FirebaseBootstrapResult(isReady: false, error: error);
    }
  }
}
