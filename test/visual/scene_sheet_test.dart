import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprout/domain/logic/seasons.dart';
import 'package:sprout/ui/art/scene_painter.dart';

import 'render.dart';

/// Every plot's scenery by day, evening and night, plus the sky themes,
/// weather and seasons, to check by eye.
void main() {
  const envs = ['meadow', 'forest', 'orchard', 'wetland', 'desert', 'tropical', 'alpine'];
  const cellW = 160.0;
  const cellH = 220.0;

  Widget cell(String label, GardenScenePainter painter) => Padding(
    padding: const EdgeInsets.all(4),
    child: Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: CustomPaint(size: const Size(cellW, cellH), painter: painter),
        ),
        Text(label, style: const TextStyle(fontSize: 10)),
      ],
    ),
  );

  testWidgets('scenery sheet', (tester) async {
    await loadAppFonts();
    setPhoneScreen(tester, size: const Size(cellW * 4 + 48, (cellH + 24) * 6.5), systemBar: 0);
    await tester.pumpWidget(
      themed(
        Wrap(
          children: [
            for (final env in envs) ...[
              cell('$env day', GardenScenePainter(hour: 13, envId: env)),
              cell('$env evening', GardenScenePainter(hour: 18.5, envId: env)),
              cell('$env night', GardenScenePainter(hour: 22, envId: env)),
            ],
            cell('sunset sky', GardenScenePainter(hour: 13, skyTheme: 'sunset_sky')),
            cell('aurora night', GardenScenePainter(hour: 23, skyTheme: 'aurora_sky')),
            cell('rain', GardenScenePainter(hour: 11, weather: Weather.softRain)),
            cell('rainbow', GardenScenePainter(hour: 11, weather: Weather.rainbow)),
            cell('winter', GardenScenePainter(hour: 11, season: Season.winter)),
            cell('autumn forest', GardenScenePainter(hour: 11, envId: 'forest', season: Season.autumn)),
            cell('locked', GardenScenePainter(hour: 13, envId: 'forest', silhouette: true)),
          ],
        ),
      ),
    );
    await tester.pump();
    await savePng(tester, 'scenery');
  });
}
