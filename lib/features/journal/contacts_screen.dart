import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../data/repositories/wellbeing_repository.dart';
import '../../ui/widgets/soft_card.dart';
import '../settings/about_screen.dart';
import '../../ui/layout/insets.dart';
import '../../ui/art/icon_art.dart';

final _contactsProvider = StreamProvider<List<HelpContact>>(
  (ref) => ref.watch(wellbeingRepositoryProvider).watchContacts(),
);

/// The user's own list of people and places that help.
class ContactsScreen extends ConsumerWidget {
  const ContactsScreen({super.key});

  Future<void> _edit(BuildContext context, WidgetRef ref, [HelpContact? contact]) async {
    final name = TextEditingController(text: contact?.name ?? '');
    final detail = TextEditingController(text: contact?.detail ?? '');
    final note = TextEditingController(text: contact?.note ?? '');
    final repo = ref.read(wellbeingRepositoryProvider);
    final result = await showDialog<String>(
      context: context,
      builder: (c) => AlertDialog(
        scrollable: true,
        title: Text(contact == null ? 'Add a contact' : 'Edit contact'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: name,
                autofocus: true,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(hintText: 'Name (a friend, a helpline, your doctor)'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: detail,
                decoration: const InputDecoration(hintText: 'Phone, website or address'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: note,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(hintText: 'Note (optional)'),
              ),
            ],
          ),
        ),
        actions: [
          if (contact != null) TextButton(onPressed: () => Navigator.pop(c, 'delete'), child: const Text('Delete')),
          TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(c, 'save'), child: const Text('Save')),
        ],
      ),
    );
    if (result == 'save' && name.text.trim().isNotEmpty) {
      if (contact == null) {
        await repo.addContact(name.text.trim(), detail.text.trim(), note.text.trim());
      } else {
        await repo.updateContact(
          HelpContact(id: contact.id, name: name.text.trim(), detail: detail.text.trim(), note: note.text.trim()),
        );
      }
    } else if (result == 'delete' && contact != null) {
      await repo.deleteContact(contact.id);
    }
    name.dispose();
    detail.dispose();
    note.dispose();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final contacts = ref.watch(_contactsProvider).value ?? const <HelpContact>[];
    return Scaffold(
      appBar: AppBar(title: const Text('My helpful contacts')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _edit(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
      body: ListView(
        padding: AppInsets.list(context, withFab: true),
        children: [
          Text(
            'Keep the people and places that help you close at hand. These stay on this phone.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          for (final c in contacts)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: SoftCard(
                padding: const EdgeInsets.symmetric(vertical: 4),
                onTap: () => _edit(context, ref, c),
                child: ListTile(
                  leading: const ArtIcon('heart', size: 30),
                  title: Text(c.name, style: theme.textTheme.titleMedium),
                  subtitle: Text([c.detail, c.note].where((s) => s.isNotEmpty).join('\n')),
                  isThreeLine: c.detail.isNotEmpty && c.note.isNotEmpty,
                ),
              ),
            ),
          if (contacts.isEmpty)
            const Padding(padding: EdgeInsets.all(16), child: Text('Nothing here yet. Tap Add to start your list.')),
          const SizedBox(height: 16),
          Text(notMedicalAdviceNote, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}
