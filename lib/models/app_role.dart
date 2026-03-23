enum AppRole { customer, admin }

extension AppRoleX on AppRole {
  String get storageValue => name;

  String get label => this == AppRole.customer ? 'Customer' : 'Business/Admin';

  String get dashboardLabel =>
      this == AppRole.customer ? 'Customer dashboard' : 'Admin dashboard';

  String get historyLabel =>
      this == AppRole.customer ? 'Queue History' : 'Analytics & History';
}

AppRole? parseAppRole(String? value) {
  if (value == null || value.isEmpty) {
    return null;
  }

  for (final role in AppRole.values) {
    if (role.storageValue == value) {
      return role;
    }
  }

  return null;
}
