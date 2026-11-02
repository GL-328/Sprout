import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../domain/logic/reminders.dart';

/// Schedules reminders and garden notifications. Swappable so tests don't
/// touch the platform.
abstract class ReminderScheduler {
  /// Asks for permission to show notifications. Returns whether it's allowed.
  Future<bool> requestPermission();

  /// Replaces all repeating reminders (check-in, quests) with [plans].
  Future<void> replaceAll(List<ReminderPlan> plans);

  /// Replaces all one-off garden notifications with [notices].
  Future<void> replaceGarden(List<GardenNotice> notices);

  /// Shows a sample notification after [delay] (straight away for zero), for
  /// trying notifications out in the dev account.
  Future<void> test(GardenNotice sample, {Duration delay = Duration.zero});
}

class NoopReminderScheduler implements ReminderScheduler {
  const NoopReminderScheduler();

  @override
  Future<bool> requestPermission() async => true;

  @override
  Future<void> replaceAll(List<ReminderPlan> plans) async {}

  @override
  Future<void> replaceGarden(List<GardenNotice> notices) async {}

  @override
  Future<void> test(GardenNotice sample, {Duration delay = Duration.zero}) async {}
}

/// Reminders below this id, garden notices from [gardenNoticeBaseId] up to
/// here, and dev test notifications from here up.
const testNoticeBaseId = 9000;

class LocalNotificationScheduler implements ReminderScheduler {
  final _plugin = FlutterLocalNotificationsPlugin();
  Future<void>? _ready;

  // High importance: Android shows these as pop-ups on top of other apps.
  // (A channel's importance can't change once made, hence the new ids.)
  static const _reminders = NotificationDetails(
    android: AndroidNotificationDetails(
      'sprout_reminders',
      'Reminders',
      channelDescription: 'Your daily check-in and the quest reminders you chose',
      importance: Importance.high,
      priority: Priority.high,
      icon: 'ic_stat_sprout',
    ),
  );

  static const _garden = NotificationDetails(
    android: AndroidNotificationDetails(
      'sprout_garden',
      'Garden',
      channelDescription: 'Fruit ready to pick and plants fully grown',
      importance: Importance.high,
      priority: Priority.high,
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
    // The old quiet channel, replaced by the pop-up ones above.
    final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await android?.deleteNotificationChannel(channelId: 'gentle_reminders').catchError((Object _) {});
  }();

  @override
  Future<bool> requestPermission() async {
    await _init();
    final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    return await android?.requestNotificationsPermission() ?? true;
  }

  /// Cancels the pending notifications with ids in [from]..[to).
  Future<void> _cancelRange(int from, int to) async {
    for (final p in await _plugin.pendingNotificationRequests()) {
      if (p.id >= from && p.id < to) await _plugin.cancel(id: p.id);
    }
  }

  @override
  Future<void> replaceAll(List<ReminderPlan> plans) async {
    await _init();
    await _cancelRange(0, gardenNoticeBaseId);
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
        notificationDetails: _reminders,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: p.weekday == null ? DateTimeComponents.time : DateTimeComponents.dayOfWeekAndTime,
      );
    }
  }

  @override
  Future<void> replaceGarden(List<GardenNotice> notices) async {
    await _init();
    await _cancelRange(gardenNoticeBaseId, testNoticeBaseId);
    final now = DateTime.now();
    for (final n in notices) {
      if (!n.at.isAfter(now)) continue;
      await _plugin.zonedSchedule(
        id: n.id,
        title: n.title,
        body: n.body,
        scheduledDate: tz.TZDateTime.from(n.at, tz.local),
        notificationDetails: _garden,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
  }

  @override
  Future<void> test(GardenNotice sample, {Duration delay = Duration.zero}) async {
    await _init();
    final details = sample.id == testNoticeBaseId ? _reminders : _garden;
    if (delay <= Duration.zero) {
      await _plugin.show(id: sample.id, title: sample.title, body: sample.body, notificationDetails: details);
      return;
    }
    await _plugin.zonedSchedule(
      id: sample.id,
      title: sample.title,
      body: sample.body,
      scheduledDate: tz.TZDateTime.now(tz.local).add(delay),
      notificationDetails: details,
      // Exact-ish timing isn't promised without the exact-alarm permission;
      // inexact on an idle phone can be a little late, which is fine here.
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }
}
