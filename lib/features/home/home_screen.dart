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
import '../friends/friends_controller.dart';
import '../friends/friends_screen.dart';
import 'garden_providers.dart';
import 'plant_carousel.dart';
import 'plant_sheet.dart';
import 'plot_picker.dart';
import 'quests_panel.dart';
import 'seed_sheets.dart';
import '../../ui/art/icon_art.dart';
import '../../ui/layout/insets.dart';
import '../../ui/widgets/measure_size.dart';
import 'home_tutorial.dart';

/// The garden: one plot, one plant at a time, with today's quests below.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with SingleTickerProviderStateMixin {
  /// The carousel opens on the middle spot, so there's a plant to either side.
  late final _slots = PageController(viewportFraction: PlantCarousel.viewportFraction, initialPage: _slot);
  late final _ambient = AnimationController(vsync: this, duration: const Duration(seconds: 24));
  String? _envId;
  late int _slot = ref.read(gameConfigProvider).startingEnvironment.slots ~/ 2;

  /// Measured heights of the header and the quests panel, so the garden
  /// always fits between them, at any text size. Estimates until measured.
  double _headerH = 104;
  double _panelH = 260;

  /// Quest rows in the panel: two, or fewer when the screen is too short
  /// for the garden to keep [_minGarden] of room.
  int _rows = QuestsPanel.defaultShown;
  double _rowH = 64;
  double _screenH = 0;
  double _headerBottom = 0;
  static const _minGarden = 120.0;

  /// Whether the first-run tips fit above the panel (see [_panelMeasured]
  /// for what gives way first when space is short).
  bool _tipsFit = true;

  void _panelMeasured(Size s) {
    if (!mounted || s.height == _panelH) return;
    setState(() {
      final previous = _panelH;
      _panelH = s.height;
      final garden = _screenH - _panelH - 8 - _headerBottom;
      final tipsShowing = _tipsFit && !(ref.read(tutorialDoneProvider).value ?? true);
      // When space is short: first drop to one quest row, then set the
      // first-run tips aside, then drop the last row.
      if (garden < _minGarden && _rows > 1) {
        _rows--;
      } else if (garden < _minGarden && tipsShowing) {
        _tipsFit = false;
      } else if (garden < _minGarden && _rows > 0) {
        _rows--;
      } else if (garden > _minGarden + _rowH * 1.2 && _rows < QuestsPanel.defaultShown) {
        _rows++;
      }
      if (previous > _panelH && previous - _panelH > 30) _rowH = previous - _panelH;
    });
  }

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
      icon: 'fruit:${species.id}',
      count: math.min(result.fruit, 8),
      reduceMotion: reduceMotion(context, ref),
    );
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: IconText('Picked ${result.fruit} ${species.fruit.name} {fruit:${species.id}}')));
  }

  Future<void> _pickPlot(String current) async {
    final picked = await showPlotPicker(context, current: current);
    if (picked != null && picked != current && mounted) {
      final middle = ref.read(gameConfigProvider).environment(picked).slots ~/ 2;
      setState(() {
        _envId = picked;
        _slot = middle;
      });
      if (_slots.hasClients) _slots.jumpToPage(middle);
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
    // A friend visited today: a butterfly always comes by too.
    final butterfly = config.visitors['butterfly'];
    if (butterfly != null &&
        (ref.watch(visitsTodayProvider).value ?? const []).isNotEmpty &&
        !visitors.any((v) => v.id == butterfly.id)) {
      visitors.insert(0, butterfly);
    }
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
          // The panel ends behind the floating nav bar; its content stays above
          // the nav bar and the system bar.
          final bottomInset = AppInsets.covered(context);
          final panelTop = h - _panelH;
          final headerBottom = safeTop + 8 + _headerH + 6;
          // Never let the garden leave the screen, even when the panel is tall.
          final gardenBottom = math.max(panelTop - 8, safeTop + 88);
          _screenH = h;
          _headerBottom = headerBottom;
          // Always leave the plant some room, even on very short screens.
          final gardenTop = math.min(headerBottom, gardenBottom - 72);
          // The ground sits just under the plants; the panel covers the rest.
          final sceneHeight = math.max(gardenBottom / 0.86, panelTop + 40);

          return AnimatedBuilder(
            animation: _ambient,
            builder: (context, _) {
              final phase = calm ? 0.0 : _ambient.value;
              final sway = calm ? 0.0 : math.sin(phase * 2 * math.pi * 6);
              final pulse = calm ? 0.5 : 0.5 + 0.5 * math.sin(phase * 2 * math.pi * 10);
              final carousel = Positioned(
                left: 0,
                right: 0,
                top: gardenTop,
                height: gardenBottom - gardenTop,
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
                  night: isNight,
                  onPageChanged: (i) {
                    Haptics.selection();
                    setState(() => _slot = i);
                  },
                  onTapEmpty: (i) => showChooseSeedSheet(context, envId: envId, slot: i),
                  onTapPlant: _tapPlant,
                ),
              );
              final header = Positioned(
                left: 16,
                right: 16,
                top: safeTop + 8,
                child: MeasureSize(
                  onChange: (s) {
                    if (mounted && s.height != _headerH) setState(() => _headerH = s.height);
                  },
                  child: _Header(
                    greeting: greetingFor(now, name),
                    plotLabel: '{plot:${env.id}} ${env.name}',
                    color: onScene,
                    onPlotTap: () => _pickPlot(envId),
                  ),
                ),
              );
              return Stack(
                // Fill the screen: every layer is positioned against it.
                fit: StackFit.expand,
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
                  ..._cosmetics(config, placed, Size(w, sceneHeight), gardenBottom),
                  for (final (i, v) in visitors.indexed) _visitor(v, i, phase, w, headerBottom, gardenBottom),
                  // The header normally sits on top. On very short screens the
                  // plant overlaps it, and then the plant comes first so it stays tappable.
                  if (gardenTop >= headerBottom) ...[carousel, header] else ...[header, carousel],
                  // The quests panel, with first-run tips just above it. Both
                  // are measured, so the garden always fits above them and
                  // nothing covers the plant.
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: MeasureSize(
                      onChange: _panelMeasured,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // First-run tips, on screens tall enough to have room for them.
                          if (h >= 480 && _tipsFit)
                            const Padding(padding: EdgeInsets.fromLTRB(16, 0, 16, 8), child: HomeTutorial()),
                          QuestsPanel(bottomInset: bottomInset, shown: _rows),
                        ],
                      ),
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

  /// Placed decorations, standing on the ground and always above the quests
  /// panel. [depth] is how far in front of the ground's edge each one stands.
  List<Widget> _cosmetics(GameConfig config, Map<String, String> placed, Size scene, double gardenBottom) {
    Widget at(String kind, double x, double depth, double size) {
      final c = config.cosmetics[placed[kind]];
      if (c == null) return const SizedBox.shrink();
      final ground = GardenScenePainter.groundTop(scene, scene.width * x);
      final bottom = math.min(ground + depth, gardenBottom - 2);
      return Positioned(
        left: scene.width * x - size / 2,
        top: bottom - size,
        child: IgnorePointer(
          child: ArtIcon('cosmetic:${c.id}', key: ValueKey('decor-$kind-$x'), size: size),
        ),
      );
    }

    return [
      at('lantern', 0.15, 6, 36),
      at('lantern', 0.85, 6, 36),
      at('fence', 0.06, 14, 40),
      at('fence', 0.94, 14, 40),
      at('bench', 0.2, 34, 40),
      at('pond', 0.8, 40, 44),
      at('path', 0.3, 64, 36),
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
        child: GestureDetector(onTap: () => showVisitorSheet(context, v), child: ArtIcon('visitor:${v.id}', size: 36)),
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
                    const ArtIcon('coin', size: 20),
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
            if (ref.watch(friendsProvider.select((s) => s.on))) ...[
              Badge(
                isLabelVisible: (ref.watch(incomingRequestsProvider).value ?? const []).isNotEmpty,
                smallSize: 10,
                backgroundColor: const Color(0xFFF59E7A),
                child: _Frosted(
                  label: 'Friends',
                  circle: true,
                  onTap: () => pushPage(context, const FriendsScreen()),
                  child: const Padding(
                    padding: EdgeInsets.all(9),
                    child: Icon(Icons.people_alt_rounded, size: 24, color: ink),
                  ),
                ),
              ),
              const SizedBox(width: 10),
            ],
            Badge(
              isLabelVisible: inBag > 0,
              label: Text('$inBag'),
              backgroundColor: const Color(0xFFF59E7A),
              child: _Frosted(
                key: CounterTargets.bag,
                label: 'Bag, $seeds seeds and $fruit fruit',
                circle: true,
                onTap: () => showBagSheet(context),
                child: const Padding(padding: EdgeInsets.all(9), child: ArtIcon('bag', size: 24)),
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
          label: 'Change plot, now ${IconText.plain(plotLabel)}',
          child: InkWell(
            borderRadius: BorderRadius.circular(100),
            onTap: onPlotTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconText(plotLabel, style: theme.textTheme.bodySmall?.copyWith(color: color.withValues(alpha: 0.75))),
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
