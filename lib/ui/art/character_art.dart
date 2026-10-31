import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'icon_painters.dart';

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

/// Ben: a teenage boy with long, warm blonde hair, freckles, a sage t-shirt
/// and a cream apron.
///
/// His hair is one colour throughout: every hair shape uses [_hair], and the
/// only shading is two soft highlights from the same
/// colour family, so it reads as one continuous piece.
class BenPainter extends CustomPainter {
  BenPainter({required this.mood, this.blink = 0, this.sway = 0, this.bob = 0});

  final BenMood mood;
  final double blink;
  final double sway;
  final double bob;

  static const _skin = Color(0xFFF6D3BC);
  static const _skinShade = Color(0xFFEBBDA3);
  static const _hair = Color(0xFFF0C978);
  static const _brow = Color(0xFFC79A55);
  static const _shirt = Color(0xFF9CC8A6);
  static const _apron = Color(0xFFFFF3DF);
  static const _ink = Color(0xFF3B3346);

  /// Highlights: a whisper lighter.
  static final _shine = Color.lerp(_hair, Colors.white, 0.4)!;

  @override
  void paint(Canvas canvas, Size size) =>
      paintOutlined(canvas, Offset.zero & size, outlineWidth(size.width) * 0.8, () => _draw(canvas, size));

