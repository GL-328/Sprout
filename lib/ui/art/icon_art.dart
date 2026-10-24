import 'package:flutter/material.dart';

import 'icon_painters.dart';

/// One icon: which painter draws it and its colours. Change an entry in
/// [iconSpecs] to restyle one icon without touching any other.
class IconSpec {
  const IconSpec(this.paint, this.a, [this.b = const Color(0xFF7FC48B), this.c = const Color(0xFF7FC48B)]);

  final IconPaint paint;
  final Color a;
  final Color b;
  final Color c;
}

// Pastel palette shared by the icons.
const _gold = Color(0xFFF4C04E);
const _goldDeep = Color(0xFFD9982E);
const _leaf = Color(0xFF7FC48B);
const _leafDeep = Color(0xFF5FA86E);
const _stem = Color(0xFF8A5A3B);
const _brown = Color(0xFFC08A5B);
const _cream = Color(0xFFFFF4DE);
const _pink = Color(0xFFF59AAE);
const _sky = Color(0xFFCFE6F7);
const _sun = Color(0xFFFFC93C);
const _white = Color(0xFFFFFFFF);
const _ink = Color(0xFF4A3F55);

/// Every icon in the app, by id. Ids are plain words for app icons, or
/// `kind:configId` for things from the game config (fruit by species id,
/// visitors, decorations, plots, families, recipes and mystery packs).
final Map<String, IconSpec> iconSpecs = {
  // App icons.
  'coin': const IconSpec(paintCoin, _gold, _goldDeep),
  'bag': const IconSpec(paintBag, Color(0xFFF2A07B), Color(0xFFF8C7A8), Color(0xFFFFE08A)),
  'basket': const IconSpec(paintBasket, Color(0xFFDDAE72), Color(0xFFFFB05C), Color(0xFFE8574F)),
  'seed': const IconSpec(paintSeed, Color(0xFFC98D5E), _leaf),
  'sprout': const IconSpec(paintSprout, _leaf, Color(0xFF8BD18F), Color(0xFFD9B48C)),
  'check': const IconSpec(paintCheck, _leaf),
  'heart': const IconSpec(paintHeart, _pink),
  'moon': const IconSpec(paintMoon, Color(0xFFFFE08A), Color(0xFFC9C3F2)),
  'sun': const IconSpec(paintSun, _sun, Color(0xFFFFDC7A)),
  'sparkle': const IconSpec(paintSparkle, Color(0xFFFFD45C), Color(0xFFC9B7F0)),
  'star': const IconSpec(paintStar, Color(0xFFFFD45C)),
  'question': const IconSpec(paintQuestion, Color(0xFFE6DFF0), Color(0xFFA899C2)),
  'leaf': const IconSpec(paintLeaf, _leaf),
  'tree': const IconSpec(paintTree, _leaf, Color(0xFF9AD5A0), _brown),
  'map': const IconSpec(paintMap, Color(0xFFF6E7C1), Color(0xFFE8956B), Color(0xFFE8574F)),
  'compass': const IconSpec(paintCompass, Color(0xFF9CC9E8), Color(0xFFF2836B), Color(0xFF8A9BB8)),
  'bell': const IconSpec(paintBell, _sun, Color(0xFFE0A93A)),
  'pencil': const IconSpec(paintPencil, Color(0xFFFFC96B), _pink, Color(0xFFF6DDBA)),
  'tulip': const IconSpec(paintTulip, _pink, _leaf),
  'cloud_sun': const IconSpec(paintCloudSun, Color(0xFFF2F4FA), _sun),
  'compost': const IconSpec(paintCompost, Color(0xFFB98A62), _leaf),
  'plus': const IconSpec(paintPlus, _leaf),

  // Seasons.
  'season:spring': const IconSpec(paintBlossom, Color(0xFFF9C3D3), Color(0xFFFFE08A)),
  'season:summer': const IconSpec(paintSun, _sun, Color(0xFFFFDC7A)),
  'season:autumn': const IconSpec(paintMaple, Color(0xFFF29A57)),
  'season:winter': const IconSpec(paintSnowflake, Color(0xFF9CC9E8), _white),

  // Fruit, by species id.
  'fruit:apple_tree': const IconSpec(paintApple, Color(0xFFE8625A), _stem, _leaf),
  'fruit:giant_sunflower': const IconSpec(paintFlowerHead, _sun, Color(0xFFA0683F)),
  'fruit:berry_bush': const IconSpec(paintRaspberry, Color(0xFFEF6A8A), _stem, _leaf),
  'fruit:lavender_hedge': const IconSpec(paintLavender, Color(0xFFAE93E0), _leafDeep, Color(0xFFF2C9A0)),
  'fruit:oak': const IconSpec(paintAcorn, Color(0xFFD9A066), Color(0xFF9C6B4E)),
  'fruit:mushroom_grove': const IconSpec(paintMushroom, Color(0xFFEC7A6C), _cream, _white),
  'fruit:hazelnut': const IconSpec(paintHazelnut, Color(0xFFC98D5E), _stem, Color(0xFF9CC48A)),
  'fruit:fern_canopy': const IconSpec(paintFiddlehead, Color(0xFF6DB57E), Color(0xFF9AD5A0)),
  'fruit:cherry': const IconSpec(paintCherries, Color(0xFFE5485E), Color(0xFF7DA35A), _leaf),
  'fruit:peach': const IconSpec(paintPeach, Color(0xFFFFAE8A), _stem, _leaf),
  'fruit:plum': const IconSpec(paintOvalFruit, Color(0xFF9B72C4), _stem, _leaf),
  'fruit:pear': const IconSpec(paintPear, Color(0xFFCFDC6A), _stem, _leaf),
  'fruit:lotus': const IconSpec(paintLotusPod, Color(0xFF9CCF96), Color(0xFF5F8F5A)),
  'fruit:cranberry_bog': const IconSpec(paintBerries, Color(0xFFD8455C), Color(0xFFB3354A), _leaf),
  'fruit:bamboo': const IconSpec(paintBambooShoot, Color(0xFFE7E2A6), Color(0xFF9CCB7A)),
  'fruit:willow': const IconSpec(paintCatkins, Color(0xFFF2EBB8), Color(0xFFA67C5B), _leaf),
  'fruit:date_palm': const IconSpec(paintDates, Color(0xFFB27548), Color(0xFF8A6A3B)),
  'fruit:prickly_pear': const IconSpec(paintCactusFruit, Color(0xFFE86B95), Color(0xFFFFE6EF)),
  'fruit:giant_cactus': const IconSpec(paintBlossom, Color(0xFFFFE6EF), Color(0xFFFFD45C)),
  'fruit:aloe': const IconSpec(paintAloe, Color(0xFF8CCB9F), _white, Color(0xFFE8A27A)),
  'fruit:banana': const IconSpec(paintBananas, Color(0xFFFFDA5A), Color(0xFF8A6A3B)),
  'fruit:mango': const IconSpec(paintOvalFruit, Color(0xFFFFAE45), _stem, _leaf),
  'fruit:coconut_palm': const IconSpec(paintCoconut, Color(0xFF9C6B45), Color(0xFFF7EEDC)),
  'fruit:cacao': const IconSpec(paintCacao, Color(0xFFD58A4E), _stem),
  'fruit:pine': const IconSpec(paintPineCone, Color(0xFFC48A5C), _leaf, _leafDeep),
  'fruit:blueberry': const IconSpec(paintBerries, Color(0xFF6F8EE0), Color(0xFF4F69B8), _leaf),
  'fruit:edelweiss': const IconSpec(paintEdelweiss, Color(0xFFF4F4EE), Color(0xFFFFD45C)),
  'fruit:snow_pear': const IconSpec(paintPear, Color(0xFFDDEBF3), Color(0xFF8A7A6E), Color(0xFFA8D4DA)),

  // Visitors.
  'visitor:butterfly': const IconSpec(paintButterfly, Color(0xFFF7A8C4), Color(0xFFC9B7F0), _ink),
  'visitor:bee': const IconSpec(paintBee, Color(0xFFFFD45C), Color(0xFF5B4B55), Color(0xFFCFE6F7)),
  'visitor:songbird': const IconSpec(paintBird, Color(0xFF8CC2EA), Color(0xFFEAF4FB), Color(0xFFFFB45C)),
  'visitor:ladybird': const IconSpec(paintLadybird, Color(0xFFEE5A5A), Color(0xFF4A3F55)),
  'visitor:hedgehog': const IconSpec(paintHedgehog, Color(0xFFB08562), Color(0xFFF1DCC3), _pink),
  'visitor:firefly': const IconSpec(paintFirefly, Color(0xFFFFE070), Color(0xFF6E6A86), Color(0xFFCFE6F7)),
  'visitor:squirrel': const IconSpec(paintSquirrel, Color(0xFFE09A5E), Color(0xFFF6DDBA), Color(0xFF5B4B55)),
  'visitor:fox': const IconSpec(paintFox, Color(0xFFF2925A), Color(0xFFFFF4E8), Color(0xFFFFD0B5)),
  'visitor:rabbit': const IconSpec(paintRabbit, Color(0xFFE9E2DA), _white, Color(0xFFF7B6C4)),
  'visitor:frog': const IconSpec(paintFrog, Color(0xFF86C97A), Color(0xFFD5EEC4), Color(0xFFF7B6C4)),
  'visitor:duck': const IconSpec(paintDuck, Color(0xFFFFE07A), _white, Color(0xFFF59A4A)),
  'visitor:lizard': const IconSpec(paintLizard, Color(0xFF8ACB7E), Color(0xFFFFE07A), Color(0xFFF59AAE)),
  'visitor:owl': const IconSpec(paintOwl, Color(0xFFB8916B), Color(0xFFF1DCC3), Color(0xFFF2B33D)),
  'visitor:parrot': const IconSpec(paintParrot, Color(0xFF6CC28A), Color(0xFFEE6A5A), Color(0xFFFFD45C)),
  'visitor:sloth': const IconSpec(paintSloth, Color(0xFFB59A7E), Color(0xFFEBDCC8), Color(0xFF6E5A4E)),
  'visitor:goat': const IconSpec(paintGoat, Color(0xFFF4EFE8), Color(0xFFDCD2C6), Color(0xFFB59A7E)),

  // Decorations.
  'cosmetic:stone_path': const IconSpec(paintStones, Color(0xFFC9C3BB), _leaf),
  'cosmetic:flower_path': const IconSpec(paintPetalPath, Color(0xFFF9C3D3), Color(0xFFFFE08A)),
  'cosmetic:picket_fence': const IconSpec(paintFence, Color(0xFFF6EEE2), _leaf),
  'cosmetic:hedge_fence': const IconSpec(paintHedge, Color(0xFF7DBE7F), Color(0xFFF7B6C4)),
  'cosmetic:lily_pond': const IconSpec(paintPond, Color(0xFF8CC9E8), Color(0xFF6FBF8E), _pink),
  'cosmetic:wooden_bench': const IconSpec(paintBench, Color(0xFFD6A06C)),
  'cosmetic:paper_lantern': const IconSpec(paintLantern, Color(0xFFF2836B), Color(0xFFFFD45C), Color(0xFF8A5A3B)),
  'cosmetic:fairy_lights': const IconSpec(paintFairyLights, Color(0xFFFFE070), _pink, Color(0xFF8A7A6E)),
  'cosmetic:sunset_sky': const IconSpec(paintSky, Color(0xFFFFC7A6), Color(0xFFF59AAE), _sun),
  'cosmetic:aurora_sky': const IconSpec(paintAurora, Color(0xFF4A4F7E), Color(0xFF8BE0B4), Color(0xFFC9A6F2)),

  // Plots.
  'plot:meadow': const IconSpec(paintMeadow, _sky, Color(0xFFA6D99A), _pink),
  'plot:forest': const IconSpec(paintForest, _sky, Color(0xFF8CC98A), Color(0xFF4F9D6E)),
  'plot:orchard': const IconSpec(paintOrchard, _sky, Color(0xFF9FD48F), Color(0xFFE8574F)),
  'plot:wetland': const IconSpec(paintWetland, _sky, Color(0xFF9CD3A6), _pink),
  'plot:desert': const IconSpec(paintDesert, Color(0xFFFFE6C7), Color(0xFFF2CF94), Color(0xFF7FB27A)),
  'plot:tropical': const IconSpec(paintTropical, Color(0xFFBDE6F2), Color(0xFFF4DDA6), Color(0xFF59B05C)),
  'plot:alpine': const IconSpec(paintAlpine, _sky, Color(0xFFB7DDB0), Color(0xFF9DAFC8)),

  // Families.
  'family:sunflower': const IconSpec(paintFlowerHead, _sun, Color(0xFFA0683F)),
  'family:lavender': const IconSpec(paintLavender, Color(0xFFAE93E0), _leafDeep, Color(0xFFF2C9A0)),
  'family:moonflower': const IconSpec(paintMoonflower, Color(0xFFF4F1FF), Color(0xFFC9C3F2), Color(0xFFFFE08A)),
  'family:berry': const IconSpec(paintBerries, Color(0xFF6F8EE0), Color(0xFF4F69B8), _leaf),
  'family:rose': const IconSpec(paintRose, Color(0xFFF58DA5), _pink, _leaf),
  'family:herb': const IconSpec(paintLeaf, _leaf),
  'family:bamboo': const IconSpec(paintBambooStalk, Color(0xFF9CCB7A), _leafDeep),

  // Recipes.
  'recipe:fruit_salad': const IconSpec(paintSalad, Color(0xFFCFE6F7), Color(0xFFE8574F), Color(0xFFFFAE45)),
  'recipe:calming_tea': const IconSpec(paintCup, Color(0xFFA9D8B4), Color(0xFFD9C98A), Colors.transparent),
  'recipe:sunny_granola': const IconSpec(paintGranola, Color(0xFFF8D3DA), Color(0xFFF6E7C1), Color(0xFFD9A066)),
  'recipe:forest_stew': const IconSpec(paintStew, Color(0xFFE09A7A), Color(0xFFC9925E), Color(0xFFF2836B)),
  'recipe:orchard_pie': const IconSpec(paintPie, Color(0xFFF2C98E), Color(0xFFE8625A), Color(0xFFFFE6C7)),
  'recipe:hot_cocoa': const IconSpec(paintCup, Color(0xFFF2A9A0), Color(0xFF9C6B4E), _white),

  // Mystery packs.
  'pack:small_pack': const IconSpec(paintGift, Color(0xFFC9B7F0), Color(0xFFF59AAE), _white),
};

