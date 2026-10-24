import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprout/ui/art/character_art.dart';

import 'render.dart';

/// Ben in every expression, blinking and in the wind, to check by eye.
void main() {
  testWidgets('Ben sheet', (tester) async {
    await loadAppFonts();
    setPhoneScreen(tester, size: const Size(760, 460), systemBar: 0);
    Widget cell(String label, Widget art) => Column(
      children: [
        art,
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
    await tester.pumpWidget(
      themed(
        ColoredBox(
          color: const Color(0xFFFAD5C4),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final mood in BenMood.values) cell(mood.name, characterArt.ben(mood: mood, size: 180)),
                cell('blink', characterArt.ben(mood: BenMood.idle, size: 180, blink: 1)),
                cell('wind left', characterArt.ben(mood: BenMood.idle, size: 110, sway: -1)),
                cell('wind right', characterArt.ben(mood: BenMood.idle, size: 110, sway: 1)),
                cell('talking, bob', characterArt.ben(mood: BenMood.talking, size: 110, bob: 1)),
                cell('small', characterArt.ben(mood: BenMood.happy, size: 70)),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await savePng(tester, 'ben');
  });
}
