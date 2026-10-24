import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/game_config.dart';
import '../../core/providers.dart';
import '../../data/repositories/counters_repository.dart';
import '../../domain/logic/friends.dart';
import '../../domain/logic/growth.dart';
import '../../domain/models/enums.dart';
import '../../domain/models/plant.dart';
import '../home/garden_providers.dart';
import 'friends_backend.dart';

/// The Friends server. Disabled unless `main.dart` started Firebase.
final friendsBackendProvider = Provider<FriendsBackend>((ref) => const DisabledFriendsBackend());

/// Settings keys for Friends, kept on this phone.
abstract final class FriendsKeys {
  static const on = 'friends_on';
  static const name = 'friends_name';
  static const code = 'friends_code';
  static const rewardDay = 'friend_visit_reward_day';
}

/// What friends see of your garden: plots, what grows in each spot and its
/// stage, and placed decorations.
GardenSnapshot buildGardenSnapshot(
  GameConfig config, {
  required Set<String> plots,
  required List<Plant> plants,
  required Map<String, Map<String, String>> placed,
  required DateTime now,
}) => GardenSnapshot([
  for (final env in config.environments.where((e) => plots.contains(e.id)))
    SnapshotPlot(
      env: env.id,
      slots: [
        for (final p in plants.where((p) => p.envId == env.id && p.uprootedAt == null))
          SnapshotSlot(
            slot: p.slot,
            species: p.speciesId,
            stage: Growth.status(
              config.speciesById(p.speciesId),
              plantedAt: p.plantedAt,
              fruitAnchor: p.fruitAnchorAt,
              now: now,
            ).stage,
          ),
      ],
      decor: placed[env.id] ?? const {},
    ),
]);

/// The live garden snapshot, rebuilt as the garden changes.
final gardenSnapshotProvider = Provider<GardenSnapshot?>((ref) {
  final plots = ref.watch(plotsProvider).value;
  final plants = ref.watch(allPlantsProvider).value;
  if (plots == null || plants == null) return null;
  return buildGardenSnapshot(
    ref.watch(gameConfigProvider),
    plots: plots.keys.toSet(),
    plants: plants,
    placed: ref.watch(placedCosmeticsProvider).value ?? const {},
    now: ref.watch(nowProvider).value ?? ref.watch(clockProvider).now(),
  );
});

class FriendsState {
  const FriendsState({this.loaded = false, this.on = false, this.available = false, this.name = '', this.code});

  final bool loaded;
  final bool on;

  /// Whether this build can use Friends at all.
  final bool available;
  final String name;
  final String? code;

  FriendsState copyWith({bool? loaded, bool? on, String? name, String? code, bool clearCode = false}) => FriendsState(
    loaded: loaded ?? this.loaded,
    on: on ?? this.on,
    available: available,
    name: name ?? this.name,
    code: clearCode ? null : code ?? this.code,
  );
}

/// The outcome of a Friends action, in words for the user.
class FriendsResult {
  const FriendsResult.ok(this.message) : ok = true;
  const FriendsResult.problem(this.message) : ok = false;

  final bool ok;
  final String message;
}

/// A calm explanation of [p].
String friendsProblemText(FriendsProblem p) => switch (p) {
  FriendsProblem.notSetUp => "Friends isn't set up in this version yet. Everything else works as usual.",
  FriendsProblem.offline => "Couldn't reach Friends right now. Try again when you're online.",
  FriendsProblem.unknownCode => 'No one has that code yet. Check the letters and try again.',
  FriendsProblem.ownCode => "That's your own code. Share it with a friend instead.",
  FriendsProblem.alreadyFriends => "You're already friends.",
  FriendsProblem.alreadyAsked => 'You already asked. They can accept whenever they like.',
  FriendsProblem.blocked => "That didn't go through.",
  FriendsProblem.limit => "That's the limit for now. Try again tomorrow.",
  FriendsProblem.other => "Something didn't work. Try again in a little while.",
};

final friendsProvider = NotifierProvider<FriendsController, FriendsState>(FriendsController.new);

/// Opt-in, friend codes, requests and visits.
class FriendsController extends Notifier<FriendsState> {
  Timer? _publish;
  String? _uid;

  FriendsBackend get _backend => ref.read(friendsBackendProvider);