/// Mood faces, from 1 (rough) to 5 (great).
const moodFaceColors = <int, Color>{
  1: Color(0xFFB9C6E4),
  2: Color(0xFFC9D6EA),
  3: Color(0xFFEDE5C4),
  4: Color(0xFFCDEBC6),
  5: Color(0xFFFFE2A8),
};

/// Everything the app draws as a small icon goes through this interface, so
/// the whole icon set can be swapped (for example for illustrated art)
/// without touching the screens.
abstract class IconArtProvider {
  Widget icon(String id, {double size = 24, String? semanticLabel});

  /// Whether [id] has its own drawing (otherwise a soft leaf is shown).
  bool has(String id);
}

/// The art used by the app.
IconArtProvider iconArtProvider = const PaintedIconArt();

/// Flat icons painted from [iconSpecs].
class PaintedIconArt implements IconArtProvider {
  const PaintedIconArt();

  @override
  bool has(String id) => iconSpecs.containsKey(id) || id.startsWith('mood:');

  @override
  Widget icon(String id, {double size = 24, String? semanticLabel}) {
    final art = CustomPaint(size: Size.square(size), painter: _IconPainter(id));
    if (semanticLabel == null) return ExcludeSemantics(child: art);
    return Semantics(label: semanticLabel, image: true, excludeSemantics: true, child: art);
  }
}

