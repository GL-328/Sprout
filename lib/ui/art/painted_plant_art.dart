import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../config/game_config.dart';
import '../../domain/models/enums.dart';
import 'icon_art.dart';
import 'icon_painters.dart';
import 'plant_art_provider.dart';

/// The shapes the plant painter knows.
enum PlantForm {
  tree,
  palm,
  banana,
  giantFlower,
  starFlower,
  bush,
  hedge,
  grove,
  cactus,
  pads,
  bamboo,
  fern,
  lotus,
  willow,
  conifer,
  succulent,
  bog,
}

/// Crown shapes for trees, so each species has its own silhouette.
enum TreeShape { round, spread, umbrella, twin, tall, dense, tiered, vase }

/// How one species looks. Add an entry to [plantLooks] for each species in
/// the config; unknown species fall back to a round tree. Use [stages] to
/// change one growth stage of one species without touching the others.
class PlantLook {
  const PlantLook(
    this.form, {
    required this.leaf,
    required this.accent,
    this.trunk = _bark,
    this.bloom,
    this.width = 0.8,
    this.height = 0.6,
    this.trunkHeight = 0.32,
    this.snow = false,
    this.fruitSpots,
    this.shape = TreeShape.round,
    this.stages = const {},
  });

  /// The crown shape, for trees.
  final TreeShape shape;

  final PlantForm form;

  /// Main foliage colour; darker and lighter tones are made from it.
  final Color leaf;

  /// The form's flower or feature colour (petals, caps, spikes).
  final Color accent;
  final Color trunk;

  /// Blossom colour on a mature plant, or null for none.
  final Color? bloom;

  /// Size of the crown or body, in plant widths.
  final double width;
  final double height;
  final double trunkHeight;

  /// A dusting of snow on top (alpine plants).
  final bool snow;

  /// Where fruit hangs when fruiting, as (x, y) in plant units: x from -0.5
  /// to 0.5, y upwards from the ground (negative). Null uses the form's spots.
  final List<(double, double)>? fruitSpots;

  /// Per-stage replacements for this species.
  final Map<GrowthStage, PlantLook> stages;

  PlantLook forStage(GrowthStage stage) => stages[stage] ?? this;
}

const _bark = Color(0xFFA0704F);
const _soil = Color(0xFFC0916A);

/// Every species' look, keyed by species id.
const plantLooks = <String, PlantLook>{
  // Meadow
  'apple_tree': PlantLook(PlantForm.tree, leaf: Color(0xFF7DC47E), accent: Color(0xFFE8574F), bloom: Color(0xFFFFF1F4)),
  'giant_sunflower': PlantLook(PlantForm.giantFlower, leaf: Color(0xFF7DBF6A), accent: Color(0xFFFFC93C)),
  'berry_bush': PlantLook(PlantForm.bush, leaf: Color(0xFF63B26F), accent: Color(0xFFE5486B), bloom: Color(0xFFFFFFFF)),
  'lavender_hedge': PlantLook(PlantForm.hedge, leaf: Color(0xFF93BE8F), accent: Color(0xFFA58CDB)),
  // Forest
  'oak': PlantLook(
    PlantForm.tree,
    leaf: Color(0xFF62A35E),
    accent: Color(0xFFB07A44),
    trunk: Color(0xFF8A5E40),
    shape: TreeShape.spread,
    width: 0.88,
    height: 0.52,
    trunkHeight: 0.36,
  ),
  'mushroom_grove': PlantLook(PlantForm.grove, leaf: Color(0xFF8CC48A), accent: Color(0xFFE8695C)),
  'hazelnut': PlantLook(
    PlantForm.tree,
    leaf: Color(0xFF7FB56E),
    accent: Color(0xFFB98A5A),
    shape: TreeShape.vase,
    width: 0.86,
    height: 0.56,
    trunkHeight: 0.26,
  ),
  'fern_canopy': PlantLook(PlantForm.fern, leaf: Color(0xFF58A872), accent: Color(0xFF8BD18F)),
  // Orchard
  'cherry': PlantLook(
    PlantForm.tree,
    leaf: Color(0xFFF5B5C7),
    accent: Color(0xFFD7263D),
    bloom: Color(0xFFFFFFFF),
    shape: TreeShape.spread,
    width: 0.84,
    height: 0.5,
    stages: {
      GrowthStage.fruiting: PlantLook(
        PlantForm.tree,
        leaf: Color(0xFF86C27E),
        accent: Color(0xFFD7263D),
        shape: TreeShape.spread,
        width: 0.84,
        height: 0.5,
      ),
    },
  ),
  'peach': PlantLook(
    PlantForm.tree,
    leaf: Color(0xFF8CC97E),
    accent: Color(0xFFFFA07A),
    bloom: Color(0xFFFFC9D6),
    shape: TreeShape.twin,
    width: 0.92,
  ),
  'plum': PlantLook(
    PlantForm.tree,
    leaf: Color(0xFF7DB87A),
    accent: Color(0xFF7B4B94),
    bloom: Color(0xFFFFFFFF),
    shape: TreeShape.umbrella,
    width: 0.9,
    height: 0.48,
    trunkHeight: 0.4,
  ),
  'pear': PlantLook(
    PlantForm.tree,
    leaf: Color(0xFF8BC27B),
    accent: Color(0xFFC9D85B),
    bloom: Color(0xFFFFFFFF),
    shape: TreeShape.tall,
    width: 0.62,
    height: 0.74,
  ),
  // Pond
  'lotus': PlantLook(PlantForm.lotus, leaf: Color(0xFF72C08F), accent: Color(0xFFF7A1C4)),
  'cranberry_bog': PlantLook(
    PlantForm.bog,
    leaf: Color(0xFF6FAA7B),
    accent: Color(0xFFC81D3A),
    bloom: Color(0xFFF9C3D3),
  ),
  'bamboo': PlantLook(PlantForm.bamboo, leaf: Color(0xFF7DC46A), accent: Color(0xFF9DCF6E)),
  'willow': PlantLook(PlantForm.willow, leaf: Color(0xFF9ACB78), accent: Color(0xFFE8E2A0), trunk: Color(0xFF8E6A50)),
  // Desert
  'date_palm': PlantLook(PlantForm.palm, leaf: Color(0xFF7DB65A), accent: Color(0xFF8A5A2B), trunk: Color(0xFFB98A5E)),
  'prickly_pear': PlantLook(PlantForm.pads, leaf: Color(0xFF86B97C), accent: Color(0xFFFFD45C)),
  'giant_cactus': PlantLook(PlantForm.cactus, leaf: Color(0xFF6AAB78), accent: Color(0xFFFFF2F6)),
  'aloe': PlantLook(PlantForm.succulent, leaf: Color(0xFF86C29A), accent: Color(0xFFF08A4B)),
  // Tropical
  'banana': PlantLook(PlantForm.banana, leaf: Color(0xFF72C76C), accent: Color(0xFFFFD84A), trunk: Color(0xFF9CC77A)),
  'mango': PlantLook(
    PlantForm.tree,
    leaf: Color(0xFF479E5B),
    accent: Color(0xFFFFA62B),
    shape: TreeShape.dense,
    width: 0.84,
    height: 0.6,
  ),
  'coconut_palm': PlantLook(
    PlantForm.palm,
    leaf: Color(0xFF5CB35F),
    accent: Color(0xFF8B5A2B),
    trunk: Color(0xFFB08560),
  ),
  'cacao': PlantLook(
    PlantForm.tree,
    leaf: Color(0xFF55A363),
    accent: Color(0xFFB5652E),
    shape: TreeShape.tiered,
    width: 0.86,
    height: 0.62,
    trunkHeight: 0.3,
    fruitSpots: [(-0.04, -0.16), (0.05, -0.24), (-0.3, -0.5), (0.3, -0.48)],
  ),
  // Alpine
  'pine': PlantLook(PlantForm.conifer, leaf: Color(0xFF4A9469), accent: Color(0xFF9C6B4E), snow: true),
  'blueberry': PlantLook(PlantForm.bush, leaf: Color(0xFF6EAE7E), accent: Color(0xFF4F6FD8), bloom: Color(0xFFFFF4F7)),
  'edelweiss': PlantLook(PlantForm.starFlower, leaf: Color(0xFFA9C9AE), accent: Color(0xFFF7F7F0)),
  'snow_pear': PlantLook(
    PlantForm.tree,
    leaf: Color(0xFFA9D3C9),
    accent: Color(0xFFEFF3D2),
    trunk: Color(0xFF8A7A6E),
    bloom: Color(0xFFFFFFFF),
    shape: TreeShape.tall,
    width: 0.64,
    height: 0.72,
    snow: true,
  ),
};

