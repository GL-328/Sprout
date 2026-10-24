import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/haptics.dart';
import '../../core/providers.dart';
import '../../core/sound_service.dart';
import '../../ui/widgets/fly_to_counter.dart';
import '../../ui/widgets/motion.dart';
import '../home/garden_providers.dart';
import '../../ui/layout/insets.dart';
import '../../ui/art/icon_art.dart';

Future<void> showBasketSheet(BuildContext context) =>
    showSproutSheet<void>(context, heightFactor: 0.7, builder: (_) => const FruitBasket());

/// The fruit you've picked, with buttons to sell it.
class FruitBasket extends ConsumerWidget {
  const FruitBasket({super.key, this.embedded = false});

  /// When shown inside the Shop rather than a sheet.
  final bool embedded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final config = ref.watch(gameConfigProvider);
    final inventory = ref.watch(inventoryProvider).value ?? const <String, int>{};
    final items = inventory.entries.where((e) => config.species.containsKey(e.key)).toList()
      ..sort((a, b) => config.speciesById(a.key).name.compareTo(config.speciesById(b.key).name));
    final total = items.fold(0, (sum, e) => sum + e.value * config.speciesById(e.key).fruit.sellPrice);

    Future<void> sell(String speciesId, int qty, Offset from) async {
      final coins = await ref.read(economyServiceProvider).sellFruit(speciesId, qty);
      Haptics.medium();
      ref.read(soundServiceProvider).play(Sfx.coin);
      if (!context.mounted) return;
      flyToCounter(
        context,
        from: from,
        target: CounterTargets.coins,
        icon: 'coin',
        count: qty.clamp(3, 8),
        reduceMotion: reduceMotion(context, ref),
      );
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: IconText('Sold for {coin} $coins')));
    }

    final list = <Widget>[
      if (!embedded) ...[
        Text('Fruit basket', style: theme.textTheme.titleLarge),
        const SizedBox(height: 4),
        Text(
          'Sell fruit for coins, or keep it for recipes and visitors.',
          style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 16),
      ],
      if (items.isEmpty)
        const Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: Text('Nothing picked yet. Tap a plant with fruit to harvest it.')),
        ),
      for (final e in items)
        Builder(
          builder: (tileContext) {
            final s = config.speciesById(e.key);
            Offset origin() {
              final box = tileContext.findRenderObject() as RenderBox?;
              return box == null ? Offset.zero : box.localToGlobal(box.size.centerRight(const Offset(-60, 0)));
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Material(
                color: theme.colorScheme.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
                child: ListTile(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  leading: ArtIcon('fruit:${s.id}', size: 38),
                  title: Text('${s.fruit.name} ×${e.value}', style: theme.textTheme.titleMedium),
                  subtitle: Text('${s.fruit.sellPrice} coins each'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton(onPressed: () => sell(e.key, 1, origin()), child: const Text('Sell 1')),
                      if (e.value > 1)
                        FilledButton.tonal(onPressed: () => sell(e.key, e.value, origin()), child: const Text('All')),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      if (items.length > 1)
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: OutlinedButton(
            onPressed: () async {
              for (final e in items) {
                await ref.read(economyServiceProvider).sellFruit(e.key, e.value);
              }
              Haptics.medium();
              ref.read(soundServiceProvider).play(Sfx.coin);
              if (context.mounted) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: IconText('Sold everything for {coin} $total')));
              }
            },
            child: Text('Sell everything for $total coins'),
          ),
        ),
    ];

    if (embedded) return Column(children: list);
    return ListView(padding: AppInsets.list(context, top: 0), children: list);
  }
}
