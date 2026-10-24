enum Season {
  spring('Spring'),
  summer('Summer'),
  autumn('Autumn'),
  winter('Winter');

  const Season(this.label);

  final String label;

  /// The season's icon id (see icon_art.dart).
  String get icon => 'season:$name';
}

/// A plot's season, starting at spring the day it was unlocked and moving on
/// every [daysPerSeason] days.
Season seasonFor({required DateTime unlockedAt, required DateTime now, required int daysPerSeason}) {
  final days = now.difference(unlockedAt).inDays;
  final index = (days < 0 ? 0 : days ~/ daysPerSeason) % Season.values.length;
  return Season.values[index];
}
