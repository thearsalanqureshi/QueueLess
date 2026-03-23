import 'dart:async';

import '../../repositories/user_profile_repository.dart';
import 'notification_service.dart';

class StartupCoordinator {
  StartupCoordinator(this._notificationService, this._userProfileRepository);

  final NotificationService _notificationService;
  final UserProfileRepository _userProfileRepository;

  StreamSubscription<String>? _tokenRefreshSubscription;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    _initialized = true;
    await _safeEnsureCurrentUserDocument();
    await _syncCurrentToken();

    _tokenRefreshSubscription = _notificationService.onTokenRefresh.listen(
      (token) => unawaited(_safeRegisterFcmToken(token)),
    );
  }

  void dispose() {
    _tokenRefreshSubscription?.cancel();
    _tokenRefreshSubscription = null;
    _initialized = false;
  }

  Future<void> _safeEnsureCurrentUserDocument() async {
    try {
      await _userProfileRepository.ensureCurrentUserDocument();
    } catch (_) {}
  }

  Future<void> _syncCurrentToken() async {
    try {
      final currentToken = await _notificationService.getFcmToken();
      await _safeRegisterFcmToken(currentToken);
    } catch (_) {}
  }

  Future<void> _safeRegisterFcmToken(String? token) async {
    if (token == null || token.trim().isEmpty) {
      return;
    }

    try {
      await _userProfileRepository.registerFcmToken(token);
    } catch (_) {}
  }
}
