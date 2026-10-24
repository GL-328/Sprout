import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Drawing helpers for flat, soft icons. Everything is drawn in a 1×1 box:
/// flat pastel fills, rounded shapes, and at most one soft highlight.
class Pen {
  Pen(this.canvas);

  final Canvas canvas;

  static const ink = Color(0xFF4A3F55);
  static const white = Color(0xFFFFFFFF);

  Paint _fill(Color c) => Paint()
    ..color = c
    ..isAntiAlias = true;

  void circle(double x, double y, double r, Color c) => canvas.drawCircle(Offset(x, y), r, _fill(c));

  void oval(double cx, double cy, double w, double h, Color c, {double rot = 0}) {
    if (rot == 0) {
      canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy), width: w, height: h), _fill(c));
      return;
    }
    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(rot);
    canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: w, height: h), _fill(c));
    canvas.restore();
  }

  void rrect(double l, double t, double r, double b, double radius, Color c) =>
      canvas.drawRRect(RRect.fromLTRBR(l, t, r, b, Radius.circular(radius)), _fill(c));

  void fill(Path p, Color c) => canvas.drawPath(p, _fill(c));

  void stroke(Path p, Color c, double width) => canvas.drawPath(
    p,
    Paint()
      ..color = c
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true,
  );

  void line(double x1, double y1, double x2, double y2, Color c, double width) => stroke(
    Path()
      ..moveTo(x1, y1)
      ..lineTo(x2, y2),
    c,
    width,
  );

  /// The one soft highlight.
  void shine(double cx, double cy, double w, double h, {double rot = -0.6}) =>
      oval(cx, cy, w, h, white.withValues(alpha: 0.42), rot: rot);

  /// A leaf shape from [base] pointing at [angle] (radians, 0 = right).
  void leaf(double bx, double by, double length, double width, double angle, Color c) {
    canvas.save();
    canvas.translate(bx, by);
    canvas.rotate(angle);
    final p = Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(length * 0.45, -width, length, 0)
      ..quadraticBezierTo(length * 0.45, width, 0, 0)
      ..close();
    canvas.drawPath(p, _fill(c));
    canvas.restore();
  }

  /// A rounded star with [points] points.
  Path star(double cx, double cy, double outer, double inner, {int points = 5, double rot = -math.pi / 2}) {
    final p = Path();
    for (var i = 0; i < points * 2; i++) {
      final r = i.isEven ? outer : inner;
      final a = rot + i * math.pi / points;
      final pt = Offset(cx + r * math.cos(a), cy + r * math.sin(a));
      i == 0 ? p.moveTo(pt.dx, pt.dy) : p.lineTo(pt.dx, pt.dy);
    }
    return p..close();
  }

  /// Small round eyes and an optional smile, for critters.
  void face(double cx, double cy, double spread, {double eye = 0.032, double smile = 0.05, Color? cheeks}) {
    circle(cx - spread, cy, eye, ink);
    circle(cx + spread, cy, eye, ink);
    if (cheeks != null) {
      oval(cx - spread * 1.55, cy + eye * 2.4, eye * 2.4, eye * 1.5, cheeks);
      oval(cx + spread * 1.55, cy + eye * 2.4, eye * 2.4, eye * 1.5, cheeks);
    }
    if (smile > 0) {
      stroke(
        Path()
          ..moveTo(cx - smile * 0.6, cy + eye * 2.2)
          ..quadraticBezierTo(cx, cy + eye * 2.2 + smile * 0.7, cx + smile * 0.6, cy + eye * 2.2),
        ink,
        0.022,
      );
    }
  }
}

/// Darker shade of [c], for stems and details (same colour family).
Color shade(Color c, [double t = 0.28]) => Color.lerp(c, const Color(0xFF3B2E3A), t)!;

/// Lighter tint of [c].
Color tint(Color c, [double t = 0.45]) => Color.lerp(c, Colors.white, t)!;

/// Draws one icon. [a], [b] and [c] are its colours from the spec table.
typedef IconPaint = void Function(Pen p, Color a, Color b, Color c);

const _leafGreen = Color(0xFF7FC48B);
const _wood = Color(0xFFC9925E);

// --- Core -------------------------------------------------------------------

void paintCoin(Pen p, Color a, Color b, Color c) {
  p.circle(0.5, 0.5, 0.42, a);
  p.circle(0.5, 0.5, 0.33, tint(a, 0.22));
  // The embossed sprout: a soft light edge under a slightly darker shape.
  void sprout(double dx, double dy, Color col) {
    p.stroke(
      Path()
        ..moveTo(0.5 + dx, 0.69 + dy)
        ..quadraticBezierTo(0.49 + dx, 0.55 + dy, 0.5 + dx, 0.46 + dy),
      col,
      0.055,
    );
    p.leaf(0.5 + dx, 0.5 + dy, 0.2, 0.09, -2.5, col);
    p.leaf(0.5 + dx, 0.47 + dy, 0.22, 0.1, -0.55, col);
  }

  sprout(0.012, 0.014, tint(a, 0.6));
  sprout(0, 0, b);
  p.shine(0.33, 0.27, 0.16, 0.08);
}

void paintBag(Pen p, Color a, Color b, Color c) {
  // Top handle.
  p.stroke(
    Path()
      ..moveTo(0.4, 0.24)
      ..quadraticBezierTo(0.5, 0.08, 0.6, 0.24),
    shade(a, 0.35),
    0.06,
  );
  // Side straps peeking out.
  p.rrect(0.13, 0.42, 0.24, 0.78, 0.05, shade(a, 0.18));
  p.rrect(0.76, 0.42, 0.87, 0.78, 0.05, shade(a, 0.18));
  // Body.
  p.rrect(0.2, 0.22, 0.8, 0.9, 0.17, a);
  // Flap.
  p.fill(
    Path()
      ..moveTo(0.2, 0.4)
      ..lineTo(0.2, 0.36)
      ..quadraticBezierTo(0.2, 0.22, 0.37, 0.22)
      ..lineTo(0.63, 0.22)
      ..quadraticBezierTo(0.8, 0.22, 0.8, 0.36)
      ..lineTo(0.8, 0.4)
      ..quadraticBezierTo(0.5, 0.56, 0.2, 0.4)
      ..close(),
    shade(a, 0.14),
  );
  // Front pocket and its button.
  p.rrect(0.31, 0.58, 0.69, 0.82, 0.08, b);
  p.circle(0.5, 0.47, 0.035, c);
  p.shine(0.3, 0.3, 0.1, 0.05);
}

void paintBasket(Pen p, Color a, Color b, Color c) {
  p.stroke(
    Path()
      ..moveTo(0.2, 0.5)
      ..quadraticBezierTo(0.5, 0.0, 0.8, 0.5),
    shade(a, 0.25),
    0.06,
  );
  // Fruit peeking out.
  p.circle(0.38, 0.48, 0.11, c);
  p.circle(0.6, 0.47, 0.1, b);
  p.leaf(0.6, 0.38, 0.1, 0.05, -1.0, _leafGreen);
  // The basket.
  p.fill(
    Path()
      ..moveTo(0.12, 0.5)
      ..lineTo(0.88, 0.5)
      ..lineTo(0.79, 0.84)
      ..quadraticBezierTo(0.77, 0.9, 0.7, 0.9)
      ..lineTo(0.3, 0.9)
      ..quadraticBezierTo(0.23, 0.9, 0.21, 0.84)
      ..close(),
    a,
  );
  p.rrect(0.1, 0.47, 0.9, 0.57, 0.04, shade(a, 0.18));
  for (final x in [0.33, 0.5, 0.67]) {
    p.line(x, 0.62, x - (x - 0.5) * 0.2, 0.85, tint(a, 0.35), 0.03);
  }
  p.shine(0.25, 0.51, 0.1, 0.03, rot: 0);
}

void paintSeed(Pen p, Color a, Color b, Color c) {
  final body = Path()
    ..moveTo(0.5, 0.2)
    ..cubicTo(0.75, 0.32, 0.8, 0.62, 0.68, 0.78)
    ..quadraticBezierTo(0.5, 0.92, 0.32, 0.78)
    ..cubicTo(0.2, 0.62, 0.25, 0.32, 0.5, 0.2)
    ..close();
  p.fill(body, a);
  p.stroke(
    Path()
      ..moveTo(0.5, 0.3)
      ..quadraticBezierTo(0.56, 0.55, 0.5, 0.8),
    shade(a, 0.18),
    0.025,
  );
  p.leaf(0.5, 0.22, 0.17, 0.07, -2.2, b);
  p.leaf(0.5, 0.22, 0.15, 0.06, -0.8, b);
  p.shine(0.39, 0.5, 0.08, 0.17, rot: 0.15);
}

void paintSprout(Pen p, Color a, Color b, Color c) {
  p.oval(0.5, 0.84, 0.5, 0.14, c);
  p.stroke(
    Path()
      ..moveTo(0.5, 0.84)
      ..quadraticBezierTo(0.47, 0.6, 0.5, 0.44),
    shade(a, 0.2),
    0.06,
  );
  p.leaf(0.5, 0.5, 0.32, 0.14, -2.6, a);
  p.leaf(0.5, 0.45, 0.36, 0.15, -0.5, b);
  p.shine(0.68, 0.33, 0.1, 0.04, rot: -0.5);
}

void paintCheck(Pen p, Color a, Color b, Color c) {
  p.circle(0.5, 0.5, 0.4, a);
  p.stroke(
    Path()
      ..moveTo(0.32, 0.51)
      ..lineTo(0.45, 0.64)
      ..lineTo(0.69, 0.38),
    Pen.white,
    0.085,
  );
}

