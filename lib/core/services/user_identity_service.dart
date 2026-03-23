import '../constants/app_strings.dart';
import 'firebase_service.dart';
import 'hive_service.dart';

class UserIdentityService {
  UserIdentityService(this._firebaseService, this._hiveService);

  final FirebaseService _firebaseService;
  final HiveService _hiveService;

  Future<String> getOrCreateUserId() async {
    final firebaseUid = _firebaseService.uid;
    if (firebaseUid != null && firebaseUid.isNotEmpty) {
      if (_hiveService.anonymousUserId != firebaseUid) {
        await _hiveService.setAnonymousUserId(firebaseUid);
      }
      return firebaseUid;
    }

    final fallback = _hiveService.anonymousUserId;
    if (fallback != null && fallback.isNotEmpty) {
      return fallback;
    }

    throw StateError(AppStrings.authUnavailable);
  }
}