class _IconPainter extends CustomPainter {
  _IconPainter(this.id);

  final String id;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width, size.height);
    final pen = Pen(canvas);
    if (id.startsWith('mood:')) {
      final mood = int.tryParse(id.substring(5)) ?? 3;
      paintMoodFace(pen, moodFaceColors[mood] ?? moodFaceColors[3]!, const Color(0xFFF7B6C4), mood);
    } else {
      final spec = iconSpecs[id] ?? const IconSpec(paintLeaf, Color(0xFF9AD5A0));
      spec.paint(pen, spec.a, spec.b, spec.c);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_IconPainter old) => old.id != id;
}

/// A painted icon by id, e.g. `ArtIcon('coin')` or `ArtIcon('fruit:apple_tree')`.
class ArtIcon extends StatelessWidget {
  const ArtIcon(this.id, {super.key, this.size = 24, this.semanticLabel});

  final String id;
  final double size;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) => iconArtProvider.icon(id, size: size, semanticLabel: semanticLabel);
}

/// What a screen reader says for an inline icon token.
String iconWord(String id) => switch (id) {
  'coin' => 'coins',
  'seed' => 'seed',
  'basket' => 'basket',
  'bag' => 'bag',
  _ => '',
};

final _token = RegExp(r'\{([a-z_]+(?::[a-z0-9_]+)?)\}');