void paintHeart(Pen p, Color a, Color b, Color c) {
  p.fill(
    Path()
      ..moveTo(0.5, 0.86)
      ..cubicTo(0.1, 0.6, 0.08, 0.32, 0.26, 0.22)
      ..cubicTo(0.38, 0.16, 0.48, 0.24, 0.5, 0.33)
      ..cubicTo(0.52, 0.24, 0.62, 0.16, 0.74, 0.22)
      ..cubicTo(0.92, 0.32, 0.9, 0.6, 0.5, 0.86)
      ..close(),
    a,
  );
  p.shine(0.3, 0.34, 0.12, 0.07);
}

void paintMoon(Pen p, Color a, Color b, Color c) {
  final moon = Path.combine(
    PathOperation.difference,
    Path()..addOval(Rect.fromCircle(center: const Offset(0.48, 0.52), radius: 0.34)),
    Path()..addOval(Rect.fromCircle(center: const Offset(0.66, 0.4), radius: 0.3)),
  );
  p.fill(moon, a);
  p.fill(p.star(0.74, 0.7, 0.08, 0.035, points: 4, rot: 0), b);
  p.shine(0.28, 0.5, 0.06, 0.14, rot: 0.2);
}

void paintSun(Pen p, Color a, Color b, Color c) {
  for (var i = 0; i < 8; i++) {
    final ang = i * math.pi / 4;
    p.line(
      0.5 + 0.3 * math.cos(ang),
      0.5 + 0.3 * math.sin(ang),
      0.5 + 0.41 * math.cos(ang),
      0.5 + 0.41 * math.sin(ang),
      b,
      0.07,
    );
  }
  p.circle(0.5, 0.5, 0.24, a);
  p.shine(0.42, 0.42, 0.1, 0.06);
}

void paintSparkle(Pen p, Color a, Color b, Color c) {
  p.fill(p.star(0.44, 0.52, 0.34, 0.1, points: 4, rot: 0), a);
  p.fill(p.star(0.78, 0.24, 0.13, 0.045, points: 4, rot: 0), b);
}

void paintStar(Pen p, Color a, Color b, Color c) {
  final s = p.star(0.5, 0.54, 0.4, 0.2);
  p.fill(s, a);
  p.stroke(s, a, 0.07);
  p.shine(0.38, 0.4, 0.09, 0.05);
}

void paintQuestion(Pen p, Color a, Color b, Color c) {
  p.circle(0.5, 0.5, 0.4, a);
  p.stroke(
    Path()
      ..moveTo(0.38, 0.4)
      ..quadraticBezierTo(0.38, 0.26, 0.5, 0.26)
      ..quadraticBezierTo(0.63, 0.26, 0.63, 0.38)
      ..quadraticBezierTo(0.63, 0.47, 0.5, 0.52)
      ..lineTo(0.5, 0.58),
    b,
    0.075,
  );
  p.circle(0.5, 0.71, 0.045, b);
}

void paintLeaf(Pen p, Color a, Color b, Color c) {
  p.leaf(0.2, 0.8, 0.78, 0.3, -0.8, a);
  p.stroke(
    Path()
      ..moveTo(0.16, 0.84)
      ..quadraticBezierTo(0.45, 0.6, 0.72, 0.28),
    shade(a, 0.22),
    0.035,
  );
  p.shine(0.38, 0.44, 0.12, 0.05, rot: -0.8);
}

void paintTree(Pen p, Color a, Color b, Color c) {
  p.rrect(0.44, 0.55, 0.56, 0.9, 0.05, c);
  p.circle(0.5, 0.42, 0.3, a);
  p.circle(0.32, 0.52, 0.17, a);
  p.circle(0.68, 0.52, 0.17, a);
  p.circle(0.58, 0.3, 0.12, b);
  p.shine(0.38, 0.28, 0.12, 0.06);
}

void paintMap(Pen p, Color a, Color b, Color c) {
  final panels = [(0.12, 0.24, 0.38, 0.18), (0.38, 0.18, 0.62, 0.24), (0.62, 0.24, 0.88, 0.18)];
  for (var i = 0; i < 3; i++) {
    final (l, t1, r, t2) = panels[i];
    p.fill(
      Path()
        ..moveTo(l, t1)
        ..lineTo(r, t2)
        ..lineTo(r, t2 + 0.6)
        ..lineTo(l, t1 + 0.6)
        ..close(),
      i == 1 ? shade(a, 0.08) : a,
    );
  }
  for (var i = 0; i < 5; i++) {
    p.circle(0.22 + i * 0.13, 0.62 - math.sin(i * 1.2) * 0.12, 0.022, b);
  }
  p.fill(p.star(0.78, 0.4, 0.06, 0.028, points: 5), c);
}

void paintCompass(Pen p, Color a, Color b, Color c) {
  p.circle(0.5, 0.5, 0.4, a);
  p.circle(0.5, 0.5, 0.32, tint(a, 0.55));
  p.fill(
    Path()
      ..moveTo(0.5, 0.22)
      ..lineTo(0.58, 0.5)
      ..lineTo(0.42, 0.5)
      ..close(),
    b,
  );
  p.fill(
    Path()
      ..moveTo(0.5, 0.78)
      ..lineTo(0.58, 0.5)
      ..lineTo(0.42, 0.5)
      ..close(),
    c,
  );
  p.circle(0.5, 0.5, 0.045, Pen.white);
}

void paintBell(Pen p, Color a, Color b, Color c) {
  p.circle(0.5, 0.82, 0.07, b);
  p.fill(
    Path()
      ..moveTo(0.18, 0.76)
      ..quadraticBezierTo(0.27, 0.68, 0.28, 0.5)
      ..quadraticBezierTo(0.3, 0.2, 0.5, 0.2)
      ..quadraticBezierTo(0.7, 0.2, 0.72, 0.5)
      ..quadraticBezierTo(0.73, 0.68, 0.82, 0.76)
      ..close(),
    a,
  );
  p.circle(0.5, 0.17, 0.05, a);
  p.shine(0.38, 0.38, 0.06, 0.14, rot: 0.2);
}

void paintPencil(Pen p, Color a, Color b, Color c) {
  p.canvas.save();
  p.canvas.translate(0.5, 0.5);
  p.canvas.rotate(math.pi / 4);
  p.canvas.translate(-0.5, -0.5);
  p.rrect(0.4, 0.08, 0.6, 0.66, 0.04, a);
  p.rrect(0.4, 0.08, 0.6, 0.2, 0.06, b);
  p.fill(
    Path()
      ..moveTo(0.4, 0.66)
      ..lineTo(0.6, 0.66)
      ..lineTo(0.5, 0.88)
      ..close(),
    c,
  );
  p.fill(
    Path()
      ..moveTo(0.465, 0.81)
      ..lineTo(0.535, 0.81)
      ..lineTo(0.5, 0.88)
      ..close(),
    Pen.ink,
  );
  p.canvas.restore();
}

void paintTulip(Pen p, Color a, Color b, Color c) {
  p.stroke(
    Path()
      ..moveTo(0.5, 0.9)
      ..lineTo(0.5, 0.5),
    shade(b, 0.15),
    0.05,
  );
  p.leaf(0.5, 0.82, 0.3, 0.1, -2.4, b);
  p.leaf(0.5, 0.76, 0.28, 0.09, -0.6, b);
  p.fill(
    Path()
      ..moveTo(0.3, 0.26)
      ..lineTo(0.4, 0.36)
      ..lineTo(0.5, 0.2)
      ..lineTo(0.6, 0.36)
      ..lineTo(0.7, 0.26)
      ..quadraticBezierTo(0.74, 0.56, 0.5, 0.58)
      ..quadraticBezierTo(0.26, 0.56, 0.3, 0.26)
      ..close(),
    a,
  );
  p.shine(0.4, 0.42, 0.05, 0.1, rot: 0.2);
}

void paintCloudSun(Pen p, Color a, Color b, Color c) {
  p.circle(0.62, 0.38, 0.2, b);
  p.circle(0.34, 0.62, 0.16, a);
  p.circle(0.52, 0.54, 0.2, a);
  p.circle(0.7, 0.64, 0.14, a);
  p.rrect(0.2, 0.62, 0.84, 0.78, 0.08, a);
}

void paintCompost(Pen p, Color a, Color b, Color c) {
  p.fill(
    Path()
      ..moveTo(0.1, 0.82)
      ..quadraticBezierTo(0.5, 0.36, 0.9, 0.82)
      ..close(),
    a,
  );
  for (final (x, y) in [(0.36, 0.7), (0.55, 0.62), (0.66, 0.74), (0.45, 0.77)]) {
    p.circle(x, y, 0.025, shade(a, 0.25));
  }
  p.stroke(
    Path()
      ..moveTo(0.5, 0.55)
      ..lineTo(0.5, 0.34),
    shade(b, 0.2),
    0.045,
  );
  p.leaf(0.5, 0.38, 0.22, 0.09, -2.5, b);
  p.leaf(0.5, 0.35, 0.24, 0.1, -0.6, b);
}

void paintGift(Pen p, Color a, Color b, Color c) {
  p.rrect(0.18, 0.42, 0.82, 0.88, 0.07, a);
  p.rrect(0.13, 0.32, 0.87, 0.46, 0.06, shade(a, 0.1));
  p.rrect(0.44, 0.32, 0.56, 0.88, 0.02, b);
  p.oval(0.38, 0.26, 0.2, 0.14, b, rot: 0.4);
  p.oval(0.62, 0.26, 0.2, 0.14, b, rot: -0.4);
  p.circle(0.5, 0.3, 0.045, shade(b, 0.15));
  p.fill(p.star(0.5, 0.64, 0.08, 0.035, points: 4, rot: 0), c);
  p.shine(0.27, 0.54, 0.05, 0.1, rot: 0);
}

