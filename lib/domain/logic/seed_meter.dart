import '../../config/game_config.dart';

/// Rules for the Seed Meter. Pure and stateless.
class SeedMeterRules {
  const SeedMeterRules(this.config);

  final GameConfig config;

  int get questsPerSeed => config.questsPerSeed;

  /// Whether a new completion today should fill the meter, given how many of
  /// today's completions already did.
  bool countsTowardMeter(int countedToday) => countedToday < config.maxCountedCompletionsPerDay;

  /// Meter dots filled, from the number of counted completions that haven't
  /// turned into a seed yet.
  int filled(int openCounted) => openCounted % questsPerSeed;

  /// Kind words shown next to the meter.
  String message({required int filled, required int countedToday}) {
    if (!countsTowardMeter(countedToday)) {
      return "You've grown all the seeds today can hold. "
          'Anything else you do still counts for you, and the meter waits for tomorrow.';
    }
    final left = questsPerSeed - filled;
    if (filled == 0) return 'Finish $questsPerSeed quests to earn a seed 🌱';
    if (left == 1) return '$filled of $questsPerSeed, one more for a seed!';
    return '$filled of $questsPerSeed, $left more for a seed';
  }
}
