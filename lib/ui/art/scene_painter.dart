import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/logic/seasons.dart';
import 'icon_painters.dart';

/// What the sky is doing, chosen from the user's mood.
enum Weather { softRain, cloudy, partlyCloudy, clear, rainbow }

Weather weatherForMood(int? mood) => switch (mood) {
  1 => Weather.softRain,
  2 => Weather.cloudy,
  3 => Weather.partlyCloudy,
  5 => Weather.rainbow,
  _ => Weather.clear,
};

/// Draws a plot's backdrop in soft layers: sky (time of day, weather, sky
/// theme), sun or crescent moon, far hills, the environment's own backdrop,
/// mid hills and the ground with grass tufts and tiny flowers.
///
/// [phase] loops 0..1 and drives gentle ambient motion (rain, drifting
/// clouds, twinkling stars, falling leaves). Keep it at 0 for reduced motion.
class GardenScenePainter extends CustomPainter {
  GardenScenePainter({
    required this.hour,
    this.envId = 'meadow',
    this.season = Season.summer,
    this.weather = Weather.clear,
    this.skyTheme,
    this.phase = 0,
    this.silhouette = false,
  });

  final double hour;
  final String envId;
  final Season season;
  final Weather weather;

  /// Cosmetic sky: 'sunset_sky', 'aurora_sky' or null.
  final String? skyTheme;
  final double phase;

  /// Draw everything as a muted silhouette, for locked plots.
  final bool silhouette;

  bool get isNight => hour < 6 || hour >= 20;

  Color _mute(Color c) => silhouette ? Color.lerp(c, const Color(0xFF8E8A99), 0.75)! : c;

  /// Night-tinted and muted, for anything on the ground or the horizon.
  Color _land(Color c) => _mute(isNight ? Color.lerp(c, const Color(0xFF1E2E40), 0.45)! : c);

  // Hill tops as fractions of the scene: a start point, then (control, end)
  // pairs of quadratic segments. Scenery and decorations stand on these.
  static const _farHill = [(0.0, 0.54), (0.22, 0.46), (0.45, 0.52), (0.72, 0.58), (1.0, 0.49)];
  static const _dune = [(0.0, 0.57), (0.3, 0.47), (0.55, 0.57), (0.8, 0.5), (1.0, 0.55)];
  static const _midHill = [(0.0, 0.62), (0.3, 0.52), (0.6, 0.61), (0.85, 0.66), (1.0, 0.57)];
  static const _front = [(0.0, 0.72), (0.5, 0.64), (1.0, 0.74)];

  static Path _curvePath(List<(double, double)> pts, Size size) {
    final path = Path()..moveTo(pts[0].$1 * size.width, pts[0].$2 * size.height);
    for (var i = 1; i + 1 < pts.length; i += 2) {
      path.quadraticBezierTo(
        pts[i].$1 * size.width,
        pts[i].$2 * size.height,
        pts[i + 1].$1 * size.width,
        pts[i + 1].$2 * size.height,
      );
    }
    return path;
  }

  /// The y of a hill's top at [x] (in pixels).
  static double _curveY(List<(double, double)> pts, Size size, double x) {
    final fx = (x / size.width).clamp(0.0, 1.0);
    for (var i = 1; i + 1 < pts.length; i += 2) {
      final (x0, y0) = pts[i - 1];
      final (cx, cy) = pts[i];
      final (x1, y1) = pts[i + 1];
      if (fx > x1 && i + 2 < pts.length) continue;
      double at(double a, double b, double c, double t) => (1 - t) * (1 - t) * a + 2 * t * (1 - t) * b + t * t * c;
      var lo = 0.0, hi = 1.0;
      for (var k = 0; k < 24; k++) {
        final mid = (lo + hi) / 2;
        if (at(x0, cx, x1, mid) < fx) {
          lo = mid;
        } else {
          hi = mid;
        }
      }
      return at(y0, cy, y1, (lo + hi) / 2) * size.height;
    }
    return pts.last.$2 * size.height;
  }

  /// The top of the front ground at [x], for things placed on it.
  static double groundTop(Size size, double x) => _curveY(_front, size, x);

  Paint _fill(Color c) => Paint()
    ..color = c
    ..isAntiAlias = true;

