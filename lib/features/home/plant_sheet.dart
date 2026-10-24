import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/haptics.dart';
import '../../core/providers.dart';
import '../../domain/logic/growth.dart';
import '../../domain/models/plant.dart';
import '../../ui/art/painted_plant_art.dart';
import '../../ui/widgets/motion.dart';
import '../../ui/theme/category_style.dart';
import '../../ui/layout/insets.dart';
import '../../ui/art/icon_art.dart';

Future<void> showPlantSheet(BuildContext context, Plant plant) =>
    showSproutSheet<void>(context, builder: (_) => _PlantSheet(plant: plant));

class _PlantSheet extends ConsumerWidget {
  const _PlantSheet({required this.plant});

  final Plant plant;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final config = ref.watch(gameConfigProvider);
    final species = config.speciesById(plant.speciesId);
    final now = ref.watch(nowProvider).value ?? ref.watch(clockProvider).now();
    final status = Growth.status(species, plantedAt: plant.plantedAt, fruitAnchor: plant.fruitAnchorAt, now: now);

    Future<void> moveOn() async {
      final ok = await showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
          scrollable: true,
          title: Text('Move on from your ${species.name}?'),
          content: const Text(
            'It will be kept as a keepsake in your Journal, and this spot will be free for a new seed. '
            "This can't be undone.",
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Keep growing')),
            FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Move on')),
          ],
        ),
      );
      if (ok != true) return;
      await ref.read(gardenServiceProvider).moveOn(plant.id);
      Haptics.light();
      if (context.mounted) Navigator.of(context).pop();
    }

    final String headline;
    final String detail;
    final double progress;
    if (!status.isMature) {
      headline = '${status.stage.label} · ${(status.stageProgress * 100).round()}%';
      detail =
          'Next stage in ${friendlyDuration(status.untilNextStage!)}. '
          'Fully grown in ${friendlyDuration(status.maturedAt.difference(now))}.';
      progress = status.stageProgress;
    } else if (status.untilNextHarvest == null) {
      headline = 'Basket full · ${status.readyHarvests} harvests waiting';
      detail = 'Tap the plant in your garden to pick them.';
      progress = 1;
    } else {
      headline = status.canHarvest ? 'Fruiting · ${status.readyHarvests} ready' : 'Mature';
      detail =
          'Next ${species.fruit.name.toLowerCase()} in ${friendlyDuration(status.untilNextHarvest!)}. '
          'Holds up to ${species.fruit.maxStoredHarvests} harvests while you are away.';
      progress = status.fruitProgress;
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LivePlant(species: species, stage: status.stage, size: 160, animate: !reduceMotion(context, ref)),
          const SizedBox(height: 8),
          Text(species.name, style: theme.textTheme.titleLarge),
          const SizedBox(height: 6),
          Chip(label: Text(species.rarity.label), backgroundColor: rarityColor(species.rarity).withValues(alpha: 0.3)),
          const SizedBox(height: 12),
          Text(headline, style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(value: progress, minHeight: 12),
          ),
          const SizedBox(height: 10),
          Text(detail, textAlign: TextAlign.center, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 6),
          IconText(
            'Fruit: {fruit:${species.id}} ${species.fruit.name}, ${species.fruit.perHarvest} per harvest, '
            'worth ${species.fruit.sellPrice} coins each. Picked ${plant.harvests} times so far.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 20),
          TextButton.icon(onPressed: moveOn, icon: const Icon(Icons.spa_outlined), label: const Text('Move on')),
        ],
      ),
    );
  }
}
