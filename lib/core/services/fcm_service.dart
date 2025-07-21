import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:swiss_gold/core/services/cart_service.dart';
import 'package:logger/logger.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  final logger = Logger();
  logger.i('⏮️ Background message received: ${message.messageId}');

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  await FcmService.setupFlutterNotifications();
  FcmService.showFlutterNotification(message);

  logger.d('Background message data: ${message.data}'); 
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingForegroundHandler(RemoteMessage message) async {
  final logger = Logger();
  logger.i('▶️ Foreground message received: ${message.messageId}');
  logger.d('Foreground message data: ${message.data}');

  FcmService.showFlutterNotification(message);
}

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  final logger = Logger();
  logger.i('📱 Background notification tapped: ${notificationResponse.id}');
  logger.d('Action ID: ${notificationResponse.actionId}');
}

class FcmService {
  static late AndroidNotificationChannel channel;
  static late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  static bool isFlutterLocalNotificationsInitialized = false;
  static final Logger _logger = Logger();

  static Future<String?> getToken() async {
    _logger.i('📲 Retrieving FCM token');
    String? token;

    try {
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        token = await FirebaseMessaging.instance.getAPNSToken();
        _logger.d('iOS APNS token retrieved: ${token?.substring(0, 10)}...');
      } else {
        token = await FirebaseMessaging.instance.getToken();
        _logger.d('Android FCM token retrieved: ${token?.substring(0, 10)}...');
      }
      return token;
    } catch (e) {
      _logger.e('Failed to get FCM token', error: e);
      return null;
    }
  }

  static void showFlutterNotification(RemoteMessage message) {
  _logger.i('📬 Showing notification: ${message.messageId}');

  try {
    String jsonData = jsonEncode(message.data);
    _logger.d('Notification payload: $jsonData');

    final title = message.data['title'] ?? message.notification?.title ?? 'No Title';
    final body = message.data['body'] ?? message.notification?.body ?? 'No Body';
    final type = message.data['type'];

    _logger.d('Notification details - Title: $title, Body: $body, Type: $type');

    flutterLocalNotificationsPlugin.show(
      message.hashCode,
      title,
      body,
      payload: jsonData,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          actions: message.data['type'] != null
              ? <AndroidNotificationAction>[
                  AndroidNotificationAction(
                    'ACCEPT',
                    'Accept',
                    titleColor: Colors.green,
                    showsUserInterface: true,
                  ),
                  AndroidNotificationAction(
                    'DECLINE',
                    'Decline',
                    titleColor: Colors.red,
                    showsUserInterface: true,
                  ),
                ]
              : null,
          importance: Importance.max,
          priority: Priority.max,
          channelDescription: channel.description,
          icon: '@mipmap/ic_launcher',
          // Enhanced sound settings
          sound: const RawResourceAndroidNotificationSound('notification'),
          playSound: true,
          enableVibration: true,
          vibrationPattern: Int64List.fromList([0, 1000, 500, 1000]),
          // Ensure notification shows on lock screen
          visibility: NotificationVisibility.public,
          // Wake up screen
          fullScreenIntent: true,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentBanner: true,
          presentSound: true,
          sound: 'default', // You can use a custom sound file
          interruptionLevel: InterruptionLevel.active,
        ),
      ),
    );
    _logger.i('📩 Notification displayed successfully');
  } catch (e) {
    _logger.e('Failed to show notification',
        error: e, stackTrace: StackTrace.current);
  }
}

