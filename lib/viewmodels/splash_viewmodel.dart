import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_constants.dart';
import '../core/services/hive_service.dart';
import '../models/app_role.dart';
import '../providers/app_providers.dart';
import '../repositories/session_repository.dart';

final splashRouteProvider = FutureProvider.autoDispose<String>((ref) async {
  final viewModel = SplashViewModel(
    ref.read(hiveServiceProvider),
    ref.read(sessionRepositoryProvider),
  );
  return viewModel.resolveInitialRoute();
});

class SplashViewModel {
  const SplashViewModel(this._hiveService, this._sessionRepository);

  final HiveService _hiveService;
  final SessionRepository _sessionRepository;

  Future<String> resolveInitialRoute() async {
    await Future<void>.delayed(const Duration(milliseconds: 1200));
    if (!_hiveService.onboardingCompleted) {
      return AppRoutes.onboarding;
    }

    final selectedRole = _hiveService.selectedRole;
    if (selectedRole == null) {
      return AppRoutes.roleSelection;
    }

    if (selectedRole == AppRole.admin) {
      return AppRoutes.adminHome;
    }

    try {
      final activeSession = await _sessionRepository
          .findLatestActiveCustomerSession();
      if (activeSession != null) {
        return AppRoutes.customerQueueStatusLocation(
          queueId: activeSession.queueId,
          tokenId: activeSession.tokenId,
        );
      }
    } catch (_) {
      return AppRoutes.customerHome;
    }

    return AppRoutes.customerHome;
  }
}
