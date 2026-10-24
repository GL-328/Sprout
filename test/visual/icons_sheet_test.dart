import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprout/ui/art/icon_art.dart';

import 'render.dart';

/// A contact sheet of every icon, in light and dark, to check them by eye.
void main() {
  final ids = [...iconSpecs.keys, for (var m = 1; m <= 5; m++) 'mood:$m'];

  for (final brightness in Brightness.values) {
    testWidgets('icon contact sheet, ${brightness.name}', (tester) async {
      await loadAppFonts();
      const columns = 6;
      final rows = (ids.length / columns).ceil();
      setPhoneScreen(tester, size: Size(columns * 92.0 + 16, rows * 92.0 + 16), systemBar: 0);
      await tester.pumpWidget(
        themed(
          brightness: brightness,
          Padding(
            padding: const EdgeInsets.all(8),
            child: Wrap(
              children: [
                for (final id in ids)
                  SizedBox(
                    width: 92,
                    height: 92,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ArtIcon(id, size: 52),
                        const SizedBox(height: 4),
                        Text(
                          id.contains(':') ? id.split(':').last : id,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 10),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
      await tester.pump();
      await savePng(tester, 'icons_${brightness.name}');
    });
  }

  testWidgets('icons at real sizes', (tester) async {
    await loadAppFonts();
    setPhoneScreen(tester, size: const Size(360, 200), systemBar: 0);
    await tester.pumpWidget(
      themed(
        const Padding(
          padding: EdgeInsets.all(12),
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              ArtIcon('coin', size: 16),
              ArtIcon('coin', size: 22),
              ArtIcon('coin', size: 32),
              ArtIcon('bag', size: 22),
              ArtIcon('bag', size: 32),
              ArtIcon('basket', size: 22),
              ArtIcon('seed', size: 22),
              ArtIcon('fruit:apple_tree', size: 18),
              IconText('Buy for {coin} 120', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              IconText('Fruit: {fruit:berry_bush} Raspberries, 3 per harvest'),
            ],
          ),
        ),
      ),
    );
    await tester.pump();
    await savePng(tester, 'icons_small');
  });
}