const _fallbackLook = PlantLook(PlantForm.tree, leaf: Color(0xFF7DC47E), accent: Color(0xFFE8574F));

/// Plants drawn with [CustomPainter]. The default art.
class PaintedPlantArt extends SimplePlantArt {
  @override
  Widget plant(SpeciesConfig species, GrowthStage stage, {required double size, double? height, double sway = 0}) =>
      SizedBox(
        width: size,
        height: height ?? size,
        child: CustomPaint(
          painter: PlantPainter(
            look: (plantLooks[species.id] ?? _fallbackLook).forStage(stage),
            stage: stage,
            sway: sway,
            fruitIcon: 'fruit:${species.id}',
          ),
        ),
      );

  @override
  Widget groundSpot({required double size}) => CustomPaint(size: Size(size, size * 0.4), painter: _SpotPainter());
}

/// A plant that sways (or wobbles, as a seed) by itself. Still when [animate]
/// is false, for Reduce motion.
class LivePlant extends StatefulWidget {
  const LivePlant({super.key, required this.species, required this.stage, required this.size, this.animate = true});

  final SpeciesConfig species;
  final GrowthStage stage;
  final double size;
  final bool animate;

  @override
  State<LivePlant> createState() => _LivePlantState();
}

class _LivePlantState extends State<LivePlant> with SingleTickerProviderStateMixin {
  late final _wind = AnimationController(vsync: this, duration: const Duration(milliseconds: 3200));

  @override
  void initState() {
    super.initState();
    if (widget.animate) _wind.repeat();
  }

  @override
  void didUpdateWidget(LivePlant old) {
    super.didUpdateWidget(old);
    if (widget.animate && !_wind.isAnimating) _wind.repeat();
    if (!widget.animate && _wind.isAnimating) _wind.stop();
  }

  @override
  void dispose() {
    _wind.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _wind,
    builder: (context, _) => plantArtProvider.plant(
      widget.species,
      widget.stage,
      size: widget.size,
      sway: widget.animate ? math.sin(_wind.value * 2 * math.pi) : 0,
    ),
  );
}

/// Draws one plant. Everything is drawn in plant units: the plant is 1 wide,
/// the ground is at y = 0 and up is negative.
class PlantPainter extends CustomPainter {
  PlantPainter({required this.look, required this.stage, required this.sway, required this.fruitIcon});

  final PlantLook look;
  final GrowthStage stage;

  /// -1..1, gentle wind.
  final double sway;
  final String fruitIcon;

  /// How tall each form is at full size, in plant widths (for fitting).
  static double naturalHeight(PlantLook l) => switch (l.form) {
    PlantForm.tree || PlantForm.willow => l.trunkHeight + l.height + 0.16,
    PlantForm.palm || PlantForm.banana || PlantForm.conifer || PlantForm.cactus || PlantForm.bamboo => 1.0,
    PlantForm.giantFlower => 0.98,
    PlantForm.fern => 0.7,
    PlantForm.hedge => 0.72,
    _ => 0.62,
  };

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final groundY = size.height * 0.95;
    final mature = stage == GrowthStage.mature || stage == GrowthStage.fruiting;
    final young = stage == GrowthStage.young;
    final growth = mature ? 1.0 : (young ? 0.64 : 0.0);
    final tall = growth == 0 ? 0.56 : naturalHeight(look) * growth;
    final fit = math.min(1.0, (groundY / w) / math.max(tall, 0.4));

    final small = stage == GrowthStage.seed || stage == GrowthStage.sprout;
    // Seeds and sprouts are small in life; draw them a little larger so they
    // read well in the garden.
    void place() {
      canvas.translate(w / 2, groundY);
      canvas.scale(w * fit);
    }

    // The shadow and the soil bed sit on the ground, outside the outline, so
    // they fade softly into the grass.
    canvas.save();
    place();
    final p = Pen(canvas);
    _softOval(canvas, 0, 0.005, growth == 0 ? 0.6 : 0.44 + 0.34 * growth, 0.1, const Color(0x2E3B2E3A), solid: 0.3);
    if (small) canvas.scale(1.35);
    final bed = switch (stage) {
      GrowthStage.seed => 0.56,
      GrowthStage.sprout => 0.48,
      GrowthStage.young => 0.5,
      _ => 0.0,
    };
    if (bed > 0) {
      _softSoil(p, bed * 1.3, seed: 5);
      // The mound fades into its bed, so it stays outside the outline too.
      _mound(p, bed);
    }
    canvas.restore();