/// Text with painted icons inline: `IconText('Buy for {coin} 12')`. Tokens are
/// icon ids in braces. Plain text without tokens renders like [Text].
class IconText extends StatelessWidget {
  const IconText(this.text, {super.key, this.style, this.textAlign, this.maxLines, this.overflow});

  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  /// [text] with tokens turned into words, for screen readers and tests.
  static String plain(String text) =>
      text.replaceAllMapped(_token, (m) => iconWord(m[1]!)).replaceAll(RegExp(r' {2,}'), ' ').trim();

  @override
  Widget build(BuildContext context) {
    if (!text.contains('{')) {
      return Text(text, style: style, textAlign: textAlign, maxLines: maxLines, overflow: overflow);
    }
    final base = DefaultTextStyle.of(context).style.merge(style);
    final scale = MediaQuery.textScalerOf(context).scale(base.fontSize ?? 14);
    final spans = <InlineSpan>[];
    var at = 0;
    for (final m in _token.allMatches(text)) {
      if (m.start > at) spans.add(TextSpan(text: text.substring(at, m.start)));
      spans.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1),
            child: ArtIcon(m[1]!, size: scale * 1.25),
          ),
        ),
      );
      at = m.end;
    }
    if (at < text.length) spans.add(TextSpan(text: text.substring(at)));
    return Semantics(
      label: plain(text),
      excludeSemantics: true,
      child: Text.rich(
        TextSpan(children: spans),
        style: style,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
      ),
    );
  }
}