void paintPlus(Pen p, Color a, Color b, Color c) {
  p.circle(0.5, 0.5, 0.4, a);
  p.line(0.5, 0.32, 0.5, 0.68, Pen.white, 0.09);
  p.line(0.32, 0.5, 0.68, 0.5, Pen.white, 0.09);
}

// --- Fruit --------------------------------------------------------------------

/// An apple-like fruit with a stem and a leaf. [c] is the leaf.
void paintApple(Pen p, Color a, Color b, Color c) {
  p.fill(
    Path()
      ..moveTo(0.5, 0.32)
      ..cubicTo(0.66, 0.2, 0.9, 0.3, 0.86, 0.56)
      ..cubicTo(0.82, 0.8, 0.64, 0.92, 0.5, 0.84)
      ..cubicTo(0.36, 0.92, 0.18, 0.8, 0.14, 0.56)
      ..cubicTo(0.1, 0.3, 0.34, 0.2, 0.5, 0.32)
      ..close(),
    a,
  );
  p.stroke(
    Path()
      ..moveTo(0.5, 0.34)
      ..quadraticBezierTo(0.5, 0.2, 0.56, 0.13),
    b,
    0.045,
  );
  p.leaf(0.54, 0.22, 0.24, 0.09, -0.4, c);
  p.shine(0.3, 0.45, 0.1, 0.16, rot: 0.3);
}

void paintPeach(Pen p, Color a, Color b, Color c) {
  p.circle(0.5, 0.56, 0.34, a);
  p.stroke(
    Path()
      ..moveTo(0.5, 0.26)
      ..quadraticBezierTo(0.62, 0.55, 0.52, 0.88),
    shade(a, 0.14),
    0.03,
  );
  p.leaf(0.5, 0.25, 0.26, 0.1, -0.5, c);
  p.leaf(0.5, 0.25, 0.22, 0.09, -2.7, c);
  p.shine(0.33, 0.45, 0.1, 0.15, rot: 0.3);
}

void paintPear(Pen p, Color a, Color b, Color c) {
  p.fill(
    Path()
      ..moveTo(0.5, 0.22)
      ..cubicTo(0.62, 0.22, 0.62, 0.4, 0.68, 0.48)
      ..cubicTo(0.84, 0.62, 0.8, 0.9, 0.5, 0.9)
      ..cubicTo(0.2, 0.9, 0.16, 0.62, 0.32, 0.48)
      ..cubicTo(0.38, 0.4, 0.38, 0.22, 0.5, 0.22)
      ..close(),
    a,
  );
  p.stroke(
    Path()
      ..moveTo(0.5, 0.24)
      ..quadraticBezierTo(0.5, 0.14, 0.55, 0.1),
    b,
    0.04,
  );
  p.leaf(0.53, 0.17, 0.2, 0.08, -0.3, c);
  p.shine(0.35, 0.66, 0.08, 0.14, rot: 0.3);
}

/// An oval fruit (plum, mango).
void paintOvalFruit(Pen p, Color a, Color b, Color c) {
  p.oval(0.5, 0.56, 0.6, 0.7, a, rot: 0.5);
  p.stroke(
    Path()
      ..moveTo(0.42, 0.24)
      ..quadraticBezierTo(0.36, 0.16, 0.38, 0.1),
    b,
    0.04,
  );
  p.leaf(0.4, 0.2, 0.26, 0.1, -0.2, c);
  p.shine(0.36, 0.48, 0.1, 0.18, rot: 0.5);
}

void paintCherries(Pen p, Color a, Color b, Color c) {
  p.stroke(
    Path()
      ..moveTo(0.33, 0.66)
      ..quadraticBezierTo(0.4, 0.3, 0.58, 0.14),
    b,
    0.04,
  );
  p.stroke(
    Path()
      ..moveTo(0.68, 0.62)
      ..quadraticBezierTo(0.64, 0.32, 0.58, 0.14),
    b,
    0.04,
  );
  p.leaf(0.58, 0.15, 0.22, 0.08, 0.2, c);
  p.circle(0.33, 0.7, 0.17, a);
  p.circle(0.68, 0.66, 0.17, shade(a, 0.08));
  p.shine(0.27, 0.64, 0.05, 0.08, rot: 0.3);
}

/// A cluster of round berries. [b] is the little crown or leaf.
void paintBerries(Pen p, Color a, Color b, Color c) {
  p.leaf(0.5, 0.3, 0.26, 0.1, -0.7, c);
  p.circle(0.34, 0.62, 0.17, a);
  p.circle(0.66, 0.6, 0.17, shade(a, 0.06));
  p.circle(0.5, 0.42, 0.17, tint(a, 0.08));
  for (final (x, y) in [(0.34, 0.62), (0.66, 0.6), (0.5, 0.42)]) {
    p.fill(p.star(x, y - 0.02, 0.05, 0.02, points: 5), b);
  }
  p.shine(0.44, 0.36, 0.05, 0.04);
}

void paintRaspberry(Pen p, Color a, Color b, Color c) {
  p.leaf(0.5, 0.24, 0.22, 0.09, -0.5, c);
  p.leaf(0.5, 0.24, 0.22, 0.09, -2.6, c);
  final dots = <(double, double)>[];
  for (var row = 0; row < 4; row++) {
    final n = 4 - (row == 3 ? 2 : row ~/ 2);
    for (var i = 0; i < n; i++) {
      dots.add((0.5 + (i - (n - 1) / 2) * 0.13, 0.36 + row * 0.13));
    }
  }
  for (final (x, y) in dots) {
    p.circle(x, y, 0.085, a);
  }
  for (final (x, y) in dots) {
    p.circle(x - 0.02, y - 0.025, 0.022, tint(a, 0.4));
  }
}

void paintBananas(Pen p, Color a, Color b, Color c) {
  Path banana(double dy) => Path()
    ..moveTo(0.2, 0.36 + dy)
    ..quadraticBezierTo(0.3, 0.8 + dy, 0.82, 0.6 + dy)
    ..quadraticBezierTo(0.4, 0.66 + dy, 0.28, 0.32 + dy)
    ..close();
  p.fill(banana(-0.06), shade(a, 0.08));
  p.fill(banana(0.08), a);
  p.rrect(0.18, 0.24, 0.3, 0.38, 0.03, b);
  p.circle(0.82, 0.68, 0.025, b);
}

void paintHazelnut(Pen p, Color a, Color b, Color c) {
  p.circle(0.5, 0.6, 0.3, a);
  p.fill(
    Path()
      ..moveTo(0.18, 0.46)
      ..quadraticBezierTo(0.5, 0.06, 0.82, 0.46)
      ..quadraticBezierTo(0.66, 0.36, 0.5, 0.42)
      ..quadraticBezierTo(0.34, 0.36, 0.18, 0.46)
      ..close(),
    c,
  );
  p.circle(0.5, 0.86, 0.045, b);
  p.shine(0.36, 0.6, 0.08, 0.12, rot: 0.3);
}

void paintAcorn(Pen p, Color a, Color b, Color c) {
  p.oval(0.5, 0.6, 0.48, 0.56, a);
  p.fill(
    Path()
      ..moveTo(0.2, 0.46)
      ..quadraticBezierTo(0.2, 0.22, 0.5, 0.22)
      ..quadraticBezierTo(0.8, 0.22, 0.8, 0.46)
      ..quadraticBezierTo(0.5, 0.52, 0.2, 0.46)
      ..close(),
    b,
  );
  for (final x in [0.32, 0.44, 0.56, 0.68]) {
    p.circle(x, 0.36, 0.025, shade(b, 0.18));
  }
  p.line(0.5, 0.22, 0.54, 0.12, shade(b, 0.25), 0.045);
  p.shine(0.38, 0.62, 0.07, 0.13, rot: 0.2);
}

void paintMushroom(Pen p, Color a, Color b, Color c) {
  p.rrect(0.4, 0.5, 0.6, 0.86, 0.08, b);
  p.fill(
    Path()
      ..moveTo(0.12, 0.56)
      ..quadraticBezierTo(0.14, 0.18, 0.5, 0.18)
      ..quadraticBezierTo(0.86, 0.18, 0.88, 0.56)
      ..quadraticBezierTo(0.5, 0.62, 0.12, 0.56)
      ..close(),
    a,
  );
  for (final (x, y, r) in [(0.33, 0.38, 0.05), (0.56, 0.3, 0.045), (0.7, 0.45, 0.04), (0.47, 0.47, 0.035)]) {
    p.circle(x, y, r, c);
  }
  p.shine(0.28, 0.3, 0.09, 0.04, rot: -0.7);
}

/// A flower head with round petals around a centre (sunflower, daisy).
void paintFlowerHead(Pen p, Color a, Color b, Color c) {
  for (var i = 0; i < 10; i++) {
    final ang = i * math.pi / 5;
    p.oval(0.5 + 0.27 * math.cos(ang), 0.5 + 0.27 * math.sin(ang), 0.2, 0.13, a, rot: ang);
  }
  p.circle(0.5, 0.5, 0.19, b);
  for (var i = 0; i < 6; i++) {
    final ang = i * math.pi / 3 + 0.3;
    p.circle(0.5 + 0.09 * math.cos(ang), 0.5 + 0.09 * math.sin(ang), 0.022, shade(b, 0.2));
  }
}

/// A five-petal blossom (cherry blossom, moon blossom, spring).
void paintBlossom(Pen p, Color a, Color b, Color c) {
  for (var i = 0; i < 5; i++) {
    final ang = -math.pi / 2 + i * 2 * math.pi / 5;
    p.circle(0.5 + 0.21 * math.cos(ang), 0.5 + 0.21 * math.sin(ang), 0.17, a);
  }
  p.circle(0.5, 0.5, 0.11, b);
  p.shine(0.44, 0.27, 0.08, 0.04, rot: 0);
}

