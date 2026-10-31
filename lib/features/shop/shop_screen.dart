import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/game_config.dart';
import '../../core/haptics.dart';
import '../../core/providers.dart';
import '../../core/sound_service.dart';
import '../../data/services/garden_service.dart';
import '../../domain/logic/ben.dart';
import '../../domain/logic/seasons.dart';
import '../../domain/models/seed.dart';
import '../../ui/art/plant_art_provider.dart';
import '../../ui/art/scene_painter.dart';
import '../../ui/theme/category_style.dart';
import '../../ui/layout/insets.dart';
import '../../ui/widgets/bouncy.dart';
import '../../ui/widgets/fly_to_counter.dart';
import '../../ui/widgets/motion.dart';
import '../home/garden_providers.dart';
import '../today/seed_reveal.dart';
import '../today/today_providers.dart';
import 'ben.dart';
import '../../ui/art/icon_art.dart';

enum ShopSection { plots, sell, recipes, decor }

/// A Finch-like shop: Ben at his stall, four big section tiles and a grid of
/// soft cards. Details live in a bottom sheet.
class ShopScreen extends ConsumerStatefulWidget {
  const ShopScreen({super.key});

  @override
  ConsumerState<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends ConsumerState<ShopScreen> {
  ShopSection _section = ShopSection.plots;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final coins = ref.watch(coinsProvider).value ?? 0;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              sliver: SliverList.list(
                children: [
                  Row(
                    children: [
                      Text('Shop', style: theme.appBarTheme.titleTextStyle),
                      const Spacer(),
                      Container(
                        key: CounterTargets.shopCoins,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF4B740).withValues(alpha: 0.22),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: IconText(
                          '{coin} $coins',
                          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  BenWindow(height: (MediaQuery.sizeOf(context).height * 0.22).clamp(150.0, 200.0)),
                  const SizedBox(height: 14),
                  _SectionTiles(selected: _section, onSelect: (s) => setState(() => _section = s)),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, AppInsets.scrollEnd(context)),
              sliver: switch (_section) {
                ShopSection.plots => const _PlotsGrid(),
                ShopSection.sell => const _SellGrid(),
                ShopSection.recipes => const _RecipesGrid(),
                ShopSection.decor => const _DecorGrid(),
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTiles extends ConsumerWidget {
  const _SectionTiles({required this.selected, required this.onSelect});

  final ShopSection selected;
  final ValueChanged<ShopSection> onSelect;

  static const _tiles = [
    (ShopSection.plots, Icons.landscape_rounded, 'Plots', Color(0xFFCDEBD9)),
    (ShopSection.sell, Icons.shopping_basket_rounded, 'Sell', Color(0xFFFFE2B8)),
    (ShopSection.recipes, Icons.soup_kitchen_rounded, 'Recipes', Color(0xFFF8D3DA)),
    (ShopSection.decor, Icons.chair_rounded, 'Decor', Color(0xFFDDD3F4)),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final calm = reduceMotion(context, ref);
    return Row(
      children: [
        for (final (section, icon, label, color) in _tiles)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Semantics(
                button: true,
                selected: section == selected,
                label: label,
                excludeSemantics: true,
                onTap: () => onSelect(section),
                child: Bouncy(
                  enabled: !calm,
                  onTap: () {
                    Haptics.selection();
                    onSelect(section);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: section == selected ? color : color.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: section == selected ? Color.lerp(color, Colors.black, 0.25)! : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(icon, size: 28, color: Color.lerp(color, Colors.black, 0.6)),
                        const SizedBox(height: 4),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              label,
                              maxLines: 1,
                              style: theme.textTheme.labelLarge?.copyWith(color: const Color(0xFF3B3346)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// --- Shared card and sheet ----------------------------------------------------

/// A soft shop card: picture, a short name and a price pill. Nothing else.
class _ShopCard extends ConsumerWidget {
  const _ShopCard({
    required this.picture,
    required this.name,
    required this.pill,
    required this.tint,
    required this.onTap,
    this.faded = false,
    this.badge,
  });

  final Widget picture;
  final String name;
  final String pill;
  final Color tint;
  final VoidCallback onTap;

  /// Soft and faded when it can't be afforded yet. Never red.
  final bool faded;
  final String? badge;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Semantics(
      button: true,
      label: '$name, ${IconText.plain(pill)}',
      excludeSemantics: true,
      onTap: onTap,
      child: Bouncy(
        enabled: !reduceMotion(context, ref),
        onTap: onTap,
        child: Opacity(
          opacity: faded ? 0.55 : 1,
          child: Column(
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: tint.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(26),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    children: [
                      Positioned.fill(child: Center(child: picture)),
                      if (badge != null)
                        Positioned(
                          right: 10,
                          top: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Text(
                              badge!,
                              style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w800),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4B740).withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: IconText(pill, style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

SliverGrid _grid(List<Widget> cards) => SliverGrid.count(
  crossAxisCount: 2,
  mainAxisSpacing: 16,
  crossAxisSpacing: 14,
  childAspectRatio: 0.78,
  children: cards,
);

/// Bigger picture, one line, one clear button.
Future<void> _showItemSheet(
  BuildContext context, {
  required Widget picture,
  required Color tint,
  required String title,
  required String line,
  required String action,
  required Future<void> Function()? onAction,
  Widget? extra,
  String? secondary,
  Future<void> Function()? onSecondary,
}) => showSproutSheet<void>(
  context,
  builder: (sheet) {
    final theme = Theme.of(sheet);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 170,
              width: double.infinity,
              decoration: BoxDecoration(color: tint.withValues(alpha: 0.55), borderRadius: BorderRadius.circular(28)),
              clipBehavior: Clip.antiAlias,
              child: Center(child: picture),
            ),
            const SizedBox(height: 14),
            Text(title, style: theme.textTheme.titleLarge),
            const SizedBox(height: 6),
            Text(line, textAlign: TextAlign.center, style: theme.textTheme.bodyMedium),
            if (extra != null) ...[const SizedBox(height: 12), extra],
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onAction == null
                    ? null
                    : () async {
                        Navigator.pop(sheet);
                        await onAction();
                      },
                child: IconText(action),
              ),
            ),
            if (secondary != null && onSecondary != null)
              TextButton(
                onPressed: () async {
                  Navigator.pop(sheet);
                  await onSecondary();
                },
                child: Text(secondary),
              ),
          ],
        ),
      ),
    );
  },
);

void _celebrate(WidgetRef ref, BenLineType reaction, Sfx sfx) {
  Haptics.medium();
  ref.read(soundServiceProvider).play(sfx);
  ref.read(benProvider.notifier).react(reaction);
}

void _toast(BuildContext context, String message) => ScaffoldMessenger.of(context)
  ..hideCurrentSnackBar()
  ..showSnackBar(SnackBar(content: IconText(message)));

// --- Plots --------------------------------------------------------------------

class _PlotsGrid extends ConsumerWidget {
  const _PlotsGrid();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(gameConfigProvider);
    final plots = ref.watch(plotsProvider).value ?? const {};
    final coins = ref.watch(coinsProvider).value ?? 0;

    Widget thumb(EnvironmentConfig env, {double radius = 0}) => CustomPaint(
      size: Size.infinite,
      painter: GardenScenePainter(hour: 13, envId: env.id, season: Season.summer, silhouette: false),
    );

    void open(EnvironmentConfig env) {
      final owned = plots.containsKey(env.id);
      final affordable = coins >= env.price;
      if (!owned && !affordable) ref.read(benProvider.notifier).react(BenLineType.noCoins);
      final grows = config.speciesForEnvironment(env.id).map((s) => '{fruit:${s.id}}').join(' ');
      _showItemSheet(
        context,
        picture: SizedBox.expand(child: thumb(env)),
        tint: const Color(0xFFCDEBD9),
        title: env.name,
        line: env.description,
        extra: IconText('Grows: $grows', textAlign: TextAlign.center, style: const TextStyle(fontSize: 18)),
        action: owned
            ? 'Already yours'
            : affordable
            ? 'Unlock for {coin} ${env.price}'
            : '{coin} ${env.price - coins} more to go',
        onAction: owned || !affordable
            ? null
            : () async {
                await ref.read(economyServiceProvider).unlockPlot(env.id);
                _celebrate(ref, BenLineType.unlock, Sfx.coin);
                if (context.mounted) _toast(context, 'The ${env.name} is yours! Find it from the plot name on Home.');
              },
      );
    }

    final packs = config.mysteryPacks.values.toList();
    return _grid([
      for (final env in config.environments)
        _ShopCard(
          picture: SizedBox.expand(child: thumb(env)),
          name: env.name,
          pill: plots.containsKey(env.id) ? 'Yours {check}' : '{coin} ${env.price}',
          tint: const Color(0xFFCDEBD9),
          faded: !plots.containsKey(env.id) && coins < env.price,
          onTap: () => open(env),
        ),
      for (final pack in packs)
        _ShopCard(
          picture: ArtIcon('pack:${pack.id}', size: 76),
          name: pack.name,
          pill: '{coin} ${pack.price}',
          tint: const Color(0xFFE6D5F7),
          faded: coins < pack.price,
          onTap: () {
            final affordable = coins >= pack.price;
            if (!affordable) ref.read(benProvider.notifier).react(BenLineType.noCoins);
            _showItemSheet(
              context,
              picture: ArtIcon('pack:${pack.id}', size: 110),
              tint: const Color(0xFFE6D5F7),
              title: pack.name,
              line: 'A surprise seed. Quests are still the best way to grow rare ones.',
              action: affordable ? 'Buy for {coin} ${pack.price}' : '{coin} ${pack.price - coins} more to go',
              onAction: affordable
                  ? () async {
                      try {
                        final seeds = await ref.read(economyServiceProvider).buyMysteryPack(pack.id);
                        _celebrate(ref, BenLineType.buy, Sfx.seed);
                        for (final s in seeds) {
                          if (context.mounted) await showSeedReveal(context, s, title: 'A mystery seed!');
                        }
                      } on GardenException catch (e) {
                        if (context.mounted) _toast(context, e.message);
                      }
                    }
                  : null,
            );
          },
        ),
    ]);
  }
}

// --- Sell and compost ---------------------------------------------------------

class _SellGrid extends ConsumerWidget {
  const _SellGrid();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(gameConfigProvider);
    final inventory = ref.watch(inventoryProvider).value ?? const <String, int>{};
    final seeds = ref.watch(seedBagProvider).value ?? const <Seed>[];
    final fruit = inventory.entries.where((e) => config.species.containsKey(e.key) && e.value > 0).toList();

    if (fruit.isEmpty && seeds.isEmpty) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(28),
          child: Text(
            'Nothing to sell yet. Harvest a ripe plant and bring the fruit here.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return _grid([
      for (final e in fruit)
        Builder(
          builder: (context) {
            final s = config.speciesById(e.key);
            final each = s.fruit.sellPrice;
            Future<void> sell(int qty) async {
              final coins = await ref.read(economyServiceProvider).sellFruit(e.key, qty);
              _celebrate(ref, BenLineType.sell, Sfx.coin);
              if (context.mounted) _toast(context, 'Sold for {coin} $coins');
            }

            return _ShopCard(
              picture: ArtIcon('fruit:${s.id}', size: 76),
              name: s.fruit.name,
              pill: '{coin} $each each',
              tint: const Color(0xFFFFE2B8),
              badge: '×${e.value}',
              onTap: () => _showItemSheet(
                context,
                picture: ArtIcon('fruit:${s.id}', size: 110),
                tint: const Color(0xFFFFE2B8),
                title: '${s.fruit.name} ×${e.value}',
                line: 'From your ${s.name}. Worth $each coins each.',
                action: 'Sell all for {coin} ${each * e.value}',
                onAction: () => sell(e.value),
                secondary: e.value > 1 ? 'Sell just one' : null,
                onSecondary: e.value > 1 ? () => sell(1) : null,
              ),
            );
          },
        ),
      for (final seed in seeds)
        Builder(
          builder: (context) {
            final s = config.speciesById(seed.speciesId);
            final coins = config.compostCoins[seed.rarity] ?? 0;
            return _ShopCard(
              picture: plantArtProvider.seed(s, size: 70),
              name: s.name,
              pill: '{compost} +$coins',
              tint: rarityColor(s.rarity),
              onTap: () => _showItemSheet(
                context,
                picture: plantArtProvider.seed(s, size: 110),
                tint: rarityColor(s.rarity),
                title: s.name,
                line: 'A spare ${s.rarity.label.toLowerCase()} seed. Compost it for a few coins, or keep it to plant.',
                action: 'Compost for {coin} $coins',
                onAction: () async {
                  await ref.read(economyServiceProvider).compostSeed(seed.id);
                  _celebrate(ref, BenLineType.compost, Sfx.coin);
                  if (context.mounted) _toast(context, 'Composted. +{coin} $coins');
                },
              ),
            );
          },
        ),
    ]);
  }
}

// --- Recipes ------------------------------------------------------------------

class _RecipesGrid extends ConsumerWidget {
  const _RecipesGrid();

  static String effectLine(RecipeEffect e) => switch (e.type) {
    RecipeEffectType.coins => 'Gives you ${e.amount} coins.',
    RecipeEffectType.growthBoost => 'Every plant jumps ${e.hours} hours ahead.',
    RecipeEffectType.visitorLure => 'Visitors are extra curious for ${e.hours} hours.',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(gameConfigProvider);
    final inventory = ref.watch(inventoryProvider).value ?? const <String, int>{};
    final economy = ref.read(economyServiceProvider);
    return _grid([
      for (final r in config.recipes.values)
        Builder(
          builder: (context) {
            final can = economy.canCook(r, inventory);
            final needs = [for (final e in r.ingredients.entries) '{fruit:${e.key}}${e.value}'].join(' ');
            return _ShopCard(
              picture: ArtIcon('recipe:${r.id}', size: 76),
              name: r.name,
              pill: needs,
              tint: const Color(0xFFF8D3DA),
              faded: !can,
              onTap: () => _showItemSheet(
                context,
                picture: ArtIcon('recipe:${r.id}', size: 110),
                tint: const Color(0xFFF8D3DA),
                title: r.name,
                line: effectLine(r.effect),
                extra: IconText(
                  [for (final e in r.ingredients.entries) '{fruit:${e.key}} ${inventory[e.key] ?? 0}/${e.value}']
                      .join('    '),
                  style: const TextStyle(fontSize: 16),
                ),
                action: can ? 'Make it' : 'A little more fruit needed',
                onAction: can
                    ? () async {
                        try {
                          final outcome = await economy.cook(r.id);
                          _celebrate(ref, BenLineType.buy, Sfx.complete);
                          if (context.mounted) _toast(context, outcome.message);
                        } on GardenException catch (e) {
                          if (context.mounted) _toast(context, e.message);
                        }
                      }
                    : null,
              ),
            );
          },
        ),
    ]);
  }
}

// --- Decorations --------------------------------------------------------------

class _DecorGrid extends ConsumerWidget {
  const _DecorGrid();

  static const _tints = {
    'path': Color(0xFFE9E1D3),
    'fence': Color(0xFFF2DFC6),
    'pond': Color(0xFFCFE6F7),
    'bench': Color(0xFFF6E2C8),
    'lantern': Color(0xFFFFE9B8),
    'background': Color(0xFFDDD3F4),
  };

  Future<void> _place(BuildContext context, CosmeticConfig c) => showSproutSheet<void>(
    context,
    builder: (_) => Consumer(
      builder: (context, ref, _) {
        final config = ref.watch(gameConfigProvider);
        final plots = ref.watch(plotsProvider).value ?? const {};
        final placed = ref.watch(placedCosmeticsProvider).value ?? const {};
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Place ${c.name}', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              for (final env in config.environments.where((e) => plots.containsKey(e.id)))
                SwitchListTile(
                  secondary: ArtIcon('plot:${env.id}', size: 32),
                  title: Text(env.name),
                  value: placed[env.id]?[c.kind] == c.id,
                  onChanged: (on) => ref.read(economyServiceProvider).placeCosmetic(env.id, c.kind, on ? c.id : null),
                ),
            ],
          ),
        );
      },
    ),
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(gameConfigProvider);
    final owned = ref.watch(ownedCosmeticsProvider).value ?? const <String>{};
    final coins = ref.watch(coinsProvider).value ?? 0;
    return _grid([
      for (final c in config.cosmetics.values)
        Builder(
          builder: (context) {
            final tint = _tints[c.kind] ?? const Color(0xFFE6D5F7);
            final has = owned.contains(c.id);
            final affordable = coins >= c.price;
            return _ShopCard(
              picture: ArtIcon('cosmetic:${c.id}', size: 76),
              name: c.name,
              pill: has ? 'Owned {check}' : '{coin} ${c.price}',
              tint: tint,
              faded: !has && !affordable,
              onTap: () {
                if (has) {
                  _place(context, c);
                  return;
                }
                if (!affordable) ref.read(benProvider.notifier).react(BenLineType.noCoins);
                _showItemSheet(
                  context,
                  picture: ArtIcon('cosmetic:${c.id}', size: 110),
                  tint: tint,
                  title: c.name,
                  line: 'A cosy ${c.kind == 'background' ? 'sky' : c.kind} for any of your plots.',
                  action: affordable ? 'Buy for {coin} ${c.price}' : '{coin} ${c.price - coins} more to go',
                  onAction: affordable
                      ? () async {
                          await ref.read(economyServiceProvider).buyCosmetic(c.id);
                          _celebrate(ref, BenLineType.buy, Sfx.coin);
                          if (context.mounted) await _place(context, c);
                        }
                      : null,
                );
              },
            );
          },
        ),
    ]);
  }
}
