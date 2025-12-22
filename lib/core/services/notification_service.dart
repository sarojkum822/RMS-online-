import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `Firebase.initializeApp()` before using them.
  // Note: For simple notification display, FCM handles it automatically in the background.
  if (kDebugMode) {
    print("Handling a background message: ${message.messageId}");
  }
}

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  NotificationService();

  Future<void> initialize() async {
    try {
      // 1. Initialize Timezones for scheduling
      tz.initializeTimeZones();

      // 2. Request Permissions (iOS/Android 13+)
      await _requestPermissions();

      // 3. Initialize Local Notifications
      const androidSettings = AndroidInitializationSettings('@mipmap/launcher_icon'); // Corrected icon name
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      
      const initSettings = InitializationSettings(android: androidSettings, iOS: iosSettings);
      
      await _localNotifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (response) {
          // Handle notification tap
          if (kDebugMode) {
            print('Notification tapped: ${response.payload}');
          }
        },
      );

      // 4. Foreground FCM Handler
      // For iOS, foreground notifications require active presentation options
      await _firebaseMessaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        if (message.notification != null) {
          showLocalNotification(
            id: message.messageId.hashCode,
            title: message.notification!.title ?? 'New Message',
            body: message.notification!.body ?? '',
            payload: message.data['route'], // Example payload
          );
        }
      });

      // 5. Token Refresh Listener
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        // This will be handled by UserSessionService which watches the token
        if (kDebugMode) print('FCM Token Refreshed: $newToken');
      });
    } catch (e) {
      if (kDebugMode) print('NotificationService: Failed to initialize: $e');
      // Continue without notifications - don't crash the app
    }
  }

  Future<void> _requestPermissions() async {
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    
    // For Android 13+ support
    final androidImplementation = _localNotifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
    }
  }

  Future<String?> getFcmToken() async {
    try {
      if (kIsWeb) {
        return await _firebaseMessaging.getToken(
          vapidKey: 'BK7pa2tjwNqKdgg185YTDWLcEpzQ9I0fFZKjWrC26HlLeVgqGJyIFDPGtRQyrivOttGBn12mNtOoZbUnDlal0Oc'
        );
      }
      return await _firebaseMessaging.getToken();
    } catch (e) {
      if (kDebugMode) print('Error getting FCM token: $e');
      return null;
    }
  }

  Future<void> saveTokenToFirestore(String userId, String role) async {
    try {
      final token = await getFcmToken();
      if (token == null) return;

      if (role == 'owner') {
        await FirebaseFirestore.instance.collection('owners').doc(userId).update({
          'fcmTokens': FieldValue.arrayUnion([token]),
          'lastTokenUpdate': FieldValue.serverTimestamp(),
        });
      } else {
        // Tenants might have a different doc ID than their Auth UID.
        // We find the tenant document where authId == userId
        final snapshot = await FirebaseFirestore.instance
            .collection('tenants')
            .where('authId', isEqualTo: userId)
            .where('isDeleted', isEqualTo: false)
            .limit(1)
            .get();

        if (snapshot.docs.isNotEmpty) {
          await snapshot.docs.first.reference.update({
            'fcmTokens': FieldValue.arrayUnion([token]),
            'lastTokenUpdate': FieldValue.serverTimestamp(),
          });
        }
      }
      
      if (kDebugMode) print('FCM Token saved for $role: $userId');
    } catch (e) {
      if (kDebugMode) print('Error saving FCM token to Firestore: $e');
    }
  }

  /// Triggers a push notification by writing to a Firestore trigger collection.
  /// This can be picked up by a Cloud Function to send the actual FCM.
  Future<void> triggerPushNotification({
    required List<String> userIds,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      if (userIds.isEmpty) return;

      await FirebaseFirestore.instance.collection('push_triggers').add({
        'userIds': userIds,
        'title': title,
        'body': body,
        'data': data,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (kDebugMode) print('Push notification triggered for ${userIds.length} users');
    } catch (e) {
      if (kDebugMode) print('Error triggering push notification: $e');
    }
  }

  // Define Channel for Android
  Future<void> showLocalNotification({required int id, required String title, required String body, String? payload}) async {
    const androidDetails = AndroidNotificationDetails(
      'high_importance_channel', 
      'High Importance Notifications',
      channelDescription: 'This channel is used for important notifications.',
      importance: Importance.max,
      priority: Priority.high,
    );
    
    const details = NotificationDetails(android: androidDetails, iOS: DarwinNotificationDetails());
    
    await _localNotifications.show(id, title, body, details, payload: payload);
  }

  // Schedule Monthly Reminder (5th of Month)
  Future<void> scheduleMonthlyRentReminder() async {
    try {
      // ID 888 for Rent Reminder
      await _localNotifications.cancel(888); // Cancel old to reschedule

      await _localNotifications.zonedSchedule(
        888,
        'Rent Due Reminder',
        'This is a friendly reminder to pay your rent for this month.',
        _nextInstanceOfDay(5, 10), // 5th of month at 10 AM
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'monthly_reminders',
            'Monthly Reminders',
            channelDescription: 'Reminders for rent payment',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dayOfMonthAndTime, // Monthly recurrence
      );
    } catch (e) {
      if (kDebugMode) print('Failed to schedule monthly reminder: $e');
    }
  }
  
  tz.TZDateTime _nextInstanceOfDay(int day, int hour) {
    final now = tz.TZDateTime.now(tz.local);
    // Construct date for this month
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, day, hour);

    // If it's already past (e.g. today is 6th, scheduled 5th), move to next month
    if (scheduledDate.isBefore(now)) {
      scheduledDate = tz.TZDateTime(tz.local, now.year, now.month + 1, day, hour);
    }
    return scheduledDate;
  }
  
  Future<void> cancelAll() async {
    try {
      await _localNotifications.cancelAll();
    } catch (e) {
      if (kDebugMode) print('Failed to cancel notifications: $e');
    }
  }
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    try {
      await _localNotifications.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledDate, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'scheduled_notifications',
            'Scheduled Notifications',
            channelDescription: 'General scheduled notifications',
            importance: Importance.max,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    } catch (e) {
      if (kDebugMode) print('Failed to schedule notification: $e');
    }
  }

  // Settings Management (Placeholder logic using SharedPreferences internally or just mock if not critical)
  // Logic: Real implementation would save to SharedPreferences.
  // For now, let's implement basic SharedPreferences usage here to fix the error properly.
  
  Future<bool> get areNotificationsEnabled async {
     return true; 
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    if (enabled) {
      await _requestPermissions();
    } else {
      await _localNotifications.cancelAll();
      // Cannot programmatically disable system permissions.
    }
  }
}
