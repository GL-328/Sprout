import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprout/core/clock.dart';
import 'package:sprout/data/db/app_database.dart';
import 'package:sprout/data/repositories/quest_repository.dart';
import 'package:sprout/data/repositories/seed_repository.dart';
import 'package:sprout/data/repositories/settings_repository.dart';
import 'package:sprout/domain/models/app_settings.dart';
import 'package:sprout/domain/models/enums.dart';
import 'package:sprout/domain/models/quest.dart';

import 'test_app.dart';

Future<List<Quest>> activeQuests(WidgetTester tester, AppDatabase db) async {
  final all = await tester.runAsync(() => QuestRepository(db, const Clock()).watchQuests().first);
  return [
    for (final q in all!)
      if (!q.archived && q.showOnToday) q,
  ];
}

/// Walks through onboarding, picking [pick] in the quest picker.
Future<void> onboard(WidgetTester tester, {List<String> pick = const []}) async {
  await tester.tap(find.text("Let's begin"));
  await tester.pumpAndSettle();
  await tester.enterText(find.byType(TextField), 'Robin');
  await tester.tap(find.text('Next'));
  await tester.pumpAndSettle();

  expect(find.text('Pick your daily quests'), findsOneWidget);
  for (final title in pick) {
    final card = find.bySemanticsLabel(title);
    await tester.scrollUntilVisible(card, 200, scrollable: find.byType(Scrollable).last);
    await tester.pumpAndSettle();
    await tester.ensureVisible(card);
    await tester.pumpAndSettle();
    await tester.tap(card);
    await tester.pump();
  }
  await tester.tap(find.textContaining('Continue'));
  await tester.pumpAndSettle();

  await tester.tap(find.text('Next'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Plant it'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('a new install starts with no quests when none are picked', (tester) async {
    final db = memoryDb();
    addTearDown(db.close);
    await tester.pumpWidget(testApp(db));
    await tester.pumpAndSettle();

    expect(find.text('Welcome to Sprout'), findsOneWidget);
    await onboard(tester);

    expect(find.textContaining('Robin'), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('Giant sunflower')), findsOneWidget, reason: 'first seed is planted');
    expect(await activeQuests(tester, db), isEmpty, reason: 'nothing may be chosen for the user');
    expect(find.text('Add a quest'), findsOneWidget, reason: 'the friendly empty state');
    expect(find.textContaining('Add a quest" below'), findsOneWidget, reason: 'the tutorial points to it');

    await tester.tap(find.text('Today').last);
    await tester.pumpAndSettle();
    expect(find.text('Nothing planned yet.'), findsOneWidget);
    expect(find.text('Add a quest'), findsOneWidget);

    final saved = await tester.runAsync(() => SettingsRepository(db).load());
    expect(saved!.onboardingDone, isTrue);
    expect(saved.name, 'Robin');
  });

  testWidgets('exactly the picked quests become daily quests', (tester) async {
    final db = memoryDb();
    addTearDown(db.close);
    await tester.pumpWidget(testApp(db));
    await tester.pumpAndSettle();

    await onboard(tester, pick: ['Wind-down moment', 'Drink a glass of water']);

    final active = await activeQuests(tester, db);
    expect(active.map((q) => q.title).toSet(), {'Wind-down moment', 'Drink a glass of water'});
    expect(active.every((q) => q.repeat == RepeatKind.daily), isTrue);
  });

  testWidgets('"Show first" sorts the list but never picks anything', (tester) async {
    final db = memoryDb();
    addTearDown(db.close);
    await tester.pumpWidget(testApp(db));
    await tester.pumpAndSettle();
    await tester.tap(find.text("Let's begin"));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilterChip, 'Study/Work'));
    await tester.pumpAndSettle();
    expect(find.text('Continue'), findsOneWidget, reason: 'still nothing picked');
    // The Study/Work section (after the chips) is now the first one, near the
    // top; before, it was the last section, far down the list.
    expect(find.text('Study/Work'), findsNWidgets(2), reason: 'its chip and its section heading');
    final section = tester.getTopLeft(find.text('Study/Work').last).dy;
    expect(section, lessThan(400), reason: 'chosen categories come first');
    final sleepCard = find.bySemanticsLabel('Screens off before bed');
    if (sleepCard.evaluate().isNotEmpty) {
      expect(tester.getTopLeft(sleepCard).dy, greaterThan(section), reason: 'Sleep now comes after Study/Work');
    }
  });

  testWidgets('every onboarding step can be skipped', (tester) async {
    final db = memoryDb();
    addTearDown(db.close);
    await tester.pumpWidget(testApp(db));
    await tester.pumpAndSettle();

    for (var i = 0; i < 5; i++) {
      await tester.tap(find.text('Skip').first);
      await tester.pumpAndSettle();
    }
    expect(find.text('Home'), findsOneWidget);
    expect(await activeQuests(tester, db), isEmpty);
  });

  testWidgets('existing saves keep their quests exactly as they are', (tester) async {
    final db = memoryDb();
    addTearDown(db.close);
    final before = await tester.runAsync(() async {
      await SeedRepository(db, const Clock()).ensurePlot('meadow');
      final quests = QuestRepository(db, const Clock());
      await quests.create(title: 'Feed the cat', category: QuestCategory.home, difficulty: Difficulty.small);
      await quests.create(title: 'Evening walk', category: QuestCategory.movement, difficulty: Difficulty.medium);
      return quests.watchQuests().first;
    });
    await tester.pumpWidget(testApp(db, settings: const AppSettings(onboardingDone: true, reducedMotion: true)));
    await tester.pumpAndSettle();
    expect(find.text('Welcome to Sprout'), findsNothing);

    final after = await tester.runAsync(() => QuestRepository(db, const Clock()).watchQuests().first);
    expect(
      [for (final q in after!) (q.id, q.title, q.showOnToday, q.archived)],
      [for (final q in before!) (q.id, q.title, q.showOnToday, q.archived)],
    );
  });

  testWidgets('returning users go straight to the garden and can switch tabs', (tester) async {
    final db = memoryDb();
    addTearDown(db.close);
    await tester.runAsync(() => SeedRepository(db, const Clock()).ensurePlot('meadow'));
    await tester.pumpWidget(testApp(db, settings: const AppSettings(onboardingDone: true, reducedMotion: true)));
    await tester.pumpAndSettle();

    expect(find.text('Welcome to Sprout'), findsNothing);
    for (final tab in ['Today', 'Journal', 'Shop', 'Settings', 'Home']) {
      await tester.tap(find.text(tab).last);
      await tester.pumpAndSettle();
    }
    expect(find.bySemanticsLabel(RegExp('Change plot, now Meadow')), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('Empty spot')), findsWidgets);
    expect(find.text("Today's quests"), findsOneWidget);
  });

  // Every setup step keeps its main button on screen, without scrolling.
  for (final (name, size, scale) in [
    ('360x640', const Size(360, 640), 1.0),
    ('360x640 at 130% text', const Size(360, 640), 1.3),
    ('360x640 at 150% text', const Size(360, 640), 1.5),
    ('landscape', const Size(640, 360), 1.0),
  ]) {
    testWidgets('setup buttons are pinned and visible, $name', (tester) async {
      tester.view.devicePixelRatio = 2;
      tester.view.physicalSize = size * 2;
      tester.view.viewPadding = const FakeViewPadding(top: 48, bottom: 96);
      tester.view.padding = const FakeViewPadding(top: 48, bottom: 96);
      tester.platformDispatcher.textScaleFactorTestValue = scale;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      final db = memoryDb();
      addTearDown(db.close);
      await tester.pumpWidget(testApp(db));
      await tester.pumpAndSettle();

      final limit = size.height - 48;
      void visible(String label) {
        final f = find.text(label);
        expect(f, findsOneWidget, reason: '$label on screen');
        final r = tester.getRect(f);
        expect(r.top, greaterThanOrEqualTo(0), reason: '$label not above the screen');
        expect(r.bottom, lessThanOrEqualTo(limit), reason: '$label clear of the system bar ($r)');
        expect(tester.takeException(), isNull, reason: 'no overflow on the $label step');
      }

      for (final (button, goes) in [
        ("Let's begin", true),
        ('Next', true),
        ('Continue', false),
        ("Skip, I'll add some later", true),
        ('Next', true),
        ('Plant it', false),
      ]) {
        visible(button);
        if (goes) {
          await tester.tap(find.text(button));
          await tester.pumpAndSettle();
        }
      }
    });
  }
}
