import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static const int _dailyReminderId = 1; // Daily reminder
  static const int _completionId = 2;

  static Future<void> init() async {
    tz_data.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // ✅ FIX: initialize() now uses named parameters
    await _notifications.initialize(settings: initSettings);
  }

  // Daily reminder at specific time
  static Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) async {
    // ✅ FIX: zonedSchedule() now uses named parameters
    await _notifications.zonedSchedule(
      id: _dailyReminderId,
      title: title,
      body: body,
      scheduledDate: _nextInstanceOfTime(hour, minute),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_dhikr',
          'Daily Dhikr Reminders',
          channelDescription: 'Reminders for daily dhikr',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  // Instant notification
  static Future<void> showNotification({
    required String title,
    required String body,
  }) async {
    // ✅ FIX: show() now uses named parameters
    await _notifications.show(
      id: _completionId,
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'dhikr_alerts',
          'Dhikr Alerts',
          channelDescription: 'Instant dhikr notifications',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  // Cancel all
  static Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }

  // Cancel only daily reminder (keep completion notifications)
  static Future<void> cancelDailyReminder() async {
    var active = await isNotificationActive(1);

    await _notifications.cancel(id: 1);
  }

  static tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  static Future<bool> isNotificationActive(int id) async {
    final List<ActiveNotification> activeNotifications = await _notifications
        .getActiveNotifications();

    return activeNotifications.any((notification) => notification.id == id);
  }

  static Future<bool> requestExactAlarmsPermission() async {
    // Resolve the platform-specific implementation for Android
    final androidImplementation = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidImplementation != null) {
      // Prompt the user for the exact alarm permission
      final bool? hasPermission = await androidImplementation
          .requestExactAlarmsPermission();
      return hasPermission ?? false;
    }

    // Return true on iOS/non-Android devices as they don't require this permission
    return true;
  }
}
