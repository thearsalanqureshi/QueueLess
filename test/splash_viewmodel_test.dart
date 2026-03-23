import 'package:flutter_test/flutter_test.dart';

import 'package:queueless/core/constants/app_constants.dart';
import 'package:queueless/core/services/firebase_service.dart';
import 'package:queueless/core/services/hive_service.dart';
import 'package:queueless/models/active_queue_session.dart';
import 'package:queueless/models/app_role.dart';
import 'package:queueless/repositories/history_repository.dart';
import 'package:queueless/repositories/queue_repository.dart';
import 'package:queueless/repositories/session_repository.dart';
import 'package:queueless/repositories/token_repository.dart';
import 'package:queueless/repositories/user_profile_repository.dart';
import 'package:queueless/storage/token_history_storage.dart';
import 'package:queueless/viewmodels/splash_viewmodel.dart';

class _FakeHiveService extends HiveService {
  _FakeHiveService({required this.onboardingDone, required this.role});

  final bool onboardingDone;
  final AppRole? role;

  @override
  bool get onboardingCompleted => onboardingDone;

  @override
  AppRole? get selectedRole => role;
}

class _FakeFirebaseService extends FirebaseService {}

class _FakeSessionRepository extends SessionRepository {
  _FakeSessionRepository(this._session)
    : super(
        HistoryRepository(
          TokenHistoryStorage(
            _FakeHiveService(onboardingDone: true, role: AppRole.customer),
          ),
        ),
        QueueRepository(_FakeFirebaseService()),
        TokenRepository(_FakeFirebaseService()),
        UserProfileRepository(_FakeFirebaseService()),
      );

  final ActiveQueueSession? _session;

  @override
  Future<ActiveQueueSession?> findLatestActiveCustomerSession() async {
    return _session;
  }
}

void main() {
  test('Splash routes to onboarding when onboarding is incomplete', () async {
    final viewModel = SplashViewModel(
      _FakeHiveService(onboardingDone: false, role: null),
      _FakeSessionRepository(null),
    );

    final route = await viewModel.resolveInitialRoute();

    expect(route, AppRoutes.onboarding);
  });

  test('Splash routes to role selection when no role is saved', () async {
    final viewModel = SplashViewModel(
      _FakeHiveService(onboardingDone: true, role: null),
      _FakeSessionRepository(null),
    );

    final route = await viewModel.resolveInitialRoute();

    expect(route, AppRoutes.roleSelection);
  });

  test(
    'Splash routes customer with active session directly to queue status',
    () async {
      final viewModel = SplashViewModel(
        _FakeHiveService(onboardingDone: true, role: AppRole.customer),
        _FakeSessionRepository(
          const ActiveQueueSession(
            queueId: 'QUEUE1',
            queueName: 'Demo Queue',
            tokenId: 'token-1',
            tokenNumber: 5,
          ),
        ),
      );

      final route = await viewModel.resolveInitialRoute();

      expect(
        route,
        AppRoutes.customerQueueStatusLocation(
          queueId: 'QUEUE1',
          tokenId: 'token-1',
        ),
      );
    },
  );

  test('Splash routes admin directly to admin home', () async {
    final viewModel = SplashViewModel(
      _FakeHiveService(onboardingDone: true, role: AppRole.admin),
      _FakeSessionRepository(null),
    );

    final route = await viewModel.resolveInitialRoute();

    expect(route, AppRoutes.adminHome);
  });
}