void paintEdelweiss(Pen p, Color a, Color b, Color c) {
  for (var i = 0; i < 8; i++) {
    final ang = i * math.pi / 4;
    p.leaf(0.5, 0.5, 0.4, 0.1, ang, a);
  }
  for (var i = 0; i < 5; i++) {
    final ang = i * 2 * math.pi / 5;
    p.circle(0.5 + 0.06 * math.cos(ang), 0.5 + 0.06 * math.sin(ang), 0.05, b);
  }
}

void paintLavender(Pen p, Color a, Color b, Color c) {
  for (final (x, tilt) in [(0.36, -0.12), (0.5, 0.0), (0.64, 0.12)]) {
    final topX = x + tilt;
    p.line(0.5, 0.86, topX, 0.3, shade(b, 0.1), 0.035);
    for (var i = 0; i < 5; i++) {
      final t = i / 5;
      final px = topX + (0.5 - topX) * t * 0.6;
      final py = 0.18 + t * 0.3;
      p.oval(px - 0.035, py, 0.07, 0.09, a, rot: -0.4);
      p.oval(px + 0.035, py + 0.02, 0.07, 0.09, shade(a, 0.08), rot: 0.4);
    }
  }
  p.rrect(0.4, 0.68, 0.6, 0.76, 0.03, c);
}

void paintFiddlehead(Pen p, Color a, Color b, Color c) {
  final spiral = Path()..moveTo(0.36, 0.9);
  spiral.quadraticBezierTo(0.3, 0.6, 0.42, 0.46);
  for (var i = 0; i <= 24; i++) {
    final t = i / 24;
    final ang = math.pi + t * math.pi * 2.2;
    final r = 0.2 * (1 - t * 0.8);
    spiral.lineTo(0.56 + r * math.cos(ang), 0.36 + r * math.sin(ang));
  }
  p.stroke(spiral, a, 0.09);
  p.leaf(0.36, 0.72, 0.2, 0.07, -2.6, b);
}

void paintLotusPod(Pen p, Color a, Color b, Color c) {
  p.line(0.5, 0.6, 0.5, 0.92, shade(a, 0.2), 0.05);
  p.fill(
    Path()
      ..moveTo(0.18, 0.28)
      ..quadraticBezierTo(0.5, 0.2, 0.82, 0.28)
      ..quadraticBezierTo(0.72, 0.68, 0.5, 0.66)
      ..quadraticBezierTo(0.28, 0.68, 0.18, 0.28)
      ..close(),
    a,
  );
  p.oval(0.5, 0.29, 0.62, 0.14, tint(a, 0.3));
  for (final (x, y) in [(0.36, 0.29), (0.5, 0.27), (0.64, 0.29), (0.43, 0.32), (0.57, 0.32)]) {
    p.circle(x, y, 0.028, b);
  }
}

void paintBambooShoot(Pen p, Color a, Color b, Color c) {
  p.fill(
    Path()
      ..moveTo(0.5, 0.1)
      ..quadraticBezierTo(0.72, 0.5, 0.7, 0.88)
      ..lineTo(0.3, 0.88)
      ..quadraticBezierTo(0.28, 0.5, 0.5, 0.1)
      ..close(),
    a,
  );
  for (var i = 0; i < 3; i++) {
    final y = 0.44 + i * 0.15;
    p.fill(
      Path()
        ..moveTo(0.3, y + 0.12)
        ..quadraticBezierTo(0.5, y - 0.04, 0.7, y + 0.12)
        ..lineTo(0.7, y + 0.16)
        ..lineTo(0.3, y + 0.16)
        ..close(),
      i.isEven ? b : shade(b, 0.1),
    );
  }
  p.shine(0.44, 0.34, 0.04, 0.12, rot: 0.15);
}

void paintCatkins(Pen p, Color a, Color b, Color c) {
  p.stroke(
    Path()
      ..moveTo(0.14, 0.2)
      ..quadraticBezierTo(0.5, 0.18, 0.86, 0.42),
    b,
    0.04,
  );
  for (final (x, y, r) in [(0.3, 0.42, 0.25), (0.54, 0.5, 0.0), (0.76, 0.62, -0.2)]) {
    p.oval(x, y, 0.15, 0.36, a, rot: r);
  }
  p.leaf(0.62, 0.3, 0.2, 0.07, -0.4, c);
}

void paintDates(Pen p, Color a, Color b, Color c) {
  p.stroke(
    Path()
      ..moveTo(0.5, 0.1)
      ..quadraticBezierTo(0.46, 0.3, 0.5, 0.4),
    b,
    0.04,
  );
  for (final (x, y, r) in [(0.34, 0.56, 0.5), (0.66, 0.56, -0.5), (0.5, 0.68, 0.0), (0.5, 0.44, 0.0)]) {
    p.oval(x, y, 0.22, 0.34, r == 0 && y < 0.5 ? shade(a, 0.08) : a, rot: r);
  }
  p.shine(0.46, 0.62, 0.04, 0.1, rot: 0);
}

void paintCactusFruit(Pen p, Color a, Color b, Color c) {
  p.oval(0.5, 0.56, 0.52, 0.66, a);
  p.fill(
    Path()
      ..moveTo(0.34, 0.24)
      ..lineTo(0.42, 0.3)
      ..lineTo(0.5, 0.18)
      ..lineTo(0.58, 0.3)
      ..lineTo(0.66, 0.24)
      ..lineTo(0.62, 0.34)
      ..lineTo(0.38, 0.34)
      ..close(),
    shade(a, 0.15),
  );
  for (final (x, y) in [(0.38, 0.5), (0.6, 0.46), (0.5, 0.64), (0.36, 0.72), (0.64, 0.7)]) {
    p.circle(x, y, 0.02, b);
  }
  p.shine(0.38, 0.44, 0.06, 0.12, rot: 0.2);
}

void paintAloe(Pen p, Color a, Color b, Color c) {
  for (final (ang, len) in [(-2.4, 0.42), (-0.75, 0.42), (-1.95, 0.5), (-1.2, 0.5), (-1.57, 0.6)]) {
    p.leaf(0.5, 0.86, len, 0.1, ang, ang == -1.57 ? shade(a, 0.08) : a);
  }
  for (final (x, y) in [(0.38, 0.62), (0.62, 0.62), (0.5, 0.5)]) {
    p.circle(x, y, 0.016, b);
  }
  p.rrect(0.3, 0.84, 0.7, 0.92, 0.03, c);
}

void paintCacao(Pen p, Color a, Color b, Color c) {
  p.oval(0.5, 0.52, 0.44, 0.78, a, rot: 0.6);
  p.canvas.save();
  p.canvas.translate(0.5, 0.52);
  p.canvas.rotate(0.6);
  for (final x in [-0.1, 0.0, 0.1]) {
    p.stroke(
      Path()
        ..moveTo(x, -0.3)
        ..quadraticBezierTo(x * 1.6, 0, x, 0.3),
      shade(a, 0.16),
      0.022,
    );
  }
  p.canvas.restore();
  p.line(0.72, 0.2, 0.8, 0.12, b, 0.045);
  p.shine(0.38, 0.4, 0.06, 0.14, rot: 0.6);
}

void paintPineCone(Pen p, Color a, Color b, Color c) {
  p.oval(0.5, 0.56, 0.5, 0.7, a);
  for (var row = 0; row < 5; row++) {
    final y = 0.32 + row * 0.11;
    final n = row == 0 || row == 4 ? 2 : 3;
    for (var i = 0; i < n; i++) {
      final x = 0.5 + (i - (n - 1) / 2) * 0.13;
      p.fill(
        Path()
          ..moveTo(x - 0.06, y)
          ..quadraticBezierTo(x, y + 0.1, x + 0.06, y)
          ..close(),
        shade(a, 0.2),
      );
    }
  }
  p.leaf(0.5, 0.22, 0.18, 0.06, -1.2, c);
  p.leaf(0.5, 0.22, 0.16, 0.06, -2.2, c);
}

void paintCoconut(Pen p, Color a, Color b, Color c) {
  p.circle(0.5, 0.52, 0.36, a);
  p.circle(0.5, 0.52, 0.27, b);
  p.circle(0.5, 0.52, 0.19, tint(b, 0.6));
  p.shine(0.38, 0.4, 0.07, 0.04);
}

void paintSnowflake(Pen p, Color a, Color b, Color c) {
  for (var i = 0; i < 6; i++) {
    final ang = i * math.pi / 3;
    final ex = 0.5 + 0.36 * math.cos(ang);
    final ey = 0.5 + 0.36 * math.sin(ang);
    p.line(0.5, 0.5, ex, ey, a, 0.06);
    final mx = 0.5 + 0.22 * math.cos(ang);
    final my = 0.5 + 0.22 * math.sin(ang);
    for (final side in [-1, 1]) {
      final a2 = ang + side * 0.8;
      p.line(mx, my, mx + 0.1 * math.cos(a2), my + 0.1 * math.sin(a2), a, 0.05);
    }
  }
  p.circle(0.5, 0.5, 0.07, b);
}

void paintMaple(Pen p, Color a, Color b, Color c) {
  final leaf = Path();
  const pts = [
    (0.5, 0.1),
    (0.58, 0.3),
    (0.72, 0.22),
    (0.68, 0.42),
    (0.88, 0.38),
    (0.76, 0.56),
    (0.82, 0.62),
    (0.56, 0.66),
    (0.54, 0.78),
    (0.46, 0.78),
    (0.44, 0.66),
    (0.18, 0.62),
    (0.24, 0.56),
    (0.12, 0.38),
    (0.32, 0.42),
    (0.28, 0.22),
    (0.42, 0.3),
  ];
  for (var i = 0; i < pts.length; i++) {
    final (x, y) = pts[i];
    i == 0 ? leaf.moveTo(x, y) : leaf.lineTo(x, y);
  }
  leaf.close();
  p.fill(leaf, a);
  p.stroke(leaf, a, 0.05);
  p.line(0.5, 0.74, 0.5, 0.92, shade(a, 0.25), 0.04);
  p.line(0.5, 0.7, 0.5, 0.3, shade(a, 0.18), 0.025);
}

