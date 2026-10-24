import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/game_config.dart';
import '../../core/haptics.dart';
import '../../core/providers.dart';
import '../../data/services/garden_service.dart';
import '../../domain/models/enums.dart';
import '../../domain/models/seed.dart';
import '../../ui/art/plant_art_provider.dart';
import '../../ui/theme/app_theme.dart';
import '../../ui/theme/category_style.dart';
import '../../ui/widgets/fly_to_counter.dart';
import '../../ui/widgets/soft_card.dart';
import '../home/garden_providers.dart';
import '../today/seed_reveal.dart';
import '../today/today_providers.dart';
import 'basket_sheet.dart';

class ShopScreen extends ConsumerWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coins = ref.watch(coinsProvider).value ?? 0;
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Shop'),
          actions: [
            Container(
              key: CounterTargets.shopCoins,
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: SproutColors.coin.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text('🪙 $coins', style: Theme.of(context).textTheme.titleMedium),
            ),
          ],
          bottom: const TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              Tab(text: 'Plots'),
              Tab(text: 'Sell & compost'),
              Tab(text: 'Recipes'),
              Tab(text: 'Decorations'),
              Tab(text: 'Mystery seeds'),
            ],
          ),
        ),
        body: const TabBarView(children: [_PlotsTab(), _SellTab(), _RecipesTab(), _CosmeticsTab(), _MysteryTab()]),
      ),
    );
  }
}

void _toast(BuildContext context, String message) => ScaffoldMessenger.of(context)
  ..hideCurrentSnackBar()
  ..showSnackBar(SnackBar(content: Text(message)));

Future<bool> _confirm(BuildContext context, String title, String body, String action) async =>
    await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Not now')),
          FilledButton(onPressed: () => Navigator.pop(c, true), child: Text(action)),
        ],
      ),
    ) ==
    true;

const _listPadding = EdgeInsets.fromLTRB(20, 16, 20, 120);

