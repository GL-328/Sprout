import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';

import '../features/home/garden_providers.dart';
import '../features/today/today_providers.dart';
import 'accounts.dart';
import 'providers.dart';

/// What the two home-screen widgets (Today and Mood) show. Written by the
/// app, read by the Android widgets in `android/.../TodayWidgetProvider.kt`
/// and `MoodWidgetProvider.kt`.
@immutable
class WidgetSnapshot {
  const WidgetSnapshot({
    required this.day,
    required this.meterFilled,
    required this.meterGoal,
    required this.nextQuests,
    required this.questsLeft,
    required this.questsDone,
    required this.mood,
  });

  /// The day this was written (`yyyy-mm-dd`). The widgets ignore the quests
  /// and mood once the date has moved on.
  final String day;
  final int meterFilled;
  final int meterGoal;

  /// Up to two quests still to do today.
  final List<String> nextQuests;
  final int questsLeft;
  final int questsDone;

  /// Today's mood, 1 to 5, or 0 if not set yet.
  final int mood;

  /// The key/value pairs the Android widgets read.
  Map<String, Object> toData() => {
    'day': day,
    'meter_filled': meterFilled,
    'meter_goal': meterGoal,
    'quest_1': nextQuests.isNotEmpty ? nextQuests[0] : '',
    'quest_2': nextQuests.length > 1 ? nextQuests[1] : '',
    'quests_left': questsLeft,
    'quests_done': questsDone,
    'mood': mood,
  };

  @override
  bool operator ==(Object other) => other is WidgetSnapshot && mapEquals(other.toData(), toData());

  @override
  int get hashCode => Object.hashAll(toData().values);
}

/// Writes widget data and passes on widget taps. Swappable so tests don't
/// touch the platform.
abstract class HomeWidgetBridge {
  Future<void> write(WidgetSnapshot snapshot);

  /// The tap that opened the app from a widget, if any.
  Future<Uri?> launchedFrom();

  /// Taps on a widget while the app is already running.
  Stream<Uri?> get taps;
}

class NoopHomeWidgetBridge implements HomeWidgetBridge {
  const NoopHomeWidgetBridge();

  @override
  Future<void> write(WidgetSnapshot snapshot) async {}

  @override
  Future<Uri?> launchedFrom() async => null;

  @override
  Stream<Uri?> get taps => const Stream.empty();
}

class PlatformHomeWidgetBridge implements HomeWidgetBridge {
  static const _today = 'app.sprout.sprout.TodayWidgetProvider';
  static const _mood = 'app.sprout.sprout.MoodWidgetProvider';

  @override
  Future<void> write(WidgetSnapshot snapshot) async {
    try {
      for (final e in snapshot.toData().entries) {
        await HomeWidget.saveWidgetData<Object>(e.key, e.value);
      }
      await HomeWidget.updateWidget(qualifiedAndroidName: _today);
      await HomeWidget.updateWidget(qualifiedAndroidName: _mood);
    } catch (e) {
      debugPrint('Home widgets not updated: $e');
    }
  }

  @override
  Future<Uri?> launchedFrom() async {
    try {
      return await HomeWidget.initiallyLaunchedFromHomeWidget();
    } catch (_) {
      return null;
    }
  }

  @override
  Stream<Uri?> get taps => HomeWidget.widgetClicked;
}

final homeWidgetBridgeProvider = Provider<HomeWidgetBridge>((ref) => PlatformHomeWidgetBridge());

/// The widgets' data for the open garden, or null while it's loading.
final widgetSnapshotProvider = Provider<WidgetSnapshot?>((ref) {
  final view = ref.watch(todayViewProvider);
  final meter = ref.watch(meterProvider);
  final mood = ref.watch(todayMoodProvider);
  if (!view.hasValue || !meter.hasValue || mood.isLoading) return null;
  final v = view.requireValue;
  final m = meter.requireValue;
  final open = [...v.todo, ...v.later];
  return WidgetSnapshot(
    day: ref.watch(todayKeyProvider),
    meterFilled: m.filled,
    meterGoal: m.questsPerSeed,
    nextQuests: [for (final q in open.take(2)) q.title],
    questsLeft: open.length,
    questsDone: v.done.length,
    mood: mood.value?.value ?? 0,
  );
});

/// Keeps the widgets up to date with the owner's own garden (listened to by
/// the app). The dev account never writes to them on its own; its Settings
/// card has a button for that.
final homeWidgetSyncProvider = Provider<void>((ref) {
  if (ref.watch(activeAccountProvider) == Account.dev) return;
  final snapshot = ref.watch(widgetSnapshotProvider);
  if (snapshot != null) unawaited(ref.read(homeWidgetBridgeProvider).write(snapshot));
});

/// Where a widget tap should take you.
sealed class WidgetLink {
  const WidgetLink();

  /// Reads `sprout://today` and `sprout://mood?value=N`; anything else is
  /// ignored.
  static WidgetLink? parse(Uri? uri) {
    if (uri == null || uri.scheme != 'sprout') return null;
    return switch (uri.host) {
      'today' => const TodayLink(),
      'mood' => MoodLink(switch (int.tryParse(uri.queryParameters['value'] ?? '')) {
        final v? when v >= 1 && v <= 5 => v,
        _ => null,
      }),
      _ => null,
    };
  }
}

class TodayLink extends WidgetLink {
  const TodayLink();
}

class MoodLink extends WidgetLink {
  const MoodLink(this.mood);

  /// The face tapped, or null to just open the mood picker.
  final int? mood;
}

/// The launch tap is handled once per app run, not again each time the
/// accounts swap and the app is rebuilt.
bool _launchHandled = false;

/// Calls [onLink] for the widget tap that opened the app (once), and for
/// every widget tap after that until the returned subscription is cancelled.
StreamSubscription<Uri?> listenForWidgetLinks(HomeWidgetBridge bridge, void Function(WidgetLink link) onLink) {
  if (!_launchHandled) {
    _launchHandled = true;
    unawaited(
      bridge.launchedFrom().then((uri) {
        final link = WidgetLink.parse(uri);
        if (link != null) onLink(link);
      }),
    );
  }
  return bridge.taps.listen((uri) {
    final link = WidgetLink.parse(uri);
    if (link != null) onLink(link);
  });
}

/// For tests: forget that the launch tap was handled.
@visibleForTesting
void resetWidgetLaunchForTest() => _launchHandled = false;
