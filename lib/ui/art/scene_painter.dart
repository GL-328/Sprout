import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Draws the garden backdrop: sky, sun or moon, and rolling hills.
///
/// Stage 1 draws a simple meadow. Later stages feed in the environment,
/// season and mood.
class GardenScenePainter extends CustomPainter {
  GardenScenePainter({required this.hour, required this.dark});

  /// Hour of the day (0-23.99), used for sky colour and sun position.
  final double hour;
  final bool dark;

  bool get _isNight => hour < 6 || hour >= 20;

  @override
  void paint(Canvas canvas, Size size) {
    final skyColors = _isNight
        ? const [Color(0xFF2E3A6B), Color(0xFF5B5C8F)]
        : hour < 9
        ? const [Color(0xFFFFD6C2), Color(0xFFFFF1DC)]
        : hour >= 17
        ? const [Color(0xFFF7B9A6), Color(0xFFFFE3C4)]
        : const [Color(0xFFB9DDF5), Color(0xFFE6F4FB)];
    final sky = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRect(
      sky,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: skyColors,
        ).createShader(sky),
    );

    // Sun or moon on a gentle arc across the sky.
    final t = _isNight ? ((hour + 4) % 24) / 10 : (hour - 6) / 14;
    final x = size.width * (0.12 + 0.76 * t.clamp(0.0, 1.0));
    final y = size.height * (0.30 - 0.18 * math.sin(math.pi * t.clamp(0.0, 1.0)));
    final orb = Paint()..color = _isNight ? const Color(0xFFF7F1D6) : const Color(0xFFFFE08A);
    canvas.drawCircle(Offset(x, y), size.width * 0.07, Paint()..color = orb.color.withValues(alpha: 0.25));
    canvas.drawCircle(Offset(x, y), size.width * 0.05, orb);

    if (_isNight) {
      final star = Paint()..color = Colors.white.withValues(alpha: 0.8);
      final rnd = math.Random(7);
      for (var i = 0; i < 24; i++) {
        canvas.drawCircle(Offset(rnd.nextDouble() * size.width, rnd.nextDouble() * size.height * 0.45), 1.2, star);
      }
    }

    // Two layers of hills.
    final back = Path()
      ..moveTo(0, size.height * 0.62)
      ..quadraticBezierTo(size.width * 0.3, size.height * 0.50, size.width * 0.6, size.height * 0.60)
      ..quadraticBezierTo(size.width * 0.85, size.height * 0.66, size.width, size.height * 0.56)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(back, Paint()..color = _isNight ? const Color(0xFF3F6B5A) : const Color(0xFFA8D8A8));

    final front = Path()
      ..moveTo(0, size.height * 0.72)
      ..quadraticBezierTo(size.width * 0.5, size.height * 0.64, size.width, size.height * 0.74)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(front, Paint()..color = _isNight ? const Color(0xFF2F5546) : const Color(0xFF86C98A));
  }

  @override
  bool shouldRepaint(GardenScenePainter old) => old.hour != hour || old.dark != dark;
}
