import 'enums.dart';

enum SeedSource { quests, starter, mysteryPack }

enum SeedState { bag, planted, composted }

class Seed {
  const Seed({
    required this.id,
    required this.speciesId,
    required this.rarity,
    required this.source,
    required this.earnedAt,
    this.state = SeedState.bag,
  });

  final String id;
  final String speciesId;
  final Rarity rarity;
  final SeedSource source;
  final DateTime earnedAt;
  final SeedState state;
}
