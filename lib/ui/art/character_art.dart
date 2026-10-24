import 'dart:math' as math;

import 'package:flutter/material.dart';

enum BenMood { idle, talking, happy }

/// Art for characters, starting with Ben the shopkeeper. Swap the
/// implementation (see [characterArt]) for real illustrations later without
/// touching the shop.
abstract class CharacterArtProvider {
  /// Ben from the waist up, [size] wide.
  /// [blink] 0 (open) to 1 (closed), [sway] -1..1 for his hair, [bob] 0..1
  /// for the little bounce when he talks.
  Widget ben({required BenMood mood, required double size, double blink = 0, double sway = 0, double bob = 0});
}

CharacterArtProvider characterArt = PaintedCharacterArt();

class PaintedCharacterArt implements CharacterArtProvider {
  @override
  Widget ben({required BenMood mood, required double size, double blink = 0, double sway = 0, double bob = 0}) =>
      SizedBox(
        width: size,
        height: size * 1.05,
        child: CustomPaint(
          painter: BenPainter(mood: mood, blink: blink, sway: sway, bob: bob),
        ),
      );
}

/// Ben: long blonde hair, a warm smile, a sage cardigan and a cream apron.
class BenPainter extends CustomPainter {
  BenPainter({required this.mood, this.blink = 0, this.sway = 0, this.bob = 0});

  final BenMood mood;
  final double blink;
  final double sway;
  final double bob;

  static const _skin = Color(0xFFF6D3BC);
  static const _skinShade = Color(0xFFEBBDA3);
  static const _hair = Color(0xFFF3D27E);
  static const _hairShade = Color(0xFFE1B95E);
  static const _cardigan = Color(0xFF9CC8A6);
  static const _cardiganShade = Color(0xFF86B691);
  static const _apron = Color(0xFFFFF3DF);
  static const _ink = Color(0xFF3B3346);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    canvas.save();
    canvas.translate(0, -bob * h * 0.025);

    Offset p(double x, double y) => Offset(w * x, h * y);
    final s = sway * w * 0.025;

    // Long hair behind the head and shoulders.
    final back = Path()
      ..moveTo(w * 0.27, h * 0.36)
      ..quadraticBezierTo(w * 0.24, h * 0.10, w * 0.5, h * 0.12)
      ..quadraticBezierTo(w * 0.76, h * 0.10, w * 0.73, h * 0.36)
      ..quadraticBezierTo(w * 0.80 + s, h * 0.62, w * 0.78 + s * 1.4, h * 0.84)
      ..quadraticBezierTo(w * 0.70 + s, h * 0.88, w * 0.64 + s * 0.6, h * 0.80)
      ..lineTo(w * 0.36 + s * 0.6, h * 0.80)
      ..quadraticBezierTo(w * 0.30 + s, h * 0.88, w * 0.22 + s * 1.4, h * 0.84)
      ..quadraticBezierTo(w * 0.20 + s, h * 0.62, w * 0.27, h * 0.36)
      ..close();
    canvas.drawPath(back, Paint()..color = _hairShade);

    // Body: cardigan with an apron on top.
    final body = RRect.fromRectAndCorners(
      Rect.fromLTRB(w * 0.16, h * 0.66, w * 0.84, h * 1.02),
      topLeft: Radius.circular(w * 0.18),
      topRight: Radius.circular(w * 0.18),
    );
    canvas.drawRRect(body, Paint()..color = _cardigan);
    canvas.drawRect(Rect.fromLTRB(w * 0.47, h * 0.70, w * 0.53, h * 1.02), Paint()..color = _cardiganShade);
    final apron = RRect.fromRectAndCorners(
      Rect.fromLTRB(w * 0.34, h * 0.76, w * 0.66, h * 1.02),
      topLeft: Radius.circular(w * 0.04),
      topRight: Radius.circular(w * 0.04),
    );
    canvas.drawRRect(apron, Paint()..color = _apron);
    final strap = Paint()
      ..color = _apron
      ..strokeWidth = w * 0.025
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(p(0.36, 0.77), p(0.42, 0.68), strap);
    canvas.drawLine(p(0.64, 0.77), p(0.58, 0.68), strap);
    // A little leaf stitched on the apron pocket.
    canvas.drawOval(
      Rect.fromCenter(center: p(0.5, 0.88), width: w * 0.06, height: w * 0.035),
      Paint()..color = _cardigan,
    );

