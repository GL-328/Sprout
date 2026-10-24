import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../config/game_config.dart';
import '../../domain/models/enums.dart';
import 'plant_art_provider.dart';

/// Basic shapes the painter knows how to draw.
enum PlantForm {
  tree,
  palm,
  giantFlower,
  bush,
  hedge,
  grove,
  cactus,
  bamboo,
  fern,
  lotus,
  willow,
  conifer,
  succulent,
  bog,
}

/// How a species looks: shape plus colours. Add an entry here when adding a
/// species to the config; unknown species fall back to a tree.
class PlantLook {
  const PlantLook(this.form, this.leaf, this.accent, {this.trunk = const Color(0xFF9C6B4E)});

  final PlantForm form;
  final Color leaf;

  /// Flower or fruit colour.
  final Color accent;
  final Color trunk;
}

const plantLooks = <String, PlantLook>{
  'apple_tree': PlantLook(PlantForm.tree, Color(0xFF7CC47F), Color(0xFFE8574F)),
  'giant_sunflower': PlantLook(PlantForm.giantFlower, Color(0xFF7DBF6A), Color(0xFFFFC93C)),
  'berry_bush': PlantLook(PlantForm.bush, Color(0xFF5FAE6E), Color(0xFFE5486B)),
  'lavender_hedge': PlantLook(PlantForm.hedge, Color(0xFF8DB88A), Color(0xFFA48ADB)),
  'oak': PlantLook(PlantForm.tree, Color(0xFF5E9E5A), Color(0xFFB07A44), trunk: Color(0xFF7A5238)),
  'mushroom_grove': PlantLook(PlantForm.grove, Color(0xFFF4E6D2), Color(0xFFE0675A)),
  'hazelnut': PlantLook(PlantForm.bush, Color(0xFF79B26C), Color(0xFFB98A5A)),
  'fern_canopy': PlantLook(PlantForm.fern, Color(0xFF4FA36A), Color(0xFF8BD18F)),
  'cherry': PlantLook(PlantForm.tree, Color(0xFFF6B7C8), Color(0xFFD7263D)),
  'peach': PlantLook(PlantForm.tree, Color(0xFF8CC97E), Color(0xFFFFA07A)),
  'plum': PlantLook(PlantForm.tree, Color(0xFF7DB87A), Color(0xFF7B4B94)),
  'pear': PlantLook(PlantForm.tree, Color(0xFF88C07A), Color(0xFFC9D85B)),
  'lotus': PlantLook(PlantForm.lotus, Color(0xFF6FBF8E), Color(0xFFF7A1C4)),
  'cranberry_bog': PlantLook(PlantForm.bog, Color(0xFF6EAA7A), Color(0xFFC81D3A)),
  'bamboo': PlantLook(PlantForm.bamboo, Color(0xFF8CCB6A), Color(0xFF6BAF4C)),
  'willow': PlantLook(PlantForm.willow, Color(0xFF9CCB7A), Color(0xFFE8E2A0)),
  'date_palm': PlantLook(PlantForm.palm, Color(0xFF7DB65A), Color(0xFF8A5A2B)),
  'prickly_pear': PlantLook(PlantForm.cactus, Color(0xFF7FB27A), Color(0xFFE34F7A)),
  'giant_cactus': PlantLook(PlantForm.cactus, Color(0xFF5E9E6E), Color(0xFFFFF2F6)),
  'aloe': PlantLook(PlantForm.succulent, Color(0xFF86C29A), Color(0xFFF08A4B)),
  'banana': PlantLook(PlantForm.palm, Color(0xFF6CC36A), Color(0xFFFFD84A)),
  'mango': PlantLook(PlantForm.tree, Color(0xFF3F9B57), Color(0xFFFFA62B)),
  'coconut_palm': PlantLook(PlantForm.palm, Color(0xFF59B05C), Color(0xFF8B5A2B)),
  'cacao': PlantLook(PlantForm.tree, Color(0xFF4E9A5C), Color(0xFFB5652E)),
  'pine': PlantLook(PlantForm.conifer, Color(0xFF3E8A62), Color(0xFF9C6B4E)),
  'blueberry': PlantLook(PlantForm.bush, Color(0xFF6FAE7A), Color(0xFF4F6FD8)),
  'edelweiss': PlantLook(PlantForm.giantFlower, Color(0xFF9CC7A4), Color(0xFFF8F8F2)),
  'snow_pear': PlantLook(PlantForm.tree, Color(0xFFD6ECEF), Color(0xFFEFF3D2), trunk: Color(0xFF8A7A6E)),
};

