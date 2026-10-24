import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprout/core/clock.dart';
import 'package:sprout/data/repositories/counters_repository.dart';
import 'package:sprout/data/repositories/quest_repository.dart';
import 'package:sprout/data/repositories/seed_repository.dart';
import 'package:sprout/domain/models/app_settings.dart';
import 'package:sprout/domain/models/enums.dart';

import 'test_app.dart';

void main() {
  const settings = AppSettings(onboardingDone: true, reducedMotion: true);

  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 3; i++) {
      await tester.pumpAndSettle();
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
    }
    await tester.pumpAndSettle();
  }

  testWidgets('a quest can be completed from the Home quests panel', (tester) async {
    final db = memoryDb();
    addTearDown(db.close);
    await tester.runAsync(() async {
      await SeedRepository(db, const Clock()).ensurePlot('meadow');
      await QuestRepository(
        db,
        const Clock(),
      ).create(title: 'Stretch', category: QuestCategory.movement, difficulty: Difficulty.small);
    });
    await tester.pumpWidget(testApp(db, settings: settings));
    await settle(tester);

    expect(find.text("Today's quests"), findsOneWidget);
    expect(find.text('Stretch'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel(RegExp('Complete Stretch')));
    await settle(tester);

    expect(find.textContaining('1 of 3'), findsWidgets, reason: 'the Seed Meter in the panel moved on');
    expect(find.text('All done for today 🌷'), findsOneWidget);
    expect(find.text('Undo'), findsOneWidget);
  });

  testWidgets('arrows move between plant spots', (tester) async {
    final db = memoryDb();
    addTearDown(db.close);
    await tester.runAsync(() => SeedRepository(db, const Clock()).ensurePlot('meadow'));
    await tester.pumpWidget(testApp(db, settings: settings));
    await settle(tester);

    expect(find.byTooltip('Next plant'), findsOneWidget);
    await tester.tap(find.byTooltip('Next plant'));
    await settle(tester);
    await tester.tap(find.byTooltip('Next plant'));
    await settle(tester);
    // On the last spot the next arrow fades away and ignores taps.
    final arrow = tester.widget<AnimatedOpacity>(
      find.ancestor(of: find.byTooltip('Next plant'), matching: find.byType(AnimatedOpacity)),
    );
    expect(arrow.opacity, 0);
  });

  testWidgets('the Bag opens with seeds and fruit tabs', (tester) async {
    final db = memoryDb();
    addTearDown(db.close);
    await tester.runAsync(() => SeedRepository(db, const Clock()).ensurePlot('meadow'));
    await tester.pumpWidget(testApp(db, settings: settings));
    await settle(tester);

    await tester.tap(find.bySemanticsLabel(RegExp('^Bag')));
    await settle(tester);
    expect(find.text('Seeds'), findsOneWidget);
    expect(find.text('Fruit'), findsOneWidget);
  });

  testWidgets('shop cards open a sheet with one clear button', (tester) async {
    final db = memoryDb();
    addTearDown(db.close);
    await tester.runAsync(() async {
      await SeedRepository(db, const Clock()).ensurePlot('meadow');
      await CountersRepository(db).add(CounterKeys.coins, 500);
    });
    await tester.pumpWidget(testApp(db, settings: settings));
    await settle(tester);
    await tester.tap(find.text('Shop').last);
    await settle(tester);

    await tester.tap(find.bySemanticsLabel(RegExp('^Forest')));
    await settle(tester);
    expect(find.text('Unlock for 🪙 150'), findsOneWidget);
    await tester.tap(find.text('Unlock for 🪙 150'));
    await settle(tester);
    await tester.pump(const Duration(seconds: 2));
    await settle(tester);

    final coins = await tester.runAsync(() => CountersRepository(db).get(CounterKeys.coins));
    expect(coins, 350);
  });
}