  @override
  void paint(Canvas canvas, Size size) {
    _sky(canvas, size);
    _sunOrMoon(canvas, size);
    _weather(canvas, size);
    _farHills(canvas, size);
    _backdrop(canvas, size);
    _midHills(canvas, size);
    _ground(canvas, size);
    _seasonal(canvas, size);
  }

  // --- Sky ----------------------------------------------------------------------

  List<Color> _skyColors() {
    if (skyTheme == 'aurora_sky' && isNight) return const [Color(0xFF1B2A4A), Color(0xFF2F7A7A)];
    if (skyTheme == 'sunset_sky' && !isNight) return const [Color(0xFFF7A99A), Color(0xFFFFD9A0)];
    if (isNight) return const [Color(0xFF2E3A6B), Color(0xFF5B5C8F)];
    final grey = weather == Weather.softRain || weather == Weather.cloudy;
    final base = hour < 9
        ? const [Color(0xFFFFD6C2), Color(0xFFFFF1DC)]
        : hour >= 17
        ? const [Color(0xFFF7B9A6), Color(0xFFFFE3C4)]
        : envId == 'desert'
        ? const [Color(0xFF9FD1F2), Color(0xFFFCE8C8)]
        : const [Color(0xFFB9DDF5), Color(0xFFE6F4FB)];
    return grey ? [for (final c in base) Color.lerp(c, const Color(0xFFC8CCD8), 0.55)!] : base;
  }

