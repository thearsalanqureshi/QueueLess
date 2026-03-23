import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:queueless/core/services/firebase_service.dart';
import 'package:queueless/core/services/notification_service.dart';
import 'package:queueless/core/services/startup_coordinator.dart';
import 'package:queueless/repositories/user_profile_repository.dart';

class _FakeFirebaseService extends FirebaseService {}

class _FakeUserProfileRepository extends UserProfileRepository {
  _FakeUserProfileRepository({
    this.throwOnEnsure = false,
    this.throwOnRegister = false,
  }) : super(_FakeFirebaseService());

  final bool throwOnEnsure;
  final bool throwOnRegister;
  int ensureCalls = 0;
  final List<String> registeredTokens = [];

  @override
  Future<void> ensureCurrentUserDocument({role}) async {
    ensureCalls += 1;
    if (throwOnEnsure) {
      throw Exception('ensure failed');
    }
  }

  @override
  Future<void> registerFcmToken(String token) async {
    registeredTokens.add(token);
    if (throwOnRegister) {
      throw Exception('register failed');
    }
  }
}

class _FakeNotificationService extends NotificationService {
  _FakeNotificationService({this.currentToken, this.throwOnGetToken = false});

  final bool throwOnGetToken;
  final StreamController<String> controller = StreamController<String>.broadcast();
  String? currentToken;

  @override
  Future<String?> getFcmToken() async {
    if (throwOnGetToken) {
      throw Exception('token fetch failed');
    }
    return currentToken;
  }

  @override
  Stream<String> get onTokenRefresh => controller.stream;

  Future<void> close() => controller.close();
}

void main() {
  test('Startup coordinator registers current and refreshed FCM tokens', () async {
    final notifications = _FakeNotificationService(currentToken: 'token-1');
    final profiles = _FakeUserProfileRepository();
    final coordinator = StartupCoordinator(notifications, profiles);
    addTearDown(() async {
      coordinator.dispose();
      await notifications.close();
    });

    await coordinator.initialize();
    await Future<void>.delayed(Duration.zero);

    expect(profiles.ensureCalls, 1);
    expect(profiles.registeredTokens, ['token-1']);

    notifications.controller.add('token-2');
    await Future<void>.delayed(Duration.zero);

    expect(profiles.registeredTokens, ['token-1', 'token-2']);

    coordinator.dispose();
    notifications.currentToken = 'token-3';
    await coordinator.initialize();
    await Future<void>.delayed(Duration.zero);

    expect(profiles.ensureCalls, 2);
    expect(profiles.registeredTokens, ['token-1', 'token-2', 'token-3']);
  });

  test('Startup coordinator stays non-fatal when sync operations fail', () async {
    final notifications = _FakeNotificationService(
      currentToken: 'token-1',
      throwOnGetToken: true,
    );
    final profiles = _FakeUserProfileRepository(
      throwOnEnsure: true,
      throwOnRegister: true,
    );
    final coordinator = StartupCoordinator(notifications, profiles);
    addTearDown(() async {
      coordinator.dispose();
      await notifications.close();
    });

    await coordinator.initialize();
    notifications.controller.add('token-2');
    await Future<void>.delayed(Duration.zero);

    expect(profiles.ensureCalls, 1);
    expect(profiles.registeredTokens, ['token-2']);
  });
}
