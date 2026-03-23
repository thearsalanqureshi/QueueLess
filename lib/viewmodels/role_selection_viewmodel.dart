import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_role.dart';
import '../providers/app_providers.dart';

final roleSelectionViewModelProvider =
    AsyncNotifierProvider<RoleSelectionViewModel, AppRole?>(
      RoleSelectionViewModel.new,
    );

class RoleSelectionViewModel extends AsyncNotifier<AppRole?> {
  @override
  Future<AppRole?> build() async {
    return ref.read(hiveServiceProvider).selectedRole;
  }

  Future<void> selectRole(AppRole role) async {
    state = const AsyncLoading();

    try {
      await ref.read(hiveServiceProvider).setSelectedRole(role);
      try {
        await ref.read(userProfileRepositoryProvider).updateCurrentRole(role);
      } catch (_) {}
      state = AsyncData(role);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }
}
