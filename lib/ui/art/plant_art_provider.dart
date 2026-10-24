import 'package:flutter/material.dart';

import '../../config/game_config.dart';
import '../../domain/models/enums.dart';
import 'painted_plant_art.dart';
import 'icon_art.dart';

/// Everything the game draws for plants and seeds goes through this
/// interface, keyed by species and growth stage. Swap the implementation
/// (see [plantArtProvider]) to use real illustrations without touching game
/// logic.
abstract class PlantArtProvider {
  /// The plant in [stage], drawn [size] wide and [height] tall (square when
  /// [height] is null). [sway] is -1..1, for gentle wind animation.
  Widget plant(SpeciesConfig species, GrowthStage stage, {required double size, double? height, double sway = 0});

  /// A seed packet for [species].
  Widget seed(SpeciesConfig species, {double size = 56});

  /// The fruit icon.
  Widget fruit(SpeciesConfig species, {double size = 28});

  /// An empty patch of soil where a seed can be planted, [size] wide.
  Widget groundSpot({required double size});
}

/// The art used by the app.
PlantArtProvider plantArtProvider = PaintedPlantArt();

/// Simple placeholder art built from the flat icons.
class SimplePlantArt implements PlantArtProvider {
  @override
  Widget plant(SpeciesConfig species, GrowthStage stage, {required double size, double? height, double sway = 0}) {
    final icon = switch (stage) {
      GrowthStage.seed => 'seed',
      GrowthStage.sprout || GrowthStage.young => 'sprout',
      _ => 'fruit:${species.id}',
    };
    return SizedBox(
      width: size,
      height: height ?? size,
      child: Center(child: ArtIcon(icon, size: size * 0.6)),
    );
  }

  @override
  Widget seed(SpeciesConfig species, {double size = 56}) => SeedPacket(species: species, size: size);

  @override
  Widget fruit(SpeciesConfig species, {double size = 28}) => ArtIcon('fruit:${species.id}', size: size);

  @override
  Widget groundSpot({required double size}) => SizedBox(width: size, height: size * 0.4);
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
      child: ArtIcon('fruit:${species.id}', size: size * 0.5),
    );
  }
}
