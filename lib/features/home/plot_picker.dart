import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers.dart';
import 'garden_providers.dart';

/// A small sheet for switching plots. Locked plots point to the Shop.
Future<String?> showPlotPicker(BuildContext context, {required String current}) => showModalBottomSheet<String>(
  context: context,
  useRootNavigator: true,
  builder: (sheet) => Consumer(
    builder: (sheet, ref, _) {
      final theme = Theme.of(sheet);
      final config = ref.watch(gameConfigProvider);
      final plots = ref.watch(plotsProvider).value ?? const {};
      return SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
              child: Text('Your plots', style: theme.textTheme.titleLarge),
            ),
            for (final env in config.environments)
              Opacity(
                opacity: plots.containsKey(env.id) ? 1 : 0.55,
                child: ListTile(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  selected: env.id == current,
                  leading: Text(env.emoji, style: const TextStyle(fontSize: 26)),
                  title: Text(env.name),
                  trailing: plots.containsKey(env.id)
                      ? (env.id == current ? const Icon(Icons.check_rounded) : null)
                      : Text('🪙 ${env.price}', style: theme.textTheme.labelLarge),
                  onTap: () {
                    if (plots.containsKey(env.id)) {
                      Navigator.pop(sheet, env.id);
                    } else {
                      Navigator.pop(sheet);
                      context.go('/shop');
                    }
                  },
                ),
              ),
          ],
        ),
      );
    },
  ),
);