/// Plants drawn with [CustomPainter]. The default art.
class PaintedPlantArt extends EmojiPlantArt {
  @override
  Widget plant(SpeciesConfig species, GrowthStage stage, {required double size, double? height, double sway = 0}) {
    final tall = height ?? size;
    final look = plantLooks[species.id] ?? const PlantLook(PlantForm.tree, Color(0xFF7CC47F), Color(0xFFE8574F));
    return SizedBox(
      width: size,
      height: tall,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: PlantPainter(look: look, stage: stage, sway: sway),
            ),
          ),
          if (stage == GrowthStage.fruiting)
            for (final (dx, dy) in _fruitSpots(look.form))
              Positioned(
                left: size * dx - size * 0.07,
                top: tall * dy - size * 0.07,
                child: Transform.rotate(
                  angle: sway * 0.05,
                  child: Text(species.fruit.emoji, style: TextStyle(fontSize: size * 0.12)),
                ),
              ),
        ],
      ),
    );
  }

  static List<(double, double)> _fruitSpots(PlantForm form) => switch (form) {
    PlantForm.giantFlower => [(0.38, 0.30), (0.60, 0.42)],
    PlantForm.palm => [(0.45, 0.28), (0.55, 0.30)],
    PlantForm.grove || PlantForm.bog || PlantForm.succulent => [(0.25, 0.62), (0.5, 0.55), (0.72, 0.64)],
    PlantForm.bamboo => [(0.30, 0.72), (0.62, 0.74)],
    PlantForm.lotus => [(0.35, 0.55), (0.62, 0.52)],
    PlantForm.cactus => [(0.42, 0.18), (0.24, 0.40), (0.72, 0.36)],
    PlantForm.conifer => [(0.40, 0.45), (0.58, 0.62), (0.35, 0.70)],
    _ => [(0.30, 0.30), (0.58, 0.22), (0.66, 0.44), (0.40, 0.46)],
  };
}

class PlantPainter extends CustomPainter {
  PlantPainter({required this.look, required this.stage, required this.sway});

  final PlantLook look;
  final GrowthStage stage;
  final double sway;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final ground = Offset(w / 2, h * 0.94);

    // Soft shadow under every plant.
    canvas.drawOval(
      Rect.fromCenter(center: ground, width: w * 0.55, height: h * 0.07),
      Paint()..color = Colors.black.withValues(alpha: 0.12),
    );

