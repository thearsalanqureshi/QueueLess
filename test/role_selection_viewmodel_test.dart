import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:queueless/core/services/firebase_service.dart';
import 'package:queueless/core/services/hive_service.dart';
import 'package:queueless/models/app_role.dart';
import 'package:queueless/providers/app_providers.dart';
import 'package:queueless/repositories/user_profile_repository.dart';
import 'package:queueless/viewmodels/role_selection_viewmodel.dart';

class _FakeHiveService extends HiveService {
  AppRole? storedRole;

  @override
  AppRole? get selectedRole => storedRole;

  @override
  Future<void> setSelectedRole(AppRole role) async {
    storedRole = role;
  }
}

class _FakeFirebaseService extends FirebaseService {}

class _FakeUserProfileRepository extends UserProfileRepository {
  _FakeUserProfileRepository({this.throwOnUpdate = false})
    : super(_FakeFirebaseService());

  final bool throwOnUpdate;
  AppRole? updatedRole;

  @override
  Future<void> updateCurrentRole(AppRole role) async {
    updatedRole = role;
    if (throwOnUpdate) {
      throw Exception('profile sync failed');
    }
  }
}

void main() {
  test('Role selection keeps local success when remote profile sync fails', () async {
    final hiveService = _FakeHiveService();
    final profileRepository = _FakeUserProfileRepository(throwOnUpdate: true);
    final container = ProviderContainer(
      overrides: [
        hiveServiceProvider.overrideWithValue(hiveService),
        userProfileRepositoryProvider.overrideWithValue(profileRepository),
      ],
    );
    addTearDown(container.dispose);

    expect(await container.read(roleSelectionViewModelProvider.future), isNull);

    await container
        .read(roleSelectionViewModelProvider.notifier)
        .selectRole(AppRole.customer);

    expect(hiveService.selectedRole, AppRole.customer);
    expect(profileRepository.updatedRole, AppRole.customer);
    expect(container.read(roleSelectionViewModelProvider).value, AppRole.customer);
  });
}