void paintRose(Pen p, Color a, Color b, Color c) {
  p.leaf(0.5, 0.7, 0.3, 0.1, 0.4, c);
  p.leaf(0.5, 0.7, 0.3, 0.1, 2.7, c);
  p.circle(0.5, 0.48, 0.3, a);
  p.stroke(
    Path()
      ..moveTo(0.5, 0.48)
      ..quadraticBezierTo(0.62, 0.42, 0.58, 0.34)
      ..quadraticBezierTo(0.48, 0.26, 0.38, 0.38)
      ..quadraticBezierTo(0.32, 0.56, 0.52, 0.62)
      ..quadraticBezierTo(0.7, 0.6, 0.72, 0.44),
    shade(a, 0.18),
    0.035,
  );
}

void paintBambooStalk(Pen p, Color a, Color b, Color c) {
  for (final x in [0.36, 0.6]) {
    final top = x < 0.5 ? 0.12 : 0.24;
    p.rrect(x - 0.07, top, x + 0.07, 0.92, 0.05, x < 0.5 ? a : shade(a, 0.08));
    for (var y = top + 0.2; y < 0.9; y += 0.22) {
      p.rrect(x - 0.08, y, x + 0.08, y + 0.035, 0.02, shade(a, 0.2));
    }
  }
  p.leaf(0.43, 0.32, 0.3, 0.09, -0.5, b);
  p.leaf(0.53, 0.5, 0.3, 0.09, -0.3, b);
}

void paintMoonflower(Pen p, Color a, Color b, Color c) {
  paintBlossom(p, a, b, c);
  final moon = Path.combine(
    PathOperation.difference,
    Path()..addOval(Rect.fromCircle(center: const Offset(0.8, 0.2), radius: 0.13)),
    Path()..addOval(Rect.fromCircle(center: const Offset(0.86, 0.15), radius: 0.11)),
  );
  p.fill(moon, c);
}

// --- Visitors -----------------------------------------------------------------

void paintButterfly(Pen p, Color a, Color b, Color c) {
  p.oval(0.32, 0.38, 0.34, 0.38, a, rot: -0.4);
  p.oval(0.68, 0.38, 0.34, 0.38, a, rot: 0.4);
  p.oval(0.36, 0.66, 0.24, 0.26, b, rot: 0.4);
  p.oval(0.64, 0.66, 0.24, 0.26, b, rot: -0.4);
  p.circle(0.3, 0.36, 0.06, tint(a, 0.5));
  p.circle(0.7, 0.36, 0.06, tint(a, 0.5));
  p.rrect(0.465, 0.3, 0.535, 0.78, 0.035, c);
  p.stroke(
    Path()
      ..moveTo(0.49, 0.3)
      ..quadraticBezierTo(0.45, 0.2, 0.4, 0.17),
    c,
    0.025,
  );
  p.stroke(
    Path()
      ..moveTo(0.51, 0.3)
      ..quadraticBezierTo(0.55, 0.2, 0.6, 0.17),
    c,
    0.025,
  );
}

void paintBee(Pen p, Color a, Color b, Color c) {
  p.oval(0.42, 0.3, 0.24, 0.3, tint(c, 0.75), rot: -0.5);
  p.oval(0.6, 0.28, 0.22, 0.28, tint(c, 0.75), rot: 0.4);
  p.oval(0.5, 0.58, 0.62, 0.48, a);
  p.canvas.save();
  p.canvas.clipPath(Path()..addOval(Rect.fromCenter(center: const Offset(0.5, 0.58), width: 0.62, height: 0.48)));
  p.rrect(0.44, 0.3, 0.54, 0.9, 0.0, b);
  p.rrect(0.62, 0.3, 0.72, 0.9, 0.0, b);
  p.canvas.restore();
  p.face(0.31, 0.56, 0.045, eye: 0.024, smile: 0.035);
  p.shine(0.34, 0.44, 0.07, 0.035);
}

/// A round little bird. [a] body, [b] belly and wing, [c] beak.
void paintBird(Pen p, Color a, Color b, Color c) {
  p.fill(
    Path()
      ..moveTo(0.78, 0.6)
      ..lineTo(0.94, 0.5)
      ..lineTo(0.9, 0.68)
      ..close(),
    shade(a, 0.12),
  );
  p.circle(0.5, 0.55, 0.32, a);
  p.oval(0.48, 0.68, 0.36, 0.24, b);
  p.oval(0.62, 0.58, 0.22, 0.14, shade(a, 0.12), rot: 0.3);
  p.fill(
    Path()
      ..moveTo(0.2, 0.48)
      ..lineTo(0.08, 0.53)
      ..lineTo(0.2, 0.57)
      ..close(),
    c,
  );
  p.circle(0.32, 0.46, 0.032, Pen.ink);
  p.shine(0.4, 0.32, 0.1, 0.05);
}

void paintParrot(Pen p, Color a, Color b, Color c) {
  p.fill(
    Path()
      ..moveTo(0.58, 0.7)
      ..lineTo(0.72, 0.96)
      ..lineTo(0.5, 0.8)
      ..close(),
    shade(a, 0.12),
  );
  p.oval(0.52, 0.56, 0.44, 0.58, a);
  p.circle(0.46, 0.32, 0.2, b);
  p.oval(0.62, 0.6, 0.2, 0.36, shade(a, 0.14), rot: 0.2);
  p.fill(
    Path()
      ..moveTo(0.28, 0.3)
      ..quadraticBezierTo(0.14, 0.32, 0.2, 0.46)
      ..lineTo(0.3, 0.4)
      ..close(),
    c,
  );
  p.circle(0.42, 0.28, 0.03, Pen.ink);
  p.shine(0.5, 0.2, 0.08, 0.04);
}

void paintDuck(Pen p, Color a, Color b, Color c) {
  p.oval(0.56, 0.66, 0.62, 0.4, a);
  p.circle(0.36, 0.38, 0.2, a);
  p.oval(0.66, 0.66, 0.28, 0.18, shade(a, 0.08), rot: -0.2);
  p.oval(0.13, 0.42, 0.18, 0.09, c);
  p.circle(0.32, 0.34, 0.03, Pen.ink);
  p.oval(0.42, 0.48, 0.07, 0.04, tint(c, 0.4));
  p.shine(0.38, 0.26, 0.08, 0.04);
}

void paintLadybird(Pen p, Color a, Color b, Color c) {
  p.circle(0.5, 0.26, 0.14, b);
  p.circle(0.5, 0.58, 0.34, a);
  p.line(0.5, 0.28, 0.5, 0.92, b, 0.03);
  for (final (x, y, r) in [(0.36, 0.48, 0.055), (0.64, 0.48, 0.055), (0.34, 0.7, 0.05), (0.66, 0.7, 0.05)]) {
    p.circle(x, y, r, b);
  }
  p.circle(0.45, 0.24, 0.025, Pen.white);
  p.circle(0.55, 0.24, 0.025, Pen.white);
  p.shine(0.36, 0.38, 0.08, 0.04);
}

void paintFirefly(Pen p, Color a, Color b, Color c) {
  p.circle(0.58, 0.64, 0.24, tint(a, 0.6));
  p.oval(0.36, 0.36, 0.22, 0.3, tint(c, 0.8), rot: -0.6);
  p.oval(0.56, 0.32, 0.2, 0.28, tint(c, 0.8), rot: 0.3);
  p.oval(0.56, 0.62, 0.22, 0.28, a, rot: -0.6);
  p.oval(0.4, 0.48, 0.2, 0.24, b, rot: -0.6);
  p.circle(0.3, 0.4, 0.1, b);
  p.circle(0.27, 0.38, 0.022, Pen.white);
  p.fill(p.star(0.82, 0.3, 0.07, 0.025, points: 4, rot: 0), a);
}

void paintHedgehog(Pen p, Color a, Color b, Color c) {
  final spikes = Path()..moveTo(0.2, 0.74);
  for (var i = 0; i <= 14; i++) {
    final ang = math.pi + i * math.pi / 14;
    final r = i.isEven ? 0.3 : 0.4;
    spikes.lineTo(0.56 + r * math.cos(ang), 0.7 + r * math.sin(ang) * 1.1);
  }
  spikes.close();
  p.fill(spikes, a);
  p.oval(0.56, 0.66, 0.6, 0.42, a);
  p.oval(0.3, 0.68, 0.36, 0.3, b);
  p.circle(0.14, 0.7, 0.04, Pen.ink);
  p.circle(0.3, 0.62, 0.03, Pen.ink);
  p.oval(0.34, 0.72, 0.08, 0.04, c);
  p.oval(0.4, 0.88, 0.1, 0.05, shade(b, 0.2));
  p.oval(0.7, 0.88, 0.1, 0.05, shade(b, 0.2));
}

void paintSquirrel(Pen p, Color a, Color b, Color c) {
  final tail = Path()
    ..moveTo(0.6, 0.86)
    ..cubicTo(0.98, 0.84, 0.98, 0.36, 0.8, 0.2)
    ..cubicTo(0.66, 0.08, 0.56, 0.24, 0.66, 0.34)
    ..cubicTo(0.8, 0.46, 0.76, 0.66, 0.6, 0.7)
    ..close();
  p.fill(tail, shade(a, 0.08));
  p.oval(0.44, 0.66, 0.36, 0.42, a);
  p.oval(0.42, 0.72, 0.2, 0.26, b);
  p.circle(0.38, 0.38, 0.18, a);
  p.fill(
    Path()
      ..moveTo(0.26, 0.3)
      ..lineTo(0.26, 0.14)
      ..lineTo(0.36, 0.24)
      ..close(),
    a,
  );
  p.fill(
    Path()
      ..moveTo(0.42, 0.24)
      ..lineTo(0.5, 0.12)
      ..lineTo(0.52, 0.28)
      ..close(),
    a,
  );
  p.circle(0.33, 0.37, 0.026, Pen.ink);
  p.circle(0.45, 0.37, 0.026, Pen.ink);
  p.circle(0.39, 0.44, 0.02, c);
}

