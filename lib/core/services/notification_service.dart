import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {}

class NotificationService {
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  bool _firebaseAvailable = false;

  Future<void> initialize({required bool firebaseAvailable}) async {
    if (_initialized) {
      return;
    }

    _firebaseAvailable = firebaseAvailable;

    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );

    await _notifications.initialize(initializationSettings);

    await _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();

    if (firebaseAvailable) {
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      final messaging = FirebaseMessaging.instance;
      await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        provisional: false,
        sound: true,
      );

      await messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      FirebaseMessaging.onMessage.listen((message) async {
        final notification = message.notification;
        if (notification == null) {
          return;
        }

        await showLocalNotification(
          id: notification.hashCode,
          title: notification.title ?? 'QueueLess update',
          body: notification.body ?? 'You have a new queue update.',
        );
      });
    }

    _initialized = true;
  }

  Future<String?> getFcmToken() async {
    if (!_firebaseAvailable) {
      return null;
    }

    try {
      return FirebaseMessaging.instance.getToken();
    } catch (_) {
      return null;
    }
  }

  Stream<String> get onTokenRefresh {
    if (!_firebaseAvailable) {
      return const Stream<String>.empty();
    }

    return FirebaseMessaging.instance.onTokenRefresh;
  }

  Future<void> showTurnAlert({
    required String queueName,
    required int tokenNumber,
    required int peopleAhead,
  }) async {
    final body = peopleAhead <= 0
        ? 'Token $tokenNumber can be served now at $queueName.'
        : 'Token $tokenNumber has $peopleAhead turns left at $queueName.';

    await showLocalNotification(
      id: tokenNumber,
      title: 'QueueLess alert',
      body: body,
    );
  }

  Future<void> showLocalNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'queue_updates',
        'Queue Updates',
        channelDescription: 'Queue turn alerts and admin updates',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );

    await _notifications.show(id, title, body, notificationDetails);
  }
}
