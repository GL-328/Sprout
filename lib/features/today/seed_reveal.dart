import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../domain/models/seed.dart';
import '../../ui/art/plant_art_provider.dart';
import '../../ui/theme/category_style.dart';
import '../../ui/widgets/motion.dart';

/// The "You earned a seed!" moment.
Future<void> showSeedReveal(BuildContext context, Seed seed, {String title = 'You earned a seed!'}) =>
    showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Close',
      barrierColor: Colors.black.withValues(alpha: 0.45),
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, a1, a2) => _SeedReveal(seed: seed, title: title),
    );

class _SeedReveal extends ConsumerStatefulWidget {
  const _SeedReveal({required this.seed, required this.title});

  final Seed seed;
  final String title;

  @override
  ConsumerState<_SeedReveal> createState() => _SeedRevealState();
}

class _SeedRevealState extends ConsumerState<_SeedReveal> with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (reduceMotion(context, ref)) {
      _controller.value = 1;
    } else if (!_controller.isAnimating && _controller.value == 0) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final config = ref.watch(gameConfigProvider);
    final species = config.speciesById(widget.seed.speciesId);
    final family = config.families[species.family];
    final unlocked = ref.watch(_unlockedProvider).value ?? const <String>{};
    final canPlant = species.environments.any(unlocked.contains);
    final home = config.environments.firstWhere((e) => species.environments.contains(e.id));

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.all(28),
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
          decoration: BoxDecoration(color: theme.colorScheme.surface, borderRadius: BorderRadius.circular(32)),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final t = _controller.value;
              final pop = Curves.elasticOut.transform((t * 1.3).clamp(0, 1));
              final wobble = math.sin(t * math.pi * 6) * (1 - t) * 0.25;
              final textIn = Curves.easeOut.transform(((t - 0.45) / 0.55).clamp(0, 1));
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(widget.title, style: theme.textTheme.headlineSmall, textAlign: TextAlign.center),
                  const SizedBox(height: 24),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 150 * pop,
                        height: 150 * pop,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: rarityColor(species.rarity).withValues(alpha: 0.25),
                        ),
                      ),
                      Transform.rotate(
                        angle: wobble,
                        child: Transform.scale(
                          scale: 0.2 + 0.8 * pop,
                          child: plantArtProvider.seed(species, size: 110),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Opacity(
                    opacity: textIn,
                    child: Column(
                      children: [
                        Text(species.name, style: theme.textTheme.titleLarge),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          alignment: WrapAlignment.center,
                          children: [
                            Chip(
                              label: Text(species.rarity.label),
                              backgroundColor: rarityColor(species.rarity).withValues(alpha: 0.3),
                            ),
                            if (family != null) Chip(label: Text('${family.emoji} ${family.name}')),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          canPlant
                              ? "It's waiting in your Seed Bag, ready to plant."
                              : 'This one would love a ${home.name} plot. It will wait in your Seed Bag until then.',
                          style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Lovely')),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

final _unlockedProvider = StreamProvider<Set<String>>(
  (ref) => ref.watch(seedRepositoryProvider).watchUnlockedEnvironments(),
);
