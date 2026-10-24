import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../config/game_config.dart';
import '../../core/greeting.dart';
import '../../core/haptics.dart';
import '../../core/providers.dart';
import '../../core/sound_service.dart';
import '../../data/services/garden_service.dart';
import '../../domain/logic/growth.dart';
import '../../domain/logic/seasons.dart';
import '../../domain/logic/visitors.dart';
import '../../domain/models/enums.dart';
import '../../domain/models/plant.dart';
import '../../ui/art/plant_art_provider.dart';
import '../../ui/art/scene_painter.dart';
import '../../ui/widgets/fly_to_counter.dart';
import '../../ui/widgets/gentle_motion.dart';
import '../../ui/widgets/motion.dart';
import '../../ui/widgets/seed_meter_ring.dart';
import '../shop/basket_sheet.dart';
import '../shop/visitor_sheet.dart';
import '../today/today_providers.dart';
import 'garden_providers.dart';
import 'plant_sheet.dart';
import 'seed_sheets.dart';

/// The garden: one plot at a time, swipe to change plots.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with SingleTickerProviderStateMixin {
  final _pages = PageController();
  late final _ambient = AnimationController(vsync: this, duration: const Duration(seconds: 24));
  int _page = 0;
  bool _foreground = true;
  late final _lifecycle = AppLifecycleListener(
    onStateChange: (state) {
      _foreground = state == AppLifecycleState.resumed;
      ref.read(soundServiceProvider).setAmbient(_foreground && TickerMode.valuesOf(context).enabled);
    },
  );

  @override
  void initState() {
    super.initState();
    _lifecycle;
  }

  @override
  void dispose() {
    _pages.dispose();
    _ambient.dispose();
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Garden ambience plays only while Home is the visible tab.
    ref.read(soundServiceProvider).setAmbient(TickerMode.valuesOf(context).enabled && _foreground);
    if (reduceMotion(context, ref)) {
      if (_ambient.isAnimating) _ambient.stop();
    } else if (!_ambient.isAnimating) {
      _ambient.repeat();
    }
    final config = ref.watch(gameConfigProvider);
    final plots = ref.watch(plotsProvider).value ?? const <String, DateTime>{};
    final now = ref.watch(nowProvider).value ?? ref.watch(clockProvider).now();
    final name = ref.watch(settingsProvider.select((s) => s.name));
    final env = config.environments[_page.clamp(0, config.environments.length - 1)];
    final unlockedAt = plots[env.id];
    final season = unlockedAt == null
        ? null
        : seasonFor(unlockedAt: unlockedAt, now: now, daysPerSeason: config.daysPerSeason);
    const ink = Color(0xFF3B3346);
    final isNight = now.hour < 6 || now.hour >= 20;
    final onScene = isNight ? Colors.white : ink;

    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pages,
            itemCount: config.environments.length,
            onPageChanged: (i) {
              Haptics.selection();
              setState(() => _page = i);
            },
            itemBuilder: (context, i) {
              final e = config.environments[i];
              return plots.containsKey(e.id)
                  ? _UnlockedPlot(env: e, unlockedAt: plots[e.id]!, ambient: _ambient)
                  : _LockedPlot(env: e);
            },
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _TopBar(),
                  const SizedBox(height: 14),
                  Text(
                    greetingFor(now, name),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: onScene),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        '${env.emoji} ${env.name}${season == null ? '' : '  ·  ${season.emoji} ${season.label}'}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(color: onScene.withValues(alpha: 0.8)),
                      ),
                      const Spacer(),
                      for (var i = 0; i < config.environments.length; i++)
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(left: 4),
                          width: i == _page ? 16 : 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: onScene.withValues(alpha: i == _page ? 0.8 : 0.3),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopBar extends ConsumerWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coins = ref.watch(coinsProvider).value ?? 0;
    final meter = ref.watch(meterProvider).value;
    final bag = ref.watch(seedBagProvider).value?.length ?? 0;
    final fruit = (ref.watch(inventoryProvider).value ?? const {}).values.fold(0, (a, b) => a + b);
    final rules = ref.watch(progressServiceProvider).rules;

    Widget pill({Key? key, required Widget child, VoidCallback? onTap, String? label}) => Semantics(
      button: onTap != null,
      label: label,
      child: Material(
        key: key,
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(100),
        child: InkWell(
          borderRadius: BorderRadius.circular(100),
          onTap: onTap,
          child: Padding(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8), child: child),
        ),
      ),
    );

    const style = TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF3B3346));
    return Row(
      children: [
        pill(
          key: CounterTargets.coins,
          label: '$coins coins',
          onTap: () => context.go('/shop'),
          child: Row(
            children: [
              const Text('🪙', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 6),
              AnimatedCount(value: coins, style: style, enabled: !reduceMotion(context, ref)),
            ],
          ),
        ),
        const SizedBox(width: 8),
        pill(
          key: CounterTargets.basket,
          label: 'Fruit basket, $fruit fruit',
          onTap: () => showBasketSheet(context),
          child: Row(
            children: [
              const Text('🧺', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 6),
              Text('$fruit', style: style),
            ],
          ),
        ),
        const Spacer(),
        Semantics(
          button: true,
          label: 'Seed Meter, ${meter?.filled ?? 0} of ${rules.questsPerSeed}. Opens Today',
          child: GestureDetector(
            onTap: () => context.go('/today'),
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.85), shape: BoxShape.circle),
              child: SeedMeterRing(filled: meter?.filled ?? 0, total: rules.questsPerSeed, size: 42),
            ),
          ),
        ),
        const SizedBox(width: 8),
        pill(
          key: CounterTargets.seedBag,
          label: 'Seed Bag, $bag seeds',
          onTap: () => showSeedBagSheet(context),
          child: Row(
            children: [
              const Text('🎒', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 6),
              Text('$bag', style: style),
            ],
          ),
        ),
      ],
    );
  }
}

