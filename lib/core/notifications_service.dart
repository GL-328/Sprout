import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../domain/logic/reminders.dart';

/// Schedules gentle reminders. Swappable so tests don't touch the platform.
abstract class ReminderScheduler {
  /// Asks for permission to show notifications. Returns whether it's allowed.
  Future<bool> requestPermission();

  /// Replaces all scheduled reminders with [plans].
  Future<void> replaceAll(List<ReminderPlan> plans);
}

class NoopReminderScheduler implements ReminderScheduler {
  const NoopReminderScheduler();

  @override
  Future<bool> requestPermission() async => true;

  @override
  Future<void> replaceAll(List<ReminderPlan> plans) async {}
}

class LocalNotificationScheduler implements ReminderScheduler {
  final _plugin = FlutterLocalNotificationsPlugin();
  Future<void>? _ready;

  static const _details = NotificationDetails(
    android: AndroidNotificationDetails(
      'gentle_reminders',
      'Gentle reminders',
      channelDescription: 'Soft nudges you chose in Sprout',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      icon: 'ic_stat_sprout',
    ),
  );

  Future<void> _init() => _ready ??= () async {
    tz_data.initializeTimeZones();
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } catch (e) {
      debugPrint('Could not read the time zone, using UTC: $e');
    }
    await _plugin.initialize(
      settings: const InitializationSettings(android: AndroidInitializationSettings('ic_stat_sprout')),
    );
  }();

  @override
  Future<bool> requestPermission() async {
    await _init();
    final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    return await android?.requestNotificationsPermission() ?? true;
  }

  @override
  Future<void> replaceAll(List<ReminderPlan> plans) async {
    await _init();
    await _plugin.cancelAll();
    final now = tz.TZDateTime.now(tz.local);
    for (final p in plans) {
      var when = tz.TZDateTime(tz.local, now.year, now.month, now.day, p.minutes ~/ 60, p.minutes % 60);
      if (p.weekday != null) {
        while (when.weekday != p.weekday || !when.isAfter(now)) {
          when = when.add(const Duration(days: 1));
        }
      } else if (!when.isAfter(now)) {
        when = when.add(const Duration(days: 1));
      }
      await _plugin.zonedSchedule(
        id: p.id,
        title: p.title,
        body: p.body,
        scheduledDate: when,
        notificationDetails: _details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: p.weekday == null ? DateTimeComponents.time : DateTimeComponents.dayOfWeekAndTime,
      );
    }
  }
}
