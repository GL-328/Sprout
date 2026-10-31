import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../config/game_config.dart';
import '../../domain/logic/growth.dart';
import '../../domain/models/enums.dart';
import '../../domain/models/plant.dart';
import '../../ui/art/plant_art_provider.dart';
import '../../ui/art/icon_art.dart';
import '../../ui/theme/app_theme.dart';

/// One plot's slots, one large plant at a time. Neighbours peek in from the
/// sides; arrows and swipes move between them.
class PlantCarousel extends StatelessWidget {
  const PlantCarousel({
    super.key,
    required this.controller,
    required this.config,
    required this.env,
    required this.plants,
    required this.statuses,
    required this.page,
    required this.sway,
    required this.pulse,
    required this.reduceMotion,
    this.night = false,
    required this.onPageChanged,
    required this.onTapEmpty,
    required this.onTapPlant,
  });

  final PageController controller;
  final GameConfig config;
  final EnvironmentConfig env;
  final List<Plant> plants;
  final Map<String, GrowthStatus> statuses;
  final int page;

  /// -1..1, gentle wind.
  final double sway;

  /// 0..1, for the soft pulse on empty slots and ready plants.
  final double pulse;
  final bool reduceMotion;

  /// Dims the plants a little at night, like the scenery around them.
  final bool night;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<int> onTapEmpty;
  final void Function(Plant plant, Offset globalPosition) onTapPlant;

  static const viewportFraction = 0.7;

  void _go(int to) {
    if (to < 0 || to >= env.slots) return;
    if (reduceMotion) {
      controller.jumpToPage(to);
    } else {
      controller.animateToPage(to, duration: const Duration(milliseconds: 420), curve: Curves.easeOutCubic);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              PageView.builder(
                controller: controller,
                itemCount: env.slots,
                onPageChanged: onPageChanged,
                itemBuilder: (context, i) => AnimatedBuilder(
                  animation: controller,
                  builder: (context, child) {
                    // While a rebuild briefly attaches two views, fall back to
                    // the settled page instead of reading an ambiguous position.
                    final current = controller.positions.length == 1 && controller.position.haveDimensions
                        ? controller.page ?? page.toDouble()
                        : page.toDouble();
                    final distance = (current - i).abs().clamp(0.0, 1.0);
                    return Opacity(
                      opacity: 1 - 0.45 * distance,
                      child: Transform.scale(
                        scale: 1 - 0.18 * distance,
                        alignment: Alignment.bottomCenter,
                        child: child,
                      ),
                    );
                  },
                  child: _Slot(
                    index: i,
                    centred: i == page,
                    plant: plants.where((p) => p.slot == i).firstOrNull,
                    config: config,
                    statuses: statuses,
                    sway: sway,
                    pulse: pulse,
                    night: night,
                    onTapEmpty: () => i == page ? onTapEmpty(i) : _go(i),
                    onTapPlant: (p, pos) => i == page ? onTapPlant(p, pos) : _go(i),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: _Arrow(
                  icon: Icons.chevron_left_rounded,
                  label: 'Previous plant',
                  enabled: page > 0,
                  onTap: () => _go(page - 1),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: _Arrow(
                  icon: Icons.chevron_right_rounded,
                  label: 'Next plant',
                  enabled: page < env.slots - 1,
                  onTap: () => _go(page + 1),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < env.slots; i++)
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: i == page ? 0.95 : 0.45),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

/// The same night shade the scenery uses, a little lighter so plants stay clear.
const nightTint = ColorFilter.mode(Color(0x591E2E40), BlendMode.srcATop);

/// The soft shadow under the garden's white buttons and bubbles.
final _softShadow = [
  BoxShadow(color: Colors.black.withValues(alpha: 0.10), blurRadius: 10, offset: const Offset(0, 3)),
];

class _Arrow extends StatelessWidget {
  const _Arrow({required this.icon, required this.label, required this.enabled, required this.onTap});

  final IconData icon;
  final String label;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => AnimatedOpacity(
    opacity: enabled ? 1 : 0,
    duration: const Duration(milliseconds: 200),
    child: IgnorePointer(
      ignoring: !enabled,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: DecoratedBox(
          decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: _softShadow),
          child: Material(
            color: SproutColors.paper,
            shape: const CircleBorder(),
            child: IconButton(
              tooltip: label,
              visualDensity: VisualDensity.compact,
              icon: Icon(icon, color: Theme.of(context).colorScheme.primary, weight: 700),
              onPressed: onTap,
            ),
          ),
        ),
      ),
    ),
  );
}

class _Slot extends StatelessWidget {
  const _Slot({
    required this.index,
    required this.centred,
    required this.plant,
    required this.config,
    required this.statuses,
    required this.sway,
    required this.pulse,
    required this.night,
    required this.onTapEmpty,
    required this.onTapPlant,
  });

  final int index;
  final bool centred;
  final Plant? plant;
  final GameConfig config;
  final Map<String, GrowthStatus> statuses;
  final double sway;
  final double pulse;
  final bool night;
  final VoidCallback onTapEmpty;
  final void Function(Plant plant, Offset globalPosition) onTapPlant;

  @override
  Widget build(BuildContext context) {
    final p = plant;
    Widget dim(Widget art) => night ? ColorFiltered(colorFilter: nightTint, child: art) : art;
    return LayoutBuilder(
      builder: (context, box) {
        // On short screens (landscape) the bubble, then the label, step aside so
        // the plant always fits.
        final showBubble = centred && box.maxHeight >= 170;
        final showLabel = box.maxHeight >= 110;
        final labelH = showLabel ? 30.0 : 0.0;
        final bubbleH = showBubble ? 44.0 : 0.0;
        final artH = math.max(60.0, box.maxHeight - labelH - bubbleH - 8);
        final artW = math.min(box.maxWidth * 0.92, artH / 1.25);

        if (p == null) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (showBubble) const _Bubble("I'd love a seed here"),
              const SizedBox(height: 12),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Semantics(
                    button: true,
                    label: 'Empty spot. Plant a seed',
                    excludeSemantics: true,
                    onTap: onTapEmpty,
                    child: GestureDetector(
                      onTap: onTapEmpty,
                      child: _EmptyRing(pulse: pulse, size: math.min(artW * 0.6, 120), dim: dim),
                    ),
                  ),
                ),
              ),
              if (showLabel) const SizedBox(height: 10),
              if (showLabel) const _Label('Plant a seed'),
            ],
          );
        }

        final species = config.speciesById(p.speciesId);
        final status = statuses[p.id]!;
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (showBubble) _Bubble(bubbleLine(species, status)),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.bottomCenter,
                child: Semantics(
                  button: true,
                  label: '${species.name}, ${status.stage.label}${status.canHarvest ? ', ready to harvest' : ''}',
                  child: GestureDetector(
                    onTapUp: (d) => onTapPlant(p, d.globalPosition),
                    child: Container(
                      decoration: status.canHarvest
                          ? BoxDecoration(
                              // A soft warm glow that breathes gently.
                              gradient: RadialGradient(
                                colors: [
                                  const Color(0xFFFFF1B8).withValues(alpha: 0.30 + 0.20 * pulse),
                                  const Color(0xFFFFF1B8).withValues(alpha: 0),
                                ],
                                stops: const [0.35, 0.72],
                              ),
                            )
                          : null,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 500),
                        transitionBuilder: (child, a) => ScaleTransition(
                          scale: CurvedAnimation(parent: a, curve: Curves.easeOutBack),
                          child: child,
                        ),
                        child: KeyedSubtree(
                          key: ValueKey('${p.id}-${status.stage}'),
                          child: dim(
                            plantArtProvider.plant(species, status.stage, size: artW, height: artH, sway: sway),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (showLabel) _Label(statusLine(species, status)),
          ],
        );
      },
    );
  }
}

/// Small, calm status under the plant.
String statusLine(SpeciesConfig species, GrowthStatus s) {
  if (s.canHarvest) return 'Tap to harvest';
  if (!s.isMature) return '${s.stage.label} · ${friendlyDuration(s.untilNextStage!)}';
  if (s.untilNextHarvest == null) return 'Tap to harvest';
  return 'Next {fruit:${species.id}} in ${friendlyDuration(s.untilNextHarvest!)}';
}

/// What the plant says, like a little friend.
String bubbleLine(SpeciesConfig species, GrowthStatus s) {
  if (s.canHarvest) return "{fruit:${species.id}} Fruit's ready for you!";
  return switch (s.stage) {
    GrowthStage.seed => 'Snug in the soil, getting ready…',
    GrowthStage.sprout => "I'm sprouting!",
    GrowthStage.young => 'Growing up nicely',
    _ => 'Thanks for looking after me',
  };
}

class _Bubble extends StatelessWidget {
  const _Bubble(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(maxWidth: 240),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    decoration: BoxDecoration(
      color: SproutColors.paper,
      borderRadius: BorderRadius.circular(18),
      boxShadow: _softShadow,
    ),
    child: IconText(
      text,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF3B3346)),
    ),
  );
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(top: 6),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    decoration: BoxDecoration(
      color: SproutColors.paper,
      borderRadius: BorderRadius.circular(100),
      boxShadow: _softShadow,
    ),
    child: IconText(
      text,
      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF4A4257)),
    ),
  );
}