    // Neck and head.
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTRB(w * 0.45, h * 0.56, w * 0.55, h * 0.70), Radius.circular(w * 0.03)),
      Paint()..color = _skinShade,
    );
    final head = p(0.5, 0.40);
    canvas.drawOval(Rect.fromCenter(center: head, width: w * 0.40, height: h * 0.40), Paint()..color = _skin);
    // Ears peeking through the hair.
    canvas.drawCircle(p(0.305, 0.43), w * 0.035, Paint()..color = _skinShade);
    canvas.drawCircle(p(0.695, 0.43), w * 0.035, Paint()..color = _skinShade);

    // Front hair: soft fringe and strands framing the face.
    final fringe = Path()
      ..moveTo(w * 0.29, h * 0.40)
      ..quadraticBezierTo(w * 0.28, h * 0.17, w * 0.5, h * 0.17)
      ..quadraticBezierTo(w * 0.72, h * 0.17, w * 0.71, h * 0.40)
      ..quadraticBezierTo(w * 0.66, h * 0.28, w * 0.56, h * 0.27)
      ..quadraticBezierTo(w * 0.50, h * 0.33, w * 0.40, h * 0.29)
      ..quadraticBezierTo(w * 0.33, h * 0.31, w * 0.29, h * 0.40)
      ..close();
    canvas.drawPath(fringe, Paint()..color = _hair);
    final strand = Paint()
      ..color = _hair
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.06
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.30, h * 0.36)
        ..quadraticBezierTo(w * 0.27 + s * 0.5, h * 0.58, w * 0.29 + s, h * 0.74),
      strand,
    );
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.70, h * 0.36)
        ..quadraticBezierTo(w * 0.73 + s * 0.5, h * 0.58, w * 0.71 + s, h * 0.74),
      strand,
    );
    // A shine in the hair.
    canvas.drawArc(
      Rect.fromCenter(center: p(0.44, 0.22), width: w * 0.16, height: h * 0.08),
      math.pi * 1.1,
      math.pi * 0.5,
      false,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.015
        ..strokeCap = StrokeCap.round,
    );

    // Cheeks.
    final blush = Paint()..color = const Color(0xFFF5A3A8).withValues(alpha: 0.45);
    canvas.drawOval(Rect.fromCenter(center: p(0.39, 0.48), width: w * 0.07, height: h * 0.035), blush);
    canvas.drawOval(Rect.fromCenter(center: p(0.61, 0.48), width: w * 0.07, height: h * 0.035), blush);

    // Eyes.
    final line = Paint()
      ..color = _ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.014
      ..strokeCap = StrokeCap.round;
    for (final x in [0.43, 0.57]) {
      final c = p(x, 0.42);
      if (mood == BenMood.happy) {
        canvas.drawArc(
          Rect.fromCenter(center: c.translate(0, h * 0.008), width: w * 0.05, height: h * 0.04),
          math.pi,
          math.pi,
          false,
          line,
        );
      } else if (blink > 0.5) {
        canvas.drawLine(c.translate(-w * 0.02, 0), c.translate(w * 0.02, 0), line);
      } else {
        canvas.drawOval(
          Rect.fromCenter(center: c, width: w * 0.034, height: h * 0.045 * (1 - blink)),
          Paint()..color = _ink,
        );
        canvas.drawCircle(c.translate(w * 0.006, -h * 0.01), w * 0.006, Paint()..color = Colors.white);
      }
    }

    // Mouth.
    final mouth = p(0.5, 0.505);
    switch (mood) {
      case BenMood.talking:
        canvas.drawOval(
          Rect.fromCenter(center: mouth, width: w * 0.06, height: h * (0.025 + 0.02 * bob)),
          Paint()..color = const Color(0xFFB65B66),
        );
      case BenMood.happy:
        canvas.drawArc(
          Rect.fromCenter(center: mouth.translate(0, -h * 0.01), width: w * 0.11, height: h * 0.06),
          0,
          math.pi,
          true,
          Paint()..color = const Color(0xFFB65B66),
        );
      case BenMood.idle:
        canvas.drawArc(
          Rect.fromCenter(center: mouth.translate(0, -h * 0.012), width: w * 0.09, height: h * 0.045),
          0.2,
          math.pi - 0.4,
          false,
          line,
        );
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(BenPainter old) => old.mood != mood || old.blink != blink || old.sway != sway || old.bob != bob;
}