void paintFox(Pen p, Color a, Color b, Color c) {
  p.fill(
    Path()
      ..moveTo(0.18, 0.42)
      ..lineTo(0.2, 0.12)
      ..lineTo(0.42, 0.28)
      ..close(),
    a,
  );
  p.fill(
    Path()
      ..moveTo(0.82, 0.42)
      ..lineTo(0.8, 0.12)
      ..lineTo(0.58, 0.28)
      ..close(),
    a,
  );
  p.fill(
    Path()
      ..moveTo(0.24, 0.34)
      ..lineTo(0.25, 0.2)
      ..lineTo(0.35, 0.28)
      ..close(),
    c,
  );
  p.fill(
    Path()
      ..moveTo(0.76, 0.34)
      ..lineTo(0.75, 0.2)
      ..lineTo(0.65, 0.28)
      ..close(),
    c,
  );
  p.fill(
    Path()
      ..moveTo(0.14, 0.4)
      ..quadraticBezierTo(0.5, 0.18, 0.86, 0.4)
      ..quadraticBezierTo(0.84, 0.66, 0.5, 0.86)
      ..quadraticBezierTo(0.16, 0.66, 0.14, 0.4)
      ..close(),
    a,
  );
  p.fill(
    Path()
      ..moveTo(0.18, 0.5)
      ..quadraticBezierTo(0.36, 0.52, 0.5, 0.64)
      ..quadraticBezierTo(0.64, 0.52, 0.82, 0.5)
      ..quadraticBezierTo(0.74, 0.7, 0.5, 0.86)
      ..quadraticBezierTo(0.26, 0.7, 0.18, 0.5)
      ..close(),
    b,
  );
  p.circle(0.36, 0.46, 0.034, Pen.ink);
  p.circle(0.64, 0.46, 0.034, Pen.ink);
  p.circle(0.5, 0.74, 0.04, Pen.ink);
}

void paintRabbit(Pen p, Color a, Color b, Color c) {
  p.oval(0.38, 0.26, 0.15, 0.44, a, rot: -0.15);
  p.oval(0.62, 0.26, 0.15, 0.44, a, rot: 0.15);
  p.oval(0.38, 0.28, 0.07, 0.3, c, rot: -0.15);
  p.oval(0.62, 0.28, 0.07, 0.3, c, rot: 0.15);
  p.oval(0.5, 0.64, 0.56, 0.48, a);
  p.oval(0.5, 0.74, 0.24, 0.16, b);
  p.face(0.5, 0.6, 0.11, eye: 0.03, smile: 0, cheeks: tint(c, 0.2));
  p.oval(0.5, 0.69, 0.06, 0.04, c);
}

void paintFrog(Pen p, Color a, Color b, Color c) {
  p.circle(0.32, 0.34, 0.14, a);
  p.circle(0.68, 0.34, 0.14, a);
  p.oval(0.5, 0.62, 0.74, 0.5, a);
  p.oval(0.5, 0.72, 0.42, 0.24, b);
  p.circle(0.32, 0.33, 0.08, Pen.white);
  p.circle(0.68, 0.33, 0.08, Pen.white);
  p.circle(0.33, 0.34, 0.045, Pen.ink);
  p.circle(0.67, 0.34, 0.045, Pen.ink);
  p.stroke(
    Path()
      ..moveTo(0.36, 0.56)
      ..quadraticBezierTo(0.5, 0.64, 0.64, 0.56),
    shade(a, 0.4),
    0.025,
  );
  p.oval(0.26, 0.6, 0.08, 0.05, c);
  p.oval(0.74, 0.6, 0.08, 0.05, c);
}

void paintLizard(Pen p, Color a, Color b, Color c) {
  p.stroke(
    Path()
      ..moveTo(0.62, 0.6)
      ..cubicTo(0.86, 0.6, 0.9, 0.84, 0.72, 0.86)
      ..quadraticBezierTo(0.62, 0.86, 0.66, 0.78),
    a,
    0.08,
  );
  p.oval(0.46, 0.56, 0.42, 0.22, a, rot: 0.1);
  p.oval(0.22, 0.44, 0.26, 0.18, a, rot: -0.3);
  for (final (x, y) in [(0.36, 0.68), (0.56, 0.7), (0.34, 0.44), (0.56, 0.44)]) {
    p.oval(x, y, 0.08, 0.12, shade(a, 0.1), rot: 0.4);
  }
  for (final x in [0.4, 0.5, 0.6]) {
    p.circle(x, 0.53, 0.025, b);
  }
  p.circle(0.18, 0.4, 0.028, Pen.ink);
  p.oval(0.14, 0.48, 0.05, 0.025, c);
}

void paintOwl(Pen p, Color a, Color b, Color c) {
  p.fill(
    Path()
      ..moveTo(0.22, 0.3)
      ..lineTo(0.26, 0.12)
      ..lineTo(0.4, 0.24)
      ..close(),
    a,
  );
  p.fill(
    Path()
      ..moveTo(0.78, 0.3)
      ..lineTo(0.74, 0.12)
      ..lineTo(0.6, 0.24)
      ..close(),
    a,
  );
  p.oval(0.5, 0.56, 0.62, 0.7, a);
  p.oval(0.5, 0.7, 0.36, 0.36, b);
  p.circle(0.37, 0.42, 0.12, tint(b, 0.4));
  p.circle(0.63, 0.42, 0.12, tint(b, 0.4));
  p.circle(0.37, 0.42, 0.05, Pen.ink);
  p.circle(0.63, 0.42, 0.05, Pen.ink);
  p.fill(
    Path()
      ..moveTo(0.46, 0.5)
      ..lineTo(0.54, 0.5)
      ..lineTo(0.5, 0.58)
      ..close(),
    c,
  );
  for (final (x, y) in [(0.42, 0.68), (0.58, 0.68), (0.5, 0.76)]) {
    p.stroke(
      Path()
        ..moveTo(x - 0.03, y)
        ..quadraticBezierTo(x, y + 0.03, x + 0.03, y),
      shade(b, 0.2),
      0.018,
    );
  }
}

void paintSloth(Pen p, Color a, Color b, Color c) {
  p.circle(0.5, 0.52, 0.38, a);
  p.oval(0.5, 0.56, 0.56, 0.46, b);
  p.oval(0.37, 0.52, 0.18, 0.1, c, rot: 0.35);
  p.oval(0.63, 0.52, 0.18, 0.1, c, rot: -0.35);
  p.circle(0.37, 0.52, 0.026, Pen.white);
  p.circle(0.63, 0.52, 0.026, Pen.white);
  p.oval(0.5, 0.62, 0.08, 0.05, c);
  p.stroke(
    Path()
      ..moveTo(0.44, 0.69)
      ..quadraticBezierTo(0.5, 0.74, 0.56, 0.69),
    c,
    0.022,
  );
  p.shine(0.36, 0.22, 0.1, 0.04, rot: -0.3);
}

void paintGoat(Pen p, Color a, Color b, Color c) {
  p.stroke(
    Path()
      ..moveTo(0.38, 0.28)
      ..quadraticBezierTo(0.26, 0.08, 0.14, 0.18),
    c,
    0.06,
  );
  p.stroke(
    Path()
      ..moveTo(0.62, 0.28)
      ..quadraticBezierTo(0.74, 0.08, 0.86, 0.18),
    c,
    0.06,
  );
  p.oval(0.16, 0.42, 0.24, 0.11, b, rot: 0.4);
  p.oval(0.84, 0.42, 0.24, 0.11, b, rot: -0.4);
  p.oval(0.5, 0.5, 0.46, 0.56, a);
  p.fill(
    Path()
      ..moveTo(0.44, 0.74)
      ..lineTo(0.56, 0.74)
      ..lineTo(0.5, 0.94)
      ..close(),
    b,
  );
  p.oval(0.5, 0.68, 0.3, 0.2, tint(c, 0.6));
  p.circle(0.38, 0.46, 0.03, Pen.ink);
  p.circle(0.62, 0.46, 0.03, Pen.ink);
  p.oval(0.45, 0.66, 0.04, 0.03, shade(c, 0.2));
  p.oval(0.55, 0.66, 0.04, 0.03, shade(c, 0.2));
}

// --- Decorations --------------------------------------------------------------

void paintStones(Pen p, Color a, Color b, Color c) {
  for (final (x, y, w, h) in [(0.3, 0.74, 0.32, 0.2), (0.62, 0.52, 0.34, 0.22), (0.4, 0.3, 0.28, 0.17)]) {
    p.oval(x, y, w, h, a);
    p.oval(x - w * 0.12, y - h * 0.18, w * 0.4, h * 0.3, tint(a, 0.4));
  }
  p.leaf(0.76, 0.82, 0.14, 0.05, -1.9, b);
  p.leaf(0.76, 0.82, 0.12, 0.05, -1.1, b);
}

void paintPetalPath(Pen p, Color a, Color b, Color c) {
  for (final (x, y, s) in [(0.28, 0.76, 1.0), (0.56, 0.6, 0.9), (0.38, 0.4, 0.8), (0.66, 0.24, 0.7)]) {
    for (var i = 0; i < 5; i++) {
      final ang = -math.pi / 2 + i * 2 * math.pi / 5;
      p.circle(x + 0.07 * s * math.cos(ang), y + 0.07 * s * math.sin(ang), 0.06 * s, a);
    }
    p.circle(x, y, 0.035 * s, b);
  }
}