class _EmptyRing extends StatelessWidget {
  const _EmptyRing({required this.pulse, required this.size, required this.dim});

  final double pulse;
  final double size;
  final Widget Function(Widget art) dim;

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final button = size * 0.7;
    // The ring floats above the soil patch, so the patch shows clearly below it.
    return SizedBox(
      width: size,
      height: size * 1.35,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(bottom: 0, child: dim(plantArtProvider.groundSpot(size: size * 1.1))),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: size,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // See-through: a white ring that breathes out and fades away,
                // then a white ring around an orange +.
                Container(
                  width: button * (1 + 0.3 * pulse),
                  height: button * (1 + 0.3 * pulse),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: SproutColors.paper.withValues(alpha: 0.7 * (1 - pulse)), width: 2),
                  ),
                ),
                Container(
                  width: button,
                  height: button,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: SproutColors.paper.withValues(alpha: 0.9), width: 3),
                  ),
                ),
                CustomPaint(size: Size.square(button * 0.44), painter: _PlusPainter(accent)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// An orange + with a white outline, readable on any grass.
class _PlusPainter extends CustomPainter {
  _PlusPainter(this.colour);

  final Color colour;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final cross = Path()
      ..moveTo(w / 2, w * 0.1)
      ..lineTo(w / 2, w * 0.9)
      ..moveTo(w * 0.1, w / 2)
      ..lineTo(w * 0.9, w / 2);
    Paint pen(Color c, double width) => Paint()
      ..color = c
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round;
    final bar = w * 0.16;
    final edge = bar + math.max(3.0, bar * 0.7);
    canvas.drawPath(cross.shift(const Offset(0, 1.5)), pen(Colors.black.withValues(alpha: 0.08), edge));
    canvas.drawPath(cross, pen(SproutColors.paper, edge));
    canvas.drawPath(cross, pen(colour, bar));
  }

  @override
  bool shouldRepaint(_PlusPainter old) => old.colour != colour;
}
