import 'enums.dart';

class Plant {
  const Plant({
    required this.id,
    required this.envId,
    required this.slot,
    required this.speciesId,
    required this.rarity,
    required this.plantedAt,
    this.fruitAnchorAt,
    this.harvests = 0,
    this.uprootedAt,
  });

  final String id;
  final String envId;
  final int slot;
  final String speciesId;
  final Rarity rarity;
  final DateTime plantedAt;
  final DateTime? fruitAnchorAt;
  final int harvests;

  /// Set when the plant was moved on into a keepsake.
  final DateTime? uprootedAt;

  bool get isKeepsake => uprootedAt != null;
}