  @override
  FriendsState build() {
    ref.onDispose(() => _publish?.cancel());
    // Share garden changes with friends, a few seconds after they settle.
    ref.listen(gardenSnapshotProvider, (_, snapshot) {
      if (snapshot == null || !state.on) return;
      _publish?.cancel();
      _publish = Timer(const Duration(seconds: 5), () => _share(snapshot));
    });
    Future.microtask(_load);
    return FriendsState(available: ref.watch(friendsBackendProvider).available);
  }

  Future<void> _load() async {
    final settings = ref.read(settingsRepositoryProvider);
    final on = await settings.readValue(FriendsKeys.on) == 'true';
    final name = await settings.readValue(FriendsKeys.name) ?? '';
    final code = await settings.readValue(FriendsKeys.code);
    state = state.copyWith(loaded: true, on: on && state.available, name: name, code: code);
    if (state.on) {
      try {
        _uid = await _backend.signIn();
        final snapshot = await _snapshot();
        if (snapshot != null) await _share(snapshot);
      } on FriendsException {
        // Offline: the cached code and friends still show; it syncs later.
      }
    }
  }

  /// The garden as it is now, read straight from the database.
  Future<GardenSnapshot?> _snapshot() async => buildGardenSnapshot(
    ref.read(gameConfigProvider),
    plots: (await ref.read(seedRepositoryProvider).watchPlots().first).keys.toSet(),
    plants: await ref.read(gardenServiceProvider).watchAllPlants().first,
    placed: await ref.read(economyServiceProvider).watchPlacedCosmetics().first,
    now: ref.read(clockProvider).now(),
  );

  Future<void> _share(GardenSnapshot snapshot) async {
    try {
      await _backend.publish(name: state.name, snapshot: snapshot);
    } on FriendsException {
      // Tries again on the next change or the next launch.
    }
  }

  Future<FriendsResult> _run(Future<FriendsResult> Function() action) async {
    try {
      return await action();
    } on FriendsException catch (e) {
      return FriendsResult.problem(friendsProblemText(e.problem));
    }
  }

  /// Turns Friends on with [rawName] as the display name.
  Future<FriendsResult> turnOn(String rawName) => _run(() async {
    final check = checkDisplayName(rawName);
    if (check.problem != null) return FriendsResult.problem(check.problem!);
    if (!state.available) return FriendsResult.problem(friendsProblemText(FriendsProblem.notSetUp));
    _uid = await _backend.signIn();
    final code = await _backend.claimCode(name: check.name!);
    final settings = ref.read(settingsRepositoryProvider);
    await settings.writeValue(FriendsKeys.on, 'true');
    await settings.writeValue(FriendsKeys.name, check.name!);
    await settings.writeValue(FriendsKeys.code, code);
    state = state.copyWith(on: true, name: check.name, code: code);
    final snapshot = await _snapshot();
    if (snapshot != null) await _share(snapshot);
    return FriendsResult.ok('Friends is on. Your code is ${formatFriendCode(code)}.');
  });

  /// Turns Friends off and deletes everything that was shared.
  Future<FriendsResult> turnOff() => _run(() async {
    if (state.available) await _backend.deleteEverything();
    final settings = ref.read(settingsRepositoryProvider);
    await settings.writeValue(FriendsKeys.on, 'false');
    await settings.writeValue(FriendsKeys.code, '');
    _uid = null;
    state = state.copyWith(on: false, clearCode: true);
    return const FriendsResult.ok('Friends is off, and what you shared has been deleted.');
  });

  Future<FriendsResult> rename(String rawName) => _run(() async {
    final check = checkDisplayName(rawName);
    if (check.problem != null) return FriendsResult.problem(check.problem!);
    await ref.read(settingsRepositoryProvider).writeValue(FriendsKeys.name, check.name!);
    state = state.copyWith(name: check.name);
    final snapshot = await _snapshot();
    if (state.on && snapshot != null) await _backend.publish(name: check.name!, snapshot: snapshot);
    return const FriendsResult.ok('Name saved.');
  });