/// Garden plants are drawn taller than wide, so they fill the scene.
const _plantAspect = 1.45;

class _UnlockedPlot extends ConsumerStatefulWidget {
  const _UnlockedPlot({required this.env, required this.unlockedAt, required this.ambient});

  final EnvironmentConfig env;
  final DateTime unlockedAt;
  final AnimationController ambient;

  @override
  ConsumerState<_UnlockedPlot> createState() => _UnlockedPlotState();
}

class _UnlockedPlotState extends ConsumerState<_UnlockedPlot> {
  final Set<String> _recorded = {};

  Future<void> _tapPlant(Plant plant, Offset globalPos) async {
    final config = ref.read(gameConfigProvider);
    final species = config.speciesById(plant.speciesId);
    final now = ref.read(clockProvider).now();
    final status = Growth.status(species, plantedAt: plant.plantedAt, fruitAnchor: plant.fruitAnchorAt, now: now);
    if (!status.canHarvest) {
      await showPlantSheet(context, plant);
      return;
    }
    final result = await ref.read(gardenServiceProvider).harvest(plant.id);
    if (!mounted || result.fruit == 0) return;
    Haptics.medium();
    ref.read(soundServiceProvider).play(Sfx.harvest);
    flyToCounter(
      context,
      from: globalPos,
      target: CounterTargets.basket,
      emoji: species.fruit.emoji,
      count: math.min(result.fruit, 8),
      reduceMotion: reduceMotion(context, ref),
    );
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('Picked ${result.fruit} ${species.fruit.name} ${species.fruit.emoji}')));
  }

  @override
  Widget build(BuildContext context) {
    final config = ref.watch(gameConfigProvider);
    final env = widget.env;
    final plants = ref.watch(plantsInPlotProvider(env.id)).value ?? const <Plant>[];
    final now = ref.watch(nowProvider).value ?? ref.watch(clockProvider).now();
    final mood = ref.watch(todayMoodProvider).value?.value;
    final placed = (ref.watch(placedCosmeticsProvider).value ?? const {})[env.id] ?? const <String, String>{};
    final streak = ref.watch(streakProvider);
    final lure = ref.watch(visitorLureProvider).value ?? false;
    final season = seasonFor(unlockedAt: widget.unlockedAt, now: now, daysPerSeason: config.daysPerSeason);
    final hour = now.hour + now.minute / 60;
    final calm = reduceMotion(context, ref);

    final statuses = {
      for (final p in plants)
        p.id: Growth.status(
          config.speciesById(p.speciesId),
          plantedAt: p.plantedAt,
          fruitAnchor: p.fruitAnchorAt,
          now: now,
        ),
    };
    final mature = statuses.values.where((s) => s.isMature).length;
    final visitors = visitorsPresent(
      config,
      VisitorContext(
        envId: env.id,
        maturePlants: mature,
        streakDays: streak,
        isNight: hour < 6 || hour >= 20,
        lureActive: lure,
      ),
      visitorSeed(env.id, now),
    );
    final fresh = visitors.map((v) => v.id).where((id) => !_recorded.contains(id)).toList();
    if (fresh.isNotEmpty) {
      _recorded.addAll(fresh);
      WidgetsBinding.instance.addPostFrameCallback((_) => ref.read(economyServiceProvider).recordVisitors(fresh));
    }

    return LayoutBuilder(
      builder: (context, box) {
        final w = box.maxWidth;
        final h = box.maxHeight;
        // Plants are big and may overlap a little; the middle one stands in front.
        final plantSize = math.min(w * 0.52, h * 0.40);
        double slotX(int i) => w * (0.5 + (i - (env.slots - 1) / 2) * (0.96 / env.slots));
        final middle = (env.slots - 1) / 2;
        double slotY(int i) => h * (0.84 + 0.035 * (1 - (i - middle).abs() / (middle == 0 ? 1 : middle)));
        double slotSize(int i) => plantSize * (1 - 0.12 * ((i - middle).abs() / (middle == 0 ? 1 : middle)));
        final drawOrder = [for (var i = 0; i < env.slots; i++) i]
          ..sort((a, b) => (b - middle).abs().compareTo((a - middle).abs()));

        return AnimatedBuilder(
          animation: widget.ambient,
          builder: (context, _) {
            final phase = calm ? 0.0 : widget.ambient.value;
            final sway = calm ? 0.0 : math.sin(phase * 2 * math.pi * 6);
            return Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: GardenScenePainter(
                      hour: hour,
                      envId: env.id,
                      season: season,
                      weather: weatherForMood(mood),
                      skyTheme: placed['background'],
                      phase: phase,
                    ),
                  ),
                ),
                ..._cosmetics(config, placed, w, h),
                for (final i in drawOrder)
                  _slot(context, config, plants, statuses, i, Offset(slotX(i), slotY(i)), slotSize(i), sway, env.id),
                for (final (i, v) in visitors.indexed) _visitor(context, v, i, phase, w, h, calm),
              ],
            );
          },
        );
      },
    );
  }

  Widget _slot(
    BuildContext context,
    GameConfig config,
    List<Plant> plants,
    Map<String, GrowthStatus> statuses,
    int i,
    Offset base,
    double size,
    double sway,
    String envId,
  ) {
    final plant = plants.where((p) => p.slot == i).firstOrNull;
    if (plant == null) {
      return Positioned(
        left: base.dx - 48,
        top: base.dy - 24,
        child: Semantics(
          button: true,
          label: 'Empty spot. Plant a seed',
          child: GestureDetector(
            onTap: () => showChooseSeedSheet(context, envId: envId, slot: i),
            child: Container(
              width: 96,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF8B6B4E).withValues(alpha: 0.35),
                borderRadius: const BorderRadius.all(Radius.elliptical(96, 44)),
                border: Border.all(color: Colors.white.withValues(alpha: 0.7), width: 2),
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
            ),
          ),
        ),
      );
    }
    final species = config.speciesById(plant.speciesId);
    final status = statuses[plant.id]!;
    return Positioned(
      left: base.dx - size / 2,
      top: base.dy - size * _plantAspect * 0.94,
      child: Semantics(
        button: true,
        label: '${species.name}, ${status.stage.label}${status.canHarvest ? ', ready to harvest' : ''}',
        child: GestureDetector(
          onTapUp: (d) => _tapPlant(plant, d.globalPosition),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                transitionBuilder: (child, a) => ScaleTransition(
                  scale: CurvedAnimation(parent: a, curve: Curves.easeOutBack),
                  child: child,
                ),
                child: KeyedSubtree(
                  key: ValueKey('${plant.id}-${status.stage}'),
                  child: plantArtProvider.plant(
                    species,
                    status.stage,
                    size: size,
                    height: size * _plantAspect,
                    sway: sway * (0.6 + 0.4 * ((i + 1) % 2)),
                  ),
                ),
              ),
              if (status.canHarvest)
                Positioned(
                  top: -6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(100),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 8)],
                    ),
                    child: Text(
                      '${species.fruit.emoji} ×${status.readyHarvests * species.fruit.perHarvest}',
                      style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF3B3346)),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _cosmetics(GameConfig config, Map<String, String> placed, double w, double h) {
    Widget at(String kind, double x, double y, double size) {
      final c = config.cosmetics[placed[kind]];
      if (c == null) return const SizedBox.shrink();
      return Positioned(
        left: w * x - size / 2,
        top: h * y - size / 2,
        child: IgnorePointer(
          child: Text(c.emoji, style: TextStyle(fontSize: size)),
        ),
      );
    }

    return [
      at('fence', 0.06, 0.74, 34),
      at('fence', 0.94, 0.74, 34),
      at('lantern', 0.08, 0.66, 30),
      at('lantern', 0.92, 0.66, 30),
      at('pond', 0.86, 0.95, 40),
      at('bench', 0.14, 0.95, 36),
      at('path', 0.5, 0.97, 32),
    ];
  }

  Widget _visitor(BuildContext context, VisitorConfig v, int i, double phase, double w, double h, bool calm) {
    const flyers = {'butterfly', 'bee', 'songbird', 'firefly', 'parrot', 'owl', 'ladybird'};
    final flies = flyers.contains(v.id);
    final t = (phase * (flies ? 3 : 1.5) + i * 0.37) % 1;
    final x = flies ? 0.1 + 0.8 * (0.5 + 0.5 * math.sin(t * 2 * math.pi)) : 0.08 + 0.84 * t;
    final y = flies ? 0.42 + 0.08 * math.sin(t * 4 * math.pi + i) + i * 0.05 : 0.80 + i * 0.03;
    final facingLeft = flies ? math.cos(t * 2 * math.pi) < 0 : false;
    return Positioned(
      left: w * x - 18,
      top: h * y - 18,
      child: Semantics(
        button: true,
        label: '${v.name} visiting',
        child: GestureDetector(
          onTap: () => showVisitorSheet(context, v),
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.diagonal3Values(facingLeft || (!flies) ? -1 : 1, 1, 1),
            child: Text(v.emoji, style: const TextStyle(fontSize: 32)),
          ),
        ),
      ),
    );
  }
}

