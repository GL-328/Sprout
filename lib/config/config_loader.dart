import 'package:flutter/services.dart';

import 'game_config.dart';

const gameConfigAsset = 'assets/config/game_config.yaml';

/// Loads and validates the bundled game config.
Future<GameConfig> loadGameConfig([AssetBundle? bundle]) async {
  final source = await (bundle ?? rootBundle).loadString(gameConfigAsset);
  final config = GameConfig.parse(source);
  final problems = config.validate();
  if (problems.isNotEmpty) {
    throw StateError('game_config.yaml has problems:\n- ${problems.join('\n- ')}');
  }
  return config;
}