    paintOutlined(canvas, Offset.zero & size, outlineWidth(w) * 0.85, () {
      canvas.save();
      place();
      if (small) {
        canvas.scale(1.35);
        if (stage == GrowthStage.seed) {
          _seedInSoil(p);
        } else {
          _sprout(p);
        }
      } else {
        canvas.save();
        if (young) canvas.scale(growth);
        // Sway: a skew from the ground up, so tops move and roots stay put.
        canvas.transform(Matrix4.skewX(-sway * 0.05).storage);
        _form(p, flowers: mature, fruit: stage == GrowthStage.fruiting);
        canvas.restore();
      }
      canvas.restore();
    });
    if (stage == GrowthStage.seed) {
      canvas.save();
      place();
      canvas.scale(1.35);
      _seedHug(p);
      canvas.restore();
    }
  }

  // --- Seed and sprout -------------------------------------------------------

  /// The soil mound. Its soft bed is drawn separately, under the outline.
  void _mound(Pen p, double width) {
    final h = width * 0.36;
    final dome = Path()
      ..moveTo(-width / 2, 0)
      ..cubicTo(-width * 0.42, -h * 1.15, width * 0.42, -h * 1.15, width / 2, 0)
      ..close();
    // The mound is drawn on its own layer, then faded out towards its foot,
    // so it sinks into the soil bed with no hard bottom edge.
    final bounds = Rect.fromLTRB(-width / 2, -h, width / 2, 0);
    p.canvas.saveLayer(bounds.inflate(width * 0.05), Paint());
    p.fill(dome, _soil);
    p.canvas.save();
    p.canvas.clipPath(dome);
    // Tonal shading: a darker base and a soft lit top.
    p.oval(0, h * 0.25, width * 1.1, h * 1.1, shade(_soil, 0.12));
    p.oval(-width * 0.12, -h * 0.82, width * 0.5, h * 0.38, tint(_soil, 0.22));
    p.canvas.restore();
    p.canvas.drawRect(
      bounds.inflate(width * 0.05),
      Paint()
        ..blendMode = BlendMode.dstIn
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white, Colors.white, Color(0x00FFFFFF)],
          stops: [0, 0.62, 0.96],
        ).createShader(bounds),
    );
    p.canvas.restore();
    // Speckled texture, always in the same places.
    final rnd = math.Random(7);
    for (var i = 0; i < 9; i++) {
      final x = (rnd.nextDouble() - 0.5) * width * 0.7;
      final y = -rnd.nextDouble() * h * 0.7 - h * 0.08;
      p.circle(x, y, width * (0.012 + rnd.nextDouble() * 0.01), i.isEven ? shade(_soil, 0.25) : tint(_soil, 0.35));
    }
  }

  void _seedInSoil(Pen p) {
    const seed = Color(0xFFB97B4E);
    p.canvas.save();
    // The seed rocks gently on its base.
    p.canvas.translate(0, -0.12);
    p.canvas.rotate(sway * 0.14);
    final body = Path()
      ..moveTo(0, -0.17)
      ..cubicTo(0.12, -0.12, 0.13, 0.0, 0.09, 0.04)
      ..quadraticBezierTo(0, 0.09, -0.09, 0.04)
      ..cubicTo(-0.13, 0.0, -0.12, -0.12, 0, -0.17)
      ..close();
    p.fill(body, seed);
    p.canvas.save();
    p.canvas.clipPath(body);
    p.oval(0.06, 0.02, 0.16, 0.24, shade(seed, 0.14));
    p.canvas.restore();
    p.shine(-0.045, -0.06, 0.035, 0.09, rot: 0.2);
    // A small crack with a tiny sprout tip peeking out.
    p.stroke(
      Path()
        ..moveTo(-0.01, -0.165)
        ..lineTo(0.015, -0.13)
        ..lineTo(-0.005, -0.1)
        ..lineTo(0.02, -0.07),
      shade(seed, 0.4),
      0.012,
    );
    p.stroke(
      Path()
        ..moveTo(0, -0.165)
        ..quadraticBezierTo(0.005, -0.2, 0.025, -0.215),
      const Color(0xFF6DB57E),
      0.016,
    );
    p.leaf(0.022, -0.212, 0.06, 0.022, -0.5, const Color(0xFF8BD18F));
    p.canvas.restore();
  }

  /// Soil hugging the seed's base, so it sits in the ground. Drawn over the
  /// seed's outline.
  void _seedHug(Pen p) {
    p.fill(
      Path()
        ..moveTo(-0.16, -0.06)
        ..quadraticBezierTo(0, -0.11, 0.16, -0.06)
        ..quadraticBezierTo(0.1, -0.03, 0, -0.03)
        ..quadraticBezierTo(-0.1, -0.03, -0.16, -0.06)
        ..close(),
      tint(_soil, 0.08),
    );
  }

  void _sprout(Pen p) {
    final leaf = look.form == PlantForm.tree && look.leaf.computeLuminance() > 0.5
        ? const Color(0xFF86C27E)
        : look.leaf;
    p.canvas.save();
    p.canvas.translate(0, -0.12);
    p.canvas.transform(Matrix4.skewX(-sway * 0.1).storage);
    p.stroke(
      Path()
        ..moveTo(0, 0)
        ..quadraticBezierTo(-0.02, -0.12, 0.0, -0.22),
      shade(leaf, 0.18),
      0.03,
    );
    for (final side in [-1.0, 1.0]) {
      final a = side < 0 ? -2.55 : -0.55;
      p.leaf(0, -0.2, 0.2, 0.08, a, side < 0 ? shade(leaf, 0.06) : leaf);
      p.leaf(0, -0.2, 0.15, 0.035, a, tint(leaf, 0.25));
    }
    p.leaf(0, -0.22, 0.08, 0.03, -1.7, tint(leaf, 0.15));
    p.canvas.restore();
  }

  // --- Mature forms ------------------------------------------------------------

  void _form(Pen p, {required bool flowers, required bool fruit}) {
    switch (look.form) {
      case PlantForm.tree:
        _tree(p, flowers: flowers, fruit: fruit);
      case PlantForm.palm:
        _palm(p, fruit: fruit);
      case PlantForm.banana:
        _banana(p, fruit: fruit);
      case PlantForm.giantFlower:
        _sunflower(p, flowers: flowers, fruit: fruit);
      case PlantForm.starFlower:
        _edelweiss(p, flowers: flowers, fruit: fruit);
      case PlantForm.bush:
        _bush(p, flowers: flowers, fruit: fruit);
      case PlantForm.hedge:
        _hedge(p, flowers: flowers, fruit: fruit);
      case PlantForm.grove:
        _grove(p, fruit: fruit);
      case PlantForm.cactus:
        _cactus(p, flowers: flowers, fruit: fruit);
      case PlantForm.pads:
        _pads(p, flowers: flowers, fruit: fruit);
      case PlantForm.bamboo:
        _bamboo(p, fruit: fruit);
      case PlantForm.fern:
        _fern(p, fruit: fruit);
      case PlantForm.lotus:
        _lotus(p, flowers: flowers, fruit: fruit);
      case PlantForm.willow:
        _willow(p, fruit: fruit);
      case PlantForm.conifer:
        _conifer(p, fruit: fruit);
      case PlantForm.succulent:
        _aloe(p, flowers: flowers, fruit: fruit);
      case PlantForm.bog:
        _bog(p, flowers: flowers, fruit: fruit);
    }
  }

  Color get _dark => shade(look.leaf, 0.2);
  Color get _light => tint(look.leaf, 0.3);

  /// Puffy foliage from circles: a darker back layer, the main tone, then
  /// soft lit tops.
  void _puffs(Pen p, List<(double, double, double)> puffs, Color base, {bool snow = false}) {
    for (final (x, y, r) in puffs) {
      p.circle(x, y + r * 0.14, r, shade(base, 0.2));
    }
    for (final (x, y, r) in puffs) {
      p.circle(x, y, r * 0.9, base);
    }
    final mid = puffs.map((q) => q.$2).reduce((a, b) => a + b) / puffs.length;
    for (final (x, y, r) in puffs.where((q) => q.$2 <= mid)) {
      p.circle(x - r * 0.3, y - r * 0.36, r * 0.36, tint(base, 0.16));
    }
    if (snow) {
      final top = puffs.map((q) => q.$2).reduce(math.min);
      for (final (x, y, r) in puffs.where((e) => e.$2 < top + 0.12)) {
        p.oval(x - r * 0.1, y - r * 0.62, r * 1.1, r * 0.4, const Color(0xFFFFFFFF));
      }
    }
  }

  /// Little leaves around an edge, for texture.
  void _edgeLeaves(Pen p, double cx, double cy, double rx, double ry, Color c, {int count = 9}) {
    for (var i = 0; i < count; i++) {
      final a = math.pi + (i + 0.5) * math.pi / count;
      final x = cx + rx * math.cos(a);
      final y = cy + ry * math.sin(a);
      p.leaf(x, y, 0.075, 0.028, a + (i.isEven ? 0.3 : -0.3), c);
    }
  }

  void _blossoms(Pen p, List<(double, double)> at, Color c, {double r = 0.022}) {
    for (final (x, y) in at) {
      paintSmallBlossom(p, x, y, r, c, const Color(0xFFFFD45C));
    }
  }

  void _fruit(Pen p, List<(double, double)> at, {double size = 0.13}) {
    final spec = iconSpecs[fruitIcon];
    if (spec == null) return;
    for (final (x, y) in look.fruitSpots ?? at) {
      p.canvas.save();
      final s = size * 1.5;
      p.canvas.translate(x - s / 2, y - s / 2);
      p.canvas.scale(s);
      spec.paint(Pen(p.canvas), spec.a, spec.b, spec.c);
      p.canvas.restore();
    }
  }

  void _trunk(Pen p, double top, double base, Color c) {
    final t = Path()
      ..moveTo(-base, 0)
      ..quadraticBezierTo(-base * 0.45, -top * 0.5, -base * 0.42, -top)
      ..lineTo(base * 0.42, -top)
      ..quadraticBezierTo(base * 0.45, -top * 0.5, base, 0)
      ..close();
    p.fill(t, c);
    p.canvas.save();
    p.canvas.clipPath(t);
    p.rrect(base * 0.12, -top, base * 1.2, 0.01, 0, shade(c, 0.14));
    p.canvas.restore();
  }

  /// Puff layouts for each crown shape, as (x, y, r) relative to the crown.
  static const _crowns = <TreeShape, List<(double, double, double)>>{
    TreeShape.round: [
      (-0.36, 0.2, 0.2),
      (0.36, 0.2, 0.2),
      (-0.14, 0.28, 0.2),
      (0.16, 0.28, 0.2),
      (0.0, 0.0, 0.3),
      (-0.28, -0.08, 0.22),
      (0.28, -0.06, 0.22),
      (-0.1, -0.3, 0.22),
      (0.14, -0.28, 0.2),
    ],
    TreeShape.spread: [
      (-0.44, 0.16, 0.15),
      (0.44, 0.16, 0.15),
      (-0.24, 0.22, 0.18),
      (0.0, 0.24, 0.18),
      (0.24, 0.22, 0.18),
      (-0.32, -0.1, 0.19),
      (0.32, -0.1, 0.19),
      (0.0, -0.12, 0.23),
      (-0.14, -0.34, 0.16),
      (0.16, -0.32, 0.16),
    ],
    TreeShape.umbrella: [
      (-0.42, 0.06, 0.15),
      (0.42, 0.06, 0.15),
      (-0.22, -0.06, 0.21),
      (0.22, -0.06, 0.21),
      (0.0, -0.14, 0.24),
      (-0.1, 0.18, 0.15),
      (0.12, 0.18, 0.15),
      (0.0, -0.36, 0.15),
    ],
    TreeShape.twin: [
      (-0.3, 0.12, 0.17),
      (-0.36, -0.12, 0.17),
      (-0.2, -0.3, 0.17),
      (-0.16, 0.02, 0.19),
      (0.3, 0.16, 0.17),
      (0.36, -0.08, 0.17),
      (0.22, -0.26, 0.17),
      (0.18, 0.04, 0.19),
    ],
    TreeShape.tall: [
      (-0.2, 0.32, 0.18),
      (0.2, 0.32, 0.18),
      (0.0, 0.26, 0.22),
      (-0.24, 0.05, 0.2),
      (0.24, 0.05, 0.2),
      (0.0, 0.0, 0.24),
      (-0.16, -0.22, 0.19),
      (0.16, -0.22, 0.19),
      (0.0, -0.38, 0.2),
    ],
    TreeShape.dense: [
      (-0.4, 0.18, 0.18),
      (0.4, 0.18, 0.18),
      (-0.2, 0.26, 0.2),
      (0.0, 0.28, 0.2),
      (0.2, 0.26, 0.2),
      (-0.32, -0.06, 0.21),
      (0.32, -0.06, 0.21),
      (0.0, 0.0, 0.28),
      (-0.16, -0.3, 0.21),
      (0.16, -0.3, 0.21),
      (0.0, -0.4, 0.16),
    ],
    TreeShape.tiered: [
      (-0.42, 0.3, 0.12),
      (-0.2, 0.32, 0.14),
      (0.04, 0.33, 0.14),
      (0.26, 0.31, 0.13),
      (0.44, 0.28, 0.11),
      (-0.24, -0.22, 0.15),
      (0.0, -0.26, 0.18),
      (0.24, -0.22, 0.15),
      (0.0, -0.42, 0.13),
    ],
    TreeShape.vase: [
      (-0.36, 0.12, 0.18),
      (0.36, 0.12, 0.18),
      (-0.12, 0.18, 0.18),
      (0.14, 0.18, 0.18),
      (-0.26, -0.12, 0.2),
      (0.26, -0.12, 0.2),
      (0.0, -0.1, 0.22),
      (0.0, -0.34, 0.18),
    ],
  };

  void _tree(Pen p, {required bool flowers, required bool fruit}) {
    final th = look.trunkHeight;
    final cw = look.width;
    final ch = look.height;
    final cy = -th - ch * 0.5;
    switch (look.shape) {
      case TreeShape.vase:
        // Several thin stems, like a hazel.
        for (final (x, lean) in const [(-0.05, -0.18), (0.0, 0.0), (0.05, 0.18)]) {
          p.stroke(
            Path()
              ..moveTo(x, 0)
              ..quadraticBezierTo(x + lean * 0.3, -th * 0.6, x + lean, -th - 0.04),
            look.trunk,
            0.045,
          );
        }
      case TreeShape.twin:
        _trunk(p, th * 0.7, 0.07, look.trunk);
        for (final side in [-1.0, 1.0]) {
          p.stroke(
            Path()
              ..moveTo(0, -th * 0.62)
              ..quadraticBezierTo(side * 0.08, -th * 0.9, side * 0.2, -th - 0.02),
            look.trunk,
            0.05,
          );
        }
      case TreeShape.tiered:
        _trunk(p, th + ch * 0.85, 0.06, look.trunk);
        for (final side in [-1.0, 1.0]) {
          p.stroke(
            Path()
              ..moveTo(0, cy + ch * 0.3)
              ..quadraticBezierTo(side * 0.15, cy + ch * 0.3, side * 0.32, cy + ch * 0.24),
            look.trunk,
            0.025,
          );
        }
      default:
        _trunk(p, th + 0.06, 0.07, look.trunk);
        p.stroke(
          Path()
            ..moveTo(0, -th * 0.75)
            ..quadraticBezierTo(-0.1, -th * 0.95, -0.17, -th - 0.06),
          look.trunk,
          0.035,
        );
        p.stroke(
          Path()
            ..moveTo(0, -th * 0.82)
            ..quadraticBezierTo(0.09, -th * 0.98, 0.15, -th - 0.08),
          look.trunk,
          0.03,
        );
    }
    final scale = (cw + ch) / 1.35;
    final puffs = [for (final (dx, dy, r) in _crowns[look.shape]!) (dx * cw, cy + dy * ch, r * scale)];
    _puffs(p, puffs, look.leaf, snow: look.snow);
    final longLeaves = look.shape == TreeShape.dense;
    for (var i = 0; i < puffs.length; i += 2) {
      final (x, y, r) = puffs[i];
      final a = math.atan2(y - cy, x) + 0.25;
      p.leaf(
        x + r * 0.8 * math.cos(a),
        y + r * 0.8 * math.sin(a),
        longLeaves ? 0.12 : 0.075,
        longLeaves ? 0.022 : 0.028,
        a,
        _dark,
      );
    }
    // Fruit and blossoms sit on the front of the crown's puffs.
    final spots = [
      for (var i = 0; i < puffs.length; i += 2) (puffs[i].$1 + puffs[i].$3 * 0.15, puffs[i].$2 + puffs[i].$3 * 0.3),
    ];
    if (fruit) {
      _fruit(p, spots.take(5).toList(), size: 0.11);
    } else if (flowers && look.bloom != null) {
      _blossoms(p, [
        ...spots,
        for (var i = 1; i < puffs.length; i += 2) (puffs[i].$1 - puffs[i].$3 * 0.2, puffs[i].$2 - puffs[i].$3 * 0.1),
      ], look.bloom!);
    }
  }

  void _palmTrunk(Pen p, double topX, double topY) {
    final c = look.trunk;
    final trunk = Path()
      ..moveTo(-0.07, 0)
      ..quadraticBezierTo(-0.04, topY * 0.55, topX - 0.03, topY)
      ..lineTo(topX + 0.03, topY)
      ..quadraticBezierTo(0.06, topY * 0.55, 0.07, 0)
      ..close();
    p.fill(trunk, c);
    for (var i = 1; i < 9; i++) {
      final t = i / 9;
      final x = topX * t * t;
      final y = topY * t;
      final half = 0.065 - 0.035 * t;
      p.stroke(
        Path()
          ..moveTo(x - half, y + 0.012)
          ..quadraticBezierTo(x, y - 0.012, x + half, y + 0.012),
        shade(c, 0.2),
        0.012,
      );
    }
  }

  void _palm(Pen p, {required bool fruit}) {
    const topX = 0.08;
    const topY = -0.66;
    _palmTrunk(p, topX, topY);
    void frond(double angle, double len, Color c) {
      p.canvas.save();
      p.canvas.translate(topX, topY);
      p.canvas.rotate(angle);
      final spine = Path()
        ..moveTo(0, 0)
        ..quadraticBezierTo(len * 0.5, -len * 0.22, len, len * 0.16);
      for (var i = 1; i <= 9; i++) {
        final t = i / 10;
        final x = len * t;
        final y = -len * 0.22 * 4 * t * (1 - t) * 0.5 + len * 0.16 * t * t;
        final l = 0.11 * (1 - t * 0.5);
        p.leaf(x, y, l, 0.022, 1.25, c);
        p.leaf(x, y, l, 0.022, -0.15, shade(c, 0.06));
      }
      p.stroke(spine, shade(c, 0.25), 0.014);
      p.canvas.restore();
    }

    for (final a in [-2.6, -0.5, -1.6]) {
      frond(a, 0.36, _dark);
    }
    for (final a in [-3.0, -2.2, -1.2, -0.15]) {
      frond(a, 0.4, look.leaf);
    }
    frond(-1.9, 0.3, _light);
    if (fruit) {
      _fruit(p, [(topX - 0.06, topY + 0.07), (topX + 0.05, topY + 0.08), (topX, topY + 0.13)], size: 0.1);
    }
  }

  void _banana(Pen p, {required bool fruit}) {
    final stem = look.trunk;
    p.rrect(-0.05, -0.5, 0.05, 0, 0.04, stem);
    p.rrect(0.01, -0.5, 0.05, 0, 0.02, shade(stem, 0.12));
    void paddle(double angle, double len, Color c) {
      p.canvas.save();
      p.canvas.translate(0, -0.5);
      p.canvas.rotate(angle);
      final blade = Path()
        ..moveTo(0, 0)
        ..cubicTo(len * 0.2, -0.13, len * 0.8, -0.12, len, 0.02)
        ..cubicTo(len * 0.75, 0.08, len * 0.25, 0.08, 0, 0)
        ..close();
      p.fill(blade, c);
      p.stroke(
        Path()
          ..moveTo(0, 0)
          ..quadraticBezierTo(len * 0.5, -0.03, len, 0.02),
        tint(c, 0.35),
        0.012,
      );
      for (var i = 1; i < 6; i++) {
        final x = len * i / 6;
        p.line(x, -0.015, x + 0.03, -0.07, shade(c, 0.08), 0.008);
      }
      p.canvas.restore();
    }

    paddle(-2.7, 0.42, _dark);
    paddle(-0.45, 0.42, _dark);
    paddle(-2.1, 0.46, look.leaf);
    paddle(-1.05, 0.46, look.leaf);
    paddle(-1.6, 0.4, _light);
    if (fruit) {
      p.line(0.06, -0.46, 0.14, -0.36, shade(look.leaf, 0.3), 0.02);
      _fruit(p, [(0.15, -0.3), (0.2, -0.22)], size: 0.14);
      p.oval(0.22, -0.13, 0.05, 0.08, const Color(0xFFB04F7A));
    }
  }

  void _bigLeaf(Pen p, double x, double y, double len, double angle, Color c) {
    p.leaf(x, y, len, len * 0.36, angle, c);
    p.leaf(x, y, len * 0.85, len * 0.12, angle - 0.06, tint(c, 0.22));
  }

  void _sunflower(Pen p, {required bool flowers, required bool fruit}) {
    final stem = shade(look.leaf, 0.12);
    const head = (0.04, -0.74);
    p.stroke(
      Path()
        ..moveTo(0, 0)
        ..quadraticBezierTo(-0.03, -0.4, head.$1, head.$2),
      stem,
      0.05,
    );
    _bigLeaf(p, -0.01, -0.22, 0.26, -2.7, _dark);
    _bigLeaf(p, 0.0, -0.36, 0.28, -0.35, look.leaf);
    _bigLeaf(p, -0.02, -0.5, 0.22, -2.4, look.leaf);
    if (!flowers) {
      // A closed green bud.
      p.circle(head.$1, head.$2, 0.08, look.leaf);
      for (var i = 0; i < 6; i++) {
        p.leaf(head.$1, head.$2, 0.11, 0.035, -math.pi / 2 + (i - 2.5) * 0.45, _dark);
      }
      return;
    }
    p.canvas.save();
    p.canvas.translate(head.$1, head.$2);
    for (var i = 0; i < 16; i++) {
      final a = i * math.pi / 8 + 0.2;
      p.oval(0.2 * math.cos(a), 0.2 * math.sin(a), 0.16, 0.075, shade(look.accent, 0.12), rot: a);
    }
    for (var i = 0; i < 16; i++) {
      final a = i * math.pi / 8;
      p.oval(0.17 * math.cos(a), 0.17 * math.sin(a), 0.15, 0.07, look.accent, rot: a);
    }
    const disk = Color(0xFF8A5A33);
    p.circle(0, 0, 0.13, disk);
    p.circle(0, 0, 0.095, shade(disk, 0.12));
    final seeds = fruit ? 26 : 14;
    for (var i = 0; i < seeds; i++) {
      final a = i * 2.39996;
      final r = 0.11 * math.sqrt((i + 0.5) / seeds);
      p.circle(
        r * math.cos(a),
        r * math.sin(a),
        fruit ? 0.012 : 0.009,
        fruit ? const Color(0xFFF2E2C4) : tint(disk, 0.3),
      );
    }
    p.shine(-0.05, -0.06, 0.05, 0.025);
    p.canvas.restore();
  }

  void _edelweiss(Pen p, {required bool flowers, required bool fruit}) {
    final stem = shade(look.leaf, 0.18);
    for (final (x, y) in const [(-0.18, -0.36), (0.16, -0.46), (0.0, -0.56)]) {
      p.stroke(
        Path()
          ..moveTo(x * 0.3, 0)
          ..quadraticBezierTo(x * 0.6, y * 0.5, x, y),
        stem,
        0.03,
      );
    }
    for (final (x, a) in const [(-0.04, -2.5), (0.04, -0.6), (-0.06, -2.0), (0.06, -1.1)]) {
      _bigLeaf(p, x, -0.02, 0.2, a, look.leaf);
    }
    for (final (x, y, s) in const [(-0.18, -0.36, 0.85), (0.16, -0.46, 0.9), (0.0, -0.56, 1.0)]) {
      if (!flowers) {
        p.circle(x, y, 0.04 * s, look.leaf);
        continue;
      }
      for (var i = 0; i < 9; i++) {
        final a = i * 2 * math.pi / 9;
        p.leaf(x, y, 0.12 * s, 0.035 * s, a, shade(look.accent, 0.06));
      }
      for (var i = 0; i < 9; i++) {
        final a = i * 2 * math.pi / 9 + 0.35;
        p.leaf(x, y, 0.09 * s, 0.03 * s, a, look.accent);
      }
      for (var i = 0; i < 5; i++) {
        final a = i * 2 * math.pi / 5;
        p.circle(x + 0.018 * s * math.cos(a), y + 0.018 * s * math.sin(a), 0.016 * s, const Color(0xFFFFD45C));
      }
    }
    if (fruit) _fruit(p, [(-0.3, -0.12), (0.3, -0.16)], size: 0.15);
  }

  void _bush(Pen p, {required bool flowers, required bool fruit}) {
    final bw = look.width;
    final bh = look.height;
    for (final x in [-0.12, 0.0, 0.12]) {
      p.line(x * 0.6, 0, x, -0.12, const Color(0xFF8E6448), 0.03);
    }
    final puffs = [
      for (final (dx, dy, r) in const [
        (-0.4, -0.18, 0.16),
        (0.4, -0.18, 0.16),
        (-0.22, -0.16, 0.2),
        (0.22, -0.16, 0.2),
        (0.0, -0.18, 0.22),
        (-0.3, -0.42, 0.2),
        (0.3, -0.42, 0.2),
        (0.0, -0.5, 0.24),
        (-0.14, -0.7, 0.18),
        (0.16, -0.68, 0.18),
      ])
        (dx * bw, dy * bh, r * (bw + bh) / 1.5),
    ];
    _puffs(p, puffs, look.leaf);
    _edgeLeaves(p, 0, -bh * 0.42, bw * 0.5, bh * 0.5, _dark, count: 9);
    for (final (x, y, a) in [(-0.2, -0.3, -0.6), (0.18, -0.52, -2.4), (0.05, -0.24, -1.2), (-0.1, -0.56, -0.4)]) {
      p.leaf(x * bw, y * bh, 0.08, 0.03, a, _light);
    }
    final spots = [
      for (final (x, y) in const [
        (-0.3, -0.26),
        (0.12, -0.2),
        (0.32, -0.38),
        (-0.12, -0.46),
        (0.16, -0.62),
        (-0.34, -0.5),
        (0.0, -0.74),
      ])
        (x * bw, y * bh),
    ];
    if (fruit) {
      _fruit(p, spots, size: 0.12);
    } else if (flowers && look.bloom != null) {
      _blossoms(p, spots, look.bloom!, r: 0.02);
    }
  }

  void _hedge(Pen p, {required bool flowers, required bool fruit}) {
    final stalk = shade(look.leaf, 0.22);
    final spikeTops = [
      for (var i = 0; i < 11; i++) (-0.4 + i * 0.08, -0.34 - 0.12 * math.sin(i * 1.7).abs() - 0.18 * math.sin(i * 0.3)),
    ];
    for (final (x, top) in spikeTops) {
      p.line(x * 0.8, -0.18, x, top + 0.03, stalk, 0.014);
    }
    if (flowers) {
      for (final (x, top) in spikeTops) {
        for (var j = 0; j < 8; j++) {
          final y = top + j * 0.026;
          final s = 1 - j / 14;
          p.oval(x - 0.012, y, 0.026 * s, 0.034 * s, shade(look.accent, 0.12), rot: -0.5);
          p.oval(x + 0.012, y + 0.01, 0.026 * s, 0.034 * s, look.accent, rot: 0.5);
        }
        p.circle(x, top - 0.004, 0.012, tint(look.accent, 0.3));
      }
    }
    _puffs(p, const [
      (-0.36, -0.12, 0.13),
      (0.36, -0.12, 0.13),
      (-0.18, -0.14, 0.15),
      (0.18, -0.14, 0.15),
      (0.0, -0.16, 0.16),
      (-0.26, -0.24, 0.12),
      (0.26, -0.24, 0.12),
      (-0.06, -0.27, 0.12),
      (0.1, -0.27, 0.12),
    ], look.leaf);
    if (fruit) _fruit(p, [(-0.26, -0.08), (0.26, -0.08)], size: 0.14);
  }

  void _mushroom(Pen p, double x, double s) {
    const stem = Color(0xFFF6EAD6);
    p.rrect(x - 0.045 * s, -0.24 * s, x + 0.045 * s, 0, 0.04 * s, stem);
    p.rrect(x + 0.01 * s, -0.24 * s, x + 0.045 * s, 0, 0.02 * s, shade(stem, 0.08));
    final capTop = -0.4 * s;
    final cap = Path()
      ..moveTo(x - 0.17 * s, -0.22 * s)
      ..quadraticBezierTo(x - 0.16 * s, capTop, x, capTop)
      ..quadraticBezierTo(x + 0.16 * s, capTop, x + 0.17 * s, -0.22 * s)
      ..quadraticBezierTo(x, -0.18 * s, x - 0.17 * s, -0.22 * s)
      ..close();
    p.oval(x, -0.21 * s, 0.32 * s, 0.05 * s, shade(stem, 0.14));
    p.fill(cap, look.accent);
    p.canvas.save();
    p.canvas.clipPath(cap);
    p.oval(x + 0.08 * s, -0.24 * s, 0.3 * s, 0.14 * s, shade(look.accent, 0.12));
    p.canvas.restore();
    for (final (dx, dy, r) in const [
      (-0.08, -0.3, 0.026),
      (0.03, -0.35, 0.022),
      (0.09, -0.27, 0.018),
      (-0.02, -0.26, 0.015),
    ]) {
      p.circle(x + dx * s, dy * s, r * s, const Color(0xFFFFFFFF));
    }
    p.shine(x - 0.08 * s, -0.34 * s, 0.05 * s, 0.025 * s, rot: -0.5);
  }

  void _grove(Pen p, {required bool fruit}) {
    _puffs(p, const [(-0.32, -0.04, 0.1), (0.3, -0.04, 0.1), (-0.12, -0.05, 0.12), (0.12, -0.05, 0.12)], look.leaf);
    _mushroom(p, -0.22, 0.78);
    _mushroom(p, 0.24, 0.9);
    _mushroom(p, 0.0, 1.2);
    if (fruit) {
      _mushroom(p, -0.38, 0.42);
      _mushroom(p, 0.4, 0.38);
    }
    for (final x in [-0.42, -0.08, 0.36]) {
      p.leaf(x, 0, 0.08, 0.02, -1.9, const Color(0xFF7DBF7E));
      p.leaf(x, 0, 0.07, 0.02, -1.2, const Color(0xFF8CC98A));
    }
  }

  void _column(Pen p, double l, double t, double r, double b) {
    final width = r - l;
    p.rrect(l, t, r, b, width / 2, look.leaf);
    p.rrect(l + width * 0.55, t + width * 0.2, r, b, width / 2, _dark);
    p.rrect(l + width * 0.18, t + width * 0.3, l + width * 0.34, b - width * 0.2, width * 0.1, _light);
    for (var y = t + width * 0.5; y < b - 0.02; y += 0.07) {
      p.circle(l + width * 0.5, y, 0.007, const Color(0xFFF7F2E0));
    }
  }

  void _cactus(Pen p, {required bool flowers, required bool fruit}) {
    _column(p, -0.24, -0.62, -0.13, -0.34);
    p.rrect(-0.24, -0.42, -0.02, -0.33, 0.045, look.leaf);
    _column(p, 0.13, -0.72, 0.24, -0.46);
    p.rrect(0.02, -0.54, 0.24, -0.45, 0.045, _dark);
    _column(p, -0.1, -0.96, 0.1, 0);
    if (flowers) {
      final top = fruit ? [(0.0, -0.98), (-0.185, -0.64), (0.185, -0.74)] : [(0.0, -0.97), (-0.185, -0.63)];
      if (fruit) {
        _fruit(p, top, size: 0.13);
      } else {
        _blossoms(p, top, look.accent, r: 0.035);
      }
    }
  }

  void _pad(Pen p, double x, double y, double w, double h, double rot) {
    p.oval(x, y, w, h, look.leaf, rot: rot);
    p.oval(x + w * 0.12, y + h * 0.1, w * 0.7, h * 0.7, _dark, rot: rot);
    p.oval(x - w * 0.12, y - h * 0.12, w * 0.5, h * 0.55, _light, rot: rot);
    for (var i = 0; i < 6; i++) {
      final a = i * 1.1;
      p.circle(x + w * 0.3 * math.cos(a), y + h * 0.32 * math.sin(a), 0.007, const Color(0xFFF7F2E0));
    }
  }

  void _pads(Pen p, {required bool flowers, required bool fruit}) {
    _pad(p, 0.0, -0.16, 0.3, 0.34, 0.0);
    _pad(p, -0.18, -0.4, 0.24, 0.28, -0.5);
    _pad(p, 0.17, -0.42, 0.24, 0.28, 0.45);
    _pad(p, 0.0, -0.58, 0.2, 0.24, 0.05);
    final rim = [(-0.27, -0.55), (0.27, -0.56), (0.02, -0.71), (-0.08, -0.42)];
    if (fruit) {
      _fruit(p, rim.take(3).toList(), size: 0.11);
    } else if (flowers) {
      _blossoms(p, rim.take(3).toList(), look.accent, r: 0.028);
    }
  }

  void _bamboo(Pen p, {required bool fruit}) {
    final culm = look.accent;
    for (final (x, top, wide) in const [
      (-0.22, -0.74, 0.05),
      (0.2, -0.82, 0.05),
      (-0.06, -0.98, 0.06),
      (0.08, -0.66, 0.045),
      (-0.34, -0.56, 0.04),
    ]) {
      p.rrect(x - wide / 2, top, x + wide / 2, 0, wide / 2, culm);
      p.rrect(x + wide * 0.1, top, x + wide / 2, 0, wide / 3, shade(culm, 0.12));
      for (var y = -0.12; y > top + 0.04; y -= 0.15) {
        p.rrect(x - wide * 0.62, y, x + wide * 0.62, y + 0.016, 0.008, shade(culm, 0.28));
      }
      for (final (a, l) in [(-2.4, 0.16), (-0.6, 0.17), (-1.9, 0.13), (-1.1, 0.13)]) {
        p.leaf(x, top + 0.02, l, 0.03, a, a < -1.5 ? look.leaf : _dark);
      }
      p.leaf(x, top + 0.2, 0.13, 0.025, -0.3, look.leaf);
    }
    if (fruit) _fruit(p, [(-0.14, -0.06), (0.3, -0.06)], size: 0.13);
  }

  void _fern(Pen p, {required bool fruit}) {
    void frond(double angle, double len, Color c) {
      p.canvas.save();
      p.canvas.rotate(angle);
      for (var j = 1; j <= 11; j++) {
        final t = j / 12;
        final y = -len * t;
        final x = len * 0.18 * t * t;
        final l = 0.09 * (1 - t * 0.75);
        p.leaf(x, y, l, 0.022, -0.35, c);
        p.leaf(x, y, l, 0.022, math.pi + 0.35, c);
      }
      p.stroke(
        Path()
          ..moveTo(0, 0)
          ..quadraticBezierTo(len * 0.06, -len * 0.5, len * 0.18, -len),
        shade(c, 0.25),
        0.012,
      );
      p.canvas.restore();
    }

    for (final a in [-1.0, 1.0, -0.55, 0.6]) {
      frond(a, 0.5, _dark);
    }
    for (final a in [-0.75, 0.8, -0.25, 0.3]) {
      frond(a, 0.6, look.leaf);
    }
    frond(0.02, 0.66, _light);
    if (fruit) _fruit(p, [(-0.12, -0.08), (0.14, -0.1), (0.0, -0.14)], size: 0.12);
  }

  void _lilyPad(Pen p, double x, double y, double r, Color c) {
    final pad = Path.combine(
      PathOperation.difference,
      Path()..addOval(Rect.fromCenter(center: Offset(x, y), width: r * 2, height: r * 0.8)),
      Path()
        ..moveTo(x, y)
        ..lineTo(x + r * 1.2, y - r * 0.25)
        ..lineTo(x + r * 1.2, y + r * 0.05)
        ..close(),
    );
    p.fill(pad, c);
    p.oval(x - r * 0.25, y - r * 0.08, r * 0.9, r * 0.3, tint(c, 0.2));
  }

  void _lotus(Pen p, {required bool flowers, required bool fruit}) {
    const water = Color(0xFF9FD3E8);
    p.oval(0, -0.03, 0.96, 0.18, water);
    p.oval(-0.12, -0.05, 0.5, 0.06, tint(water, 0.35));
    _lilyPad(p, -0.27, -0.04, 0.17, _dark);
    _lilyPad(p, 0.28, -0.05, 0.15, look.leaf);
    _lilyPad(p, 0.06, -0.02, 0.12, _light);
    p.stroke(
      Path()
        ..moveTo(-0.02, -0.05)
        ..quadraticBezierTo(-0.04, -0.2, 0.0, -0.3),
      shade(look.leaf, 0.2),
      0.025,
    );
    const c = (0.0, -0.36);
    if (!flowers) {
      p.oval(c.$1, c.$2, 0.1, 0.16, look.accent);
      p.oval(c.$1 + 0.02, c.$2, 0.05, 0.13, shade(look.accent, 0.1));
      return;
    }
    for (var i = 0; i < 7; i++) {
      final a = -math.pi / 2 + (i - 3) * 0.42;
      p.leaf(c.$1, c.$2 + 0.06, 0.2, 0.06, a, shade(look.accent, 0.12));
    }
    for (var i = 0; i < 5; i++) {
      final a = -math.pi / 2 + (i - 2) * 0.4;
      p.leaf(c.$1, c.$2 + 0.06, 0.17, 0.055, a, look.accent);
    }
    for (var i = 0; i < 3; i++) {
      final a = -math.pi / 2 + (i - 1) * 0.35;
      p.leaf(c.$1, c.$2 + 0.06, 0.12, 0.04, a, tint(look.accent, 0.35));
    }
    p.circle(c.$1, c.$2 + 0.0, 0.03, const Color(0xFFFFD45C));
    if (fruit) _fruit(p, [(-0.3, -0.24), (0.3, -0.26)], size: 0.13);
  }

  void _willow(Pen p, {required bool fruit}) {
    const th = 0.34;
    _trunk(p, th + 0.06, 0.08, look.trunk);
    const cy = -th - 0.2;
    _puffs(p, [
      (-0.24, cy + 0.04, 0.2),
      (0.24, cy + 0.04, 0.2),
      (0.0, cy - 0.04, 0.26),
      (0.0, cy + 0.08, 0.2),
    ], look.leaf);
    for (var i = 0; i < 13; i++) {
      final x = -0.42 + i * 0.07;
      final len = 0.36 + 0.1 * math.sin(i * 1.3).abs();
      final c = i.isEven ? _dark : _light;
      final strand = Path()
        ..moveTo(x * 0.9, cy + 0.04)
        ..quadraticBezierTo(x * 1.08, cy + len * 0.5, x * 1.12, cy + len);
      p.stroke(strand, c, 0.022);
      for (var j = 1; j < 5; j++) {
        final t = j / 5;
        p.leaf(x * (0.9 + 0.22 * t), cy + len * t, 0.04, 0.014, math.pi / 2 + (j.isEven ? 0.5 : -0.5), c);
      }
    }
    if (fruit) _fruit(p, [(-0.2, cy + 0.12), (0.18, cy + 0.08), (0.0, cy + 0.2)], size: 0.12);
  }

  void _conifer(Pen p, {required bool fruit}) {
    _trunk(p, 0.2, 0.05, look.trunk);
    for (var i = 0; i < 5; i++) {
      final top = -0.96 + i * 0.16;
      final half = 0.1 + i * 0.075;
      final bottom = top + 0.26;
      final tier = Path()..moveTo(0, top);
      tier.quadraticBezierTo(half * 0.6, top + 0.1, half, bottom);
      const scallops = 4;
      for (var k = 0; k < scallops; k++) {
        final x1 = half - (k + 1) * 2 * half / scallops;
        tier.quadraticBezierTo(x1 + half / scallops, bottom + 0.045, x1, bottom);
      }
      tier.quadraticBezierTo(-half * 0.6, top + 0.1, 0, top);
      tier.close();
      p.fill(tier, i.isEven ? look.leaf : shade(look.leaf, 0.08));
      p.canvas.save();
      p.canvas.clipPath(tier);
      p.oval(-half * 0.55, bottom - 0.06, half * 0.7, 0.12, tint(look.leaf, 0.2));
      p.oval(half * 0.6, bottom, half * 0.9, 0.16, shade(look.leaf, 0.18));
      p.canvas.restore();
      if (look.snow) p.oval(-half * 0.2, top + 0.06, half * 0.8, 0.035, const Color(0xF2FFFFFF));
    }
    if (fruit) _fruit(p, [(-0.2, -0.34), (0.22, -0.2), (0.08, -0.56), (-0.1, -0.64)], size: 0.1);
  }

  void _aloe(Pen p, {required bool flowers, required bool fruit}) {
    if (flowers) {
      final stalk = shade(look.leaf, 0.25);
      p.stroke(
        Path()
          ..moveTo(0.04, -0.2)
          ..quadraticBezierTo(0.1, -0.5, 0.12, -0.76),
        stalk,
        0.018,
      );
      for (var j = 0; j < 9; j++) {
        final y = -0.78 + j * 0.035;
        p.oval(0.12 - 0.016, y, 0.022, 0.05, look.accent, rot: 0.5);
        p.oval(0.12 + 0.016, y + 0.01, 0.022, 0.05, shade(look.accent, 0.1), rot: -0.5);
      }
    }
    void blade(double angle, double len, Color c) {
      p.canvas.save();
      p.canvas.rotate(angle);
      final b = Path()
        ..moveTo(-0.05, 0)
        ..quadraticBezierTo(-0.045, -len * 0.6, 0, -len)
        ..quadraticBezierTo(0.045, -len * 0.6, 0.05, 0)
        ..close();
      p.fill(b, c);
      p.oval(-0.015, -len * 0.4, 0.025, len * 0.5, tint(c, 0.2));
      for (var j = 1; j < 4; j++) {
        p.circle(0.012, -len * j / 4.5, 0.006, const Color(0xE6FFFFFF));
      }
      p.canvas.restore();
    }

    for (final a in [-1.2, 1.2, -0.85, 0.9]) {
      blade(a, 0.36, _dark);
    }
    for (final a in [-0.55, 0.6, -0.25]) {
      blade(a, 0.44, look.leaf);
    }
    blade(0.22, 0.42, _light);
    blade(0.0, 0.48, look.leaf);
    if (fruit) _fruit(p, [(-0.3, -0.06), (0.3, -0.06)], size: 0.12);
  }

  void _bog(Pen p, {required bool flowers, required bool fruit}) {
    const water = Color(0xFF8FC9D8);
    p.oval(0, -0.04, 0.96, 0.2, water);
    p.oval(-0.18, -0.06, 0.4, 0.05, tint(water, 0.35));
    final mats = <(double, double, double)>[
      for (var i = 0; i < 9; i++) (-0.4 + i * 0.1, -0.1 - 0.05 * math.sin(i * 1.4).abs(), 0.075),
      for (var i = 0; i < 6; i++) (-0.26 + i * 0.1, -0.2 - 0.04 * math.sin(i * 2.1).abs(), 0.07),
    ];
    _puffs(p, mats, look.leaf);
    for (final (x, y, _) in mats) {
      p.leaf(x, y, 0.05, 0.016, -1.2 + x, _dark);
    }
    final spots = [(-0.3, -0.16), (-0.1, -0.24), (0.1, -0.18), (0.28, -0.14), (0.02, -0.3), (-0.2, -0.28)];
    if (fruit) {
      _fruit(p, spots, size: 0.11);
    } else if (flowers && look.bloom != null) {
      _blossoms(p, spots, look.bloom!, r: 0.018);
    }
  }

  @override
  bool shouldRepaint(PlantPainter old) =>
      old.stage != stage || old.sway != sway || old.look != look || old.fruitIcon != fruitIcon;
}

