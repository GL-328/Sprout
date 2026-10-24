import 'dart:math';

import '../../config/game_config.dart';
import '../models/enums.dart';

class VisitorContext {
  const VisitorContext({
    required this.envId,
    required this.maturePlants,
    required this.streakDays,
    required this.isNight,
    this.lureActive = false,
  });

  final String envId;
  final int maturePlants;
  final int streakDays;
  final bool isNight;
  final bool lureActive;
}

/// Whether [v] could visit at all in [c] (before the chance roll).
bool visitorEligible(VisitorConfig v, VisitorContext c) {
  if (v.environments.isNotEmpty && !v.environments.contains(c.envId)) return false;
  if (c.maturePlants < v.minMaturePlants) return false;
  if (c.streakDays < v.minStreakDays) return false;
  return switch (v.timeOfDay) {
    TimeOfDayKind.any => true,
    TimeOfDayKind.day => !c.isNight,
    TimeOfDayKind.night => c.isNight,
  };
}

/// Visitors in a plot right now. [seed] should stay the same for a few hours
/// so visitors don't flicker on every rebuild.
List<VisitorConfig> visitorsPresent(GameConfig config, VisitorContext c, int seed, {int max = 3}) {
  final random = Random(seed);
  final present = <VisitorConfig>[];
  for (final v in config.visitors.values) {
    final chance = c.lureActive ? (v.chance * 2).clamp(0.0, 1.0) : v.chance;
    if (visitorEligible(v, c) && random.nextDouble() < chance) present.add(v);
  }
  return present.take(max).toList();
}

/// A stable seed for [envId] in the current few-hour window.
int visitorSeed(String envId, DateTime now) => Object.hash(envId, now.year, now.month, now.day, now.hour ~/ 3);