class _PlotsTab extends ConsumerWidget {
  const _PlotsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final config = ref.watch(gameConfigProvider);
    final plots = ref.watch(plotsProvider).value ?? const {};
    final coins = ref.watch(coinsProvider).value ?? 0;
    return ListView(
      padding: _listPadding,
      children: [
        Text(
          'Each new plot has its own 3 spots, its own look, and new plants that only grow there.',
          style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 16),
        for (final env in config.environments)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: SoftCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(env.emoji, style: const TextStyle(fontSize: 34)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(env.name, style: theme.textTheme.titleMedium),
                            Text(env.description, style: theme.textTheme.bodySmall),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final s in config.speciesForEnvironment(env.id))
                        Chip(
                          visualDensity: VisualDensity.compact,
                          label: Text('${s.fruit.emoji} ${s.name}'),
                          backgroundColor: rarityColor(s.rarity).withValues(alpha: 0.2),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: plots.containsKey(env.id)
                        ? const Chip(label: Text('✅ Unlocked'))
                        : FilledButton(
                            onPressed: coins >= env.price
                                ? () async {
                                    if (!await _confirm(
                                      context,
                                      'Unlock the ${env.name}?',
                                      'This uses ${env.price} coins.',
                                      'Unlock',
                                    )) {
                                      return;
                                    }
                                    await ref.read(economyServiceProvider).unlockPlot(env.id);
                                    Haptics.medium();
                                    if (context.mounted) {
                                      _toast(context, 'The ${env.name} is yours! Swipe to it on Home 🌱');
                                    }
                                  }
                                : null,
                            child: Text('🪙 ${env.price}'),
                          ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _SellTab extends ConsumerWidget {
  const _SellTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final config = ref.watch(gameConfigProvider);
    final seeds = ref.watch(seedBagProvider).value ?? const <Seed>[];
    return ListView(
      padding: _listPadding,
      children: [
        Text('Fruit', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        const FruitBasket(embedded: true),
        const SizedBox(height: 24),
        Text('Spare seeds', style: theme.textTheme.titleMedium),
        const SizedBox(height: 4),
        Text(
          'Compost seeds you don\'t need for a few coins. Seeds never expire, so there\'s no rush.',
          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 8),
        if (seeds.isEmpty) const Padding(padding: EdgeInsets.all(16), child: Text('No spare seeds right now.')),
        for (final seed in seeds)
          Builder(
            builder: (context) {
              final s = config.speciesById(seed.speciesId);
              final coins = config.compostCoins[seed.rarity] ?? 0;
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: plantArtProvider.seed(s, size: 44),
                title: Text(s.name),
                subtitle: Text(seed.rarity.label),
                trailing: OutlinedButton(
                  onPressed: () async {
                    if (!await _confirm(context, 'Compost ${s.name}?', 'You\'ll get $coins coins.', 'Compost')) return;
                    await ref.read(economyServiceProvider).compostSeed(seed.id);
                    Haptics.light();
                    if (context.mounted) _toast(context, '+$coins coins 🪙');
                  },
                  child: Text('♻️ +$coins'),
                ),
              );
            },
          ),
      ],
    );
  }
}

class _RecipesTab extends ConsumerWidget {
  const _RecipesTab();

  String _effect(RecipeEffect e) => switch (e.type) {
    RecipeEffectType.coins => '+${e.amount} coins',
    RecipeEffectType.growthBoost => 'All plants jump ${e.hours}h ahead',
    RecipeEffectType.visitorLure => 'More visitors for ${e.hours}h',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final config = ref.watch(gameConfigProvider);
    final inventory = ref.watch(inventoryProvider).value ?? const <String, int>{};
    final economy = ref.read(economyServiceProvider);
    return ListView(
      padding: _listPadding,
      children: [
        Text(
          'Turn fruit into little treats for your garden.',
          style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 16),
        for (final r in config.recipes.values)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: SoftCard(
              child: Row(
                children: [
                  Text(r.emoji, style: const TextStyle(fontSize: 40)),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(r.name, style: theme.textTheme.titleMedium),
                        Text(_effect(r.effect), style: theme.textTheme.bodyMedium),
                        const SizedBox(height: 4),
                        Text(
                          [
                            for (final e in r.ingredients.entries)
                              '${config.speciesById(e.key).fruit.emoji} ${inventory[e.key] ?? 0}/${e.value}',
                          ].join('   '),
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  FilledButton.tonal(
                    onPressed: economy.canCook(r, inventory)
                        ? () async {
                            try {
                              final outcome = await economy.cook(r.id);
                              Haptics.medium();
                              if (context.mounted) _toast(context, outcome.message);
                            } on GardenException catch (e) {
                              if (context.mounted) _toast(context, e.message);
                            }
                          }
                        : null,
                    child: const Text('Make'),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _CosmeticsTab extends ConsumerWidget {
  const _CosmeticsTab();

  Future<void> _place(BuildContext context, WidgetRef ref, CosmeticConfig c) => showModalBottomSheet<void>(
    context: context,
    builder: (_) => Consumer(
      builder: (context, ref, _) {
        final config = ref.watch(gameConfigProvider);
        final plots = ref.watch(plotsProvider).value ?? const {};
        final placed = ref.watch(placedCosmeticsProvider).value ?? const {};
        return ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
          children: [
            Text('Place ${c.name}', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            for (final env in config.environments.where((e) => plots.containsKey(e.id)))
              SwitchListTile(
                title: Text('${env.emoji} ${env.name}'),
                value: placed[env.id]?[c.kind] == c.id,
                onChanged: (on) => ref.read(economyServiceProvider).placeCosmetic(env.id, c.kind, on ? c.id : null),
              ),
          ],
        );
      },
    ),
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final config = ref.watch(gameConfigProvider);
    final owned = ref.watch(ownedCosmeticsProvider).value ?? const <String>{};
    final coins = ref.watch(coinsProvider).value ?? 0;
    return GridView.count(
      padding: _listPadding,
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 0.92,
      children: [
        for (final c in config.cosmetics.values)
          SoftCard(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                Text(c.emoji, style: const TextStyle(fontSize: 44)),
                const SizedBox(height: 6),
                Text(
                  c.name,
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                  textAlign: TextAlign.center,
                ),
                Text(c.kind[0].toUpperCase() + c.kind.substring(1), style: theme.textTheme.bodySmall),
                const Spacer(),
                if (owned.contains(c.id))
                  OutlinedButton(onPressed: () => _place(context, ref, c), child: const Text('Place'))
                else
                  FilledButton(
                    onPressed: coins >= c.price
                        ? () async {
                            await ref.read(economyServiceProvider).buyCosmetic(c.id);
                            Haptics.medium();
                            if (context.mounted) await _place(context, ref, c);
                          }
                        : null,
                    child: Text('🪙 ${c.price}'),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _MysteryTab extends ConsumerWidget {
  const _MysteryTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final config = ref.watch(gameConfigProvider);
    final coins = ref.watch(coinsProvider).value ?? 0;
    return ListView(
      padding: _listPadding,
      children: [
        Text(
          'A little surprise seed. Finishing quests is still the best way to get seeds, '
          'especially rare ones.',
          style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 16),
        for (final p in config.mysteryPacks.values)
          SoftCard(
            child: Row(
              children: [
                Text(p.emoji, style: const TextStyle(fontSize: 44)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.name, style: theme.textTheme.titleMedium),
                      Text(
                        '${p.seeds} seed · ${((p.odds[Rarity.rare] ?? 0) * 100).round()}% chance of rare',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                FilledButton(
                  onPressed: coins >= p.price
                      ? () async {
                          try {
                            final seeds = await ref.read(economyServiceProvider).buyMysteryPack(p.id);
                            Haptics.medium();
                            for (final s in seeds) {
                              if (context.mounted) await showSeedReveal(context, s, title: 'A mystery seed!');
                            }
                          } on GardenException catch (e) {
                            if (context.mounted) _toast(context, e.message);
                          }
                        }
                      : null,
                  child: Text('🪙 ${p.price}'),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