static Future<void> setupFlutterNotifications() async {
  _logger.i('🛠️ Setting up Flutter notifications');

  if (isFlutterLocalNotificationsInitialized) {
    _logger.d('Notifications already initialized, skipping setup');
    return;
  }

  try {
    // Enhanced channel setup with sound
    channel = const AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      showBadge: true,
      sound: RawResourceAndroidNotificationSound('notification'),
    );
    _logger.d('Android notification channel created: ${channel.id}');

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
    _logger.d('Android notification channel registered');

    // Enhanced foreground notification settings
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    _logger.d('Foreground notification presentation options set');

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      // onDidReceiveLocalNotification: null,
    );
    
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _handleNotificationResponse,
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    isFlutterLocalNotificationsInitialized = true;
    _logger.i('✅ Flutter notifications setup complete');
  } catch (e) {
    _logger.e('Failed to setup notifications',
        error: e, stackTrace: StackTrace.current);
    rethrow;
  }
}

  static void requestPermission() {
    _logger.i('🔐 Requesting FCM permissions');
    try {
      FirebaseMessaging.instance
          .requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: true,
        criticalAlert: true,
        provisional: true,
        sound: true,
      )
          .then((settings) {
        _logger.d(
            'Permission settings - AuthorizationStatus: ${settings.authorizationStatus}');
      });
    } catch (e) {
      _logger.e('Failed to request permissions', error: e);
    }
  }

  // static Future<void> setupFlutterNotifications() async {
  //   _logger.i('🛠️ Setting up Flutter notifications');

  //   if (isFlutterLocalNotificationsInitialized) {
  //     _logger.d('Notifications already initialized, skipping setup');
  //     return;
  //   }

  //   try {
  //     channel = const AndroidNotificationChannel(
  //       'high_importance_channel',
  //       'High Importance Notifications',
  //       description: 'This channel is used for important notifications.',
  //       importance: Importance.max,
  //     );
  //     _logger.d('Android notification channel created: ${channel.id}');

  //     flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  //     await flutterLocalNotificationsPlugin
  //         .resolvePlatformSpecificImplementation<
  //             AndroidFlutterLocalNotificationsPlugin>()
  //         ?.createNotificationChannel(channel);
  //     _logger.d('Android notification channel registered');

  //     await FirebaseMessaging.instance
  //         .setForegroundNotificationPresentationOptions(
  //       alert: true,
  //       badge: true,
  //       sound: true,
  //     );
  //     _logger.d('Foreground notification presentation options set');

  //     const AndroidInitializationSettings initializationSettingsAndroid =
  //         AndroidInitializationSettings('mipmap/ic_launcher');
  //     const InitializationSettings initializationSettings =
  //         InitializationSettings(
  //       android: initializationSettingsAndroid,
  //       iOS: DarwinInitializationSettings(),
  //     );

  //     await flutterLocalNotificationsPlugin.initialize(
  //       initializationSettings,
  //       onDidReceiveNotificationResponse: _handleNotificationResponse,
  //     );

  //     isFlutterLocalNotificationsInitialized = true;
  //     _logger.i('✅ Flutter notifications setup complete');
  //   } catch (e) {
  //     _logger.e('Failed to setup notifications',
  //         error: e, stackTrace: StackTrace.current);
  //     rethrow;
  //   }
  // }

  static Future<void> _handleNotificationResponse(
      NotificationResponse notificationResponse) async {
    _logger.i('👆 Notification response received: ${notificationResponse.id}');
    _logger.d(
        'Action ID: ${notificationResponse.actionId}, Payload: ${notificationResponse.payload}');

    try {
      if (notificationResponse.payload == null) {
        _logger.w('Notification payload is null, cannot process response');
        return;
      }

      Map<String, dynamic> fcmData = jsonDecode(notificationResponse.payload!);
      _logger.d('Decoded FCM data: $fcmData');

      final itemId = fcmData['itemId'];
      final orderId = fcmData['orderId'];

      if (itemId == null || orderId == null) {
        _logger.w('Missing required data - itemId: $itemId, orderId: $orderId');
        return;
      }

      if (notificationResponse.actionId == 'ACCEPT') {
        _logger.i('👍 User ACCEPTED notification action');

        final confirmData = {
          'action': true,
          'itemId': itemId,
          'orderId': orderId
        };

        _logger
            .d('Calling CartService.confirmQuantity with data: $confirmData');
        await CartService.confirmQuantity(confirmData);
        _logger.i('✅ CartService.confirmQuantity completed for ACCEPT action');
      } else if (notificationResponse.actionId == 'DECLINE') {
        _logger.i('👎 User DECLINED notification action');

        final confirmData = {
          'action': false,
          'itemId': itemId,
          'orderId': orderId
        };

        _logger
            .d('Calling CartService.confirmQuantity with data: $confirmData');
        await CartService.confirmQuantity(confirmData);
        _logger.i('✅ CartService.confirmQuantity completed for DECLINE action');
      } else {
        _logger.d('Notification tapped without specific action');
      }
    } catch (e) {
      _logger.e('Error handling notification response',
          error: e, stackTrace: StackTrace.current);
    }
  }
}
