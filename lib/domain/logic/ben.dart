import 'dart:math';

/// Kinds of things Ben the shopkeeper says.
enum BenLineType { fact, greeting, tip, encourage, buy, sell, compost, unlock, noCoins }

BenLineType? _typeFromId(String id) => switch (id) {
  'fact' => BenLineType.fact,
  'greeting' => BenLineType.greeting,
  'tip' => BenLineType.tip,
  'encourage' => BenLineType.encourage,
  'buy' => BenLineType.buy,
  'sell' => BenLineType.sell,
  'compost' => BenLineType.compost,
  'unlock' => BenLineType.unlock,
  'no_coins' => BenLineType.noCoins,
  _ => null,
};

/// Ben's lines from `assets/content/ben_lines.json`, grouped by type.
class BenLines {
  const BenLines(this.byType);

  factory BenLines.fromJson(Map<String, dynamic> json) {
    final byType = <BenLineType, List<String>>{};
    for (final entry in (json['lines'] as List).whereType<Map>()) {
      final type = _typeFromId(entry['type'] as String? ?? '');
      final text = (entry['text'] as String? ?? '').trim();
      if (type != null && text.isNotEmpty) (byType[type] ??= []).add(text);
    }
    return BenLines(byType);
  }

  final Map<BenLineType, List<String>> byType;

  List<String> of(BenLineType type) => byType[type] ?? const [];

  /// The fun fact for [day]. The same all day, a new one after midnight.
  String factOfTheDay(DateTime day) {
    final facts = of(BenLineType.fact);
    if (facts.isEmpty) return 'Hello! Lovely to see you.';
    final dayNumber = DateTime.utc(day.year, day.month, day.day).millisecondsSinceEpoch ~/ Duration.millisecondsPerDay;
    return facts[dayNumber % facts.length];
  }

  /// A random line of one of [types], never the same as [previous].
  String pick(List<BenLineType> types, Random random, {String? previous}) {
    final pool = [for (final t in types) ...of(t)].where((l) => l != previous).toList();
    if (pool.isEmpty) return previous ?? '';
    return pool[random.nextInt(pool.length)];
  }

  /// What Ben says when tapped: a greeting, a tip or some encouragement.
  String chat(Random random, {String? previous}) =>
      pick(const [BenLineType.greeting, BenLineType.tip, BenLineType.encourage], random, previous: previous);
}
