import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprout/domain/models/enums.dart';
import 'package:sprout/ui/art/plant_art_provider.dart';

import '../widget/test_app.dart';
import 'render.dart';

/// A contact sheet of every species at every stage, plus the ground spot and
/// the seed's wobble, to check the plant art by eye.
void main() {
  final species = testConfig.species.values.toList();
  const cell = 104.0;

  Widget row(String label, List<Widget> cells) => Row(
    children: [
      SizedBox(
        width: 96,
        child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
      ),
      for (final c in cells) SizedBox(width: cell, height: cell * 1.15, child: c),
    ],
  );

  Future<void> sheet(WidgetTester tester, String name, List<Widget> rows) async {
    await loadAppFonts();
    setPhoneScreen(tester, size: Size(96 + cell * 5 + 16, rows.length * cell * 1.15 + 16), systemBar: 0);
    await tester.pumpWidget(
      themed(
        ColoredBox(
          color: const Color(0xFFDCEFD6),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(children: rows),
          ),
        ),
      ),
    );
    await tester.pump();
    await savePng(tester, name);
  }

  for (var part = 0; part < 2; part++) {
    testWidgets('plants sheet ${part + 1}', (tester) async {
      final half = (species.length / 2).ceil();
      final some = species.skip(part * half).take(half);
      await sheet(tester, 'plants_${part + 1}', [
        for (final s in some)
          row(s.name, [
            for (final stage in GrowthStage.values) plantArtProvider.plant(s, stage, size: cell, height: cell * 1.15),
          ]),
      ]);
    });
  }

  testWidgets('seed wobble, sprout sway and ground spot', (tester) async {
    final s = species.first;
    await sheet(tester, 'plants_motion', [
      row('Seed wobble', [
        for (final sway in [-1.0, 0.0, 1.0]) plantArtProvider.plant(s, GrowthStage.seed, size: cell, sway: sway),
        Center(child: plantArtProvider.groundSpot(size: cell * 0.8)),
        plantArtProvider.plant(s, GrowthStage.seed, size: 60),
      ]),
      row('Sway', [
        for (final sway in [-1.0, 0.0, 1.0]) plantArtProvider.plant(s, GrowthStage.fruiting, size: cell, sway: sway),
        plantArtProvider.plant(species[2], GrowthStage.fruiting, size: cell, sway: -1),
        plantArtProvider.plant(species[2], GrowthStage.fruiting, size: cell, sway: 1),
      ]),
    ]);
  });
}
