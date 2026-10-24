import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/logic/friends.dart';

/// Why a Friends action didn't work, in a form the UI can explain gently.
enum FriendsProblem { notSetUp, offline, unknownCode, ownCode, alreadyFriends, alreadyAsked, blocked, limit, other }

class FriendsException implements Exception {
  const FriendsException(this.problem, [this.detail = '']);

  final FriendsProblem problem;
  final String detail;

  @override
  String toString() => 'FriendsException($problem${detail.isEmpty ? '' : ': $detail'})';
}

class Friend {
  const Friend({required this.uid, required this.name});

  final String uid;
  final String name;
}

class FriendRequest {
  const FriendRequest({required this.from, required this.to, required this.fromName});

  final String from;
  final String to;
  final String fromName;
}

/// A friend's shared garden, as they last published it.
class FriendGarden {
  const FriendGarden({required this.name, required this.snapshot, this.updatedAt});

  final String name;
  final GardenSnapshot snapshot;
  final DateTime? updatedAt;
}

/// A friend who visited your garden today.
class VisitNote {
  const VisitNote({required this.visitorUid, required this.name});

  final String visitorUid;
  final String name;
}

/// Everything Friends needs from the server. Only display names, friend
/// codes, friend links, requests, visits and the garden snapshot ever leave
/// the phone.
abstract class FriendsBackend {
  /// Whether Friends can work in this build (Firebase is set up).
  bool get available;

  /// Signs in anonymously and returns the user id.
  Future<String> signIn();

  /// The user's friend code, created on first use.
  Future<String> claimCode({required String name});

  /// The user id a code belongs to, or null.
  Future<String?> lookUpCode(String code);

  Future<void> publish({required String name, required GardenSnapshot snapshot});

  Future<void> sendRequest(String toUid, {required String fromName});
  Future<void> accept(FriendRequest request, {required String myName});
  Future<void> decline(FriendRequest request);

  Stream<List<FriendRequest>> incoming();
  Stream<List<FriendRequest>> outgoing();
  Stream<List<Friend>> friends();

  Future<void> removeFriend(String uid);
  Future<void> block(String uid);

  Future<FriendGarden?> garden(String uid);

  /// Records today's visit to [hostUid]. Once per friend per day.
  Future<void> recordVisit(String hostUid, {required String myName, required DateTime now});

  Stream<List<VisitNote>> visitsToday(DateTime now);

  /// Deletes everything this user shared, and their friend links.
  Future<void> deleteEverything();
}

/// Used when Firebase isn't set up in this build: Friends says so politely,
/// and the rest of the app carries on.
class DisabledFriendsBackend implements FriendsBackend {
  const DisabledFriendsBackend();

  static const _no = FriendsException(FriendsProblem.notSetUp);

  @override
  bool get available => false;
  @override
  Future<String> signIn() async => throw _no;
  @override
  Future<String> claimCode({required String name}) async => throw _no;
  @override
  Future<String?> lookUpCode(String code) async => throw _no;
  @override
  Future<void> publish({required String name, required GardenSnapshot snapshot}) async => throw _no;
  @override
  Future<void> sendRequest(String toUid, {required String fromName}) async => throw _no;
  @override
  Future<void> accept(FriendRequest request, {required String myName}) async => throw _no;
  @override
  Future<void> decline(FriendRequest request) async => throw _no;
  @override
  Stream<List<FriendRequest>> incoming() => const Stream.empty();
  @override
  Stream<List<FriendRequest>> outgoing() => const Stream.empty();
  @override
  Stream<List<Friend>> friends() => const Stream.empty();
  @override
  Future<void> removeFriend(String uid) async => throw _no;
  @override
  Future<void> block(String uid) async => throw _no;
  @override
  Future<FriendGarden?> garden(String uid) async => throw _no;
  @override
  Future<void> recordVisit(String hostUid, {required String myName, required DateTime now}) async => throw _no;
  @override
  Stream<List<VisitNote>> visitsToday(DateTime now) => const Stream.empty();
  @override
  Future<void> deleteEverything() async {}
}

