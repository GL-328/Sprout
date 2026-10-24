import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../domain/logic/friends.dart';
import '../../ui/art/icon_art.dart';
import '../../ui/art/plant_art_provider.dart';
import '../../ui/layout/insets.dart';
import '../../ui/widgets/soft_card.dart';
import 'friends_backend.dart';
import 'friends_controller.dart';
import 'friends_section.dart';
import 'visit_screen.dart';

/// A friend's shared garden, for the little previews on the list.
final friendGardenProvider = FutureProvider.family<FriendGarden?, String>((ref, uid) async {
  try {
    return await ref.watch(friendsBackendProvider).garden(uid);
  } on FriendsException {
    return null;
  }
});

/// Friends: your code, requests, your friends and their gardens.
class FriendsScreen extends ConsumerStatefulWidget {
  const FriendsScreen({super.key});

  @override
  ConsumerState<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends ConsumerState<FriendsScreen> {
  final _code = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  void _say(String text) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: IconText(text)));

  Future<void> _act(Future<FriendsResult> Function() action) async {
    setState(() => _busy = true);
    final result = await action();
    if (!mounted) return;
    setState(() => _busy = false);
    _say(result.message);
  }

  Future<bool> _confirm(String title, String body, String yes) async =>
      await showDialog<bool>(
        context: context,
        builder: (dialog) => AlertDialog(
          scrollable: true,
          title: Text(title),
          content: Text(body),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialog, false), child: const Text('Not now')),
            FilledButton(onPressed: () => Navigator.pop(dialog, true), child: Text(yes)),
          ],
        ),
      ) ??
      false;

  Future<void> _add() async {
    final friends = ref.read(friendsListProvider).value ?? const [];
    final sent = ref.read(outgoingRequestsProvider).value ?? const [];
    FocusScope.of(context).unfocus();
    await _act(() => ref.read(friendsProvider.notifier).addByCode(_code.text, friends: friends, sent: sent));
    if (mounted) _code.clear();
  }

  Future<void> _visit(Friend f) async {
    final result = await ref.read(friendsProvider.notifier).visit(f);
    if (!mounted) return;
    if (result.problem != null || result.garden == null) {
      _say(result.problem ?? "${f.name}'s garden isn't ready to visit yet.");
      return;
    }
    await pushPage(context, VisitScreen(name: f.name, garden: result.garden!));
    if (mounted && result.rewarded) _say('Thanks for visiting ${f.name}. +{coin} $visitRewardCoins');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = ref.watch(friendsProvider);
    final soft = theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant);

    if (!s.available || !s.on) {
      return Scaffold(
        appBar: AppBar(title: const Text('Friends')),
        body: ListView(
          padding: AppInsets.list(context, top: 16),
          children: [
            const Center(child: ArtIcon('heart', size: 72)),
            const SizedBox(height: 16),
            Text(
              s.available ? 'Friends is off' : "Friends isn't set up yet",
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(friendsPrivacyText, style: soft, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            if (s.available) const FriendsSection(),
          ],
        ),
      );
    }

    final friends = ref.watch(friendsListProvider).value ?? const <Friend>[];
    final incoming = ref.watch(incomingRequestsProvider).value ?? const <FriendRequest>[];
    final sent = ref.watch(outgoingRequestsProvider).value ?? const <FriendRequest>[];
    final visits = ref.watch(visitsTodayProvider).value ?? const <VisitNote>[];

    return Scaffold(
      appBar: AppBar(title: const Text('Friends')),
      body: ListView(
        padding: AppInsets.list(context, top: 12),
        children: [
          SoftCard(
            padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Your friend code', style: soft),
                      Text(
                        s.code == null ? '…' : formatFriendCode(s.code!),
                        style: theme.textTheme.headlineSmall?.copyWith(letterSpacing: 2),
                      ),
                    ],
                  ),
                ),
                if (s.code != null)
                  IconButton(
                    tooltip: 'Copy code',
                    icon: const Icon(Icons.copy_rounded),
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: formatFriendCode(s.code!)));
                      _say('Code copied. Share it with a friend.');
                    },
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _code,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                    hintText: "A friend's code",
                    prefixIcon: Icon(Icons.person_add_alt_1_rounded),
                  ),
                  onSubmitted: (_) => _add(),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(onPressed: _busy ? null : _add, child: const Text('Add')),
            ],
          ),
          if (visits.isNotEmpty) ...[
            const SizedBox(height: 16),
            for (final v in visits)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    const ArtIcon('visitor:butterfly', size: 24),
                    const SizedBox(width: 8),
                    Expanded(child: Text('${v.name} visited your garden today.', style: theme.textTheme.bodyMedium)),
                  ],
                ),
              ),
          ],
          if (incoming.isNotEmpty) ...[
            const _Heading('Waiting for you'),
            for (final r in incoming)
              Card(
                child: ListTile(
                  leading: const ArtIcon('heart', size: 28),
                  title: Text(r.fromName),
                  subtitle: const Text('would like to be friends'),
                  trailing: Wrap(
                    children: [
                      IconButton(
                        tooltip: 'Decline',
                        icon: const Icon(Icons.close_rounded),
                        onPressed: _busy ? null : () => _act(() => ref.read(friendsProvider.notifier).decline(r)),
                      ),
                      IconButton(
                        tooltip: 'Accept',
                        icon: const Icon(Icons.check_rounded),
                        onPressed: _busy
                            ? null
                            : () =>
                                  _act(() => ref.read(friendsProvider.notifier).accept(r, friendCount: friends.length)),
                      ),
                    ],
                  ),
                ),
              ),
          ],
          _Heading(friends.isEmpty ? 'Your friends' : 'Your friends (${friends.length})'),
          if (friends.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'No friends here yet. Share your code, or add a friend with theirs.',
                style: soft,
                textAlign: TextAlign.center,
              ),
            ),
          for (final f in friends)
            _FriendCard(
              friend: f,
              onVisit: () => _visit(f),
              onRemove: () async {
                if (await _confirm('Remove ${f.name}?', 'You can add each other again any time.', 'Remove')) {
                  await _act(() => ref.read(friendsProvider.notifier).remove(f));
                }
              },
              onBlock: () async {
                if (await _confirm(
                  'Block ${f.name}?',
                  "You'll stop being friends, and they won't be able to send you requests.",
                  'Block',
                )) {
                  await _act(() => ref.read(friendsProvider.notifier).block(f.uid, f.name));
                }
              },
            ),
          if (sent.isNotEmpty) ...[
            const _Heading('Requests you sent'),
            for (final r in sent)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.schedule_rounded),
                title: const Text('Waiting for them to accept'),
                trailing: TextButton(
                  onPressed: _busy ? null : () => _act(() => ref.read(friendsProvider.notifier).decline(r)),
                  child: const Text('Cancel'),
                ),
              ),
          ],
          const SizedBox(height: 16),
          Text(friendsPrivacyText, style: soft),
        ],
      ),
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(2, 20, 2, 8),
    child: Text(text, style: Theme.of(context).textTheme.titleMedium),
  );
}

