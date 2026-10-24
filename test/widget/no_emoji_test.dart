import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprout/core/clock.dart';
import 'package:sprout/data/repositories/quest_repository.dart';
import 'package:sprout/data/repositories/seed_repository.dart';
import 'package:sprout/domain/models/app_settings.dart';
import 'package:sprout/domain/models/enums.dart';
import 'package:sprout/ui/art/icon_art.dart';
import 'package:yaml/yaml.dart';

import 'test_app.dart';

/// Emoji and pictographs (which the phone's emoji font draws in glossy 3D).
/// Plain symbols like the bullet "●" and arrows "→" are fine.
final emoji = RegExp(
  '[\u{1F000}-\u{1FAFF}\u{2600}-\u{27BF}\u{2B50}\u{2B55}\u{2300}-\u{23FF}\u{FE0F}\u{1F1E6}-\u{1F1FF}]',
  unicode: true,
);

List<String> emojiIn(String text) => [for (final m in emoji.allMatches(text)) m[0]!];

void main() {
  test('no emoji in the app source', () {
    final found = <String>[];
    for (final file in Directory('lib').listSync(recursive: true).whereType<File>()) {
      if (!file.path.endsWith('.dart')) continue;
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        if (emoji.hasMatch(lines[i])) found.add('${file.path}:${i + 1}: ${lines[i].trim()}');
      }
    }
    expect(found, isEmpty, reason: 'Use ArtIcon or IconText instead of emoji:\n${found.join('\n')}');
  });

  test('config emoji fields are never shown', () {
    final found = <String>[];
    for (final file in Directory('lib').listSync(recursive: true).whereType<File>()) {
      if (!file.path.endsWith('.dart') || file.path.endsWith('game_config.dart')) continue;
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        if (lines[i].contains('.emoji')) found.add('${file.path}:${i + 1}');
      }
    }
    expect(found, isEmpty, reason: 'Show ArtIcon(id) instead of a config emoji:\n${found.join('\n')}');
  });

  test('game text in the config and Ben\'s lines has no emoji', () {
    final found = <String>[];
    void walk(Object? node, String path) {
      if (node is Map) {
        node.forEach((k, v) => k == 'emoji' ? null : walk(v, '$path.$k'));
      } else if (node is List) {
        for (var i = 0; i < node.length; i++) {
          walk(node[i], '$path[$i]');
        }
      } else if (node is String && emoji.hasMatch(node)) {
        found.add('$path: $node');
      }
    }

    walk(loadYaml(File('assets/config/game_config.yaml').readAsStringSync()), 'config');
    walk(jsonDecode(File('assets/content/ben_lines.json').readAsStringSync()), 'ben');
    expect(found, isEmpty, reason: found.join('\n'));
  });

  test('everything in the config has its own icon', () {
    final ids = [
      for (final s in testConfig.species.values) 'fruit:${s.id}',
      for (final v in testConfig.visitors.values) 'visitor:${v.id}',
      for (final c in testConfig.cosmetics.values) 'cosmetic:${c.id}',
      for (final e in testConfig.environments) 'plot:${e.id}',
      for (final f in testConfig.families.values) 'family:${f.id}',
      for (final r in testConfig.recipes.values) 'recipe:${r.id}',
      for (final p in testConfig.mysteryPacks.values) 'pack:${p.id}',
    ];
    expect([
      for (final id in ids)
        if (!iconArtProvider.has(id)) id,
    ], isEmpty);
  });

  testWidgets('no emoji on the main screens', (tester) async {
    final db = memoryDb();
    addTearDown(db.close);
    await tester.runAsync(() async {
      await SeedRepository(db, const Clock()).ensurePlot('meadow');
      await QuestRepository(
        db,
        const Clock(),
      ).create(title: 'Drink a glass of water', category: QuestCategory.foodWater, difficulty: Difficulty.small);
    });
    await tester.pumpWidget(testApp(db, settings: const AppSettings(onboardingDone: true, reducedMotion: true)));
    await tester.pumpAndSettle();

    final found = <String>{};
    void collect(String where) {
      for (final e in find.byType(RichText).evaluate()) {
        final text = (e.widget as RichText).text.toPlainText();
        for (final hit in emojiIn(text)) {
          found.add('$where: "$text" ($hit)');
        }
      }
    }

    collect('Home');
    for (final tab in ['Today', 'Journal', 'Shop', 'Settings']) {
      await tester.tap(find.text(tab).last);
      await tester.pumpAndSettle();
      collect(tab);
    }
    await tester.tap(find.text('Journal').last);
    await tester.pumpAndSettle();
    for (final tab in ['Quests', 'Plants', 'Visitors', 'Achievements', 'Moods']) {
      await tester.tap(find.text(tab));
      await tester.pumpAndSettle();
      collect('Journal $tab');
    }
    await tester.tap(find.text('Shop').last);
    await tester.pumpAndSettle();
    for (final tab in ['Sell', 'Recipes', 'Decor', 'Plots']) {
      await tester.tap(find.bySemanticsLabel(RegExp('^$tab')));
      await tester.pumpAndSettle();
      collect('Shop $tab');
    }
    expect(found, isEmpty, reason: found.join('\n'));
  });
}
