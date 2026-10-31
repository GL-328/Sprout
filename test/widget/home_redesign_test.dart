import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprout/core/clock.dart';
import 'package:sprout/data/db/app_database.dart';
import 'package:sprout/data/repositories/counters_repository.dart';
import 'package:sprout/data/repositories/quest_repository.dart';
import 'package:sprout/data/repositories/seed_repository.dart';
import 'package:sprout/domain/models/app_settings.dart';
import 'package:sprout/domain/models/enums.dart';
import 'package:sprout/ui/art/icon_art.dart';

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
    expect(find.text('All done for today'), findsOneWidget);
    expect(find.text('Undo'), findsOneWidget);
  });

  testWidgets('arrows move between plant spots', (tester) async {
    final db = memoryDb();
    addTearDown(db.close);
    await tester.runAsync(() => SeedRepository(db, const Clock()).ensurePlot('meadow'));
    await tester.pumpWidget(testApp(db, settings: settings));
    await settle(tester);

    double opacity(String tooltip) => tester
        .widget<AnimatedOpacity>(find.ancestor(of: find.byTooltip(tooltip), matching: find.byType(AnimatedOpacity)))
        .opacity;

    // It starts on the far-left spot: nothing to go back to yet.
    expect(opacity('Previous plant'), 0);
    expect(opacity('Next plant'), 1);
    await tester.tap(find.byTooltip('Next plant'));
    await settle(tester);
    expect(opacity('Previous plant'), 1);
    expect(opacity('Next plant'), 1);
    await tester.tap(find.byTooltip('Next plant'));
    await settle(tester);
    // On the last spot the next arrow fades away and ignores taps.
    expect(opacity('Next plant'), 0);
    expect(opacity('Previous plant'), 1);
  });

  testWidgets('placed decorations stand on the ground, above the quests panel', (tester) async {
    final db = memoryDb();
    addTearDown(db.close);
    const kinds = {
      'fence': 'picket_fence',
      'lantern': 'paper_lantern',
      'pond': 'lily_pond',
      'bench': 'wooden_bench',
      'path': 'stone_path',
    };
    await tester.runAsync(() async {
      await SeedRepository(db, const Clock()).ensurePlot('meadow');
      for (final MapEntry(key: kind, value: id) in kinds.entries) {
        await db
            .into(db.plotCosmetics)
            .insertOnConflictUpdate(PlotCosmeticsCompanion.insert(envId: 'meadow', kind: kind, cosmeticId: id));
      }
    });
    await tester.pumpWidget(testApp(db, settings: settings));
    await settle(tester);

    final panelTop = tester.getTopLeft(find.text("Today's quests")).dy;
    final screen = tester.view.physicalSize / tester.view.devicePixelRatio;
    for (final MapEntry(key: kind, value: id) in kinds.entries) {
      final icons = find.byWidgetPredicate((w) => w is ArtIcon && w.id == 'cosmetic:$id');
      expect(icons, findsWidgets, reason: '$kind is drawn');
      for (final e in icons.evaluate()) {
        final rect = tester.getRect(find.byWidget(e.widget));
        expect(rect.bottom, lessThan(panelTop), reason: '$kind is not hidden under the quests panel');
        expect(rect.left, greaterThanOrEqualTo(-1), reason: '$kind is on screen');
        expect(rect.right, lessThanOrEqualTo(screen.width + 1), reason: '$kind is on screen');
      }
    }
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

    await tester.ensureVisible(find.bySemanticsLabel(RegExp('^Forest')));
    await settle(tester);
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -150));
    await settle(tester);
    await tester.tap(find.bySemanticsLabel(RegExp('^Forest')));
    await settle(tester);
    expect(find.textContaining('Unlock for'), findsOneWidget);
    await tester.tap(find.textContaining('Unlock for'));
    await settle(tester);
    await tester.pump(const Duration(seconds: 2));
    await settle(tester);

    final coins = await tester.runAsync(() => CountersRepository(db).get(CounterKeys.coins));
    expect(coins, 350);
  });
}
