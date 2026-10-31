import 'package:flutter_test/flutter_test.dart';
import 'package:sprout/core/clock.dart';
import 'package:sprout/data/db/app_database.dart';
import 'package:sprout/data/repositories/counters_repository.dart';
import 'package:sprout/data/repositories/quest_repository.dart';
import 'package:sprout/data/repositories/seed_repository.dart';
import 'package:sprout/data/services/garden_service.dart';
import 'package:sprout/domain/models/app_settings.dart';
import 'package:sprout/domain/models/enums.dart';
import 'package:sprout/domain/models/seed.dart';

import '../widget/test_app.dart';
import 'render.dart';

/// Renders the main screens at a small phone size, at normal and 130% text,
/// to check icons and layout by eye.
Future<AppDatabase> seeded(WidgetTester tester) async {
  final db = memoryDb();
  addTearDown(db.close);
  await tester.runAsync(() async {
    final clock = FakeClock(DateTime.now().subtract(const Duration(days: 2)));
    final seeds = SeedRepository(db, clock);
    final counters = CountersRepository(db);
    await seeds.ensurePlot('meadow');
    final garden = GardenService(db, testConfig, clock, seeds, counters);
    final s = await seeds.add('berry_bush', Rarity.common, SeedSource.quests);
    await garden.plantSeed(s.id, 'meadow', 0);
    await seeds.add('apple_tree', Rarity.common, SeedSource.quests);
    await counters.add('coins', 120);
    final quests = QuestRepository(db, const Clock());
    for (final (t, c) in [
      ('Drink a glass of water', QuestCategory.foodWater),
      ('Stretch for two minutes', QuestCategory.movement),
      ('Text a friend', QuestCategory.social),
    ]) {
      await quests.create(title: t, category: c, difficulty: Difficulty.small);
    }
  });
  return db;
}

void main() {
  testWidgets('a new seed in the garden and in its sheet', (tester) async {
    await loadAppFonts();
    setPhoneScreen(tester);
    final db = memoryDb();
    addTearDown(db.close);
    await tester.runAsync(() async {
      final seeds = SeedRepository(db, const Clock());
      await seeds.ensurePlot('meadow');
      final garden = GardenService(db, testConfig, const Clock(), seeds, CountersRepository(db));
      final s = await seeds.add('giant_sunflower', Rarity.common, SeedSource.quests);
      await garden.plantSeed(s.id, 'meadow', 0);
    });
    await tester.pumpWidget(
      shot(testApp(db, settings: const AppSettings(name: 'Sam', onboardingDone: true, reducedMotion: true))),
    );
    await tester.pumpAndSettle();
    await savePng(tester, 'home_seed');
    await tester.tap(find.bySemanticsLabel(RegExp('Giant sunflower')).first);
    await tester.pumpAndSettle();
    await savePng(tester, 'plant_sheet_seed');
  });

  testWidgets('home with every kind of decoration', (tester) async {
    await loadAppFonts();
    setPhoneScreen(tester);
    final db = await seeded(tester);
    await tester.runAsync(() async {
      for (final (kind, id) in [
        ('fence', 'picket_fence'),
        ('lantern', 'paper_lantern'),
        ('pond', 'lily_pond'),
        ('bench', 'wooden_bench'),
        ('path', 'stone_path'),
      ]) {
        await db
            .into(db.plotCosmetics)
            .insertOnConflictUpdate(PlotCosmeticsCompanion.insert(envId: 'meadow', kind: kind, cosmeticId: id));
      }
    });
    await tester.pumpWidget(
      shot(testApp(db, settings: const AppSettings(name: 'Sam', onboardingDone: true, reducedMotion: true))),
    );
    await tester.pumpAndSettle();
    await savePng(tester, 'home_decor');
  });

  for (final scale in [1.0, 1.3]) {
    final tag = '${(scale * 100).round()}';

    testWidgets('screens at $tag% text', (tester) async {
      await loadAppFonts();
      setPhoneScreen(tester, textScale: scale);
      final db = await seeded(tester);
      await tester.pumpWidget(
        shot(testApp(db, settings: const AppSettings(name: 'Sam', onboardingDone: true, reducedMotion: true))),
      );
      await tester.pumpAndSettle();
      await savePng(tester, 'home_$tag');

      await tester.tap(find.text('Shop').last);
      await tester.pumpAndSettle();
      await savePng(tester, 'shop_plots_$tag');
      await tester.tap(find.bySemanticsLabel(RegExp('^Decor')));
      await tester.pumpAndSettle();
      await savePng(tester, 'shop_decor_$tag');
      await tester.tap(find.bySemanticsLabel(RegExp('^Recipes')));
      await tester.pumpAndSettle();
      await savePng(tester, 'shop_recipes_$tag');

      await tester.tap(find.text('Journal').last);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Achievements'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Achievements'));
      await tester.pumpAndSettle();
      await savePng(tester, 'journal_achievements_$tag');
      await tester.ensureVisible(find.text('Visitors'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Visitors'));
      await tester.pumpAndSettle();
      await savePng(tester, 'journal_visitors_$tag');

      await tester.tap(find.text('Today').last);
      await tester.pumpAndSettle();
      await savePng(tester, 'today_$tag');
    });
  }
}