  void _draw(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    canvas.save();
    canvas.translate(0, -bob * h * 0.025);

    Offset p(double x, double y) => Offset(w * x, h * y);
    final s = sway * 0.025;
    final hair = Paint()..color = _hair;
    Paint stroke(Color c, double width) => Paint()
      ..color = c
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * width
      ..strokeCap = StrokeCap.round;

    // 1. The hair's full silhouette, behind everything: crown, sides and the
    //    long fall past his shoulders.
    final back = Path()
      ..moveTo(w * 0.5, h * 0.1)
      ..cubicTo(w * 0.73, h * 0.1, w * 0.8, h * 0.26, w * 0.78, h * 0.42)
      ..cubicTo(w * 0.77, h * 0.56, w * (0.83 + s), h * 0.7, w * (0.8 + s * 1.4), h * 0.86)
      ..quadraticBezierTo(w * (0.74 + s * 1.2), h * 0.91, w * (0.68 + s), h * 0.84)
      ..cubicTo(w * 0.66, h * 0.72, w * 0.66, h * 0.56, w * 0.64, h * 0.46)
      ..lineTo(w * 0.36, h * 0.46)
      ..cubicTo(w * 0.34, h * 0.56, w * 0.34, h * 0.72, w * (0.32 + s), h * 0.84)
      ..quadraticBezierTo(w * (0.26 + s * 1.2), h * 0.91, w * (0.2 + s * 1.4), h * 0.86)
      ..cubicTo(w * (0.17 + s), h * 0.7, w * 0.23, h * 0.56, w * 0.22, h * 0.42)
      ..cubicTo(w * 0.2, h * 0.26, w * 0.27, h * 0.1, w * 0.5, h * 0.1)
      ..close();
    canvas.drawPath(back, hair);
    // A couple of tousled tufts on the crown.
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.44, h * 0.11)
        ..quadraticBezierTo(w * (0.47 + s), h * 0.045, w * (0.53 + s * 1.5), h * 0.06)
        ..quadraticBezierTo(w * 0.5, h * 0.09, w * 0.52, h * 0.11)
        ..close(),
      hair,
    );
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.53, h * 0.105)
        ..quadraticBezierTo(w * (0.58 + s), h * 0.06, w * (0.63 + s * 1.5), h * 0.085)
        ..quadraticBezierTo(w * 0.6, h * 0.1, w * 0.6, h * 0.12)
        ..close(),
      hair,
    );

    // 2. Body: broad shoulders in a t-shirt, with an apron on top.
    final body = RRect.fromRectAndCorners(
      Rect.fromLTRB(w * 0.13, h * 0.68, w * 0.87, h * 1.04),
      topLeft: Radius.circular(w * 0.16),
      topRight: Radius.circular(w * 0.16),
    );
    canvas.drawRRect(body, Paint()..color = _shirt);
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.41, h * 0.68)
        ..quadraticBezierTo(w * 0.5, h * 0.745, w * 0.59, h * 0.68)
        ..close(),
      Paint()..color = _skinShade,
    );
    // Crew-neck collar.
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.4, h * 0.68)
        ..quadraticBezierTo(w * 0.5, h * 0.76, w * 0.6, h * 0.68),
      stroke(Color.lerp(_shirt, const Color(0xFF3B3346), 0.12)!, 0.018),
    );
    final apron = RRect.fromRectAndCorners(
      Rect.fromLTRB(w * 0.33, h * 0.78, w * 0.67, h * 1.04),
      topLeft: Radius.circular(w * 0.04),
      topRight: Radius.circular(w * 0.04),
    );
    canvas.drawRRect(apron, Paint()..color = _apron);
    final strap = stroke(_apron, 0.025);
    canvas.drawLine(p(0.35, 0.79), p(0.41, 0.69), strap);
    canvas.drawLine(p(0.65, 0.79), p(0.59, 0.69), strap);
    // A pocket with a little stitched leaf.
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTRB(w * 0.42, h * 0.86, w * 0.58, h * 0.95), Radius.circular(w * 0.02)),
      Paint()..color = Color.lerp(_apron, _shirt, 0.18)!,
    );
    canvas.drawOval(Rect.fromCenter(center: p(0.5, 0.895), width: w * 0.06, height: w * 0.03), Paint()..color = _shirt);

    // 3. Neck and face: a slightly square jaw.
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTRB(w * 0.425, h * 0.56, w * 0.575, h * 0.7), Radius.circular(w * 0.03)),
      Paint()..color = _skinShade,
    );
    final face = Path()
      ..moveTo(w * 0.31, h * 0.32)
      ..cubicTo(w * 0.3, h * 0.5, w * 0.34, h * 0.59, w * 0.43, h * 0.615)
      ..quadraticBezierTo(w * 0.5, h * 0.632, w * 0.57, h * 0.615)
      ..cubicTo(w * 0.66, h * 0.59, w * 0.7, h * 0.5, w * 0.69, h * 0.32)
      ..cubicTo(w * 0.66, h * 0.16, w * 0.34, h * 0.16, w * 0.31, h * 0.32)
      ..close();
    canvas.drawPath(face, Paint()..color = _skin);

    // 4. Front hair, the same colour as the silhouette so it joins without a
    //    seam: locks falling in front of the shoulders and a side-parted
    //    fringe (parting on his right, sweeping across).
    for (final side in [-1.0, 1.0]) {
      final x = 0.5 + side * 0.2;
      canvas.drawPath(
        Path()
          ..moveTo(w * (x - side * 0.03), h * 0.3)
          ..cubicTo(
            w * (x + side * 0.03),
            h * 0.44,
            w * (x + side * 0.0 + s),
            h * 0.62,
            w * (x + side * 0.02 + s * 1.3),
            h * 0.8,
          )
          ..quadraticBezierTo(w * (x + side * 0.06 + s * 1.3), h * 0.84, w * (x + side * 0.08 + s), h * 0.78)
          ..cubicTo(w * (x + side * 0.08), h * 0.6, w * (x + side * 0.09), h * 0.44, w * (x + side * 0.08), h * 0.3)
          ..close(),
        hair,
      );
    }
    const part = 0.42;
    final fringe = Path()
      ..moveTo(w * 0.29, h * 0.38)
      ..cubicTo(w * 0.27, h * 0.2, w * 0.36, h * 0.13, w * part, h * 0.135)
      ..cubicTo(w * 0.58, h * 0.12, w * 0.73, h * 0.18, w * 0.71, h * 0.38)
      ..quadraticBezierTo(w * 0.66, h * 0.27, w * 0.55, h * 0.28)
      ..quadraticBezierTo(w * 0.47, h * 0.3, w * 0.4, h * 0.27)
      ..quadraticBezierTo(w * part, h * 0.2, w * (part - 0.01), h * 0.19)
      ..quadraticBezierTo(w * 0.34, h * 0.26, w * 0.29, h * 0.38)
      ..close();
    canvas.drawPath(fringe, hair);

    // Two soft highlights on the crown, same colour family.
    final shine = stroke(_shine.withValues(alpha: 0.85), 0.016);
    canvas.drawArc(
      Rect.fromCenter(center: p(0.5, 0.23), width: w * 0.26, height: h * 0.12),
      math.pi * 1.12,
      math.pi * 0.35,
      false,
      shine,
    );
    canvas.drawArc(
      Rect.fromCenter(center: p(0.5, 0.25), width: w * 0.36, height: h * 0.18),
      math.pi * 1.62,
      math.pi * 0.16,
      false,
      stroke(_shine.withValues(alpha: 0.6), 0.012),
    );

    // 5. Face details: brows, freckles, cheeks, eyes, mouth.
    final brow = stroke(_brow, 0.021);
    final lift = mood == BenMood.happy ? -0.008 : 0.0;
    canvas.drawLine(p(0.39, 0.37 + lift), p(0.455, 0.365 + lift), brow);
    canvas.drawLine(p(0.545, 0.365 + lift), p(0.61, 0.37 + lift), brow);
    final freckle = Paint()..color = const Color(0xFFD9A07E);
    for (final (x, y) in const [
      (0.385, 0.465),
      (0.405, 0.475),
      (0.395, 0.49),
      (0.615, 0.465),
      (0.595, 0.475),
      (0.605, 0.49),
    ]) {
      canvas.drawCircle(p(x, y), w * 0.0065, freckle);
    }
    final blush = Paint()..color = const Color(0xFFF5A3A8).withValues(alpha: 0.2);
    canvas.drawOval(Rect.fromCenter(center: p(0.375, 0.5), width: w * 0.07, height: h * 0.03), blush);
    canvas.drawOval(Rect.fromCenter(center: p(0.625, 0.5), width: w * 0.07, height: h * 0.03), blush);

    final line = stroke(_ink, 0.014);
    for (final x in [0.43, 0.57]) {
      final c = p(x, 0.425);
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

    final mouth = p(0.5, 0.535);
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