void paintFence(Pen p, Color a, Color b, Color c) {
  p.rrect(0.08, 0.44, 0.92, 0.52, 0.02, shade(a, 0.12));
  p.rrect(0.08, 0.68, 0.92, 0.76, 0.02, shade(a, 0.12));
  for (final x in [0.18, 0.4, 0.62, 0.84]) {
    p.fill(
      Path()
        ..moveTo(x - 0.08, 0.88)
        ..lineTo(x - 0.08, 0.3)
        ..lineTo(x, 0.2)
        ..lineTo(x + 0.08, 0.3)
        ..lineTo(x + 0.08, 0.88)
        ..close(),
      a,
    );
  }
  p.leaf(0.3, 0.9, 0.16, 0.06, -2.0, b);
  p.leaf(0.72, 0.9, 0.16, 0.06, -1.1, b);
}

void paintHedge(Pen p, Color a, Color b, Color c) {
  p.rrect(0.1, 0.42, 0.9, 0.86, 0.14, a);
  for (final (x, y) in [(0.24, 0.42), (0.42, 0.36), (0.6, 0.38), (0.78, 0.43)]) {
    p.circle(x, y, 0.13, a);
  }
  for (final (x, y) in [(0.3, 0.58), (0.58, 0.52), (0.72, 0.7), (0.42, 0.74)]) {
    p.circle(x, y, 0.035, b);
  }
  p.shine(0.38, 0.3, 0.12, 0.05, rot: -0.2);
}

void paintPond(Pen p, Color a, Color b, Color c) {
  p.oval(0.5, 0.62, 0.86, 0.5, a);
  p.oval(0.5, 0.6, 0.66, 0.34, tint(a, 0.3));
  final pad = Path.combine(
    PathOperation.difference,
    Path()..addOval(Rect.fromCircle(center: const Offset(0.38, 0.62), radius: 0.12)),
    Path()
      ..moveTo(0.38, 0.62)
      ..lineTo(0.52, 0.52)
      ..lineTo(0.52, 0.62)
      ..close(),
  );
  p.fill(pad, b);
  paintSmallBlossom(p, 0.64, 0.56, 0.08, c, const Color(0xFFFFE08A));
}

void paintSmallBlossom(Pen p, double x, double y, double r, Color petal, Color centre) {
  for (var i = 0; i < 5; i++) {
    final ang = -math.pi / 2 + i * 2 * math.pi / 5;
    p.circle(x + r * math.cos(ang), y + r * math.sin(ang), r * 0.8, petal);
  }
  p.circle(x, y, r * 0.5, centre);
}

void paintBench(Pen p, Color a, Color b, Color c) {
  p.rrect(0.14, 0.26, 0.86, 0.36, 0.04, a);
  p.rrect(0.14, 0.4, 0.86, 0.48, 0.04, a);
  p.rrect(0.1, 0.56, 0.9, 0.66, 0.04, shade(a, 0.08));
  for (final x in [0.2, 0.76]) {
    p.rrect(x, 0.3, x + 0.06, 0.88, 0.03, shade(a, 0.22));
  }
  p.shine(0.3, 0.29, 0.12, 0.025, rot: 0);
}

void paintLantern(Pen p, Color a, Color b, Color c) {
  p.line(0.5, 0.04, 0.5, 0.16, c, 0.03);
  p.rrect(0.38, 0.14, 0.62, 0.2, 0.02, c);
  p.oval(0.5, 0.5, 0.56, 0.62, a);
  for (final x in [0.36, 0.5, 0.64]) {
    p.stroke(
      Path()
        ..moveTo(x, 0.21)
        ..quadraticBezierTo(x + (x - 0.5) * 0.7, 0.5, x, 0.79),
      shade(a, 0.14),
      0.02,
    );
  }
  p.rrect(0.38, 0.79, 0.62, 0.85, 0.02, c);
  p.line(0.5, 0.86, 0.5, 0.96, b, 0.03);
  p.shine(0.36, 0.38, 0.06, 0.14, rot: 0.2);
}

void paintFairyLights(Pen p, Color a, Color b, Color c) {
  p.stroke(
    Path()
      ..moveTo(0.06, 0.26)
      ..quadraticBezierTo(0.5, 0.74, 0.94, 0.26),
    shade(c, 0.1),
    0.025,
  );
  final colours = [a, b, const Color(0xFFA6D9F7), a, b];
  for (var i = 0; i < 5; i++) {
    final t = (i + 0.5) / 5;
    final x = 0.06 + 0.88 * t;
    final y = 0.26 + 0.48 * 4 * t * (1 - t) * 0.5;
    p.rrect(x - 0.025, y - 0.01, x + 0.025, y + 0.035, 0.01, c);
    p.oval(x, y + 0.1, 0.1, 0.14, colours[i]);
    p.circle(x - 0.015, y + 0.08, 0.015, Pen.white.withValues(alpha: 0.6));
  }
}

void paintSky(Pen p, Color a, Color b, Color c) {
  p.canvas.save();
  p.canvas.clipRRect(RRect.fromLTRBR(0.1, 0.1, 0.9, 0.9, const Radius.circular(0.2)));
  p.rrect(0.1, 0.1, 0.9, 0.9, 0.2, a);
  p.circle(0.5, 0.74, 0.22, c);
  p.rrect(0.1, 0.56, 0.9, 0.64, 0, b.withValues(alpha: 0.75));
  p.rrect(0.1, 0.72, 0.9, 0.9, 0, b);
  p.canvas.restore();
}

void paintAurora(Pen p, Color a, Color b, Color c) {
  p.canvas.save();
  p.canvas.clipRRect(RRect.fromLTRBR(0.1, 0.1, 0.9, 0.9, const Radius.circular(0.2)));
  p.rrect(0.1, 0.1, 0.9, 0.9, 0.2, a);
  for (final (dy, col) in [(0.0, b), (0.16, c)]) {
    p.stroke(
      Path()
        ..moveTo(0.04, 0.42 + dy)
        ..cubicTo(0.3, 0.2 + dy, 0.5, 0.6 + dy, 0.96, 0.32 + dy),
      col,
      0.09,
    );
  }
  for (final (x, y) in [(0.26, 0.24), (0.7, 0.2), (0.78, 0.72), (0.34, 0.76)]) {
    p.circle(x, y, 0.018, Pen.white);
  }
  p.canvas.restore();
}

// --- Plots --------------------------------------------------------------------

/// Rounded ground with a sky: the base of every plot icon.
void _plotBase(Pen p, Color sky, Color ground) {
  p.canvas.save();
  p.canvas.clipRRect(RRect.fromLTRBR(0.08, 0.08, 0.92, 0.92, const Radius.circular(0.22)));
  p.rrect(0.08, 0.08, 0.92, 0.92, 0.22, sky);
  p.fill(
    Path()
      ..moveTo(0.0, 0.72)
      ..quadraticBezierTo(0.5, 0.56, 1.0, 0.72)
      ..lineTo(1, 1)
      ..lineTo(0, 1)
      ..close(),
    ground,
  );
}

void paintMeadow(Pen p, Color a, Color b, Color c) {
  _plotBase(p, a, b);
  for (final (x, y, col) in [(0.3, 0.72, c), (0.52, 0.68, const Color(0xFFFFFFFF)), (0.72, 0.74, c)]) {
    p.line(x, y, x, y + 0.12, shade(b, 0.2), 0.02);
    paintSmallBlossom(p, x, y, 0.045, col, const Color(0xFFFFC93C));
  }
  p.circle(0.74, 0.28, 0.08, const Color(0xFFFFE08A));
  p.canvas.restore();
}

void paintForest(Pen p, Color a, Color b, Color c) {
  _plotBase(p, a, b);
  for (final (x, s) in [(0.34, 1.0), (0.64, 0.82)]) {
    p.rrect(x - 0.025, 0.66, x + 0.025, 0.78, 0.01, _wood);
    for (var i = 0; i < 3; i++) {
      final y = 0.26 + i * 0.13 * s + (1 - s) * 0.3;
      final w = (0.14 + i * 0.05) * s;
      p.fill(
        Path()
          ..moveTo(x, y)
          ..lineTo(x + w, y + 0.2 * s)
          ..lineTo(x - w, y + 0.2 * s)
          ..close(),
        i.isEven ? c : shade(c, 0.08),
      );
    }
  }
  p.canvas.restore();
}

void paintOrchard(Pen p, Color a, Color b, Color c) {
  _plotBase(p, a, b);
  p.rrect(0.46, 0.5, 0.54, 0.76, 0.02, _wood);
  p.circle(0.5, 0.4, 0.2, shade(b, 0.05));
  p.circle(0.36, 0.48, 0.12, shade(b, 0.05));
  p.circle(0.64, 0.48, 0.12, shade(b, 0.05));
  for (final (x, y) in [(0.4, 0.38), (0.58, 0.32), (0.62, 0.5), (0.44, 0.52)]) {
    p.circle(x, y, 0.035, c);
  }
  p.canvas.restore();
}

void paintWetland(Pen p, Color a, Color b, Color c) {
  _plotBase(p, a, b);
  p.oval(0.5, 0.78, 0.6, 0.16, const Color(0xFF8CC9E8));
  p.circle(0.4, 0.78, 0.05, const Color(0xFF6FBF8E));
  paintSmallBlossom(p, 0.6, 0.76, 0.035, c, const Color(0xFFFFE08A));
  for (final x in [0.2, 0.26, 0.8]) {
    p.line(x, 0.76, x + 0.02, 0.48, shade(b, 0.2), 0.025);
    p.oval(x + 0.02, 0.5, 0.04, 0.1, const Color(0xFFB07A44));
  }
  p.canvas.restore();
}

