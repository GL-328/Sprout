import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/game_config.dart';
import '../../core/haptics.dart';
import '../../core/providers.dart';
import '../../core/sound_service.dart';
import '../../data/services/garden_service.dart';
import '../../domain/models/seed.dart';
import '../../ui/art/plant_art_provider.dart';
import '../../ui/theme/category_style.dart';
import '../today/today_providers.dart';
import 'garden_providers.dart';
import '../../ui/layout/insets.dart';

/// "This one would love a Forest plot", or null if it fits an unlocked plot.
String? seedHint(GameConfig config, SpeciesConfig species, Set<String> unlocked) {
  if (species.environments.any(unlocked.contains)) return null;
  final env = config.environments.firstWhere((e) => species.environments.contains(e.id));
  return 'This one would love a ${env.name} plot';
}

Future<void> showChooseSeedSheet(BuildContext context, {required String envId, required int slot}) =>
    showSproutSheet<void>(
      context,
      heightFactor: 0.75,
      builder: (_) => SizedBox.expand(
        child: _ChooseSeed(envId: envId, slot: slot),
      ),
    );

class _ChooseSeed extends ConsumerWidget {
  const _ChooseSeed({required this.envId, required this.slot});

  final String envId;
  final int slot;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final config = ref.watch(gameConfigProvider);
    final env = config.environment(envId);
    final seeds = ref.watch(seedBagProvider).value ?? const <Seed>[];
    final fits = seeds.where((s) => config.speciesById(s.speciesId).environments.contains(envId)).toList();
    final others = seeds.where((s) => !fits.contains(s)).toList();

    Future<void> plant(Seed seed) async {
      try {
        await ref.read(gardenServiceProvider).plantSeed(seed.id, envId, slot);
        Haptics.medium();
        ref.read(soundServiceProvider).play(Sfx.plant);
        if (context.mounted) Navigator.of(context).pop();
      } on GardenException catch (e) {
        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    }

    return ListView(
      padding: AppInsets.list(context, top: 0),
      children: [
        Text('Choose a seed', style: theme.textTheme.titleLarge),
        const SizedBox(height: 4),
        Text(
          'This plant will be a permanent part of your ${env.name}.',
          style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 16),
        if (fits.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(
              children: [
                const Text('🌱', style: TextStyle(fontSize: 44)),
                const SizedBox(height: 8),
                Text(
                  seeds.isEmpty
                      ? 'No seeds yet. Every 3 quests you finish earns one.'
                      : 'None of your seeds grow in the ${env.name} yet. Finish a few quests for more.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
          ),
        for (final s in fits) _SeedTile(seed: s, onTap: () => plant(s)),
        if (others.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
            child: Text('Waiting for another plot', style: theme.textTheme.titleMedium),
          ),
          for (final s in others) Opacity(opacity: 0.55, child: _SeedTile(seed: s)),
        ],
      ],
    );
  }
}

class _SeedTile extends ConsumerWidget {
  const _SeedTile({required this.seed, this.onTap, this.trailing});

  final Seed seed;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final config = ref.watch(gameConfigProvider);
    final species = config.speciesById(seed.speciesId);
    final unlocked = (ref.watch(plotsProvider).value ?? const {}).keys.toSet();
    final hint = seedHint(config, species, unlocked);
    final envNames = [for (final e in species.environments) config.environment(e).name].join(', ');
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: rarityColor(species.rarity).withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                plantArtProvider.seed(species, size: 52),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(species.name, style: theme.textTheme.titleMedium),
                      Text(
                        '${species.rarity.label} · grows in $envNames',
                        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      ),
                      if (hint != null)
                        Text('$hint 💛', style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
                ?trailing,
                if (onTap != null && trailing == null) const Icon(Icons.chevron_right),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> showSeedBagSheet(BuildContext context) =>
    showSproutSheet<void>(context, heightFactor: 0.8, builder: (_) => const SeedBagList());

/// The seeds in the bag, with compost buttons.
class SeedBagList extends ConsumerWidget {
  const SeedBagList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final config = ref.watch(gameConfigProvider);
    final seeds = ref.watch(seedBagProvider).value ?? const <Seed>[];

    Future<void> compost(Seed seed) async {
      final species = config.speciesById(seed.speciesId);
      final coins = config.compostCoins[seed.rarity] ?? 0;
      final ok = await showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
          scrollable: true,
          title: Text('Compost ${species.name}?'),
          content: Text('It goes back into the soil and gives you $coins coins.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Keep it')),
            FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Compost')),
          ],
        ),
      );
      if (ok != true) return;
      await ref.read(economyServiceProvider).compostSeed(seed.id);
      Haptics.light();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Composted. +$coins coins 🪙')));
      }
    }

    return ListView(
      padding: AppInsets.list(context, top: 0),
      children: [
        Row(
          children: [
            Expanded(child: Text('Seed Bag', style: theme.textTheme.titleLarge)),
            Text('${seeds.length} / ${config.seedBagCap}', style: theme.textTheme.titleMedium),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Seeds never expire. Tap an empty spot in your garden to plant one.',
          style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 16),
        if (seeds.isEmpty)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: Text('Your bag is empty for now. Every 3 quests earns a seed 🌱')),
          ),
        for (final s in seeds)
          _SeedTile(
            seed: s,
            trailing: IconButton(
              tooltip: 'Compost',
              icon: const Icon(Icons.recycling_rounded),
              onPressed: () => compost(s),
            ),
          ),
      ],
    );
  }
}