  /// Sends a friend request to whoever owns [rawCode].
  Future<FriendsResult> addByCode(String rawCode, {required List<Friend> friends, required List<FriendRequest> sent}) =>
      _run(() async {
        final code = normalizeFriendCode(rawCode);
        if (code == null) {
          return const FriendsResult.problem("That doesn't look like a friend code. It has 8 letters and numbers.");
        }
        if (code == state.code) return FriendsResult.problem(friendsProblemText(FriendsProblem.ownCode));
        final uid = await _backend.lookUpCode(code);
        if (uid == null) return FriendsResult.problem(friendsProblemText(FriendsProblem.unknownCode));
        if (uid == _uid) return FriendsResult.problem(friendsProblemText(FriendsProblem.ownCode));
        if (friends.any((f) => f.uid == uid)) {
          return FriendsResult.problem(friendsProblemText(FriendsProblem.alreadyFriends));
        }
        if (sent.any((r) => r.to == uid)) return FriendsResult.problem(friendsProblemText(FriendsProblem.alreadyAsked));
        if (friends.length >= maxFriends) return FriendsResult.problem(friendsProblemText(FriendsProblem.limit));
        await _backend.sendRequest(uid, fromName: state.name);
        return const FriendsResult.ok('Request sent. It shows up for them next time they open Sprout.');
      });

  Future<FriendsResult> accept(FriendRequest r, {required int friendCount}) => _run(() async {
    if (friendCount >= maxFriends) return FriendsResult.problem(friendsProblemText(FriendsProblem.limit));
    await _backend.accept(r, myName: state.name);
    return FriendsResult.ok('You and ${r.fromName} are friends now.');
  });

  Future<FriendsResult> decline(FriendRequest r) => _run(() async {
    await _backend.decline(r);
    return const FriendsResult.ok('Request removed.');
  });

  Future<FriendsResult> remove(Friend f) => _run(() async {
    await _backend.removeFriend(f.uid);
    return FriendsResult.ok('${f.name} is no longer on your list.');
  });

  Future<FriendsResult> block(String uid, String name) => _run(() async {
    await _backend.block(uid);
    return FriendsResult.ok("$name can't send you requests any more.");
  });

  /// Opens a friend's garden and records the visit. The first visit each
  /// day earns [visitRewardCoins] coins.
  Future<({FriendGarden? garden, bool rewarded, String? problem})> visit(Friend f) async {
    try {
      final garden = await _backend.garden(f.uid);
      final now = ref.read(clockProvider).now();
      try {
        await _backend.recordVisit(f.uid, myName: state.name, now: now);
      } on FriendsException {
        // Visiting still works offline; the note just doesn't reach them.
      }
      final settings = ref.read(settingsRepositoryProvider);
      final today = dayStamp(now);
      var rewarded = false;
      if (garden != null && await settings.readValue(FriendsKeys.rewardDay) != today) {
        await settings.writeValue(FriendsKeys.rewardDay, today);
        final counters = ref.read(countersRepositoryProvider);
        await counters.add(CounterKeys.coins, visitRewardCoins);
        await counters.add(CounterKeys.coinsEarned, visitRewardCoins);
        rewarded = true;
      }
      return (garden: garden, rewarded: rewarded, problem: null);
    } on FriendsException catch (e) {
      return (garden: null, rewarded: false, problem: friendsProblemText(e.problem));
    }
  }
}

/// Live lists, only while Friends is on.
final friendsListProvider = StreamProvider<List<Friend>>((ref) {
  final s = ref.watch(friendsProvider);
  return s.on ? ref.watch(friendsBackendProvider).friends() : Stream.value(const []);
});

final incomingRequestsProvider = StreamProvider<List<FriendRequest>>((ref) {
  final s = ref.watch(friendsProvider);
  return s.on ? ref.watch(friendsBackendProvider).incoming() : Stream.value(const []);
});

final outgoingRequestsProvider = StreamProvider<List<FriendRequest>>((ref) {
  final s = ref.watch(friendsProvider);
  return s.on ? ref.watch(friendsBackendProvider).outgoing() : Stream.value(const []);
});

final visitsTodayProvider = StreamProvider<List<VisitNote>>((ref) {
  final s = ref.watch(friendsProvider);
  final now = ref.watch(clockProvider).now();
  return s.on ? ref.watch(friendsBackendProvider).visitsToday(now) : Stream.value(const []);
});

/// Whether a stage counts as grown, for the small garden previews.
bool snapshotGrown(GrowthStage s) => s == GrowthStage.mature || s == GrowthStage.fruiting;
