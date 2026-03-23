import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/navigation/app_router.dart';
import '../core/services/ai_service.dart';
import '../core/services/app_bootstrap.dart';
import '../core/services/firebase_service.dart';
import '../core/services/hive_service.dart';
import '../core/services/notification_service.dart';
import '../core/services/startup_coordinator.dart';
import '../core/services/user_identity_service.dart';
import '../repositories/analytics_repository.dart';
import '../repositories/history_repository.dart';
import '../repositories/queue_repository.dart';
import '../repositories/session_repository.dart';
import '../repositories/token_repository.dart';
import '../repositories/user_profile_repository.dart';
import '../storage/token_history_storage.dart';

final appBootstrapProvider = Provider<AppBootstrapData>(
  (ref) => throw UnimplementedError('App bootstrap has not been provided.'),
);

final firebaseServiceProvider = Provider<FirebaseService>(
  (ref) => ref.watch(appBootstrapProvider).firebaseService,
);

final hiveServiceProvider = Provider<HiveService>(
  (ref) => ref.watch(appBootstrapProvider).hiveService,
);

final notificationServiceProvider = Provider<NotificationService>(
  (ref) => ref.watch(appBootstrapProvider).notificationService,
);

final aiServiceProvider = Provider<AiService>((ref) => AiService());

final userIdentityServiceProvider = Provider<UserIdentityService>(
  (ref) => UserIdentityService(
    ref.watch(firebaseServiceProvider),
    ref.watch(hiveServiceProvider),
  ),
);

final tokenHistoryStorageProvider = Provider<TokenHistoryStorage>(
  (ref) => TokenHistoryStorage(ref.watch(hiveServiceProvider)),
);

final queueRepositoryProvider = Provider<QueueRepository>(
  (ref) => QueueRepository(ref.watch(firebaseServiceProvider)),
);

final tokenRepositoryProvider = Provider<TokenRepository>(
  (ref) => TokenRepository(ref.watch(firebaseServiceProvider)),
);

final analyticsRepositoryProvider = Provider<AnalyticsRepository>(
  (ref) => AnalyticsRepository(
    ref.watch(tokenRepositoryProvider),
    ref.watch(aiServiceProvider),
  ),
);

final historyRepositoryProvider = Provider<HistoryRepository>(
  (ref) => HistoryRepository(ref.watch(tokenHistoryStorageProvider)),
);

final userProfileRepositoryProvider = Provider<UserProfileRepository>(
  (ref) => UserProfileRepository(ref.watch(firebaseServiceProvider)),
);

final sessionRepositoryProvider = Provider<SessionRepository>(
  (ref) => SessionRepository(
    ref.watch(historyRepositoryProvider),
    ref.watch(queueRepositoryProvider),
    ref.watch(tokenRepositoryProvider),
    ref.watch(userProfileRepositoryProvider),
  ),
);

final startupCoordinatorProvider = Provider<StartupCoordinator>(
  (ref) => StartupCoordinator(
    ref.watch(notificationServiceProvider),
    ref.watch(userProfileRepositoryProvider),
  ),
);

final startupWarningProvider = Provider<String?>(
  (ref) => ref.watch(appBootstrapProvider).startupWarning,
);

final appRouterProvider = Provider<GoRouter>(buildAppRouter);