/// A soft oval that fades out at its edge, [width] by [height], centred on
/// ([cx], [cy]). Nothing hard-edged, so it melts into whatever is under it.
void _softOval(Canvas canvas, double cx, double cy, double width, double height, Color colour, {double solid = 0.55}) {
  canvas.save();
  canvas.translate(cx, cy);
  canvas.scale(1, height / width);
  final r = width / 2;
  canvas.drawCircle(
    Offset.zero,
    r,
    Paint()
      ..shader = RadialGradient(
        colors: [colour, colour, colour.withValues(alpha: 0)],
        stops: [0, solid, 1],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: r)),
  );
  canvas.restore();
}

/// Dug soil that blends into the grass: a soft shadow, a soil bed with a
/// feathered edge, crumbs spilling onto the grass and blades at its sides.
/// [width] is in the pen's units, centred on x = 0. The bed sits just above
/// y = 0, so nothing is cut off at the bottom of the picture.
void _softSoil(Pen p, double width, {int seed = 3}) {
  final h = width * 0.27;
  final cy = -h * 0.42;
  _softOval(p.canvas, 0, cy + h * 0.06, width * 1.2, h * 0.8, const Color(0x2E3B2E3A), solid: 0.3);
  _softOval(p.canvas, 0, cy, width * 1.06, h * 0.8, shade(_soil, 0.08), solid: 0.6);
  _softOval(p.canvas, 0, cy - h * 0.04, width * 0.86, h * 0.62, _soil, solid: 0.7);
  _softOval(p.canvas, -width * 0.14, cy - h * 0.14, width * 0.4, h * 0.2, tint(_soil, 0.22));
  final rnd = math.Random(seed);
  // Crumbs and small pebbles, inside the bed and just past its sides.
  for (var i = 0; i < 12; i++) {
    final a = rnd.nextDouble() * 2 * math.pi;
    final d = i < 8 ? rnd.nextDouble() * 0.75 : 0.95 + rnd.nextDouble() * 0.2;
    final c = i.isEven ? shade(_soil, 0.25) : tint(_soil, 0.35);
    p.circle(
      math.cos(a) * d * width * 0.5,
      cy + math.sin(a) * d * h * 0.3,
      width * (0.01 + rnd.nextDouble() * 0.008),
      c,
    );
  }
  // Grass blades over the bed's edge at each side.
  const blade = Color(0xFF8CC98A);
  const bladeDark = Color(0xFF7DBF7E);
  for (final fx in [-0.5, -0.4, 0.42, 0.5]) {
    final x = fx * width;
    final s = width * (0.09 + rnd.nextDouble() * 0.04);
    final lean = fx.sign * 0.25;
    p.leaf(x, cy + h * 0.1, s, s * 0.24, -math.pi / 2 - 0.4 + lean, bladeDark);
    p.leaf(x, cy + h * 0.1, s * 1.2, s * 0.26, -math.pi / 2 + lean, blade);
    p.leaf(x, cy + h * 0.1, s, s * 0.24, -math.pi / 2 + 0.4 + lean, bladeDark);
  }
}

/// An empty patch of dug soil, where a new seed can go.
class _SpotPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(size.width / 2, size.height * 0.55);
    canvas.scale(size.width);
    _softSoil(Pen(canvas), 0.82);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_SpotPainter old) => false;
}
