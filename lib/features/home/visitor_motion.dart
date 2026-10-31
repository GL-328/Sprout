import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../config/game_config.dart';
import '../../ui/art/icon_art.dart';

/// How a visitor gets about.
enum _Gait { flutter, buzz, drift, glide, perch, hop, waddle, stride, amble }

_Gait _gaitOf(String id) => switch (id) {
  'butterfly' => _Gait.flutter,
  'bee' => _Gait.buzz,
  'ladybird' || 'firefly' => _Gait.drift,
  'songbird' || 'parrot' => _Gait.glide,
  'owl' => _Gait.perch,
  'rabbit' || 'frog' || 'squirrel' => _Gait.hop,
  'duck' || 'hedgehog' => _Gait.waddle,
  'sloth' => _Gait.amble,
  _ => _Gait.stride,
};

/// A garden visitor, alive: butterflies flap, bees buzz, birds glide, and
/// creatures on the ground hop, waddle or stroll back and forth, turning to
/// face the way they go. Visitors keep to the edges and the sky, so they
/// never cover the plant.
///
/// [phase] loops 0..1 over the garden's 24 second ambient loop; every motion
/// repeats a whole number of times per loop, so nothing jumps when it wraps.
/// At phase 0 (reduce motion) everyone sits still.
class AnimatedVisitor extends StatelessWidget {
  const AnimatedVisitor({
    super.key,
    required this.visitor,
    required this.index,
    required this.phase,
    required this.width,
    required this.top,
    required this.bottom,
    required this.onTap,
    this.still = false,
    this.slot = 0,
    this.slots = 1,
  });

  /// Whether [id] flies (in the sky) rather than walking on the ground.
  static bool flies(String id) => _gaitOf(id).index <= _Gait.perch.index;

  final VisitorConfig visitor;
  final int index;
  final double phase;

  /// The screen width, and the band between the header and the panel.
  final double width;
  final double top;
  final double bottom;
  final VoidCallback onTap;

  /// Reduce motion: no movement at all.
  final bool still;

  /// Each visitor's own patch of sky or ground: [slot] of [slots] among the
  /// visitors that fly (or that walk), so they don't bunch up or cross paths.
  final int slot;
  final int slots;

  static const size = 36.0;