class _LockedPlot extends ConsumerWidget {
  const _LockedPlot({required this.env});

  final EnvironmentConfig env;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final config = ref.watch(gameConfigProvider);
    final coins = ref.watch(coinsProvider).value ?? 0;
    final now = ref.watch(nowProvider).value ?? DateTime.now();
    final grows = config.speciesForEnvironment(env.id).toList();
    final canAfford = coins >= env.price;

    Future<void> unlock() async {
      final ok = await showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
          title: Text('Unlock the ${env.name}?'),
          content: Text('This uses ${env.price} coins. You will have ${coins - env.price} left.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Not yet')),
            FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Unlock')),
          ],
        ),
      );
      if (ok != true) return;
      try {
        await ref.read(economyServiceProvider).unlockPlot(env.id);
        Haptics.medium();
        ref.read(soundServiceProvider).play(Sfx.coin);
      } on GardenException catch (e) {
        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    }

    return Stack(
      children: [
        Positioned.fill(
          child: CustomPaint(
            painter: GardenScenePainter(hour: now.hour + now.minute / 60, envId: env.id, silhouette: true),
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 120, 24, 100),
            child: Material(
              color: theme.colorScheme.surface.withValues(alpha: 0.94),
              borderRadius: BorderRadius.circular(32),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(env.emoji, style: const TextStyle(fontSize: 48)),
                    const SizedBox(height: 8),
                    Text(env.name, style: theme.textTheme.titleLarge),
                    const SizedBox(height: 4),
                    Text(env.description, textAlign: TextAlign.center, style: theme.textTheme.bodyMedium),
                    const SizedBox(height: 14),
                    Text('What grows here', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 6),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        for (final s in grows)
                          Chip(
                            visualDensity: VisualDensity.compact,
                            label: Text('${s.fruit.emoji} ${s.name}${s.rarity == Rarity.rare ? ' ✨' : ''}'),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: canAfford ? unlock : null,
                      icon: const Text('🪙'),
                      label: Text(canAfford ? 'Unlock for ${env.price}' : '${env.price} coins to unlock'),
                    ),
                    if (!canAfford)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'Sell fruit from your garden to save up. ${env.price - coins} to go.',
                          style: theme.textTheme.bodySmall,
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
