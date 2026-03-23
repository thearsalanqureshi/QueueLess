import 'package:hive_flutter/hive_flutter.dart';

import '../../models/app_role.dart';
import '../../models/queue_history_entry.dart';
import '../../storage/hive_boxes.dart';

class HiveService {
  Future<void> initialize() async {
    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(QueueHistoryEntryAdapter.typeIdValue)) {
      Hive.registerAdapter(QueueHistoryEntryAdapter());
    }

    if (!Hive.isBoxOpen(HiveBoxes.settings)) {
      await Hive.openBox<dynamic>(HiveBoxes.settings);
    }
    if (!Hive.isBoxOpen(HiveBoxes.queueHistory)) {
      await Hive.openBox<QueueHistoryEntry>(HiveBoxes.queueHistory);
    }
  }

  Box<dynamic> get settingsBox => Hive.box<dynamic>(HiveBoxes.settings);

  Box<QueueHistoryEntry> get queueHistoryBox =>
      Hive.box<QueueHistoryEntry>(HiveBoxes.queueHistory);

  bool get onboardingCompleted {
    return settingsBox.get(HiveKeys.onboardingCompleted, defaultValue: false)
        as bool;
  }

  Future<void> setOnboardingCompleted(bool value) {
    return settingsBox.put(HiveKeys.onboardingCompleted, value);
  }

  String? get anonymousUserId {
    return settingsBox.get(HiveKeys.anonymousUserId) as String?;
  }

  Future<void> setAnonymousUserId(String value) {
    return settingsBox.put(HiveKeys.anonymousUserId, value);
  }

  AppRole? get selectedRole {
    return parseAppRole(settingsBox.get(HiveKeys.selectedRole) as String?);
  }

  Future<void> setSelectedRole(AppRole role) {
    return settingsBox.put(HiveKeys.selectedRole, role.storageValue);
  }

  Future<void> clearSelectedRole() {
    return settingsBox.delete(HiveKeys.selectedRole);
  }
}