    switch (stage) {
      case GrowthStage.seed:
        _mound(canvas, ground, w);
        canvas.drawOval(
          Rect.fromCenter(center: ground.translate(0, -h * 0.05), width: w * 0.10, height: w * 0.14),
          Paint()..color = const Color(0xFF8A5A3B),
        );
      case GrowthStage.sprout:
        _mound(canvas, ground, w);
        _sprout(canvas, ground, h * 0.22, w);
      case GrowthStage.young:
        _mound(canvas, ground, w);
        canvas.save();
        canvas.translate(ground.dx, ground.dy);
        canvas.scale(0.6);
        canvas.translate(-ground.dx, -ground.dy);
        _full(canvas, size, ground, flowers: false);
        canvas.restore();
      case GrowthStage.mature:
      case GrowthStage.fruiting:
        _full(canvas, size, ground, flowers: true);
    }
  }

  void _mound(Canvas canvas, Offset ground, double w) {
    canvas.drawArc(
      Rect.fromCenter(center: ground, width: w * 0.34, height: w * 0.14),
      math.pi,
      math.pi,
      true,
      Paint()..color = const Color(0xFFB88A63),
    );
  }

  void _sprout(Canvas canvas, Offset ground, double height, double w) {
    final top = ground.translate(sway * 4, -height);
    final stem = Paint()
      ..color = look.leaf
      ..strokeWidth = w * 0.025
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawPath(
      Path()
        ..moveTo(ground.dx, ground.dy)
        ..quadraticBezierTo(ground.dx, top.dy + height / 2, top.dx, top.dy),
      stem,
    );
    final leaf = Paint()..color = look.leaf;
    for (final side in [-1.0, 1.0]) {
      canvas.save();
      canvas.translate(top.dx, top.dy);
      canvas.rotate(side * 0.7);
      canvas.drawOval(Rect.fromCenter(center: Offset(side * w * 0.06, 0), width: w * 0.12, height: w * 0.06), leaf);
      canvas.restore();
    }
  }

  void _full(Canvas canvas, Size size, Offset ground, {required bool flowers}) {
    final w = size.width;
    final h = size.height;
    final leaf = Paint()..color = look.leaf;
    final dark = Paint()..color = Color.lerp(look.leaf, Colors.black, 0.18)!;
    final light = Paint()..color = Color.lerp(look.leaf, Colors.white, 0.25)!;
    final accent = Paint()..color = look.accent;
    final trunk = Paint()..color = look.trunk;
    final s = sway;

    void trunkPath(double topY, double width, {double lean = 0}) {
      final p = Path()
        ..moveTo(ground.dx - width, ground.dy)
        ..quadraticBezierTo(ground.dx - width * 0.6, (ground.dy + topY) / 2, ground.dx - width * 0.4 + lean, topY)
        ..lineTo(ground.dx + width * 0.4 + lean, topY)
        ..quadraticBezierTo(ground.dx + width * 0.6, (ground.dy + topY) / 2, ground.dx + width, ground.dy)
        ..close();
      canvas.drawPath(p, trunk);
    }

    switch (look.form) {
      case PlantForm.tree:
        trunkPath(h * 0.50, w * 0.07, lean: s * 3);
        final c = Offset(w / 2 + s * 6, h * 0.36);
        canvas.drawCircle(c.translate(-w * 0.18, h * 0.06), w * 0.20, dark);
        canvas.drawCircle(c.translate(w * 0.18, h * 0.06), w * 0.20, dark);
        canvas.drawCircle(c, w * 0.27, leaf);
        canvas.drawCircle(c.translate(-w * 0.16, -h * 0.02), w * 0.17, leaf);
        canvas.drawCircle(c.translate(w * 0.17, 0), w * 0.17, leaf);
        canvas.drawCircle(c.translate(-w * 0.07, -h * 0.10), w * 0.10, light);
        if (flowers) {
          final petal = Paint()..color = Colors.white.withValues(alpha: 0.75);
          for (final o in [
            const Offset(-0.12, -0.05),
            const Offset(0.1, -0.12),
            const Offset(0.2, 0.06),
            const Offset(-0.2, 0.08),
          ]) {
            canvas.drawCircle(c.translate(w * o.dx, h * o.dy), w * 0.018, petal);
          }
        }
      case PlantForm.palm:
        final topX = w / 2 + w * 0.08 + s * 6;
        final topY = h * 0.28;
        final p = Path()
          ..moveTo(ground.dx - w * 0.05, ground.dy)
          ..quadraticBezierTo(w * 0.5, h * 0.6, topX - w * 0.02, topY)
          ..lineTo(topX + w * 0.02, topY)
          ..quadraticBezierTo(w * 0.56, h * 0.6, ground.dx + w * 0.05, ground.dy)
          ..close();
        canvas.drawPath(p, trunk);
        final ring = Paint()
          ..color = Color.lerp(look.trunk, Colors.black, 0.2)!
          ..strokeWidth = 1.5
          ..style = PaintingStyle.stroke;
        for (var i = 1; i < 6; i++) {
          final y = ground.dy - (ground.dy - topY) * i / 6;
          canvas.drawLine(Offset(w * 0.47, y), Offset(w * 0.55, y), ring);
        }
        for (var i = 0; i < 7; i++) {
          final a = -math.pi + i * math.pi / 6 + s * 0.08;
          canvas.save();
          canvas.translate(topX, topY);
          canvas.rotate(a);
          final frond = Path()
            ..moveTo(0, 0)
            ..quadraticBezierTo(w * 0.18, -h * 0.07, w * 0.34, h * 0.05)
            ..quadraticBezierTo(w * 0.18, h * 0.0, 0, 0);
          canvas.drawPath(frond, i.isEven ? leaf : dark);
          canvas.restore();
        }
      case PlantForm.giantFlower:
        final head = Offset(w / 2 + s * 8, h * 0.30);
        final stem = Paint()
          ..color = Color.lerp(look.leaf, Colors.black, 0.1)!
          ..strokeWidth = w * 0.05
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke;
        canvas.drawPath(
          Path()
            ..moveTo(ground.dx, ground.dy)
            ..quadraticBezierTo(w * 0.5, h * 0.6, head.dx, head.dy),
          stem,
        );
        for (final side in [-1.0, 1.0]) {
          canvas.save();
          canvas.translate(w / 2 + s * 3, h * 0.62);
          canvas.rotate(side * 0.8);
          canvas.drawOval(Rect.fromCenter(center: Offset(side * w * 0.11, 0), width: w * 0.24, height: w * 0.10), leaf);
          canvas.restore();
        }
        if (flowers) {
          for (var i = 0; i < 14; i++) {
            canvas.save();
            canvas.translate(head.dx, head.dy);
            canvas.rotate(i * 2 * math.pi / 14 + s * 0.05);
            canvas.drawOval(Rect.fromCenter(center: Offset(0, -w * 0.15), width: w * 0.08, height: w * 0.16), accent);
            canvas.restore();
          }
          canvas.drawCircle(head, w * 0.11, Paint()..color = const Color(0xFF7A4E2D));
        } else {
          canvas.drawCircle(head, w * 0.07, leaf);
        }
      case PlantForm.bush:
        for (final (dx, dy, r, p) in [
          (-0.2, 0.74, 0.20, dark),
          (0.2, 0.74, 0.20, dark),
          (0.0, 0.66, 0.26, leaf),
          (-0.17, 0.70, 0.17, leaf),
          (0.18, 0.69, 0.17, leaf),
          (-0.06, 0.58, 0.10, light),
        ]) {
          canvas.drawCircle(Offset(w * (0.5 + dx) + s * 3 * (1 - dy), h * dy), w * r, p);
        }
      case PlantForm.hedge:
        // A rounded, bumpy bush with tall flower spikes, sized by width so it
        // keeps its shape in tall boxes.
        final bodyTop = ground.dy - w * 0.40;
        for (var i = 0; i < 6; i++) {
          canvas.drawCircle(Offset(w * (0.18 + i * 0.128), bodyTop + w * 0.08), w * 0.11, i.isEven ? leaf : dark);
        }
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTRB(w * 0.08, bodyTop + w * 0.06, w * 0.92, ground.dy),
            Radius.circular(w * 0.16),
          ),
          leaf,
        );
        if (flowers) {
          final stalk = Paint()
            ..color = dark.color
            ..strokeWidth = 2;
          for (var i = 0; i < 9; i++) {
            final x = w * (0.16 + i * 0.085);
            final top = bodyTop - w * (0.42 + (i % 3) * 0.08);
            final lean = s * 6;
            canvas.drawLine(Offset(x, bodyTop + w * 0.1), Offset(x + lean, top), stalk);
            for (var j = 0; j < 7; j++) {
              canvas.drawOval(
                Rect.fromCenter(
                  center: Offset(x + lean * (1 - j / 7), top + j * w * 0.05),
                  width: w * 0.045,
                  height: w * 0.055,
                ),
                accent,
              );
            }
          }
        }
      case PlantForm.grove:
        for (final (dx, scale) in [(-0.22, 0.75), (0.24, 0.85), (0.0, 1.1)]) {
          final x = w * (0.5 + dx) + s * 2;
          final stemTop = h * (0.94 - 0.38 * scale);
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTRB(x - w * 0.05 * scale, stemTop, x + w * 0.05 * scale, ground.dy),
              Radius.circular(w * 0.03),
            ),
            leaf,
          );
          final cap = Rect.fromCenter(center: Offset(x, stemTop), width: w * 0.34 * scale, height: w * 0.26 * scale);
          canvas.drawArc(cap, math.pi, math.pi, true, accent);
          final dot = Paint()..color = Colors.white.withValues(alpha: 0.85);
          canvas.drawCircle(Offset(x - w * 0.06 * scale, stemTop - w * 0.06 * scale), w * 0.022 * scale, dot);
          canvas.drawCircle(Offset(x + w * 0.05 * scale, stemTop - w * 0.08 * scale), w * 0.018 * scale, dot);
        }
      case PlantForm.cactus:
        final body = Paint()..color = look.leaf;
        final x = w / 2;
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTRB(x - w * 0.09, h * 0.18, x + w * 0.09, ground.dy),
            Radius.circular(w * 0.09),
          ),
          body,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTRB(x - w * 0.30, h * 0.40, x - w * 0.18, h * 0.66),
            Radius.circular(w * 0.06),
          ),
          body,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTRB(x - w * 0.30, h * 0.60, x - w * 0.05, h * 0.68),
            Radius.circular(w * 0.04),
          ),
          body,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTRB(x + w * 0.18, h * 0.34, x + w * 0.30, h * 0.58),
            Radius.circular(w * 0.06),
          ),
          body,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTRB(x + w * 0.05, h * 0.52, x + w * 0.30, h * 0.60),
            Radius.circular(w * 0.04),
          ),
          body,
        );
        final rib = Paint()
          ..color = dark.color
          ..strokeWidth = 1.5;
        canvas.drawLine(Offset(x, h * 0.22), Offset(x, ground.dy - 4), rib);
        if (flowers) {
          for (final o in [Offset(x, h * 0.17), Offset(x - w * 0.24, h * 0.39), Offset(x + w * 0.24, h * 0.33)]) {
            for (var i = 0; i < 5; i++) {
              canvas.save();
              canvas.translate(o.dx, o.dy);
              canvas.rotate(i * 2 * math.pi / 5);
              canvas.drawOval(
                Rect.fromCenter(center: Offset(0, -w * 0.03), width: w * 0.035, height: w * 0.06),
                accent,
              );
              canvas.restore();
            }
          }
        }
      case PlantForm.bamboo:
        for (final (dx, top) in [(-0.2, 0.18), (0.0, 0.08), (0.2, 0.22), (-0.08, 0.30)]) {
          final x = w * (0.5 + dx);
          final lean = s * 8 * (1 - top);
          final stalk = Paint()
            ..color = look.accent
            ..strokeWidth = w * 0.05
            ..strokeCap = StrokeCap.round;
          canvas.drawLine(Offset(x, ground.dy), Offset(x + lean, h * top), stalk);
          final node = Paint()
            ..color = dark.color
            ..strokeWidth = 2;
          for (var y = ground.dy - h * 0.14; y > h * top; y -= h * 0.14) {
            final t = (ground.dy - y) / (ground.dy - h * top);
            canvas.drawLine(Offset(x - w * 0.028 + lean * t, y), Offset(x + w * 0.028 + lean * t, y), node);
          }
          for (final side in [-1.0, 1.0]) {
            canvas.save();
            canvas.translate(x + lean, h * top + h * 0.06);
            canvas.rotate(side * 0.9);
            canvas.drawOval(
              Rect.fromCenter(center: Offset(side * w * 0.07, 0), width: w * 0.16, height: w * 0.05),
              leaf,
            );
            canvas.restore();
          }
        }
      case PlantForm.fern:
        for (var i = 0; i < 9; i++) {
          final a = -math.pi / 2 + (i - 4) * 0.32 + s * 0.06;
          canvas.save();
          canvas.translate(ground.dx, ground.dy);
          canvas.rotate(a + math.pi / 2);
          final len = h * (0.55 + (4 - (i - 4).abs()) * 0.06);
          final spine = Paint()
            ..color = dark.color
            ..strokeWidth = 2
            ..style = PaintingStyle.stroke;
          canvas.drawLine(Offset.zero, Offset(0, -len), spine);
          for (var j = 1; j < 9; j++) {
            final y = -len * j / 9;
            final lw = w * 0.07 * (1 - j / 10);
            canvas.drawOval(
              Rect.fromCenter(center: Offset(-lw / 2, y), width: lw, height: w * 0.03),
              i.isEven ? leaf : light,
            );
            canvas.drawOval(
              Rect.fromCenter(center: Offset(lw / 2, y), width: lw, height: w * 0.03),
              i.isEven ? leaf : light,
            );
          }
          canvas.restore();
        }
      case PlantForm.lotus:
        canvas.drawOval(
          Rect.fromCenter(center: ground.translate(0, -h * 0.02), width: w * 0.9, height: h * 0.16),
          Paint()..color = const Color(0xFF9FD3E8),
        );
        for (final dx in [-0.25, 0.25]) {
          canvas.drawOval(
            Rect.fromCenter(center: Offset(w * (0.5 + dx), ground.dy - h * 0.04), width: w * 0.34, height: h * 0.10),
            leaf,
          );
        }
        if (flowers) {
          final c = Offset(w / 2 + s * 3, h * 0.66);
          for (var i = 0; i < 9; i++) {
            canvas.save();
            canvas.translate(c.dx, c.dy);
            canvas.rotate(-math.pi / 2 + (i - 4) * 0.33);
            canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.12, 0), width: w * 0.26, height: w * 0.10), accent);
            canvas.restore();
          }
          canvas.drawCircle(c, w * 0.05, Paint()..color = const Color(0xFFFFE08A));
        }
      case PlantForm.willow:
        trunkPath(h * 0.36, w * 0.08);
        final c = Offset(w / 2, h * 0.30);
        canvas.drawOval(Rect.fromCenter(center: c, width: w * 0.8, height: h * 0.30), leaf);
        final strand = Paint()
          ..color = light.color
          ..strokeWidth = w * 0.025
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke;
        for (var i = 0; i < 11; i++) {
          final x = w * (0.14 + i * 0.072);
          final len = h * (0.40 + (i % 3) * 0.06);
          canvas.drawPath(
            Path()
              ..moveTo(x, h * 0.30)
              ..quadraticBezierTo(x + s * 10, h * 0.30 + len / 2, x + s * 14, h * 0.30 + len),
            strand,
          );
        }
      case PlantForm.conifer:
        trunkPath(h * 0.78, w * 0.05);
        for (var i = 0; i < 4; i++) {
          final top = h * (0.08 + i * 0.16);
          final half = w * (0.14 + i * 0.07);
          final p = Path()
            ..moveTo(w / 2 + s * 5 * (1 - i / 4), top)
            ..lineTo(w / 2 - half, top + h * 0.26)
            ..lineTo(w / 2 + half, top + h * 0.26)
            ..close();
          canvas.drawPath(p, i.isEven ? leaf : dark);
        }
        final snow = Paint()..color = Colors.white.withValues(alpha: 0.85);
        canvas.drawCircle(Offset(w / 2, h * 0.10), w * 0.03, snow);
      case PlantForm.succulent:
        for (var i = 0; i < 9; i++) {
          final a = -math.pi / 2 + (i - 4) * 0.34 + s * 0.04;
          canvas.save();
          canvas.translate(ground.dx, ground.dy - h * 0.02);
          canvas.rotate(a + math.pi / 2);
          final len = h * (0.40 + (4 - (i - 4).abs()) * 0.06);
          final blade = Path()
            ..moveTo(-w * 0.05, 0)
            ..quadraticBezierTo(-w * 0.03, -len * 0.6, 0, -len)
            ..quadraticBezierTo(w * 0.03, -len * 0.6, w * 0.05, 0)
            ..close();
          canvas.drawPath(blade, i.isEven ? leaf : dark);
          canvas.restore();
        }
        if (flowers) {
          final stalk = Paint()
            ..color = dark.color
            ..strokeWidth = 2;
          canvas.drawLine(ground, Offset(w * 0.62 + s * 6, h * 0.10), stalk);
          for (var j = 0; j < 6; j++) {
            canvas.drawOval(
              Rect.fromCenter(
                center: Offset(w * 0.62 + s * 6, h * (0.10 + j * 0.035)),
                width: w * 0.035,
                height: w * 0.05,
              ),
              accent,
            );
          }
        }
      case PlantForm.bog:
        canvas.drawOval(
          Rect.fromCenter(center: ground.translate(0, -h * 0.04), width: w * 0.92, height: h * 0.22),
          Paint()..color = const Color(0xFF8CC7D8),
        );
        for (var i = 0; i < 12; i++) {
          final x = w * (0.12 + i * 0.07);
          final y = h * (0.72 + (i % 3) * 0.04);
          canvas.drawCircle(Offset(x + s * 2, y), w * 0.07, i.isEven ? leaf : dark);
        }
        if (flowers) {
          for (var i = 0; i < 10; i++) {
            canvas.drawCircle(Offset(w * (0.16 + i * 0.075), h * (0.68 + (i % 2) * 0.06)), w * 0.022, accent);
          }
        }
    }
  }

  @override
  bool shouldRepaint(PlantPainter old) => old.stage != stage || old.sway != sway || old.look != look;
}
