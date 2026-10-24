import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers.dart';
import 'garden_providers.dart';
import '../../ui/layout/insets.dart';
import '../../ui/art/icon_art.dart';

/// A small sheet for switching plots. Locked plots point to the Shop.
Future<String?> showPlotPicker(BuildContext context, {required String current}) => showSproutSheet<String>(
  context,
  builder: (sheet) => Consumer(
    builder: (sheet, ref, _) {
      final theme = Theme.of(sheet);
      final config = ref.watch(gameConfigProvider);
      final plots = ref.watch(plotsProvider).value ?? const {};
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
                    leading: ArtIcon('plot:${env.id}', size: 36),
                    title: Text(env.name),
                    trailing: plots.containsKey(env.id)
                        ? (env.id == current ? const Icon(Icons.check_rounded) : null)
                        : IconText('{coin} ${env.price}', style: theme.textTheme.labelLarge),
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
        ),
      );
    },
  ),
);
