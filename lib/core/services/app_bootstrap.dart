import 'firebase_service.dart';
import 'hive_service.dart';
import 'notification_service.dart';

class AppBootstrapData {
  const AppBootstrapData({
    required this.firebaseService,
    required this.hiveService,
    required this.notificationService,
    required this.firebaseReady,
    this.firebaseError,
    required this.hiveReady,
    this.hiveError,
  });

  final FirebaseService firebaseService;
  final HiveService hiveService;
  final NotificationService notificationService;
  final bool firebaseReady;
  final Object? firebaseError;
  final bool hiveReady;
  final Object? hiveError;

  String? get startupWarning {
    if (!hiveReady) {
      return 'Local storage could not be initialized. Queue history and onboarding state may be unavailable.';
    }
    if (!firebaseReady) {
      return 'Firebase or anonymous sign-in is not available yet. The UI works, but live queues, secure ownership, Firestore sync, and notifications need Firebase setup to finish.';
    }
    return null;
  }
}

Future<AppBootstrapData> bootstrapApplication() async {
  final hiveService = HiveService();
  var hiveReady = false;
  Object? hiveError;

  try {
    await hiveService.initialize();
    hiveReady = true;
  } catch (error) {
    hiveError = error;
  }

  final firebaseService = FirebaseService();
  final firebaseResult = await firebaseService.initialize();

  final notificationService = NotificationService();
  await notificationService.initialize(
    firebaseAvailable: firebaseResult.isReady,
  );

  return AppBootstrapData(
    firebaseService: firebaseService,
    hiveService: hiveService,
    notificationService: notificationService,
    firebaseReady: firebaseResult.isReady,
    firebaseError: firebaseResult.error,
    hiveReady: hiveReady,
    hiveError: hiveError,
  );
}
