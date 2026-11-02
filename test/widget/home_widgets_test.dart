import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprout/app.dart';
import 'package:sprout/core/accounts.dart';
import 'package:sprout/core/clock.dart';
import 'package:sprout/core/home_widgets.dart';
import 'package:sprout/core/notifications_service.dart';
import 'package:sprout/core/providers.dart';
import 'package:sprout/core/sound_service.dart';
import 'package:sprout/core/updater.dart';
import 'package:sprout/data/db/app_database.dart';
import 'package:sprout/data/repositories/quest_repository.dart';
import 'package:sprout/data/repositories/seed_repository.dart';
import 'package:sprout/data/repositories/wellbeing_repository.dart';
import 'package:sprout/domain/models/app_settings.dart';
import 'package:sprout/domain/models/enums.dart';
import 'package:sprout/features/today/today_screen.dart';

import 'test_app.dart';

class _FakeBridge implements HomeWidgetBridge {
  final written = <WidgetSnapshot>[];
  final tapController = StreamController<Uri?>.broadcast();
  Uri? launch;

  @override
  Future<void> write(WidgetSnapshot snapshot) async => written.add(snapshot);

  @override
  Future<Uri?> launchedFrom() async => launch;

  @override
  Stream<Uri?> get taps => tapController.stream;
}

void main() {
  setUp(resetWidgetLaunchForTest);

  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 3; i++) {
      await tester.pumpAndSettle();
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
    }
    await tester.pumpAndSettle();
  }

  Future<AppDatabase> seeded(WidgetTester tester, {int? mood}) async {
    final db = memoryDb();
    addTearDown(db.close);
    await tester.runAsync(() async {
      await SeedRepository(db, const Clock()).ensurePlot('meadow');
      final quests = QuestRepository(db, const Clock());
      for (final t in ['Drink a glass of water', 'Stretch for two minutes', 'Text a friend']) {
        await quests.create(title: t, category: QuestCategory.movement, difficulty: Difficulty.small);
      }
      if (mood != null) await WellbeingRepository(db, const Clock()).setMood(dayKey(DateTime.now()), mood, '');
    });
    return db;
  }

  Widget app(AppDatabase db, _FakeBridge bridge, {Account account = Account.main}) => ProviderScope(
    overrides: [
      gameConfigProvider.overrideWithValue(testConfig),
      databaseProvider.overrideWithValue(db),
      initialSettingsProvider.overrideWithValue(const AppSettings(onboardingDone: true, reducedMotion: true)),
      reminderSchedulerProvider.overrideWithValue(const NoopReminderScheduler()),
      soundServiceProvider.overrideWithValue(const SilentSoundService()),
      updaterProvider.overrideWithValue(const NoopUpdater()),
      homeWidgetBridgeProvider.overrideWithValue(bridge),
      activeAccountProvider.overrideWithValue(account),
    ],
    child: const SproutApp(),
  );

  test('widget links', () {
    expect(WidgetLink.parse(Uri.parse('sprout://today')), isA<TodayLink>());
    expect((WidgetLink.parse(Uri.parse('sprout://mood?value=4'))! as MoodLink).mood, 4);
    expect((WidgetLink.parse(Uri.parse('sprout://mood'))! as MoodLink).mood, isNull);
    expect((WidgetLink.parse(Uri.parse('sprout://mood?value=9'))! as MoodLink).mood, isNull);
    expect(WidgetLink.parse(Uri.parse('https://example.com/today')), isNull);
    expect(WidgetLink.parse(null), isNull);
  });

  testWidgets("the widgets get today's quests, the meter and the mood", (tester) async {
    final db = await seeded(tester, mood: 4);
    final bridge = _FakeBridge();
    await tester.pumpWidget(app(db, bridge));
    await settle(tester);

    expect(bridge.written, isNotEmpty);
    final data = bridge.written.last.toData();
    expect(data['day'], dayKey(DateTime.now()));
    expect(data['quests_left'], 3);
    expect(data['quests_done'], 0);
    expect(data['quest_1'], isNotEmpty);
    expect(data['quest_2'], isNotEmpty);
    expect(data['quest_1'], isNot(data['quest_2']));
    expect(data['meter_goal'], testConfig.questsPerSeed);
    expect(data['mood'], 4);
  });

  testWidgets('the dev account leaves the widgets alone', (tester) async {
    final db = await seeded(tester);
    final bridge = _FakeBridge();
    await tester.pumpWidget(app(db, bridge, account: Account.dev));
    await settle(tester);
    expect(bridge.written, isEmpty);
  });

  testWidgets('tapping a face on the widget opens the mood picker with it chosen', (tester) async {
    final db = await seeded(tester);
    final bridge = _FakeBridge()..launch = Uri.parse('sprout://mood?value=4');
    await tester.pumpWidget(app(db, bridge));
    await settle(tester);
    expect(find.text('How are you feeling?'), findsWidgets);
    expect(find.text('Good'), findsOneWidget, reason: 'face 4 is picked');
    expect(find.text('Save check-in'), findsOneWidget);
  });

  testWidgets('tapping the Today widget opens Today', (tester) async {
    final db = await seeded(tester);
    final bridge = _FakeBridge();
    await tester.pumpWidget(app(db, bridge));
    await settle(tester);
    expect(find.byType(TodayScreen), findsNothing);
    bridge.tapController.add(Uri.parse('sprout://today'));
    await settle(tester);
    expect(find.byType(TodayScreen), findsOneWidget);
  });
}
