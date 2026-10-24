import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../domain/logic/friends.dart';
import '../../domain/logic/seasons.dart';
import '../../ui/art/icon_art.dart';
import '../../ui/art/plant_art_provider.dart';
import '../../ui/art/scene_painter.dart';
import '../../ui/layout/insets.dart';
import 'friends_backend.dart';

/// "When did they last share?", gently.
String lastUpdatedText(DateTime? at, DateTime now) {
  if (at == null) return 'Shared a little while ago';
  final ago = now.difference(at);
  if (ago.inMinutes < 2) return 'Updated just now';
  if (ago.inHours < 1) return 'Updated ${ago.inMinutes} minutes ago';
  if (ago.inDays < 1) return 'Updated ${ago.inHours} hour${ago.inHours == 1 ? '' : 's'} ago';
  return 'Updated ${ago.inDays} day${ago.inDays == 1 ? '' : 's'} ago';
}

/// A friend's garden, to look at. Nothing here can be changed or picked.
class VisitScreen extends ConsumerStatefulWidget {
  const VisitScreen({super.key, required this.name, required this.garden});

  final String name;
  final FriendGarden garden;

  @override
  ConsumerState<VisitScreen> createState() => _VisitScreenState();
}

class _VisitScreenState extends ConsumerState<VisitScreen> {
  int _plot = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final config = ref.watch(gameConfigProvider);
    final now = ref.watch(clockProvider).now();
    final plots = [
      for (final p in widget.garden.snapshot.plots)
        if (config.environments.any((e) => e.id == p.env)) p,
    ];
    final plot = plots.isEmpty ? null : plots[_plot.clamp(0, plots.length - 1)];
    final env = plot == null ? config.startingEnvironment : config.environment(plot.env);
    final hour = now.hour + now.minute / 60;

    return Scaffold(
      appBar: AppBar(title: Text("${widget.name}'s garden")),
      body: Column(
        children: [
          if (plots.length > 1)
            SizedBox(
              height: 52,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                children: [
                  for (final (i, p) in plots.indexed)
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ChoiceChip(
                        avatar: ArtIcon('plot:${p.env}', size: 20),
                        label: Text(config.environment(p.env).name),
                        selected: i == _plot,
                        onSelected: (_) => setState(() => _plot = i),
                      ),
                    ),
                ],
              ),
            ),
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                CustomPaint(
                  painter: GardenScenePainter(hour: hour, envId: env.id, season: Season.summer),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(8, 24, 8, AppInsets.system(context) + 96),
                  child: LayoutBuilder(
                    builder: (context, box) {
                      final count = env.slots;
                      final size = (box.maxWidth / (count < 3 ? 2.2 : 3.2)).clamp(80.0, 180.0);
                      final bySlot = {for (final s in plot?.slots ?? const <SnapshotSlot>[]) s.slot: s};
                      return Align(
                        alignment: Alignment.bottomCenter,
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.end,
                          spacing: 8,
                          children: [
                            for (var i = 0; i < count; i++)
                              SizedBox(
                                width: size,
                                height: size * 1.2,
                                child: switch (bySlot[i]) {
                                  final s? when config.species.containsKey(s.species) => Semantics(
                                    label: '${config.speciesById(s.species).name}, ${s.stage.label}',
                                    child: plantArtProvider.plant(
                                      config.speciesById(s.species),
                                      s.stage,
                                      size: size,
                                      height: size * 1.2,
                                    ),
                                  ),
                                  _ => Align(
                                    alignment: Alignment.bottomCenter,
                                    child: plantArtProvider.groundSpot(size: size * 0.6),
                                  ),
                                },
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: AppInsets.system(context) + 12,
                  child: Center(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Their decorations, shown together so they never cover a plant.
                            if (plot != null && plot.decor.values.any(config.cosmetics.containsKey))
                              Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Wrap(
                                  spacing: 6,
                                  children: [
                                    for (final id in plot.decor.values)
                                      if (config.cosmetics.containsKey(id))
                                        ArtIcon('cosmetic:$id', size: 28, semanticLabel: config.cosmetics[id]!.name),
                                  ],
                                ),
                              ),
                            Text(
                              plots.isEmpty
                                  ? "${widget.name}'s garden is still getting ready."
                                  : '${lastUpdatedText(widget.garden.updatedAt, now)}. Just looking, nothing to tend.',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodySmall?.copyWith(color: const Color(0xFF3B3346)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
