import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:flutter_timezone/flutter_timezone.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  @visibleForTesting
  NotificationService.test();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    // Initialize timezone database
    tzdata.initializeTimeZones();
    String timeZoneName;
    try {
      final timeZoneInfo = await FlutterTimezone.getLocalTimezone();
      timeZoneName = timeZoneInfo.identifier;
    } catch (error, stackTrace) {
      _logFailure('Read local time zone', error, stackTrace);
      timeZoneName = 'UTC';
    }
    tz.setLocalLocation(tz.getLocation(timeZoneName));

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const initSettings = InitializationSettings(android: androidSettings);

    try {
      await _notifications.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: (_) {},
      );
      _initialized = true;
    } catch (error, stackTrace) {
      _logFailure('Initialize notifications', error, stackTrace);
    }
  }

  Future<void> requestPermissions() async {
    try {
      await _notifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
    } catch (error, stackTrace) {
      _logFailure('Request notification permissions', error, stackTrace);
    }
  }

  Future<void> showRestTimerFinished({
    required String title,
    required String body,
  }) async {
    if (!_initialized) return;
    try {
      const androidDetails = AndroidNotificationDetails(
        'rest_timer_channel',
        'Rest Timer Notifications',
        channelDescription:
            'Alerts when rest timer finishes during a workout session',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
      );
      const notificationDetails = NotificationDetails(android: androidDetails);

      await _notifications.show(
        id: 999,
        title: title,
        body: body,
        notificationDetails: notificationDetails,
      );
    } catch (error, stackTrace) {
      _logFailure('Show rest timer notification', error, stackTrace);
    }
  }

  Future<void> showInstantReminder({
    required String title,
    required String body,
  }) async {
    if (!_initialized) return;
    try {
      const androidDetails = AndroidNotificationDetails(
        'workout_reminder_channel',
        'Workout Reminders',
        channelDescription: 'Reminders to start your scheduled workout',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
      );
      const notificationDetails = NotificationDetails(android: androidDetails);

      await _notifications.show(
        id: 1001,
        title: title,
        body: body,
        notificationDetails: notificationDetails,
      );
    } catch (error, stackTrace) {
      _logFailure('Show workout reminder', error, stackTrace);
    }
  }

  /// Schedule weekly workout reminders for specified days and time.
  /// Each day gets a unique notification ID (baseId + dayOfWeek).
  /// dayOfWeek: 1 = Monday ... 7 = Sunday
  Future<void> scheduleWorkoutReminders({
    required List<int> daysOfWeek,
    required int hour,
    required int minute,
    String title = 'Time to workout 💪',
    String body = 'Your scheduled workout is waiting!',
  }) async {
    if (!_initialized) return;

    // Cancel existing reminders first
    await cancelWorkoutReminders();

    const androidDetails = AndroidNotificationDetails(
      'workout_reminder_channel',
      'Workout Reminders',
      channelDescription: 'Reminders to start your scheduled workout',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
    );
    const notificationDetails = NotificationDetails(android: androidDetails);

    final now = tz.TZDateTime.now(tz.local);
    const baseId = 1000;

    for (final dayOfWeek in daysOfWeek) {
      // Calculate the next occurrence of this day
      tz.TZDateTime scheduledDate = _nextInstanceOfDay(
        dayOfWeek: dayOfWeek,
        hour: hour,
        minute: minute,
        from: now,
      );

      // If the calculated time is in the past, add 7 days
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 7));
      }

      final notificationId = baseId + dayOfWeek;

      try {
        await _notifications.zonedSchedule(
          id: notificationId,
          title: title,
          body: body,
          scheduledDate: scheduledDate,
          notificationDetails: notificationDetails,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        );
      } catch (error, stackTrace) {
        _logFailure(
          'Schedule workout reminder for day $dayOfWeek',
          error,
          stackTrace,
        );
      }
    }
  }

  /// Calculate the next TZDateTime for a given day of week and time
  tz.TZDateTime _nextInstanceOfDay({
    required int dayOfWeek, // 1 = Monday ... 7 = Sunday
    required int hour,
    required int minute,
    required tz.TZDateTime from,
  }) {
    // Dart: DateTime.weekday: 1=Mon ... 7=Sun
    int daysToAdd = dayOfWeek - from.weekday;
    if (daysToAdd < 0) {
      daysToAdd += 7;
    }
    if (daysToAdd == 0) {
      // Same day - check if time has passed
      final todayAtTime = tz.TZDateTime(
        tz.local,
        from.year,
        from.month,
        from.day,
        hour,
        minute,
      );
      if (todayAtTime.isBefore(from)) {
        daysToAdd = 7;
      }
    }

    return tz.TZDateTime(
      tz.local,
      from.year,
      from.month,
      from.day,
      hour,
      minute,
    ).add(Duration(days: daysToAdd));
  }

  /// Cancel all workout reminder notifications (IDs 1001-1007)
  Future<void> cancelWorkoutReminders() async {
    if (!_initialized) return;
    try {
      for (int id = 1001; id <= 1007; id++) {
        await _notifications.cancel(id: id);
      }
    } catch (error, stackTrace) {
      _logFailure('Cancel workout reminders', error, stackTrace);
    }
  }

  Future<void> cancelAll() async {
    if (!_initialized) return;
    try {
      await _notifications.cancelAll();
    } catch (error, stackTrace) {
      _logFailure('Cancel all notifications', error, stackTrace);
    }
  }

  /// Schedule a rest timer notification at a specific time (in milliseconds since epoch UTC)
  Future<void> scheduleRestTimerAt({
    required int notificationId,
    required int endAtMillis,
    required String title,
    required String body,
  }) async {
    if (!_initialized) return;
    try {
      const androidDetails = AndroidNotificationDetails(
        'rest_timer_channel',
        'Rest Timer Notifications',
        channelDescription:
            'Alerts when rest timer finishes during a workout session',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
      );
      const notificationDetails = NotificationDetails(android: androidDetails);

      final scheduledDate = tz.TZDateTime.fromMillisecondsSinceEpoch(
        tz.local,
        endAtMillis,
      );

      await _notifications.zonedSchedule(
        id: notificationId,
        title: title,
        body: body,
        scheduledDate: scheduledDate,
        notificationDetails: notificationDetails,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    } catch (error, stackTrace) {
      _logFailure('Schedule rest timer notification', error, stackTrace);
    }
  }

  /// Cancel a specific notification by ID
  Future<void> cancel(int notificationId) async {
    if (!_initialized) return;
    try {
      await _notifications.cancel(id: notificationId);
    } catch (error, stackTrace) {
      _logFailure('Cancel notification $notificationId', error, stackTrace);
    }
  }

  void _logFailure(String operation, Object error, StackTrace stackTrace) {
    if (kDebugMode) debugPrint('$operation failed: $error\n$stackTrace');
  }
}
