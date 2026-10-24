import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../art/icon_art.dart';

/// Little icons (coins, fruit, seeds) that arc from [from] to the widget
/// holding [target], then disappear. Does nothing when [reduceMotion].
void flyToCounter(
  BuildContext context, {
  required Offset from,
  required GlobalKey target,
  required String icon,
  int count = 5,
  bool reduceMotion = false,
}) {
  if (reduceMotion) return;
  final overlay = Overlay.maybeOf(context, rootOverlay: true);
  final box = target.currentContext?.findRenderObject() as RenderBox?;
  if (overlay == null || box == null || !box.attached) return;
  final to = box.localToGlobal(box.size.center(Offset.zero));
  for (var i = 0; i < count; i++) {
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _Flyer(
        from: from,
        to: to,
        icon: icon,
        delay: Duration(milliseconds: 70 * i),
        spread: (i - count / 2) * 14.0,
        onDone: () => entry.remove(),
      ),
    );
    overlay.insert(entry);
  }
}

class _Flyer extends StatefulWidget {
  const _Flyer({
    required this.from,
    required this.to,
    required this.icon,
    required this.delay,
    required this.spread,
    required this.onDone,
  });

  final Offset from;
  final Offset to;
  final String icon;
  final Duration delay;
  final double spread;
  final VoidCallback onDone;

  @override
  State<_Flyer> createState() => _FlyerState();
}

class _FlyerState extends State<_Flyer> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 750));

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(widget.delay, () {
      if (mounted) _c.forward().whenComplete(widget.onDone);
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          final t = Curves.easeInOutCubic.transform(_c.value);
          final control = Offset(
            (widget.from.dx + widget.to.dx) / 2 + widget.spread * 3,
            math.min(widget.from.dy, widget.to.dy) - 80,
          );
          final p = Offset(
            _bezier(widget.from.dx, control.dx, widget.to.dx, t),
            _bezier(widget.from.dy, control.dy, widget.to.dy, t),
          );
          return Stack(
            children: [
              Positioned(
                left: p.dx - 14,
                top: p.dy - 14,
                child: Opacity(
                  opacity: _c.value == 0 ? 0 : (1 - t * 0.3),
                  child: Transform.scale(scale: 1.2 - 0.5 * t, child: ArtIcon(widget.icon, size: 28)),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  static double _bezier(double a, double b, double c, double t) =>
      (1 - t) * (1 - t) * a + 2 * (1 - t) * t * b + t * t * c;
}

/// Keys for the counters on the Home screen, so things can fly to them.
class CounterTargets {
  static final coins = GlobalKey(debugLabel: 'coins');

  /// The Home Bag button holds both seeds and fruit.
  static final bag = GlobalKey(debugLabel: 'bag');
  static GlobalKey get basket => bag;
  static GlobalKey get seedBag => bag;
  static final shopCoins = GlobalKey(debugLabel: 'shopCoins');
}
