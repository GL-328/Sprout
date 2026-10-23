import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/greeting.dart';
import '../../core/providers.dart';
import '../../ui/art/scene_painter.dart';

/// The garden. Stage 1 shows the Meadow backdrop and three empty slots.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final now = ref.watch(clockProvider).now();
    final name = ref.watch(settingsProvider.select((s) => s.name));
    final meadow = ref.watch(gameConfigProvider).startingEnvironment;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: GardenScenePainter(hour: now.hour + now.minute / 60, dark: theme.brightness == Brightness.dark),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    greetingFor(now, name),
                    style: theme.textTheme.headlineSmall?.copyWith(color: const Color(0xFF3B3346)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${meadow.emoji} ${meadow.name}',
                    style: theme.textTheme.titleMedium?.copyWith(color: const Color(0xFF5B5268)),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [for (var i = 0; i < meadow.slots; i++) const _EmptySlot()],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptySlot extends StatelessWidget {
  const _EmptySlot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 92,
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFF8B6B4E).withValues(alpha: 0.35),
        borderRadius: const BorderRadius.all(Radius.elliptical(92, 40)),
      ),
      alignment: Alignment.center,
      child: const Icon(Icons.add, color: Colors.white),
    );
  }
}
