import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprout/core/clock.dart';
import 'package:sprout/core/providers.dart';
import 'package:sprout/data/repositories/counters_repository.dart';
import 'package:sprout/data/repositories/seed_repository.dart';
import 'package:sprout/domain/models/enums.dart';
import 'package:sprout/domain/models/seed.dart';
import 'package:sprout/features/friends/friends_backend.dart';
import 'package:sprout/features/friends/friends_controller.dart';

import '../widget/test_app.dart';
import 'fake_friends.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeFriendsWorld world;
  late FakeClock clock;

  /// One person's app, talking to the shared fake server as [uid].
  Future<ProviderContainer> app(String uid, {FriendsBackend? backend}) async {
    final db = memoryDb();
    addTearDown(db.close);
    await SeedRepository(db, clock).ensurePlot('meadow');
    final c = ProviderContainer(
      overrides: [
        gameConfigProvider.overrideWithValue(testConfig),
        databaseProvider.overrideWithValue(db),
        clockProvider.overrideWithValue(clock),
        friendsBackendProvider.overrideWithValue(backend ?? FakeFriendsBackend(world, uid)),
      ],
    );
    addTearDown(c.dispose);
    c.read(friendsProvider);
    await pumpEventQueue();
    return c;
  }

  FriendsController ctl(ProviderContainer c) => c.read(friendsProvider.notifier);

  Future<List<Friend>> friendsOf(ProviderContainer c) => c.read(friendsBackendProvider).friends().first;
  Future<List<FriendRequest>> incomingOf(ProviderContainer c) => c.read(friendsBackendProvider).incoming().first;
  Future<List<FriendRequest>> sentBy(ProviderContainer c) => c.read(friendsBackendProvider).outgoing().first;

  Future<FriendsResult> add(ProviderContainer from, String code) async =>
      ctl(from).addByCode(code, friends: await friendsOf(from), sent: await sentBy(from));

  setUp(() {
    world = FakeFriendsWorld();
    clock = FakeClock(DateTime(2026, 5, 1, 10));
  });

  test('without Firebase, Friends politely stays off and nothing else breaks', () async {
    final c = await app('alice', backend: const DisabledFriendsBackend());
    expect(c.read(friendsProvider).available, isFalse);
    final r = await ctl(c).turnOn('Alice');
    expect(r.ok, isFalse);
    expect(r.message, contains("isn't set up"));
    expect(c.read(friendsProvider).on, isFalse);
    expect(await c.read(countersRepositoryProvider).get(CounterKeys.coins), 0);
  });

  test('turning on checks the name, gives a code and shares only the garden', () async {
    final c = await app('alice');
    expect((await ctl(c).turnOn('   ')).ok, isFalse);
    final r = await ctl(c).turnOn('Alice');
    expect(r.ok, isTrue);
    final s = c.read(friendsProvider);
    expect(s.on, isTrue);
    expect(s.code, hasLength(8));
    expect(r.message, contains('-'), reason: 'the code is shown as ABCD-EFGH');
    // Only a name, a code and a garden snapshot were shared.
    expect(world.users['alice']!.keys.toSet(), {'name', 'code', 'snapshot'});
    expect((world.users['alice']!['snapshot']! as Map).keys, ['plots']);
  });

  test('a friend is added by code and accepted', () async {
    final alice = await app('alice');
    final bob = await app('bob');
    await ctl(alice).turnOn('Alice');
    await ctl(bob).turnOn('Bob');
    final aliceCode = alice.read(friendsProvider).code!;

    expect((await add(bob, 'nope')).message, contains("doesn't look like"));
    expect((await add(bob, 'ZZZZ9999')).message, contains('No one has that code'));
    expect((await add(bob, bob.read(friendsProvider).code!)).message, contains('your own code'));

    final sent = await add(bob, aliceCode.toLowerCase());
    expect(sent.ok, isTrue, reason: sent.message);
    expect((await add(bob, aliceCode)).message, contains('already asked'));

    final waiting = await incomingOf(alice);
    expect(waiting.single.fromName, 'Bob');
    final accepted = await ctl(alice).accept(waiting.single, friendCount: 0);
    expect(accepted.ok, isTrue);
    expect((await friendsOf(alice)).single.name, 'Bob');
    expect((await friendsOf(bob)).single.name, 'Alice');
    expect(await incomingOf(alice), isEmpty);
    expect((await add(bob, aliceCode)).message, contains('already friends'));
  });

  test('declining removes the request; blocking stops new ones', () async {
    final alice = await app('alice');
    final bob = await app('bob');
    await ctl(alice).turnOn('Alice');
    await ctl(bob).turnOn('Bob');
    await add(bob, alice.read(friendsProvider).code!);
    await ctl(alice).decline((await incomingOf(alice)).single);
    expect(await incomingOf(alice), isEmpty);

    await ctl(alice).block('bob', 'Bob');
    final again = await add(bob, alice.read(friendsProvider).code!);
    expect(again.ok, isFalse);
    expect(await incomingOf(alice), isEmpty);
  });

  test('removing a friend ends it for both', () async {
    final alice = await app('alice');
    final bob = await app('bob');
    await ctl(alice).turnOn('Alice');
    await ctl(bob).turnOn('Bob');
    await add(bob, alice.read(friendsProvider).code!);
    await ctl(alice).accept((await incomingOf(alice)).single, friendCount: 0);
    await ctl(bob).remove((await friendsOf(bob)).single);
    expect(await friendsOf(alice), isEmpty);
    expect(await friendsOf(bob), isEmpty);
  });

  test('the friends limit is respected', () async {
    final alice = await app('alice');
    await ctl(alice).turnOn('Alice');
    final many = [for (var i = 0; i < 30; i++) Friend(uid: 'f$i', name: 'F$i')];
    final bob = await app('bob');
    await ctl(bob).turnOn('Bob');
    final r = await ctl(alice).addByCode(bob.read(friendsProvider).code!, friends: many, sent: const []);
    expect(r.message, contains('limit'));
    final accepted = await ctl(alice)
        .accept(const FriendRequest(from: 'bob', to: 'alice', fromName: 'Bob'), friendCount: 30);
    expect(accepted.ok, isFalse);
  });

  test('visiting shows their garden, leaves one note, and rewards once a day', () async {
    final alice = await app('alice');
    final bob = await app('bob');
    // Alice plants something so her garden has a plant to show.
    await alice
        .read(gardenServiceProvider)
        .plantSeed(
          (await SeedRepository(
            alice.read(databaseProvider),
            clock,
          ).add('apple_tree', Rarity.common, SeedSource.quests)).id,
          'meadow',
          0,
        );
    await pumpEventQueue();
    await ctl(alice).turnOn('Alice');
    await ctl(bob).turnOn('Bob');
    await add(bob, alice.read(friendsProvider).code!);
    await ctl(alice).accept((await incomingOf(alice)).single, friendCount: 0);

    final aliceFriend = (await friendsOf(bob)).single;
    final first = await ctl(bob).visit(aliceFriend);
    expect(first.problem, isNull);
    expect(first.garden!.name, 'Alice');
    expect(first.garden!.snapshot.plots.single.slots.single.species, 'apple_tree');
    expect(first.rewarded, isTrue);
    final coins = bob.read(countersRepositoryProvider);
    expect(await coins.get(CounterKeys.coins), 3);

    final second = await ctl(bob).visit(aliceFriend);
    expect(second.rewarded, isFalse, reason: 'once a day');
    expect(await coins.get(CounterKeys.coins), 3);
    final notes = await alice.read(friendsBackendProvider).visitsToday(clock.now()).first;
    expect(notes.single.name, 'Bob', reason: 'one note per friend per day');

    clock.advance(const Duration(days: 1));
    expect((await ctl(bob).visit(aliceFriend)).rewarded, isTrue, reason: 'a new day');
    expect(await coins.get(CounterKeys.coins), 6);
  });

  test('offline problems are explained calmly', () async {
    final alice = await app('alice');
    await ctl(alice).turnOn('Alice');
    world.online = false;
    final r = await add(alice, 'BBBB3333');
    expect(r.ok, isFalse);
    expect(r.message, contains('online'));
  });

  test('turning off deletes everything that was shared', () async {
    final alice = await app('alice');
    final bob = await app('bob');
    await ctl(alice).turnOn('Alice');
    await ctl(bob).turnOn('Bob');
    await add(bob, alice.read(friendsProvider).code!);
    await ctl(alice).accept((await incomingOf(alice)).single, friendCount: 0);

    final r = await ctl(alice).turnOff();
    expect(r.ok, isTrue);
    expect(alice.read(friendsProvider).on, isFalse);
    expect(world.users.containsKey('alice'), isFalse);
    expect(world.codes.containsValue('alice'), isFalse);
    expect(await friendsOf(bob), isEmpty);
  });
}
