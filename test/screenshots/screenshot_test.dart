// Renders key screens to PNGs for a visual check. Not part of the normal run:
//   flutter test test/screenshots --run-skipped --update-goldens
@Tags(['screenshots'])
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprout/core/clock.dart';
import 'package:sprout/data/repositories/quest_repository.dart';
import 'package:sprout/data/repositories/seed_repository.dart';
import 'package:sprout/data/services/garden_service.dart';
import 'package:sprout/data/repositories/counters_repository.dart';
import 'package:sprout/domain/models/app_settings.dart';
import 'package:sprout/domain/models/enums.dart';
import 'package:sprout/domain/models/seed.dart';

import '../widget/test_app.dart';

Future<void> loadFonts() async {
  final loader = FontLoader('Nunito');
  for (final w in ['Regular', 'SemiBold', 'Bold', 'ExtraBold']) {
    loader.addFont(Future.value(ByteData.sublistView(File('assets/fonts/Nunito-$w.ttf').readAsBytesSync())));
  }
  await loader.load();
  final icons = FontLoader('MaterialIcons');
  final path =
      '${Platform.environment['FLUTTER_ROOT'] ?? '/opt/sdk/flutter'}/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf';
  if (File(path).existsSync()) {
    icons.addFont(Future.value(ByteData.sublistView(File(path).readAsBytesSync())));
    await icons.load();
  }
}

void main() {
  for (final (label, size, ratio) in [('large', const Size(1080, 2340), 2.75), ('small', const Size(720, 1280), 2.0)]) {
    testWidgets('screens $label', (tester) async {
      await loadFonts();
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = ratio;
      addTearDown(tester.view.reset);

      final db = memoryDb();
      addTearDown(db.close);
      await tester.runAsync(() async {
        final clock = FakeClock(DateTime.now().subtract(const Duration(days: 2)));
        final seeds = SeedRepository(db, clock);
        final counters = CountersRepository(db);
        final garden = GardenService(db, testConfig, clock, seeds, counters);
        await seeds.ensurePlot('meadow');
        for (final (i, id) in ['apple_tree', 'giant_sunflower', 'lavender_hedge'].indexed) {
          final s = await seeds.add(id, Rarity.common, SeedSource.quests);
          await garden.plantSeed(s.id, 'meadow', i);
        }
        await seeds.add('oak', Rarity.uncommon, SeedSource.quests);
        await counters.add(CounterKeys.coins, 120);
        final quests = QuestRepository(db, const Clock());
        await quests.create(
          title: 'Drink a glass of water',
          category: QuestCategory.foodWater,
          difficulty: Difficulty.small,
        );
        await quests.create(
          title: 'Step outside for 5 minutes',
          category: QuestCategory.movement,
          difficulty: Difficulty.small,
        );
        await quests.create(
          title: 'Text someone you like',
          category: QuestCategory.social,
          difficulty: Difficulty.medium,
        );
      });

      await tester.pumpWidget(
        testApp(db, settings: const AppSettings(onboardingDone: true, reducedMotion: true, name: 'Robin')),
      );
      await tester.pumpAndSettle();
      await expectLater(find.byType(MaterialApp), matchesGoldenFile('out/${label}_home.png'));

      for (final tab in ['Today', 'Shop', 'Journal']) {
        await tester.tap(find.text(tab).last);
        await tester.pumpAndSettle();
        await expectLater(find.byType(MaterialApp), matchesGoldenFile('out/${label}_${tab.toLowerCase()}.png'));
      }
    });
  }
}
