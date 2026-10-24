import 'dart:math' as math;

import '../models/enums.dart';

/// Letters and digits for friend codes, without the easily confused
/// 0, O, 1 and I.
const friendCodeAlphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
const friendCodeLength = 8;

/// At most this many friends.
const maxFriends = 30;

/// At most this many friend requests a day.
const maxRequestsPerDay = 10;

/// Coins for your first visit to a friend's garden each day.
const visitRewardCoins = 3;

String generateFriendCode(math.Random random) => String.fromCharCodes(
  Iterable.generate(friendCodeLength, (_) {
    return friendCodeAlphabet.codeUnitAt(random.nextInt(friendCodeAlphabet.length));
  }),
);

/// Cleans up a typed code ("abcd-efgh", " ABCD EFGH ") or returns null if it
/// can't be a friend code.
String? normalizeFriendCode(String input) {
  final code = input.toUpperCase().replaceAll(RegExp(r'[\s\-_.]'), '');
  if (code.length != friendCodeLength) return null;
  for (final c in code.split('')) {
    if (!friendCodeAlphabet.contains(c)) return null;
  }
  return code;
}

/// "ABCDEFGH" shown as "ABCD-EFGH".
String formatFriendCode(String code) =>
    code.length == friendCodeLength ? '${code.substring(0, 4)}-${code.substring(4)}' : code;

/// A calendar day as "yyyymmdd", for once-a-day things.
String dayStamp(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}${d.month.toString().padLeft(2, '0')}${d.day.toString().padLeft(2, '0')}';

/// The id of one friend's visit on one day, so it can happen only once.
String visitId(String visitorUid, DateTime day) => '${visitorUid}_${dayStamp(day)}';

/// A small list of unkind words kept out of display names.
const _unkind = ['idiot', 'stupid', 'hate', 'kill', 'loser', 'dumb', 'ugly', 'shut up'];

/// Checks a display name. Returns the tidied name, or a gentle reason why
/// it can't be used.
({String? name, String? problem}) checkDisplayName(String input) {
  final name = input.trim().replaceAll(RegExp(r'\s+'), ' ');
  if (name.isEmpty) return (name: null, problem: 'Pick a name your friends will know.');
  if (name.length > 20) return (name: null, problem: 'Keep it to 20 characters or fewer.');
  if (!RegExp(r"^[\p{L}\p{N} .'_-]+$", unicode: true).hasMatch(name)) {
    return (name: null, problem: 'Letters, numbers and spaces only, please.');
  }
  final lower = name.toLowerCase();
  if (_unkind.any(lower.contains)) return (name: null, problem: "Let's pick a kinder name.");
  return (name: name, problem: null);
}

/// One planted spot in a shared garden: which species, at which stage.
class SnapshotSlot {
  const SnapshotSlot({required this.slot, required this.species, required this.stage});

  final int slot;
  final String species;
  final GrowthStage stage;

  Map<String, Object> toJson() => {'slot': slot, 'species': species, 'stage': stage.name};

  static SnapshotSlot? fromJson(Object? json) {
    if (json is! Map) return null;
    final slot = json['slot'];
    final species = json['species'];
    final stage = GrowthStage.values.where((s) => s.name == json['stage']).firstOrNull;
    if (slot is! int || species is! String || stage == null) return null;
    return SnapshotSlot(slot: slot, species: species, stage: stage);
  }
}

/// One plot in a shared garden.
class SnapshotPlot {
  const SnapshotPlot({required this.env, this.slots = const [], this.decor = const {}});

  final String env;
  final List<SnapshotSlot> slots;

  /// Placed decorations, by kind.
  final Map<String, String> decor;

  Map<String, Object> toJson() => {
    'env': env,
    'slots': [for (final s in slots) s.toJson()],
    'decor': decor,
  };

  static SnapshotPlot? fromJson(Object? json) {
    if (json is! Map || json['env'] is! String) return null;
    final slots = json['slots'];
    final decor = json['decor'];
    return SnapshotPlot(
      env: json['env'] as String,
      slots: [
        if (slots is List)
          for (final s in slots.take(_maxSlots)) ?SnapshotSlot.fromJson(s),
      ],
      decor: {
        if (decor is Map)
          for (final e in decor.entries)
            if (e.key is String && e.value is String) e.key as String: e.value as String,
      },
    );
  }
}

const _maxPlots = 12;
const _maxSlots = 12;

/// What friends can see of your garden: your plots, what grows in each spot
/// and how far along it is, and placed decorations. Nothing else, ever: no
/// quests, moods, notes, contacts or history.
class GardenSnapshot {
  const GardenSnapshot(this.plots);

  final List<SnapshotPlot> plots;

  Map<String, Object> toJson() => {
    'plots': [for (final p in plots.take(_maxPlots)) p.toJson()],
  };

  static GardenSnapshot fromJson(Object? json) {
    final plots = json is Map ? json['plots'] : null;
    return GardenSnapshot([
      if (plots is List)
        for (final p in plots.take(_maxPlots)) ?SnapshotPlot.fromJson(p),
    ]);
  }
}
