import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/logic/seasons.dart';

/// What the sky is doing, chosen from the user's mood.
enum Weather { softRain, cloudy, partlyCloudy, clear, rainbow }

Weather weatherForMood(int? mood) => switch (mood) {
  1 => Weather.softRain,
  2 => Weather.cloudy,
  3 => Weather.partlyCloudy,
  5 => Weather.rainbow,
  _ => Weather.clear,
};

/// Draws a plot's backdrop: sky (time of day, weather, sky theme), ground and
/// ambient details for the environment and season.
///
/// [phase] loops 0..1 and drives gentle ambient motion (rain, drifting
/// clouds, falling leaves). Keep it at 0 for reduced motion.
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

  @override
  void paint(Canvas canvas, Size size) {
    _sky(canvas, size);
    _sunOrMoon(canvas, size);
    _weather(canvas, size);
    _backdrop(canvas, size);
    _ground(canvas, size);
    _seasonal(canvas, size);
  }

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
    if (weather == Weather.softRain && !isNight) return;
    final t = isNight ? ((hour + 4) % 24) / 10 : (hour - 6) / 14;
    final x = size.width * (0.58 + 0.32 * t.clamp(0.0, 1.0));
    final y = size.height * (0.26 - 0.08 * math.sin(math.pi * t.clamp(0.0, 1.0)));
    final color = _mute(isNight ? const Color(0xFFF7F1D6) : const Color(0xFFFFE08A));
    canvas.drawCircle(Offset(x, y), size.width * 0.055, Paint()..color = color.withValues(alpha: 0.18));
    canvas.drawCircle(Offset(x, y), size.width * 0.034, Paint()..color = color);
    if (isNight && !silhouette) {
      final star = Paint()..color = Colors.white.withValues(alpha: 0.8);
      final rnd = math.Random(7);
      for (var i = 0; i < 10; i++) {
        final twinkle = 0.6 + 0.4 * math.sin(phase * 2 * math.pi + i);
        canvas.drawCircle(
          Offset(rnd.nextDouble() * size.width, rnd.nextDouble() * size.height * 0.45),
          1.3 * twinkle,
          star,
        );
      }
    }
  }

  void _cloud(Canvas canvas, Offset c, double s, Paint p) {
    canvas.drawCircle(c, s * 0.5, p);
    canvas.drawCircle(c.translate(-s * 0.5, s * 0.15), s * 0.38, p);
    canvas.drawCircle(c.translate(s * 0.5, s * 0.12), s * 0.4, p);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: c.translate(0, s * 0.3), width: s * 1.7, height: s * 0.45),
        Radius.circular(s),
      ),
      p,
    );
  }

  void _weather(Canvas canvas, Size size) {
    final count = switch (weather) {
      Weather.softRain => 4,
      Weather.cloudy => 4,
      Weather.partlyCloudy => 2,
      Weather.clear || Weather.rainbow => 1,
    };
    final grey = weather == Weather.softRain || weather == Weather.cloudy;
    final cloud = Paint()
      ..color = _mute(grey ? const Color(0xFFE4E6EE) : Colors.white).withValues(alpha: isNight ? 0.35 : 0.9);
    for (var i = 0; i < count; i++) {
      final x = ((i * 0.31 + 0.42 + phase * 0.05 * (i + 1)) % 1.2 - 0.1) * size.width;
      _cloud(canvas, Offset(x, size.height * (0.10 + (i % 3) * 0.07)), size.width * (0.10 + (i % 2) * 0.03), cloud);
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

  Color get _grassFront {
    final base = switch (envId) {
      'desert' => const Color(0xFFF0CF8E),
      'forest' => const Color(0xFF6FAF72),
      'alpine' => const Color(0xFF9FCF8E),
      'tropical' => const Color(0xFF5DBB6A),
      'wetland' => const Color(0xFF86C98A),
      _ => const Color(0xFF86C98A),
    };
    final seasonal = switch (season) {
      Season.spring => Color.lerp(base, const Color(0xFFB6E3A0), 0.25)!,
      Season.summer => base,
      Season.autumn => envId == 'desert' ? base : Color.lerp(base, const Color(0xFFD9A65B), 0.35)!,
      Season.winter =>
        envId == 'tropical' || envId == 'desert' ? base : Color.lerp(base, const Color(0xFFEFF4F6), 0.6)!,
    };
    return _mute(isNight ? Color.lerp(seasonal, const Color(0xFF1E2E40), 0.45)! : seasonal);
  }

  Color get _grassBack => Color.lerp(_grassFront, Colors.white, 0.2)!;

  void _backdrop(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final night = isNight ? 0.45 : 0.0;
    Color tint(Color c) => _mute(Color.lerp(c, const Color(0xFF1E2E40), night)!);

    switch (envId) {
      case 'alpine':
        final mountain = Paint()..color = tint(const Color(0xFFB7C4D6));
        final snow = Paint()..color = tint(Colors.white);
        for (final (x, peak, width) in [(0.25, 0.22, 0.6), (0.7, 0.18, 0.7)]) {
          final p = Path()
            ..moveTo(w * (x - width / 2), h * 0.6)
            ..lineTo(w * x, h * peak)
            ..lineTo(w * (x + width / 2), h * 0.6)
            ..close();
          canvas.drawPath(p, mountain);
          final cap = Path()
            ..moveTo(w * (x - width * 0.12), h * (peak + 0.09))
            ..lineTo(w * x, h * peak)
            ..lineTo(w * (x + width * 0.12), h * (peak + 0.09))
            ..close();
          canvas.drawPath(cap, snow);
        }
      case 'forest':
        final tree = Paint()..color = tint(const Color(0xFF4E8A62));
        for (var i = 0; i < 9; i++) {
          final x = w * (i / 8);
          final top = h * (0.30 + (i % 3) * 0.04);
          canvas.drawPath(
            Path()
              ..moveTo(x, top)
              ..lineTo(x - w * 0.09, h * 0.62)
              ..lineTo(x + w * 0.09, h * 0.62)
              ..close(),
            tree,
          );
        }
      case 'desert':
        canvas.drawPath(
          Path()
            ..moveTo(0, h * 0.58)
            ..quadraticBezierTo(w * 0.3, h * 0.48, w * 0.55, h * 0.58)
            ..quadraticBezierTo(w * 0.8, h * 0.50, w, h * 0.56)
            ..lineTo(w, h)
            ..lineTo(0, h)
            ..close(),
          Paint()..color = tint(const Color(0xFFF5DDA9)),
        );
      case 'tropical':
        final leaf = Paint()..color = tint(const Color(0xFF3E9A57));
        for (final (x, flip) in [(0.0, 1.0), (1.0, -1.0)]) {
          for (var i = 0; i < 3; i++) {
            canvas.save();
            canvas.translate(w * x, h * (0.30 + i * 0.12));
            canvas.rotate(flip * (0.4 + i * 0.25));
            canvas.drawOval(
              Rect.fromCenter(center: Offset(flip * w * 0.12, 0), width: w * 0.32, height: h * 0.07),
              leaf,
            );
            canvas.restore();
          }
        }
      case 'orchard':
        final crown = Paint()..color = tint(const Color(0xFF9ACB8A));
        for (var i = 0; i < 7; i++) {
          canvas.drawCircle(Offset(w * (0.07 + i * 0.145), h * 0.55), w * 0.055, crown);
        }
      default:
        break;
    }

    canvas.drawPath(
      Path()
        ..moveTo(0, h * 0.62)
        ..quadraticBezierTo(w * 0.3, h * 0.52, w * 0.6, h * 0.61)
        ..quadraticBezierTo(w * 0.85, h * 0.66, w, h * 0.57)
        ..lineTo(w, h)
        ..lineTo(0, h)
        ..close(),
      Paint()..color = _grassBack,
    );
  }

  void _ground(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    canvas.drawPath(
      Path()
        ..moveTo(0, h * 0.72)
        ..quadraticBezierTo(w * 0.5, h * 0.64, w, h * 0.74)
        ..lineTo(w, h)
        ..lineTo(0, h)
        ..close(),
      Paint()..color = _grassFront,
    );
    if (silhouette) return;

    if (envId == 'wetland') {
      final water = Paint()
        ..color = (isNight ? const Color(0xFF3C5E7A) : const Color(0xFF9FD3E8)).withValues(alpha: 0.9);
      canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.5, h * 0.95), width: w * 1.2, height: h * 0.14), water);
      final reed = Paint()
        ..color = const Color(0xFF6A9A5B)
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round;
      for (var i = 0; i < 6; i++) {
        final x = w * (0.04 + i * 0.03);
        canvas.drawLine(Offset(x, h * 0.86), Offset(x + 3, h * (0.74 - (i % 2) * 0.03)), reed);
        canvas.drawLine(Offset(w - x, h * 0.86), Offset(w - x - 3, h * (0.75 - (i % 2) * 0.03)), reed);
      }
    }

    // Little flowers and grass tufts.
    final rnd = math.Random(envId.hashCode);
    final dots = switch (envId) {
      'desert' => [const Color(0xFFE8B86B)],
      'alpine' => [Colors.white, const Color(0xFFC9B6F2)],
      _ => [Colors.white, const Color(0xFFFFE08A), const Color(0xFFF8C4CF)],
    };
    for (var i = 0; i < 12; i++) {
      final x = rnd.nextDouble() * w;
      final y = h * (0.76 + rnd.nextDouble() * 0.2);
      final c = dots[i % dots.length];
      canvas.drawCircle(Offset(x, y), 2.2, Paint()..color = c.withValues(alpha: isNight ? 0.5 : 0.9));
    }
  }

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