/// A friend with a peek at their garden and a Visit button.
class _FriendCard extends ConsumerWidget {
  const _FriendCard({required this.friend, required this.onVisit, required this.onRemove, required this.onBlock});

  final Friend friend;
  final VoidCallback onVisit;
  final VoidCallback onRemove;
  final VoidCallback onBlock;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final config = ref.watch(gameConfigProvider);
    final garden = ref.watch(friendGardenProvider(friend.uid)).value;
    final plants = [
      for (final plot in garden?.snapshot.plots ?? const <SnapshotPlot>[])
        for (final slot in plot.slots)
          if (config.species.containsKey(slot.species)) (config.speciesById(slot.species), slot.stage),
    ];
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: SoftCard(
        padding: const EdgeInsets.fromLTRB(14, 12, 4, 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(friend.name, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 6),
                  SizedBox(
                    height: 40,
                    child: plants.isEmpty
                        ? Align(
                            alignment: Alignment.centerLeft,
                            child: Text('A quiet garden for now', style: theme.textTheme.bodySmall),
                          )
                        : Row(
                            children: [
                              for (final (species, stage) in plants.take(4))
                                plantArtProvider.plant(species, stage, size: 40),
                            ],
                          ),
                  ),
                ],
              ),
            ),
            FilledButton.tonal(onPressed: onVisit, child: const Text('Visit')),
            PopupMenuButton<String>(
              tooltip: 'More',
              icon: const Icon(Icons.more_vert_rounded),
              onSelected: (v) => v == 'remove' ? onRemove() : onBlock(),
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'remove', child: Text('Remove friend')),
                PopupMenuItem(value: 'block', child: Text('Block')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
