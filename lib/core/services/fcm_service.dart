import 'dart:convert';
import 'dart:isolate';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:swiss_gold/core/services/cart_service.dart';
import 'package:logger/logger.dart';

class FcmService {
  static late AndroidNotificationChannel channel;
  static late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  static bool isFlutterLocalNotificationsInitialized = false;
  static final Logger _logger = Logger();

  static Future<void> initialize() async {
    _logger.i('Initializing FCM Service');
    await FirebaseMessaging.instance.setAutoInitEnabled(true);
    
    // Handle initial notification when app is launched from terminated state
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _logger.i('Handling initial message: ${initialMessage.messageId}');
      await _handleNotificationResponse(NotificationResponse(
        notificationResponseType: NotificationResponseType.selectedNotification,
        payload: jsonEncode(initialMessage.data),
      ));
    }

    // Handle notification opened when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _logger.i('App opened from notification: ${message.messageId}');
      _handleNotificationResponse(NotificationResponse(
        notificationResponseType: NotificationResponseType.selectedNotification,
        payload: jsonEncode(message.data),
      ));
    });
  }

  static Future<String?> getToken() async {
    _logger.i('📲 Retrieving FCM token');
    try {
      String? token = await FirebaseMessaging.instance.getToken();
      _logger.d('FCM token retrieved: ${token?.substring(0, 10)}...');
      return token;
    } catch (e) {
      _logger.e('Failed to get FCM token', error: e);
      return null;
    }
  }

  static Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    await Firebase.initializeApp();
    await setupFlutterNotifications();
    showFlutterNotification(message);
    _logger.i('⏮️ Background message handled: ${message.messageId}');
  }

  static Future<void> firebaseMessagingForegroundHandler(RemoteMessage message) async {
    showFlutterNotification(message);
    _logger.i('▶️ Foreground message handled: ${message.messageId}');
  }

  static void showFlutterNotification(RemoteMessage message) {
    _logger.i('📬 Showing notification: ${message.messageId}');
  _logger.d('Full message: ${message.toMap()}');
  try {
    String jsonData = jsonEncode(message.data);
    final title = message.notification?.title ?? message.data['title'] ?? 'Default Title';
    final body = message.notification?.body ?? message.data['body'] ?? 'Default Body';
    final type = message.data['type'];

      flutterLocalNotificationsPlugin.show(
        message.hashCode,
        title,
        body,
        payload: jsonData,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            importance: Importance.max,
            priority: Priority.high,
            icon: '@drawable/swiss_gold_logo',
            sound: const RawResourceAndroidNotificationSound('notification'),
            playSound: true,
            enableVibration: true,
            vibrationPattern: Int64List.fromList([0, 1000, 500, 1000]),
            visibility: NotificationVisibility.public,
            fullScreenIntent: true,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentBanner: true,
            presentSound: true,
            sound: 'notification',
            interruptionLevel: InterruptionLevel.active,
          ),
        ),
      );
      _logger.i('📩 Notification displayed successfully');
    } catch (e) {
      _logger.e('Failed to show notification', error: e);
    }
  }

  static Future<void> setupFlutterNotifications() async {
  if (isFlutterLocalNotificationsInitialized) {
    _logger.d('Notifications already initialized');
    return;
  }

  const maxRetries = 3;
  for (int attempt = 1; attempt <= maxRetries; attempt++) {
    try {
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

      flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      const initializationSettings = InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        ),
      );

      await flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _handleNotificationResponse,
        onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
      );

      isFlutterLocalNotificationsInitialized = true;
      _logger.i('✅ Flutter notifications setup complete');
      return;
    } catch (e) {
      _logger.e('Failed to setup notifications (attempt $attempt/$maxRetries)', error: e);
      if (attempt == maxRetries) {
        _logger.e('Max retries reached, giving up');
        rethrow;
      }
      await Future.delayed(Duration(seconds: attempt));
    }
  }
}

static Future<void> requestPermission() async {
  _logger.i('🔐 Requesting FCM permissions');
  try {
    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: true,
      provisional: true, // Enable provisional notifications for iOS
      sound: true,
    );
    _logger.i('Permission status: ${settings.authorizationStatus}');
    if (settings.authorizationStatus != AuthorizationStatus.authorized &&
        settings.authorizationStatus != AuthorizationStatus.provisional) {
      _logger.w('Notification permissions not granted');
    }
  } catch (e) {
    _logger.e('Failed to request permissions', error: e);
  }
}

  static void notificationTapBackground(NotificationResponse notificationResponse) {
    _logger.i('📱 Background notification tapped: ${notificationResponse.id}');
    _handleNotificationResponse(notificationResponse);
  }

  static Future<void> _handleNotificationResponse(NotificationResponse notificationResponse) async {
    _logger.i('👆 Notification response received: ${notificationResponse.id}');
    try {
      if (notificationResponse.payload == null) {
        _logger.w('Notification payload is null');
        return;
      }

      // Spawn an isolate for heavy processing
      final receivePort = ReceivePort();
      await Isolate.spawn(_processNotificationInIsolate, {
        'payload': notificationResponse.payload,
        'sendPort': receivePort.sendPort,
        'actionId': notificationResponse.actionId,
      });

      // Listen for results from the isolate
      receivePort.listen((message) {
        _logger.i('Received result from isolate: $message');
        receivePort.close();
      });
    } catch (e) {
      _logger.e('Error handling notification response', error: e);
    }
  }

  static void _processNotificationInIsolate(Map<String, dynamic> data) async {
    final sendPort = data['sendPort'] as SendPort;
    final payload = data['payload'] as String;
    final actionId = data['actionId'] as String?;

    try {
      Map<String, dynamic> fcmData = jsonDecode(payload);
      final itemId = fcmData['itemId'];
      final orderId = fcmData['orderId'];

      if (itemId == null || orderId == null) {
        sendPort.send('Missing required data - itemId: $itemId, orderId: $orderId');
        return;
      }

      if (actionId == 'ACCEPT') {
        await CartService.confirmQuantity({
          'action': true,
          'itemId': itemId,
          'orderId': orderId,
        });
        sendPort.send('Successfully processed ACCEPT action');
      } else if (actionId == 'DECLINE') {
        await CartService.confirmQuantity({
          'action': false,
          'itemId': itemId,
          'orderId': orderId,
        });
        sendPort.send('Successfully processed DECLINE action');
      } else {
        sendPort.send('Notification tapped without specific action');
      }
    } catch (e) {
      sendPort.send('Error in isolate: $e');
    }
  
  }
}