import 'dart:math' as math;

import 'package:flutter/material.dart';

/// The Seed Meter: a ring split into segments that fill as quests are done.
class SeedMeterRing extends StatelessWidget {
  const SeedMeterRing({super.key, required this.filled, required this.total, this.size = 64, this.animate = true});

  final int filled;
  final int total;
  final double size;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      label: 'Seed Meter, $filled of $total',
      child: TweenAnimationBuilder<double>(
        tween: Tween(end: filled.toDouble()),
        duration: animate ? const Duration(milliseconds: 600) : Duration.zero,
        curve: Curves.easeOutBack,
        builder: (context, value, _) => CustomPaint(
          size: Size.square(size),
          painter: _RingPainter(
            value: value,
            total: total,
            fill: const Color(0xFF7FC48B),
            track: scheme.onSurface.withValues(alpha: 0.10),
          ),
          child: SizedBox.square(
            dimension: size,
            child: Center(
              child: Text('🌱', style: TextStyle(fontSize: size * 0.36)),
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.value, required this.total, required this.fill, required this.track});

  final double value;
  final int total;
  final Color fill;
  final Color track;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * 0.12;
    final rect = Offset(stroke / 2, stroke / 2) & Size(size.width - stroke, size.height - stroke);
    const gap = 0.32;
    final sweep = (2 * math.pi - gap * total) / total;
    final base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < total; i++) {
      final start = -math.pi / 2 + gap / 2 + i * (sweep + gap);
      canvas.drawArc(rect, start, sweep, false, base..color = track);
      final amount = (value - i).clamp(0.0, 1.0);
      if (amount > 0) canvas.drawArc(rect, start, sweep * amount, false, base..color = fill);
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.value != value || old.total != total || old.track != track;
}
