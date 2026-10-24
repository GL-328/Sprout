import 'dart:async';

import 'package:sprout/domain/logic/friends.dart';
import 'package:sprout/features/friends/friends_backend.dart';

/// A tiny in-memory Friends server shared by several fake users, with the
/// same rules as firestore.rules where they matter to the app.
class FakeFriendsWorld {
  bool online = true;
  final codes = <String, String>{};
  final users = <String, Map<String, Object?>>{};
  final friends = <String, Map<String, String>>{};
  final requests = <String, FriendRequest>{};
  final blocked = <String, Set<String>>{};
  final visits = <String, Map<String, ({String visitor, String name, String day})>>{};
  final _changes = StreamController<void>.broadcast();
  var _nextCode = 0;

  void changed() => _changes.add(null);

  Stream<T> watch<T>(T Function() read) async* {
    yield read();
    await for (final _ in _changes.stream) {
      yield read();
    }
  }

  String newCode() {
    const codes = ['AAAA2222', 'BBBB3333', 'CCCC4444', 'DDDD5555', 'EEEE6666'];
    return codes[_nextCode++ % codes.length];
  }
}

class FakeFriendsBackend implements FriendsBackend {
  FakeFriendsBackend(this.world, this.uid);

  final FakeFriendsWorld world;
  final String uid;

  void _online() {
    if (!world.online) throw const FriendsException(FriendsProblem.offline);
  }

  @override
  bool get available => true;

  @override
  Future<String> signIn() async {
    _online();
    return uid;
  }

  @override
  Future<String> claimCode({required String name}) async {
    _online();
    final existing = world.users[uid]?['code'];
    if (existing is String) return existing;
    final code = world.newCode();
    world.codes[code] = uid;
    world.users[uid] = {...?world.users[uid], 'name': name, 'code': code};
    return code;
  }

  @override
  Future<String?> lookUpCode(String code) async {
    _online();
    return world.codes[code];
  }

  @override
  Future<void> publish({required String name, required GardenSnapshot snapshot}) async {
    _online();
    world.users[uid] = {...?world.users[uid], 'name': name, 'snapshot': snapshot.toJson()};
    world.changed();
  }

  @override
  Future<void> sendRequest(String toUid, {required String fromName}) async {
    _online();
    if (world.blocked[toUid]?.contains(uid) ?? false) throw const FriendsException(FriendsProblem.blocked);
    world.requests['${uid}_$toUid'] = FriendRequest(from: uid, to: toUid, fromName: fromName);
    world.changed();
  }

  @override
  Future<void> accept(FriendRequest request, {required String myName}) async {
    _online();
    if (!world.requests.containsKey('${request.from}_$uid')) throw const FriendsException(FriendsProblem.blocked);
    (world.friends[uid] ??= {})[request.from] = request.fromName;
    (world.friends[request.from] ??= {})[uid] = myName;
    world.requests.remove('${request.from}_$uid');
    world.changed();
  }

  @override
  Future<void> decline(FriendRequest request) async {
    _online();
    world.requests.remove('${request.from}_${request.to}');
    world.changed();
  }

  @override
  Stream<List<FriendRequest>> incoming() => world.watch(() => [...world.requests.values.where((r) => r.to == uid)]);

  @override
  Stream<List<FriendRequest>> outgoing() => world.watch(() => [...world.requests.values.where((r) => r.from == uid)]);

  @override
  Stream<List<Friend>> friends() =>
      world.watch(() => [for (final e in (world.friends[uid] ?? {}).entries) Friend(uid: e.key, name: e.value)]);

  @override
  Future<void> removeFriend(String other) async {
    _online();
    world.friends[uid]?.remove(other);
    world.friends[other]?.remove(uid);
    world.changed();
  }

  @override
  Future<void> block(String other) async {
    _online();
    (world.blocked[uid] ??= {}).add(other);
    await removeFriend(other);
    world.requests.remove('${other}_$uid');
    world.requests.remove('${uid}_$other');
    world.changed();
  }

  @override
  Future<FriendGarden?> garden(String other) async {
    _online();
    if (!(world.friends[other]?.containsKey(uid) ?? false)) throw const FriendsException(FriendsProblem.blocked);
    final data = world.users[other];
    if (data == null) return null;
    return FriendGarden(name: data['name'] as String, snapshot: GardenSnapshot.fromJson(data['snapshot']));
  }

  @override
  Future<void> recordVisit(String hostUid, {required String myName, required DateTime now}) async {
    _online();
    // Like the rules: one note per friend per day.
    (world.visits[hostUid] ??= {}).putIfAbsent(
      visitId(uid, now),
      () => (visitor: uid, name: myName, day: dayStamp(now)),
    );
    world.changed();
  }

  @override
  Stream<List<VisitNote>> visitsToday(DateTime now) => world.watch(
    () => [
      for (final v in (world.visits[uid] ?? {}).values)
        if (v.day == dayStamp(now)) VisitNote(visitorUid: v.visitor, name: v.name),
    ],
  );

  @override
  Future<void> deleteEverything() async {
    _online();
    final code = world.users[uid]?['code'];
    for (final other in [...?world.friends[uid]?.keys]) {
      await removeFriend(other);
    }
    world.requests.removeWhere((_, r) => r.from == uid || r.to == uid);
    world.visits.remove(uid);
    world.blocked.remove(uid);
    if (code is String) world.codes.remove(code);
    world.users.remove(uid);
    world.changed();
  }
}
