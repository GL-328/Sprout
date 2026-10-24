import '../../config/game_config.dart';
import '../models/enums.dart';

/// Where a plant is in its life, worked out purely from timestamps, so it
/// keeps growing while the app is closed. Plants never wilt or die.
class GrowthStatus {
  const GrowthStatus({
    required this.stage,
    required this.stageProgress,
    required this.untilNextStage,
    required this.maturedAt,
    required this.readyHarvests,
    required this.untilNextHarvest,
    required this.fruitProgress,
  });

  /// Seed, sprout, young, mature, or fruiting (mature with a harvest waiting).
  final GrowthStage stage;

  /// 0..1 through the current growing stage. 1 once mature.
  final double stageProgress;

  /// Time until the next growth stage. Null once mature.
  final Duration? untilNextStage;
  final DateTime maturedAt;

  /// Harvests waiting to be picked (0..max stored).
  final int readyHarvests;

  /// Time until the next harvest is ready. Null before maturity or when the
  /// basket is full.
  final Duration? untilNextHarvest;

  /// 0..1 towards the next harvest.
  final double fruitProgress;

  bool get isMature => stage == GrowthStage.mature || stage == GrowthStage.fruiting;
  bool get canHarvest => readyHarvests > 0;
}

class HarvestOutcome {
  const HarvestOutcome({required this.harvests, required this.fruit, required this.newAnchor});

  final int harvests;
  final int fruit;

  /// The new fruit timer anchor to store.
  final DateTime newAnchor;
}

abstract final class Growth {
  static const _growingStages = [GrowthStage.seed, GrowthStage.sprout, GrowthStage.young];

  static GrowthStatus status(
    SpeciesConfig species, {
    required DateTime plantedAt,
    DateTime? fruitAnchor,
    required DateTime now,
  }) {
    final elapsed = now.difference(plantedAt);
    var stageStart = Duration.zero;
    for (final stage in _growingStages) {
      final length = species.stageDuration(stage);
      if (elapsed < stageStart + length) {
        final into = elapsed - stageStart;
        return GrowthStatus(
          stage: stage,
          stageProgress: (into.inSeconds / length.inSeconds).clamp(0.0, 1.0),
          untilNextStage: length - (into.isNegative ? Duration.zero : into),
          maturedAt: plantedAt.add(species.timeToMature),
          readyHarvests: 0,
          untilNextHarvest: null,
          fruitProgress: 0,
        );
      }
      stageStart += length;
    }

    final maturedAt = plantedAt.add(species.timeToMature);
    final anchor = fruitAnchor ?? maturedAt;
    final timer = species.fruit.timer;
    final sinceAnchor = now.difference(anchor);
    final max = species.fruit.maxStoredHarvests;
    final rawReady = sinceAnchor.isNegative ? 0 : sinceAnchor.inSeconds ~/ timer.inSeconds;
    final ready = rawReady.clamp(0, max);
    final full = ready >= max;
    final partial = sinceAnchor.isNegative ? Duration.zero : Duration(seconds: sinceAnchor.inSeconds % timer.inSeconds);
    return GrowthStatus(
      stage: ready > 0 ? GrowthStage.fruiting : GrowthStage.mature,
      stageProgress: 1,
      untilNextStage: null,
      maturedAt: maturedAt,
      readyHarvests: ready,
      untilNextHarvest: full ? null : timer - partial,
      fruitProgress: full ? 1 : partial.inSeconds / timer.inSeconds,
    );
  }

  /// Picks every waiting harvest. Progress towards the next harvest is kept,
  /// unless the basket was full (then the timer starts fresh from [now]).
  static HarvestOutcome harvest(
    SpeciesConfig species, {
    required DateTime plantedAt,
    DateTime? fruitAnchor,
    required DateTime now,
  }) {
    final s = status(species, plantedAt: plantedAt, fruitAnchor: fruitAnchor, now: now);
    if (!s.canHarvest) return HarvestOutcome(harvests: 0, fruit: 0, newAnchor: fruitAnchor ?? s.maturedAt);
    final anchor = fruitAnchor ?? s.maturedAt;
    final full = s.readyHarvests >= species.fruit.maxStoredHarvests;
    final newAnchor = full ? now : anchor.add(species.fruit.timer * s.readyHarvests);
    return HarvestOutcome(
      harvests: s.readyHarvests,
      fruit: s.readyHarvests * species.fruit.perHarvest,
      newAnchor: newAnchor,
    );
  }
}

/// "3h 20m", "45m", "under a minute".
String friendlyDuration(Duration d) {
  if (d.inMinutes < 1) return 'under a minute';
  final days = d.inDays;
  final hours = d.inHours % 24;
  final minutes = d.inMinutes % 60;
  if (days > 0) return hours > 0 ? '${days}d ${hours}h' : '${days}d';
  if (d.inHours > 0) return minutes > 0 ? '${d.inHours}h ${minutes}m' : '${d.inHours}h';
  return '${minutes}m';
}