  void _sky(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [for (final c in _skyColors()) _mute(c)],
        ).createShader(rect),
    );
    if (skyTheme == 'aurora_sky' && isNight && !silhouette) {
      for (var i = 0; i < 3; i++) {
        final p = Path()..moveTo(0, size.height * (0.12 + i * 0.05));
        for (var x = 0.0; x <= size.width; x += size.width / 8) {
          p.lineTo(x, size.height * (0.12 + i * 0.05) + math.sin(x / 40 + phase * 2 * math.pi + i) * 10);
        }
        canvas.drawPath(
          p,
          Paint()
            ..color = [
              const Color(0xFF7CF5C4),
              const Color(0xFF8AB4FF),
              const Color(0xFFC59CFF),
            ][i].withValues(alpha: 0.35)
            ..strokeWidth = 14
            ..style = PaintingStyle.stroke
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
        );
      }
    }
  }

  void _sunOrMoon(Canvas canvas, Size size) {
    if (isNight && !silhouette) _stars(canvas, size);
    if (weather == Weather.softRain && !isNight) return;
    final t = isNight ? ((hour + 4) % 24) / 10 : (hour - 6) / 14;
    final x = size.width * (0.58 + 0.32 * t.clamp(0.0, 1.0));
    final y = size.height * (0.26 - 0.08 * math.sin(math.pi * t.clamp(0.0, 1.0)));
    final r = size.width * 0.036;
    final c = Offset(x, y);
    if (isNight) {
      final moon = _mute(const Color(0xFFFBF3D5));
      canvas.drawCircle(c, r * 2.1, _fill(moon.withValues(alpha: 0.08)));
      canvas.drawCircle(c, r * 1.5, _fill(moon.withValues(alpha: 0.12)));
      // A crescent: the moon with an offset circle cut away.
      final crescent = Path.combine(
        PathOperation.difference,
        Path()..addOval(Rect.fromCircle(center: c, radius: r)),
        Path()..addOval(Rect.fromCircle(center: c.translate(r * 0.55, -r * 0.3), radius: r * 0.88)),
      );
      canvas.drawPath(crescent, _fill(moon));
      return;
    }
    final sun = _mute(const Color(0xFFFFD86B));
    canvas.drawCircle(c, r * 2.2, _fill(sun.withValues(alpha: 0.12)));
    canvas.drawCircle(c, r * 1.55, _fill(sun.withValues(alpha: 0.2)));
    canvas.drawCircle(c, r, _fill(sun));
    canvas.drawCircle(c.translate(-r * 0.3, -r * 0.32), r * 0.3, _fill(Colors.white.withValues(alpha: 0.35)));
  }

  /// Twinkling four-point sparkles and tiny dots, always in the same places.
  void _stars(Canvas canvas, Size size) {
    final rnd = math.Random(7);
    final pen = Pen(canvas);
    for (var i = 0; i < 16; i++) {
      final p = Offset(rnd.nextDouble() * size.width, rnd.nextDouble() * size.height * 0.45);
      final twinkle = 0.65 + 0.35 * math.sin(phase * 2 * math.pi * 3 + i * 1.7);
      final colour = Colors.white.withValues(alpha: 0.85 * twinkle);
      if (i % 3 == 0) {
        final s = (2.6 + rnd.nextDouble() * 2.4) * twinkle;
        pen.fill(pen.star(p.dx, p.dy, s, s * 0.32, points: 4, rot: 0), colour);
      } else {
        canvas.drawCircle(p, (0.9 + rnd.nextDouble() * 0.7) * twinkle, _fill(colour));
      }
    }
  }

  void _cloud(Canvas canvas, Offset c, double s, Color colour, Color under) {
    void puffs(Offset at, Paint p) {
      canvas.drawCircle(at.translate(-s * 0.42, s * 0.12), s * 0.34, p);
      canvas.drawCircle(at.translate(s * 0.05, -s * 0.06), s * 0.46, p);
      canvas.drawCircle(at.translate(s * 0.5, s * 0.1), s * 0.36, p);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: at.translate(0, s * 0.28), width: s * 1.75, height: s * 0.42),
          Radius.circular(s),
        ),
        p,
      );
    }

    // A soft underside, then the cloud itself, with a flat base.
    puffs(c.translate(0, s * 0.08), _fill(under));
    puffs(c, _fill(colour));
  }

  void _weather(Canvas canvas, Size size) {
    final count = switch (weather) {
      Weather.softRain => 4,
      Weather.cloudy => 4,
      Weather.partlyCloudy => 2,
      Weather.clear || Weather.rainbow => 1,
    };
    final grey = weather == Weather.softRain || weather == Weather.cloudy;
    final alpha = isNight ? 0.35 : 0.95;
    final colour = _mute(grey ? const Color(0xFFE9EBF2) : Colors.white).withValues(alpha: alpha);
    final under = _mute(grey ? const Color(0xFFCDD1DE) : const Color(0xFFE3E9F3)).withValues(alpha: alpha);
    // A clear night sky is just the moon and stars.
    final clouds = isNight && count == 1 ? 0 : count;
    for (var i = 0; i < clouds; i++) {
      final x = ((i * 0.31 + 0.42 + phase * 0.05 * (i + 1)) % 1.2 - 0.1) * size.width;
      _cloud(
        canvas,
        Offset(x, size.height * (0.10 + (i % 3) * 0.07)),
        size.width * (0.1 + (i % 2) * 0.03),
        colour,
        under,
      );
    }
    if (weather == Weather.rainbow && !isNight && !silhouette) {
      const colors = [
        Color(0xFFFFB3BA),
        Color(0xFFFFDFBA),
        Color(0xFFFFFFBA),
        Color(0xFFBAFFC9),
        Color(0xFFBAE1FF),
        Color(0xFFD9BAFF),
      ];
      for (final (i, c) in colors.indexed) {
        canvas.drawArc(
          Rect.fromCenter(
            center: Offset(size.width * 0.7, size.height * 0.56),
            width: size.width * (0.9 - i * 0.05),
            height: size.height * (0.62 - i * 0.04),
          ),
          math.pi,
          math.pi,
          false,
          Paint()
            ..color = c.withValues(alpha: 0.45)
            ..style = PaintingStyle.stroke
            ..strokeWidth = size.width * 0.02,
        );
      }
    }
    if (weather == Weather.softRain && !silhouette) {
      final drop = Paint()
        ..color = const Color(0xFF9DB6D6).withValues(alpha: 0.6)
        ..strokeWidth = 1.6
        ..strokeCap = StrokeCap.round;
      final rnd = math.Random(3);
      for (var i = 0; i < 14; i++) {
        final x = rnd.nextDouble() * size.width;
        final y = ((rnd.nextDouble() + phase * 2) % 1) * size.height * 0.75;
        canvas.drawLine(Offset(x, y), Offset(x - 2, y + 9), drop);
      }
    }
  }

  // --- Land ---------------------------------------------------------------------

  Color get _grassFrontBase {
    final base = switch (envId) {
      'desert' => const Color(0xFFF0CF8E),
      'forest' => const Color(0xFF6FAF72),
      'alpine' => const Color(0xFF9FCF8E),
      'tropical' => const Color(0xFF5DBB6A),
      _ => const Color(0xFF86C98A),
    };
    return switch (season) {
      Season.spring => Color.lerp(base, const Color(0xFFB6E3A0), 0.25)!,
      Season.summer => base,
      Season.autumn => envId == 'desert' ? base : Color.lerp(base, const Color(0xFFD9A65B), 0.35)!,
      Season.winter =>
        envId == 'tropical' || envId == 'desert' ? base : Color.lerp(base, const Color(0xFFEFF4F6), 0.6)!,
    };
  }

  Color get _grassFront => _land(_grassFrontBase);
  Color get _grassMid => _land(Color.lerp(_grassFrontBase, Colors.white, 0.2)!);
  Color get _grassFar => _land(Color.lerp(_grassFrontBase, _skyColors().last, 0.55)!);

  /// A hill with a soft lit rim along its top edge.
  void _hill(Canvas canvas, Size size, Path top, Color colour) {
    final shape = Path.from(top)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(shape, _fill(tint(colour, 0.22)));
    canvas.save();
    canvas.translate(0, size.height * 0.01);
    canvas.drawPath(shape, _fill(colour));
    canvas.restore();
  }

  void _farHills(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    if (envId == 'tropical') {
      // A calm strip of sea on the horizon.
      canvas.drawRect(Rect.fromLTRB(0, h * 0.5, w, h * 0.6), _fill(_land(const Color(0xFF9ED8EA))));
      canvas.drawRect(Rect.fromLTRB(0, h * 0.5, w, h * 0.508), _fill(_land(const Color(0xFFD3F0F7))));
      return;
    }
    _hill(canvas, size, _curvePath(_farHill, size), _grassFar);
  }

  void _backdrop(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    switch (envId) {
      case 'alpine':
        for (final (x, peak, width, rock) in [
          (0.25, 0.22, 0.62, const Color(0xFFB7C4D6)),
          (0.72, 0.17, 0.7, const Color(0xFFA9B8CD)),
        ]) {
          final base = h * 0.6;
          final left = w * (x - width / 2);
          final right = w * (x + width / 2);
          canvas.drawPath(
            Path()
              ..moveTo(left, base)
              ..lineTo(w * x, h * peak)
              ..lineTo(right, base)
              ..close(),
            _fill(_land(rock)),
          );
          // The shaded side.
          canvas.drawPath(
            Path()
              ..moveTo(w * x, h * peak)
              ..lineTo(right, base)
              ..lineTo(w * (x + width * 0.08), base)
              ..close(),
            _fill(_land(shade(rock, 0.12))),
          );
          // A scalloped snowcap.
          final capY = h * (peak + 0.1);
          final capL = w * (x - width * 0.14);
          final capR = w * (x + width * 0.14);
          final cap = Path()
            ..moveTo(capL, capY)
            ..lineTo(w * x, h * peak);
          cap.lineTo(capR, capY);
          for (var k = 0; k < 3; k++) {
            final x1 = capR - (k + 1) * (capR - capL) / 3;
            cap.quadraticBezierTo(x1 + (capR - capL) / 6, capY + h * 0.025, x1, capY);
          }
          canvas.drawPath(cap..close(), _fill(_land(Colors.white)));
        }
      case 'forest':
        for (final (row, top, colour, count) in [
          (0, 0.34, const Color(0xFF6E9E7E), 10),
          (1, 0.4, const Color(0xFF4E8A62), 8),
        ]) {
          for (var i = 0; i < count; i++) {
            final x = w * ((i + (row == 0 ? 0.5 : 0)) / (count - 1));
            final peak = h * (top + (i % 3) * 0.03);
            // Rooted just inside the far hill.
            final foot = _curveY(_farHill, size, x) + h * (0.02 + row * 0.02);
            _pine(canvas, x, peak, foot, w * 0.075, _land(colour));
          }
        }
      case 'desert':
        _hill(canvas, size, _curvePath(_dune, size), _land(const Color(0xFFF5DDA9)));
        for (final (x, s) in [(0.14, 1.0), (0.84, 0.8)]) {
          final foot = _curveY(_dune, size, w * x) + h * 0.012;
          _cactus(canvas, w * x, foot, h * 0.09 * s, _land(const Color(0xFF9CBF8E)));
        }
      case 'tropical':
        for (final (x, lean) in [(0.06, 1.0), (0.94, -1.0), (0.2, 0.6)]) {
          final foot = _curveY(_midHill, size, w * x) + h * 0.012;
          _palm(canvas, w * x, foot, h * (x == 0.2 ? 0.2 : 0.28), lean, _land(const Color(0xFF4FA463)));
        }
      case 'orchard':
        for (var i = 0; i < 6; i++) {
          final x = w * (0.08 + i * 0.17);
          final r = w * 0.05;
          // The canopy's centre: the trunk shows below it and ends just inside the far hill.
          final y = _curveY(_farHill, size, x) + r * 0.2 - r * 1.6;
          canvas.drawRect(Rect.fromLTWH(x - r * 0.12, y, r * 0.24, r * 1.6), _fill(_land(const Color(0xFFB08560))));
          canvas.drawCircle(Offset(x, y), r, _fill(_land(const Color(0xFF8FC27F))));
          canvas.drawCircle(Offset(x - r * 0.3, y - r * 0.35), r * 0.42, _fill(_land(const Color(0xFFA9D497))));
          for (final (dx, dy) in [(-0.4, 0.1), (0.35, -0.2), (0.15, 0.4)]) {
            canvas.drawCircle(Offset(x + r * dx, y + r * dy), r * 0.14, _fill(_land(const Color(0xFFE8746A))));
          }
        }
      case 'wetland':
        break;
      default:
        // Meadow: a few soft tree clumps on the far hills.
        for (final (x, s) in [(0.12, 1.0), (0.2, 0.7), (0.82, 0.9)]) {
          final r = w * 0.032 * s;
          final c = _land(const Color(0xFF9CCB8C));
          // Sits on the far hill, its base tucked in a little.
          final y = _curveY(_farHill, size, w * x) - r * 0.5;
          canvas.drawCircle(Offset(w * x - r * 0.6, y), r * 0.8, _fill(c));
          canvas.drawCircle(Offset(w * x + r * 0.6, y), r * 0.8, _fill(c));
          canvas.drawCircle(Offset(w * x, y - r * 0.5), r, _fill(c));
          canvas.drawCircle(Offset(w * x - r * 0.3, y - r * 0.8), r * 0.4, _fill(tint(c, 0.18)));
        }
    }
  }

  void _pine(Canvas canvas, double x, double top, double bottom, double halfWidth, Color colour) {
    final height = bottom - top;
    for (var t = 0; t < 3; t++) {
      final y0 = top + height * t * 0.26;
      final y1 = y0 + height * 0.48;
      final half = halfWidth * (0.55 + t * 0.25);
      final tier = Path()
        ..moveTo(x, y0)
        ..quadraticBezierTo(x + half * 0.5, y0 + height * 0.2, x + half, y1)
        ..quadraticBezierTo(x, y1 + height * 0.06, x - half, y1)
        ..quadraticBezierTo(x - half * 0.5, y0 + height * 0.2, x, y0)
        ..close();
      canvas.drawPath(tier, _fill(colour));
      canvas.drawPath(
        Path()
          ..moveTo(x, y0)
          ..quadraticBezierTo(x - half * 0.5, y0 + height * 0.2, x - half, y1)
          ..quadraticBezierTo(x - half * 0.5, y1 + height * 0.02, x - half * 0.2, y1 - height * 0.02)
          ..close(),
        _fill(tint(colour, 0.14)),
      );
    }
  }

  void _cactus(Canvas canvas, double x, double base, double height, Color colour) {
    final wid = height * 0.22;
    canvas.drawRRect(
      RRect.fromLTRBR(x - wid / 2, base - height, x + wid / 2, base, Radius.circular(wid)),
      _fill(colour),
    );
    canvas.drawRRect(
      RRect.fromLTRBR(x - wid * 1.6, base - height * 0.7, x - wid * 0.8, base - height * 0.35, Radius.circular(wid)),
      _fill(colour),
    );
    canvas.drawRect(Rect.fromLTRB(x - wid * 1.4, base - height * 0.42, x, base - height * 0.32), _fill(colour));
    canvas.drawRRect(
      RRect.fromLTRBR(x + wid * 0.8, base - height * 0.85, x + wid * 1.6, base - height * 0.5, Radius.circular(wid)),
      _fill(colour),
    );
    canvas.drawRect(Rect.fromLTRB(x, base - height * 0.58, x + wid * 1.4, base - height * 0.48), _fill(colour));
  }

  void _palm(Canvas canvas, double x, double base, double height, double lean, Color leaf) {
    final topX = x + lean * height * 0.25;
    final topY = base - height;
    // One tapered, gently curved trunk: wide at the foot, slim at the crown.
    final bark = _land(const Color(0xFFB59472));
    final foot = height * 0.035;
    final crown = height * 0.014;
    final bendX = x + lean * height * 0.05;
    final midY = base - height * 0.5;
    final trunk = Path()
      ..moveTo(x - foot, base)
      ..quadraticBezierTo(bendX - (foot + crown) / 2, midY, topX - crown, topY)
      ..lineTo(topX + crown, topY)
      ..quadraticBezierTo(bendX + (foot + crown) / 2, midY, x + foot, base)
      ..close();
    canvas.drawPath(trunk, _fill(bark));
    // Soft rings along the trunk.
    final ring = Paint()
      ..color = shade(bark, 0.14)
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;
    for (var k = 1; k < 7; k++) {
      final t = k / 7;
      // A point on the trunk's centre line (the same curve as its edges).
      final cx = (1 - t) * (1 - t) * x + 2 * t * (1 - t) * bendX + t * t * topX;
      final cy = (1 - t) * (1 - t) * base + 2 * t * (1 - t) * midY + t * t * topY;
      final half = (foot + (crown - foot) * t) * 0.8;
      canvas.drawLine(Offset(cx - half, cy), Offset(cx + half, cy + 1), ring);
    }
    final pen = Pen(canvas);
    for (final a in [-2.8, -2.2, -1.5, -0.9, -0.3]) {
      pen.leaf(topX, topY, height * 0.42, height * 0.07, a, a < -1.5 ? leaf : tint(leaf, 0.12));
    }
  }

  void _midHills(Canvas canvas, Size size) => _hill(canvas, size, _curvePath(_midHill, size), _grassMid);

  void _ground(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    _hill(canvas, size, _curvePath(_front, size), _grassFront);
    if (silhouette) return;

    if (envId == 'wetland') {
      final water = _land(const Color(0xFF9FD3E8));
      canvas.drawOval(
        Rect.fromCenter(center: Offset(w * 0.5, h * 0.95), width: w * 1.2, height: h * 0.14),
        _fill(water),
      );
      canvas.drawOval(
        Rect.fromCenter(center: Offset(w * 0.4, h * 0.915), width: w * 0.5, height: h * 0.02),
        _fill(tint(water, 0.35)),
      );
      final pen = Pen(canvas);
      for (final (x, y, r) in [(0.18, 0.94, 0.045), (0.78, 0.95, 0.05), (0.62, 0.97, 0.035)]) {
        final pad = Path.combine(
          PathOperation.difference,
          Path()..addOval(Rect.fromCenter(center: Offset(w * x, h * y), width: w * r * 2, height: w * r * 0.8)),
          Path()
            ..moveTo(w * x, h * y)
            ..lineTo(w * (x + r * 1.2), h * y - w * r * 0.25)
            ..lineTo(w * (x + r * 1.2), h * y + w * r * 0.05)
            ..close(),
        );
        pen.fill(pad, _land(const Color(0xFF72B886)));
      }
      // Cattails at the water's edge.
      for (var i = 0; i < 5; i++) {
        for (final side in [0.0, 1.0]) {
          final x = side == 0 ? w * (0.03 + i * 0.028) : w * (0.97 - i * 0.028);
          final top = h * (0.74 - (i % 2) * 0.04);
          canvas.drawLine(
            Offset(x, h * 0.88),
            Offset(x + 2, top),
            Paint()
              ..color = _land(const Color(0xFF6A9A5B))
              ..strokeWidth = 2.4
              ..strokeCap = StrokeCap.round,
          );
          if (i.isEven) {
            canvas.drawRRect(
              RRect.fromRectAndRadius(Rect.fromLTWH(x - 1.2, top + 4, 6, h * 0.035), const Radius.circular(3)),
              _fill(_land(const Color(0xFFA06E4C))),
            );
          }
        }
      }
    }

    // Grass tufts and tiny five-petal flowers, always in the same places.
    final rnd = math.Random(envId.hashCode);
    final pen = Pen(canvas);
    final tuft = _land(shade(_grassFrontBase, 0.14));
    for (var i = 0; i < 9; i++) {
      final x = rnd.nextDouble() * w;
      final y = h * (0.78 + rnd.nextDouble() * 0.18);
      final s = h * 0.03;
      pen.leaf(x, y, s, s * 0.22, -math.pi / 2 - 0.45, tuft);
      pen.leaf(x, y, s * 1.2, s * 0.24, -math.pi / 2, tuft);
      pen.leaf(x, y, s, s * 0.22, -math.pi / 2 + 0.45, tuft);
    }
    final petals = switch (envId) {
      'desert' => [const Color(0xFFF2B06B)],
      'alpine' => [Colors.white, const Color(0xFFC9B6F2)],
      _ => [Colors.white, const Color(0xFFFFE08A), const Color(0xFFF8C4CF)],
    };
    for (var i = 0; i < 10; i++) {
      final x = rnd.nextDouble() * w;
      final y = h * (0.77 + rnd.nextDouble() * 0.2);
      final c = petals[i % petals.length].withValues(alpha: isNight ? 0.5 : 0.95);
      paintSmallBlossom(pen, x, y, 2.4, c, const Color(0xFFFFD45C).withValues(alpha: isNight ? 0.5 : 1));
    }
  }

  // --- Seasons ------------------------------------------------------------------

  void _seasonal(Canvas canvas, Size size) {
    if (silhouette) return;
    final rnd = math.Random(11);
    switch (season) {
      case Season.winter when envId != 'tropical' && envId != 'desert':
        final flake = Paint()..color = Colors.white.withValues(alpha: 0.85);
        for (var i = 0; i < 8; i++) {
          final x = (rnd.nextDouble() * size.width + math.sin(phase * 2 * math.pi + i) * 6);
          final y = ((rnd.nextDouble() + phase * 0.5) % 1) * size.height;
          canvas.drawCircle(Offset(x, y), 1.5 + rnd.nextDouble() * 1.5, flake);
        }
      case Season.autumn when envId != 'desert':
        for (var i = 0; i < 5; i++) {
          final x = (rnd.nextDouble() * size.width + math.sin(phase * 2 * math.pi + i) * 14);
          final y = ((rnd.nextDouble() + phase * 0.4) % 1) * size.height * 0.9;
          canvas.save();
          canvas.translate(x, y);
          canvas.rotate(phase * 3 + i);
          canvas.drawOval(
            const Rect.fromLTWH(-4, -2, 8, 4),
            Paint()..color = [const Color(0xFFE59A4B), const Color(0xFFD9653B), const Color(0xFFE8C15A)][i % 3],
          );
          canvas.restore();
        }
      case Season.spring:
        for (var i = 0; i < 5; i++) {
          final x = (rnd.nextDouble() * size.width + math.sin(phase * 2 * math.pi + i) * 10);
          final y = ((rnd.nextDouble() + phase * 0.3) % 1) * size.height * 0.8;
          canvas.drawOval(
            Rect.fromCenter(center: Offset(x, y), width: 5, height: 3.5),
            Paint()..color = const Color(0xFFFAD0DC).withValues(alpha: 0.9),
          );
        }
      default:
        break;
    }
  }

  @override
  bool shouldRepaint(GardenScenePainter old) =>
      old.hour != hour ||
      old.envId != envId ||
      old.season != season ||
      old.weather != weather ||
      old.skyTheme != skyTheme ||
      old.phase != phase ||
      old.silhouette != silhouette;
}
