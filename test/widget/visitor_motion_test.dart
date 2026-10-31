import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprout/features/home/visitor_motion.dart';

import 'test_app.dart';

void main() {
  // At 60 frames a second over the 24 second loop, gentle flyers move only a
  // little between frames: no shaking or jitter.
  for (final id in ['ladybird', 'firefly', 'butterfly']) {
    testWidgets('$id flies smoothly', (tester) async {
      (double, double, double)? last;
      double? lastDy;
      var reversals = 0;
      for (var frame = 0; frame < 24 * 60; frame += 2) {
        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: Stack(
              children: [
                AnimatedVisitor(
                  visitor: testConfig.visitors[id]!,
                  index: 0,
                  phase: frame / (24 * 60),
                  width: 400,
                  top: 100,
                  bottom: 600,
                  onTap: () {},
                ),
              ],
            ),
          ),
        );
        final pos = tester.widget<Positioned>(find.byType(Positioned));
        final angle = tester.widget<Transform>(find.byType(Transform).first).transform.getRotation().entry(1, 0);
        final now = (pos.left!, pos.top!, angle);
        if (last != null) {
          // Two frames apart (1/30 s).
          expect((now.$1 - last.$1).abs(), lessThan(10), reason: 'x at frame $frame');
          expect((now.$2 - last.$2).abs(), lessThan(4), reason: 'y at frame $frame');
          expect((now.$3 - last.$3).abs(), lessThan(0.2), reason: 'angle at frame $frame');
          final dy = now.$2 - last.$2;
          if (lastDy != null && dy.abs() > 0.05 && lastDy.abs() > 0.05 && dy.sign != lastDy.sign) reversals++;
          if (dy.abs() > 0.05) lastDy = dy;
        }
        last = now;
      }
      // Jitter flips up and down many times a second; a smooth flight rarely does.
      expect(reversals, lessThan(24 * 2), reason: 'up/down reversals in 24 s');
    });
  }
}
