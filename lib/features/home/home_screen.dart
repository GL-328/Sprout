import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../config/game_config.dart';
import '../../core/greeting.dart';
import '../../core/haptics.dart';
import '../../core/providers.dart';
import '../../core/sound_service.dart';
import '../../domain/logic/growth.dart';
import '../../domain/logic/seasons.dart';
import '../../domain/logic/visitors.dart';
import '../../domain/models/plant.dart';
import '../../ui/art/scene_painter.dart';
import '../../ui/widgets/fly_to_counter.dart';
import '../../ui/widgets/gentle_motion.dart';
import '../../ui/widgets/motion.dart';
import '../shop/visitor_sheet.dart';
import '../today/today_providers.dart';
import 'bag_sheet.dart';
import 'garden_providers.dart';
import 'plant_carousel.dart';
import 'plant_sheet.dart';
import 'plot_picker.dart';
import 'quests_panel.dart';
import 'seed_sheets.dart';

/// Height of the floating navigation bar, including its margin.
const _navBarSpace = 92.0;

/// The garden: one plot, one plant at a time, with today's quests below.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with SingleTickerProviderStateMixin {
  final _slots = PageController(viewportFraction: PlantCarousel.viewportFraction);
  late final _ambient = AnimationController(vsync: this, duration: const Duration(seconds: 24));
  String? _envId;
  int _slot = 0;
  double? _panelExtent;
  final Set<String> _recorded = {};
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
    _slots.dispose();
    _ambient.dispose();
    _lifecycle.dispose();
    super.dispose();
  }

  Future<void> _tapPlant(Plant plant, Offset globalPos) async {
    final config = ref.read(gameConfigProvider);
    final species = config.speciesById(plant.speciesId);
    final status = Growth.status(
      species,
      plantedAt: plant.plantedAt,
      fruitAnchor: plant.fruitAnchorAt,
      now: ref.read(clockProvider).now(),
    );
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
      target: CounterTargets.bag,
      emoji: species.fruit.emoji,
      count: math.min(result.fruit, 8),
      reduceMotion: reduceMotion(context, ref),
    );
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('Picked ${result.fruit} ${species.fruit.name} ${species.fruit.emoji}')));
  }

  Future<void> _pickPlot(String current) async {
    final picked = await showPlotPicker(context, current: current);
    if (picked != null && picked != current && mounted) {
      setState(() {
        _envId = picked;
        _slot = 0;
      });
      if (_slots.hasClients) _slots.jumpToPage(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Garden ambience plays only while Home is the visible tab.
    ref.read(soundServiceProvider).setAmbient(TickerMode.valuesOf(context).enabled && _foreground);
    final calm = reduceMotion(context, ref);
    if (calm) {
      if (_ambient.isAnimating) _ambient.stop();
    } else if (!_ambient.isAnimating) {
      _ambient.repeat();
    }

    final config = ref.watch(gameConfigProvider);
    final plots = ref.watch(plotsProvider).value ?? const <String, DateTime>{};
    final now = ref.watch(nowProvider).value ?? ref.watch(clockProvider).now();
    final name = ref.watch(settingsProvider.select((s) => s.name));
    final envId = _envId != null && plots.containsKey(_envId) ? _envId! : config.startingEnvironment.id;
    final env = config.environment(envId);
    final unlockedAt = plots[envId] ?? now;
    final season = seasonFor(unlockedAt: unlockedAt, now: now, daysPerSeason: config.daysPerSeason);
    final plants = ref.watch(plantsInPlotProvider(envId)).value ?? const <Plant>[];
    final mood = ref.watch(todayMoodProvider).value?.value;
    final placed = (ref.watch(placedCosmeticsProvider).value ?? const {})[envId] ?? const <String, String>{};
    final hour = now.hour + now.minute / 60;
    final isNight = hour < 6 || hour >= 20;
    final onScene = isNight ? Colors.white : const Color(0xFF3B3346);

    final statuses = {
      for (final p in plants)
        p.id: Growth.status(
          config.speciesById(p.speciesId),
          plantedAt: p.plantedAt,
          fruitAnchor: p.fruitAnchorAt,
          now: now,
        ),
    };
    final visitors = visitorsPresent(
      config,
      VisitorContext(
        envId: envId,
        maturePlants: statuses.values.where((s) => s.isMature).length,
        streakDays: ref.watch(streakProvider),
        isNight: isNight,
        lureActive: ref.watch(visitorLureProvider).value ?? false,
      ),
      visitorSeed(envId, now),
    );
    final fresh = visitors.map((v) => v.id).where((id) => !_recorded.contains(id)).toList();
    if (fresh.isNotEmpty) {
      _recorded.addAll(fresh);
      WidgetsBinding.instance.addPostFrameCallback((_) => ref.read(economyServiceProvider).recordVisitors(fresh));
    }

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, box) {
          final h = box.maxHeight;
          final w = box.maxWidth;
          final safeTop = MediaQuery.paddingOf(context).top;
          final bottomInset = _navBarSpace + MediaQuery.paddingOf(context).bottom;
          // The panel's sizes, as fractions of the screen. Collapsed shows the
          // meter and about three quests, but never more than 42% of the screen.
          final minExtent = ((bottomInset + 58) / h).clamp(0.08, 0.3);
          final initialExtent = ((bottomInset + 250) / h).clamp(minExtent, 0.42);
          const maxExtent = 0.78;
          final extent = (_panelExtent ?? initialExtent).clamp(minExtent, maxExtent);
          // Above about half the screen the panel is for reading quests, and
          // the garden simply waits behind it.
          final panelTop = h * (1 - math.min(extent, 0.5));
          final headerBottom = safeTop + 104;
          final gardenBottom = panelTop - 12;
          final sceneHeight = math.max(gardenBottom / 0.86, panelTop + 40);

          return AnimatedBuilder(
            animation: _ambient,
            builder: (context, _) {
              final phase = calm ? 0.0 : _ambient.value;
              final sway = calm ? 0.0 : math.sin(phase * 2 * math.pi * 6);
              final pulse = calm ? 0.5 : 0.5 + 0.5 * math.sin(phase * 2 * math.pi * 10);
              return Stack(
                children: [
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 0,
                    height: sceneHeight,
                    child: CustomPaint(
                      painter: GardenScenePainter(
                        hour: hour,
                        envId: envId,
                        season: season,
                        weather: weatherForMood(mood),
                        skyTheme: placed['background'],
                        phase: phase,
                      ),
                    ),
                  ),
                  ..._cosmetics(config, placed, w, sceneHeight),
                  for (final (i, v) in visitors.indexed) _visitor(v, i, phase, w, headerBottom, gardenBottom),
                  Positioned(
                    left: 0,
                    right: 0,
                    top: headerBottom,
                    height: math.max(0, gardenBottom - headerBottom),
                    child: PlantCarousel(
                      controller: _slots,
                      config: config,
                      env: env,
                      plants: plants,
                      statuses: statuses,
                      page: _slot,
                      sway: sway,
                      pulse: pulse,
                      reduceMotion: calm,
                      onPageChanged: (i) {
                        Haptics.selection();
                        setState(() => _slot = i);
                      },
                      onTapEmpty: (i) => showChooseSeedSheet(context, envId: envId, slot: i),
                      onTapPlant: _tapPlant,
                    ),
                  ),
                  Positioned(
                    left: 16,
                    right: 16,
                    top: safeTop + 8,
                    child: _Header(
                      greeting: greetingFor(now, name),
                      plotLabel: '${env.emoji} ${env.name}',
                      color: onScene,
                      onPlotTap: () => _pickPlot(envId),
                    ),
                  ),
                  NotificationListener<DraggableScrollableNotification>(
                    onNotification: (n) {
                      setState(() => _panelExtent = n.extent);
                      return false;
                    },
                    child: DraggableScrollableSheet(
                      initialChildSize: initialExtent,
                      minChildSize: minExtent,
                      maxChildSize: maxExtent,
                      snap: true,
                      snapSizes: [initialExtent],
                      builder: (context, scroll) => QuestsPanel(scrollController: scroll, bottomInset: bottomInset),
                    ),
                  ),
                ],
              );
            },
          );
        },
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
      at('fence', 0.05, 0.74, 30),
      at('fence', 0.95, 0.74, 30),
      at('lantern', 0.06, 0.64, 26),
      at('lantern', 0.94, 0.64, 26),
      at('pond', 0.88, 0.86, 34),
      at('bench', 0.12, 0.86, 32),
      at('path', 0.5, 0.92, 28),
    ];
  }

  /// Visitors keep to the edges and the sky, so they never cover the plant.
  Widget _visitor(VisitorConfig v, int i, double phase, double w, double top, double bottom) {
    const flyers = {'butterfly', 'bee', 'songbird', 'firefly', 'parrot', 'owl', 'ladybird'};
    final flies = flyers.contains(v.id);
    final t = (phase * (flies ? 2 : 1) + i * 0.37) % 1;
    final left = i.isEven;
    final x = left ? 0.03 + 0.07 * math.sin(t * 2 * math.pi).abs() : 0.88 + 0.07 * math.sin(t * 2 * math.pi).abs();
    final y = flies ? top + 12 + 30 * math.sin(t * 4 * math.pi + i).abs() + i * 26 : bottom - 70 - i * 8;
    return Positioned(
      left: w * x,
      top: y,
      child: Semantics(
        button: true,
        label: '${v.name} visiting',
        child: GestureDetector(
          onTap: () => showVisitorSheet(context, v),
          child: Text(v.emoji, style: const TextStyle(fontSize: 28)),
        ),
      ),
    );
  }
}

