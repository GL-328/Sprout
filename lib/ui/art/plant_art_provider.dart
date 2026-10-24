import 'package:flutter/material.dart';

import '../../config/game_config.dart';
import '../../domain/models/enums.dart';

/// Everything the game draws for plants and seeds goes through this
/// interface, keyed by species and growth stage. Swap the implementation
/// (see [plantArtProvider]) to use real illustrations without touching game
/// logic.
abstract class PlantArtProvider {
  /// The plant in [stage], drawn to fit [size]. [sway] is -1..1, for gentle
  /// wind animation.
  Widget plant(SpeciesConfig species, GrowthStage stage, {required double size, double sway = 0});

  /// A seed packet for [species].
  Widget seed(SpeciesConfig species, {double size = 56});

  /// The fruit icon.
  Widget fruit(SpeciesConfig species, {double size = 28});
}

/// The art used by the app. Replaced in later stages by the painted art.
PlantArtProvider plantArtProvider = EmojiPlantArt();

/// Simple placeholder art using emoji.
class EmojiPlantArt implements PlantArtProvider {
  @override
  Widget plant(SpeciesConfig species, GrowthStage stage, {required double size, double sway = 0}) {
    final emoji = switch (stage) {
      GrowthStage.seed => '🟤',
      GrowthStage.sprout => '🌱',
      GrowthStage.young => '🪴',
      _ => species.fruit.emoji,
    };
    return SizedBox.square(
      dimension: size,
      child: Center(
        child: Text(emoji, style: TextStyle(fontSize: size * 0.6)),
      ),
    );
  }

  @override
  Widget seed(SpeciesConfig species, {double size = 56}) => SeedPacket(species: species, size: size);

  @override
  Widget fruit(SpeciesConfig species, {double size = 28}) =>
      Text(species.fruit.emoji, style: TextStyle(fontSize: size));
}

/// A rounded seed packet with the plant's fruit on the front.
class SeedPacket extends StatelessWidget {
  const SeedPacket({super.key, required this.species, required this.size});

  final SpeciesConfig species;
  final double size;

  @override
  Widget build(BuildContext context) {
    final color = switch (species.rarity) {
      Rarity.common => const Color(0xFFCDEBD9),
      Rarity.uncommon => const Color(0xFFCFE6F7),
      Rarity.rare => const Color(0xFFE6D5F7),
    };
    return Container(
      width: size * 0.8,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(size * 0.16),
        border: Border.all(color: Colors.white, width: size * 0.04),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: size * 0.12,
            offset: Offset(0, size * 0.05),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(species.fruit.emoji, style: TextStyle(fontSize: size * 0.42)),
    );
  }
}