void paintDesert(Pen p, Color a, Color b, Color c) {
  _plotBase(p, a, b);
  p.circle(0.72, 0.28, 0.09, const Color(0xFFFFC93C));
  p.rrect(0.36, 0.34, 0.48, 0.74, 0.06, c);
  p.rrect(0.24, 0.46, 0.32, 0.6, 0.04, c);
  p.rrect(0.24, 0.56, 0.4, 0.62, 0.03, c);
  p.rrect(0.52, 0.4, 0.6, 0.54, 0.04, c);
  p.rrect(0.44, 0.5, 0.6, 0.56, 0.03, c);
  p.canvas.restore();
}

void paintTropical(Pen p, Color a, Color b, Color c) {
  _plotBase(p, a, b);
  p.stroke(
    Path()
      ..moveTo(0.48, 0.76)
      ..quadraticBezierTo(0.5, 0.5, 0.6, 0.34),
    _wood,
    0.05,
  );
  for (final ang in [-2.8, -2.0, -1.1, -0.3, 0.4]) {
    p.leaf(0.6, 0.34, 0.26, 0.08, ang, c);
  }
  p.circle(0.58, 0.38, 0.03, const Color(0xFF8B5A2B));
  p.canvas.restore();
}

void paintAlpine(Pen p, Color a, Color b, Color c) {
  _plotBase(p, a, b);
  p.fill(
    Path()
      ..moveTo(0.1, 0.74)
      ..lineTo(0.44, 0.26)
      ..lineTo(0.78, 0.74)
      ..close(),
    c,
  );
  p.fill(
    Path()
      ..moveTo(0.44, 0.74)
      ..lineTo(0.68, 0.42)
      ..lineTo(0.96, 0.74)
      ..close(),
    shade(c, 0.1),
  );
  p.fill(
    Path()
      ..moveTo(0.33, 0.42)
      ..lineTo(0.44, 0.26)
      ..lineTo(0.55, 0.42)
      ..lineTo(0.49, 0.39)
      ..lineTo(0.44, 0.43)
      ..lineTo(0.39, 0.39)
      ..close(),
    Pen.white,
  );
  p.canvas.restore();
}

// --- Recipes ------------------------------------------------------------------

void _bowl(Pen p, Color bowl) {
  p.fill(
    Path()
      ..moveTo(0.1, 0.5)
      ..lineTo(0.9, 0.5)
      ..quadraticBezierTo(0.86, 0.86, 0.5, 0.88)
      ..quadraticBezierTo(0.14, 0.86, 0.1, 0.5)
      ..close(),
    bowl,
  );
  p.rrect(0.08, 0.47, 0.92, 0.53, 0.03, shade(bowl, 0.1));
  p.shine(0.24, 0.62, 0.05, 0.1, rot: 0.4);
}

void paintSalad(Pen p, Color a, Color b, Color c) {
  for (final (x, y, r, col) in [
    (0.32, 0.44, 0.1, b),
    (0.5, 0.38, 0.11, c),
    (0.68, 0.44, 0.1, const Color(0xFFFFC93C)),
    (0.42, 0.48, 0.08, const Color(0xFF8BD18F)),
    (0.6, 0.49, 0.08, b),
  ]) {
    p.circle(x, y, r, col);
  }
  _bowl(p, a);
}

void paintGranola(Pen p, Color a, Color b, Color c) {
  p.oval(0.5, 0.48, 0.74, 0.18, b);
  for (final (x, y) in [(0.3, 0.44), (0.42, 0.4), (0.56, 0.42), (0.68, 0.44), (0.5, 0.46)]) {
    p.circle(x, y, 0.035, c);
  }
  p.circle(0.6, 0.38, 0.05, const Color(0xFFE5486B));
  _bowl(p, a);
}

void paintStew(Pen p, Color a, Color b, Color c) {
  for (final x in [0.38, 0.52, 0.66]) {
    p.stroke(
      Path()
        ..moveTo(x, 0.34)
        ..quadraticBezierTo(x - 0.05, 0.25, x, 0.18)
        ..quadraticBezierTo(x + 0.05, 0.12, x, 0.06),
      tint(c, 0.4),
      0.03,
    );
  }
  p.rrect(0.04, 0.5, 0.18, 0.56, 0.03, shade(a, 0.2));
  p.rrect(0.82, 0.5, 0.96, 0.56, 0.03, shade(a, 0.2));
  p.rrect(0.14, 0.38, 0.86, 0.86, 0.14, a);
  p.oval(0.5, 0.42, 0.68, 0.12, b);
  p.circle(0.4, 0.42, 0.035, c);
  p.circle(0.6, 0.41, 0.03, const Color(0xFF8BD18F));
  p.shine(0.26, 0.56, 0.05, 0.12, rot: 0);
}

void paintPie(Pen p, Color a, Color b, Color c) {
  p.oval(0.5, 0.7, 0.86, 0.26, shade(a, 0.12));
  p.fill(
    Path()
      ..moveTo(0.1, 0.62)
      ..quadraticBezierTo(0.12, 0.34, 0.5, 0.32)
      ..quadraticBezierTo(0.88, 0.34, 0.9, 0.62)
      ..quadraticBezierTo(0.5, 0.74, 0.1, 0.62)
      ..close(),
    a,
  );
  for (final x in [0.32, 0.5, 0.68]) {
    p.oval(x, 0.5, 0.06, 0.14, b, rot: (x - 0.5) * 2);
  }
  p.circle(0.5, 0.36, 0.035, c);
  p.shine(0.32, 0.42, 0.1, 0.04, rot: -0.3);
}

void paintCup(Pen p, Color a, Color b, Color c) {
  for (final x in [0.4, 0.56]) {
    p.stroke(
      Path()
        ..moveTo(x, 0.32)
        ..quadraticBezierTo(x - 0.05, 0.24, x, 0.17)
        ..quadraticBezierTo(x + 0.05, 0.1, x, 0.04),
      tint(b, 0.3),
      0.03,
    );
  }
  p.stroke(
    Path()
      ..moveTo(0.74, 0.46)
      ..quadraticBezierTo(0.94, 0.48, 0.74, 0.7),
    a,
    0.06,
  );
  p.fill(
    Path()
      ..moveTo(0.18, 0.38)
      ..lineTo(0.78, 0.38)
      ..lineTo(0.74, 0.76)
      ..quadraticBezierTo(0.72, 0.86, 0.62, 0.86)
      ..lineTo(0.34, 0.86)
      ..quadraticBezierTo(0.24, 0.86, 0.22, 0.76)
      ..close(),
    a,
  );
  p.oval(0.48, 0.4, 0.58, 0.1, b);
  if (c != Colors.transparent) {
    p.rrect(0.36, 0.33, 0.46, 0.41, 0.02, c);
    p.rrect(0.5, 0.34, 0.6, 0.42, 0.02, c);
  }
  p.oval(0.48, 0.92, 0.64, 0.07, shade(a, 0.1));
  p.shine(0.3, 0.58, 0.05, 0.14, rot: 0);
}

// --- Moods --------------------------------------------------------------------

/// A soft round face. [a] is the face, [b] the cheeks, [c] unused; the
/// expression comes from the mood value (see `moodFace`).
void paintMoodFace(Pen p, Color a, Color b, int mood) {
  p.circle(0.5, 0.5, 0.42, a);
  p.oval(0.27, 0.6, 0.12, 0.07, b);
  p.oval(0.73, 0.6, 0.12, 0.07, b);
  const ink = Pen.ink;
  // Eyes.
  if (mood == 5) {
    for (final x in [0.36, 0.64]) {
      p.stroke(
        Path()
          ..moveTo(x - 0.06, 0.46)
          ..quadraticBezierTo(x, 0.38, x + 0.06, 0.46),
        ink,
        0.035,
      );
    }
  } else {
    p.circle(0.36, 0.45, 0.04, ink);
    p.circle(0.64, 0.45, 0.04, ink);
  }
  // Brows for the harder days.
  if (mood <= 2) {
    p.line(0.29, 0.34 + (mood == 1 ? 0.0 : 0.02), 0.41, 0.32 + (mood == 1 ? 0.04 : 0.02), ink, 0.028);
    p.line(0.59, 0.32 + (mood == 1 ? 0.04 : 0.02), 0.71, 0.34 + (mood == 1 ? 0.0 : 0.02), ink, 0.028);
  }
  // Mouth.
  final mouth = Path();
  switch (mood) {
    case 1:
      mouth
        ..moveTo(0.36, 0.69)
        ..quadraticBezierTo(0.43, 0.63, 0.5, 0.68)
        ..quadraticBezierTo(0.57, 0.73, 0.64, 0.67);
      p.stroke(mouth, ink, 0.032);
    case 2:
      mouth
        ..moveTo(0.4, 0.7)
        ..quadraticBezierTo(0.5, 0.63, 0.6, 0.7);
      p.stroke(mouth, ink, 0.032);
    case 3:
      p.line(0.41, 0.67, 0.59, 0.67, ink, 0.032);
    case 4:
      mouth
        ..moveTo(0.38, 0.62)
        ..quadraticBezierTo(0.5, 0.74, 0.62, 0.62);
      p.stroke(mouth, ink, 0.032);
    default:
      p.fill(
        Path()
          ..moveTo(0.35, 0.6)
          ..lineTo(0.65, 0.6)
          ..quadraticBezierTo(0.64, 0.78, 0.5, 0.78)
          ..quadraticBezierTo(0.36, 0.78, 0.35, 0.6)
          ..close(),
        ink,
      );
      p.oval(0.5, 0.73, 0.12, 0.05, const Color(0xFFF59AAE));
  }
  p.shine(0.32, 0.24, 0.12, 0.06);
}