/// Coins, the Bag, a short greeting and the plot name. Nothing else.
class _Header extends ConsumerWidget {
  const _Header({required this.greeting, required this.plotLabel, required this.color, required this.onPlotTap});

  final String greeting;
  final String plotLabel;
  final Color color;
  final VoidCallback onPlotTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final coins = ref.watch(coinsProvider).value ?? 0;
    final seeds = ref.watch(seedBagProvider).value?.length ?? 0;
    final fruit = (ref.watch(inventoryProvider).value ?? const {}).values.fold(0, (a, b) => a + b);
    final inBag = seeds + fruit;
    const ink = Color(0xFF3B3346);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _Frosted(
              key: CounterTargets.coins,
              label: '$coins coins',
              onTap: () => context.go('/shop'),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Row(
                  children: [
                    const Text('🪙', style: TextStyle(fontSize: 15)),
                    const SizedBox(width: 5),
                    AnimatedCount(
                      value: coins,
                      enabled: !reduceMotion(context, ref),
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: ink),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            Badge(
              isLabelVisible: inBag > 0,
              label: Text('$inBag'),
              backgroundColor: const Color(0xFFF59E7A),
              child: _Frosted(
                key: CounterTargets.bag,
                label: 'Bag, $seeds seeds and $fruit fruit',
                circle: true,
                onTap: () => showBagSheet(context),
                child: const Padding(
                  padding: EdgeInsets.all(9),
                  child: Text('🎒', style: TextStyle(fontSize: 18)),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          greeting,
          style: theme.textTheme.titleMedium?.copyWith(color: color, fontWeight: FontWeight.w800),
        ),
        Semantics(
          button: true,
          label: 'Change plot, now $plotLabel',
          child: InkWell(
            borderRadius: BorderRadius.circular(100),
            onTap: onPlotTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(plotLabel, style: theme.textTheme.bodySmall?.copyWith(color: color.withValues(alpha: 0.75))),
                  Icon(Icons.expand_more_rounded, size: 16, color: color.withValues(alpha: 0.75)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// A small, soft, see-through pill.
class _Frosted extends StatelessWidget {
  const _Frosted({super.key, required this.child, required this.onTap, required this.label, this.circle = false});

  final Widget child;
  final VoidCallback onTap;
  final String label;
  final bool circle;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(100);
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      onTap: onTap,
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Material(
            color: Colors.white.withValues(alpha: 0.55),
            shape: circle ? const CircleBorder() : RoundedRectangleBorder(borderRadius: radius),
            child: InkWell(onTap: onTap, child: child),
          ),
        ),
      ),
    );
  }
}