  @override
  Widget build(BuildContext context) {
    final gait = _gaitOf(visitor.id);
    final i = index;
    final offset = i * 0.9;
    // A wave that repeats [n] times per loop, starting [shift] radians in.
    double wave(int n, [double shift = 0]) => still ? 0 : math.sin(phase * 2 * math.pi * n + shift + offset);

    // Where the visitor is, and which way it's heading (+1 is right).
    double x;
    double y;
    double heading;
    final flies = gait.index <= _Gait.perch.index;
    if (flies) {
      // Each flyer keeps to its own lane of sky, with neighbours a little
      // higher or lower, so they never meet. A lone flyer has the whole sky.
      final lane = 0.82 / slots;
      final cx = 0.04 + lane * (slot + 0.5) - (AnimatedVisitor.size / 2) / width;
      final row = top + 20 + (slot.isOdd ? 44 : 0);
      x = cx + math.min(0.06, lane * 0.22) * wave(2);
      y = row + 14 * wave(4);
      heading = still ? 0 : math.cos(phase * 2 * math.pi * 2 + offset);
      if (gait == _Gait.perch) {
        x = cx;
        y = row;
      }
      if (gait == _Gait.flutter && !still) {
        // Butterflies wander their lane, with little rises and dips.
        double turnOf(int n) => phase * 2 * math.pi * n + offset;
        final reach = math.min(0.36, lane * 0.3);
        x = cx + reach * math.sin(turnOf(1)) + math.min(0.05, lane * 0.06) * math.sin(turnOf(5));
        y = row + 20 + 20 * math.sin(turnOf(2)) + 7 * math.sin(turnOf(7));
      }
    } else {
      // Back and forth along the ground at the edges, slowly, each on its own
      // stretch: the first on the left, the next on the right, then further in.
      final inward = (slot ~/ 2) * 0.2;
      final from = slot.isEven ? 0.02 + inward : 0.74 - inward;
      final range = gait == _Gait.amble ? 0.03 : 0.08;
      final walk = still ? 0.5 : 0.5 - 0.5 * math.cos(phase * 2 * math.pi * 2 + offset);
      x = from + range * walk;
      y = bottom - 70 - slot * 8;
      heading = still ? 0 : math.sin(phase * 2 * math.pi * 2 + offset);
    }

    var lift = 0.0;
    var scaleX = 1.0;
    var scaleY = 1.0;
    var turn = 0.0;
    var glow = 1.0;
    switch (gait) {
      case _Gait.flutter:
        // Seen from above: the wings open and fold about three times a
        // second, and now and then it glides with them open for a beat.
        final beat = (0.5 + 0.5 * wave(3)).clamp(0.0, 1.0);
        final glide = 1 - beat * beat;
        scaleX = 1 - (0.7 - 0.6 * glide) * wave(72).abs();
        if (!still) {
          // It turns to face the way it's flying (the art's head points up).
          double rate(int n) => 2 * math.pi * n * math.cos(phase * 2 * math.pi * n + offset);
          final vx = width * (0.36 * rate(1) + 0.05 * rate(5));
          final vy = 30 * rate(2) + 9 * rate(7);
          turn = math.atan2(vx, -vy);
        }
      case _Gait.buzz:
        lift = 1.5 * wave(240);
        turn = 0.08 * wave(6);
      case _Gait.drift:
        // A slow, smooth float with a gentle bob: no jitter.
        lift = 3 * wave(3);
        if (visitor.id == 'firefly') {
          glow = 0.6 + 0.4 * (0.5 + 0.5 * wave(12));
          turn = 0.08 * wave(2, math.pi / 2);
        } else {
          // The ladybird is seen from above, head up: it leans smoothly
          // towards the side it's drifting to.
          turn = 0.5 * wave(2, math.pi / 2);
        }
      case _Gait.glide:
        // A slow wingbeat, a gentle tilt into the turns.
        scaleY = 0.92 + 0.08 * wave(36).abs();
        turn = 0.12 * wave(2, math.pi / 2);
      case _Gait.perch:
        // Looks about, and now and then settles its feathers.
        turn = 0.07 * wave(3);
        scaleY = 1 - 0.05 * math.pow(wave(4).abs(), 8);
      case _Gait.hop:
        final h = wave(40).abs();
        lift = 12 * h;
        // A little squash on landing.
        scaleY = 0.88 + 0.12 * math.min(1, h * 3);
        scaleX = 1.06 - 0.06 * math.min(1, h * 3);
      case _Gait.waddle:
        turn = 0.14 * wave(36);
        lift = 1.5 * wave(72).abs();
      case _Gait.stride:
        lift = 2.5 * wave(36).abs();
      case _Gait.amble:
        lift = 1 * wave(6).abs();
    }
    // The art faces left; turn it round when heading right. The butterfly
    // and the ladybird (seen from above) turn their whole body instead.
    final turnsBody = gait == _Gait.flutter || visitor.id == 'ladybird';
    final facing = turnsBody || heading <= 0.05 ? 1.0 : -1.0;

    return Positioned(
      left: width * x,
      top: y - lift,
      child: Semantics(
        button: true,
        label: '${visitor.name} visiting',
        child: GestureDetector(
          onTap: onTap,
          child: Opacity(
            opacity: glow,
            child: Transform.rotate(
              angle: turn,
              child: Transform(
                alignment: gait == _Gait.hop || gait == _Gait.stride ? Alignment.bottomCenter : Alignment.center,
                transform: Matrix4.diagonal3Values(scaleX * facing, scaleY, 1),
                child: ArtIcon('visitor:${visitor.id}', size: size),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
