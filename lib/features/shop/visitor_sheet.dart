import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/game_config.dart';
import '../../core/haptics.dart';
import '../../core/providers.dart';
import '../../core/sound_service.dart';
import '../home/garden_providers.dart';

Future<void> showVisitorSheet(BuildContext context, VisitorConfig visitor) => showModalBottomSheet<void>(
  useRootNavigator: true,
  context: context,
  useSafeArea: true,
  builder: (_) => _VisitorSheet(visitor: visitor),
);

class _VisitorSheet extends ConsumerWidget {
  const _VisitorSheet({required this.visitor});

  final VisitorConfig visitor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final config = ref.watch(gameConfigProvider);
    final favourite = config.speciesById(visitor.favouriteFruit);
    final have = (ref.watch(inventoryProvider).value ?? const {})[favourite.id] ?? 0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(visitor.emoji, style: const TextStyle(fontSize: 64)),
          const SizedBox(height: 8),
          Text('A ${visitor.name.toLowerCase()} came to visit!', style: theme.textTheme.titleLarge),
          const SizedBox(height: 6),
          Text(
            'It loves ${favourite.fruit.emoji} ${favourite.fruit.name.toLowerCase()}. '
            'It\'s now in your Journal.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: have > 0
                ? () async {
                    final coins = await ref.read(economyServiceProvider).feedVisitor(visitor.id);
                    Haptics.medium();
                    ref.read(soundServiceProvider).play(Sfx.coin);
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('The ${visitor.name.toLowerCase()} left you $coins coins as thanks 🪙')),
                      );
                    }
                  }
                : null,
            child: Text(
              have > 0
                  ? 'Share a ${favourite.fruit.name.toLowerCase()} ($have)'
                  : 'No ${favourite.fruit.name.toLowerCase()} yet',
            ),
          ),
        ],
      ),
    );
  }
}