/// Friends on Firebase: anonymous sign-in and Firestore. See
/// `firestore.rules` for what each user may read and write.
class FirebaseFriendsBackend implements FriendsBackend {
  FirebaseFriendsBackend({FirebaseFirestore? db, FirebaseAuth? auth})
    : _db = db ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  @override
  bool get available => true;

  String get _me {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw const FriendsException(FriendsProblem.other, 'not signed in');
    return uid;
  }

  DocumentReference<Map<String, dynamic>> _user(String uid) => _db.collection('users').doc(uid);

  /// Runs [action], turning Firebase errors into gentle problems.
  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on FriendsException {
      rethrow;
    } on FirebaseException catch (e) {
      throw FriendsException(switch (e.code) {
        'unavailable' || 'network-request-failed' || 'deadline-exceeded' => FriendsProblem.offline,
        'permission-denied' => FriendsProblem.blocked,
        'resource-exhausted' => FriendsProblem.limit,
        _ => FriendsProblem.other,
      }, e.code);
    }
  }

  @override
  Future<String> signIn() => _guard(() async {
    final user = _auth.currentUser ?? (await _auth.signInAnonymously()).user;
    if (user == null) throw const FriendsException(FriendsProblem.other, 'sign-in failed');
    return user.uid;
  });

  @override
  Future<String> claimCode({required String name}) => _guard(() async {
    final me = _me;
    final mine = await _user(me).get();
    final existing = mine.data()?['code'];
    if (existing is String) return existing;
    final random = math.Random.secure();
    for (var attempt = 0; attempt < 6; attempt++) {
      final code = generateFriendCode(random);
      final codeRef = _db.collection('codes').doc(code);
      final claimed = await _db.runTransaction((tx) async {
        if ((await tx.get(codeRef)).exists) return false;
        tx.set(codeRef, {'uid': me});
        tx.set(_user(me), {'name': name, 'code': code}, SetOptions(merge: true));
        return true;
      });
      if (claimed) return code;
    }
    throw const FriendsException(FriendsProblem.other, 'no free code');
  });

  @override
  Future<String?> lookUpCode(String code) => _guard(() async {
    final doc = await _db.collection('codes').doc(code).get();
    final uid = doc.data()?['uid'];
    return uid is String ? uid : null;
  });

  @override
  Future<void> publish({required String name, required GardenSnapshot snapshot}) => _guard(
    () => _user(_me).set({
      'name': name,
      'snapshot': snapshot.toJson(),
      'snapshotAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true)),
  );

  @override
  Future<void> sendRequest(String toUid, {required String fromName}) => _guard(() async {
    final me = _me;
    final mine = (await _user(me).get()).data() ?? const {};
    final today = DateTime.now().toUtc().millisecondsSinceEpoch ~/ Duration.millisecondsPerDay;
    final sameDay = mine['reqDay'] == today;
    final count = sameDay ? (mine['reqCount'] as int? ?? 0) + 1 : 1;
    if (count > maxRequestsPerDay) throw const FriendsException(FriendsProblem.limit);
    final batch = _db.batch()
      ..set(_db.collection('requests').doc('${me}_$toUid'), {
        'from': me,
        'to': toUid,
        'fromName': fromName,
        'at': FieldValue.serverTimestamp(),
      })
      ..set(_user(me), {'reqDay': today, 'reqCount': count}, SetOptions(merge: true));
    await batch.commit();
  });

  @override
  Future<void> accept(FriendRequest request, {required String myName}) => _guard(() async {
    final me = _me;
    final batch = _db.batch()
      ..set(_user(me).collection('friends').doc(request.from), {'name': request.fromName})
      ..set(_user(request.from).collection('friends').doc(me), {'name': myName})
      ..delete(_db.collection('requests').doc('${request.from}_$me'));
    await batch.commit();
  });

  @override
  Future<void> decline(FriendRequest request) =>
      _guard(() => _db.collection('requests').doc('${request.from}_${request.to}').delete());

  List<FriendRequest> _requests(QuerySnapshot<Map<String, dynamic>> q) => [
    for (final d in q.docs)
      if (d.data()['from'] is String && d.data()['to'] is String)
        FriendRequest(
          from: d.data()['from'] as String,
          to: d.data()['to'] as String,
          fromName: d.data()['fromName'] as String? ?? 'A friend',
        ),
  ];

  @override
  Stream<List<FriendRequest>> incoming() =>
      _db.collection('requests').where('to', isEqualTo: _me).snapshots().map(_requests);

  @override
  Stream<List<FriendRequest>> outgoing() =>
      _db.collection('requests').where('from', isEqualTo: _me).snapshots().map(_requests);

  @override
  Stream<List<Friend>> friends() =>
      _user(_me)
          .collection('friends')
          .snapshots()
          .map((q) => [for (final d in q.docs) Friend(uid: d.id, name: d.data()['name'] as String? ?? 'A friend')]);

  @override
  Future<void> removeFriend(String uid) => _guard(() async {
    final me = _me;
    final batch = _db.batch()
      ..delete(_user(me).collection('friends').doc(uid))
      ..delete(_user(uid).collection('friends').doc(me));
    await batch.commit();
  });

  @override
  Future<void> block(String uid) => _guard(() async {
    final me = _me;
    final batch = _db.batch()
      ..set(_user(me).collection('blocked').doc(uid), {'at': FieldValue.serverTimestamp()})
      ..delete(_user(me).collection('friends').doc(uid))
      ..delete(_user(uid).collection('friends').doc(me));
    await batch.commit();
    // Clear any request between the two of us; either may not exist.
    for (final id in ['${uid}_$me', '${me}_$uid']) {
      try {
        await _db.collection('requests').doc(id).delete();
      } on FirebaseException {
        // Nothing to clear.
      }
    }
  });

  @override
  Future<FriendGarden?> garden(String uid) => _guard(() async {
    final data = (await _user(uid).get()).data();
    if (data == null) return null;
    final at = data['snapshotAt'];
    return FriendGarden(
      name: data['name'] as String? ?? 'A friend',
      snapshot: GardenSnapshot.fromJson(data['snapshot']),
      updatedAt: at is Timestamp ? at.toDate() : null,
    );
  });

  @override
  Future<void> recordVisit(String hostUid, {required String myName, required DateTime now}) => _guard(() async {
    final me = _me;
    try {
      await _user(hostUid)
          .collection('visits')
          .doc(visitId(me, now))
          .set({'visitor': me, 'name': myName, 'day': dayStamp(now), 'at': FieldValue.serverTimestamp()});
    } on FirebaseException catch (e) {
      // Already visited today: the rules only allow one.
      if (e.code != 'permission-denied') rethrow;
    }
  });

  @override
  Stream<List<VisitNote>> visitsToday(DateTime now) => _user(_me)
      .collection('visits')
      .where('day', isEqualTo: dayStamp(now))
      .snapshots()
      .map(
        (q) => [
          for (final d in q.docs)
            VisitNote(
              visitorUid: d.data()['visitor'] as String? ?? '',
              name: d.data()['name'] as String? ?? 'A friend',
            ),
        ],
      );

  @override
  Future<void> deleteEverything() => _guard(() async {
    final user = _auth.currentUser;
    if (user == null) return;
    final me = user.uid;
    final mine = await _user(me).get();
    final code = mine.data()?['code'];
    for (final f in (await _user(me).collection('friends').get()).docs) {
      await removeFriend(f.id);
    }
    for (final sub in ['visits', 'blocked']) {
      for (final d in (await _user(me).collection(sub).get()).docs) {
        await d.reference.delete();
      }
    }
    for (final field in ['from', 'to']) {
      for (final d in (await _db.collection('requests').where(field, isEqualTo: me).get()).docs) {
        await d.reference.delete();
      }
    }
    if (code is String) await _db.collection('codes').doc(code).delete();
    await _user(me).delete();
    await user.delete();
  });
}
