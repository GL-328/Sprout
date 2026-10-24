import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/providers.dart';
import '../../data/services/backup_service.dart';

/// Export, import and delete-all.
class DataSection extends ConsumerWidget {
  const DataSection({super.key});

  void _say(BuildContext context, String message) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));

  Future<void> _export(BuildContext context, WidgetRef ref) async {
    try {
      final json = await ref.read(backupServiceProvider).exportJson();
      final name = 'sprout-backup-${DateFormat('yyyy-MM-dd').format(DateTime.now())}.json';
      final saved = await FilePicker.saveFile(
        fileName: name,
        bytes: utf8.encode(json),
        mimeType: 'application/json',
        dialogTitle: 'Save your Sprout backup',
      );
      if (context.mounted && saved != null) _say(context, 'Backup saved.');
    } catch (e) {
      if (context.mounted) _say(context, 'Could not save the backup: $e');
    }
  }

  Future<void> _import(BuildContext context, WidgetRef ref) async {
    final file = await FilePicker.pickFile(dialogTitle: 'Choose a Sprout backup');
    if (file == null || !context.mounted) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        scrollable: true,
        title: const Text('Restore this backup?'),
        content: const Text(
          'Everything currently in Sprout (quests, garden, moods, settings) will be replaced with the backup.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Restore')),
        ],
      ),
    );
    if (ok != true) return;
    try {
      final text = utf8.decode(await file.readAsBytes());
      await ref.read(backupServiceProvider).importJson(text);
      await ref.read(gardenServiceProvider).ensureStartingPlot();
      await ref.read(settingsProvider.notifier).reload();
      ref.invalidate(reminderSyncProvider);
      if (context.mounted) _say(context, 'Backup restored.');
    } on BackupException catch (e) {
      if (context.mounted) _say(context, e.message);
    } catch (e) {
      if (context.mounted) _say(context, 'Could not read that file: $e');
    }
  }

  Future<void> _deleteAll(BuildContext context, WidgetRef ref) async {
    final first = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        scrollable: true,
        title: const Text('Delete all data?'),
        content: const Text(
          'This permanently removes your quests, garden, seeds, coins, moods, journal and settings from this phone. '
          "It can't be undone. You might like to export a backup first.",
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Keep my data')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFB4687A)),
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
    if (first != true || !context.mounted) return;
    final controller = TextEditingController();
    final second = await showDialog<bool>(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (c, setState) => AlertDialog(
          scrollable: true,
          title: const Text('Are you sure?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Type DELETE to confirm.'),
              const SizedBox(height: 10),
              TextField(controller: controller, autofocus: true, onChanged: (_) => setState(() {})),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: const Color(0xFFB4687A)),
              onPressed: controller.text.trim().toUpperCase() == 'DELETE' ? () => Navigator.pop(c, true) : null,
              child: const Text('Delete everything'),
            ),
          ],
        ),
      ),
    );
    controller.dispose();
    if (second != true) return;
    await ref.read(backupServiceProvider).deleteAll();
    await ref.read(gardenServiceProvider).ensureStartingPlot();
    await ref.read(settingsProvider.notifier).reload();
    ref.invalidate(reminderSyncProvider);
    if (context.mounted) context.go('/onboarding');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.upload_file_outlined),
          title: const Text('Export my data'),
          subtitle: const Text('Save everything to a JSON file'),
          onTap: () => _export(context, ref),
        ),
        ListTile(
          leading: const Icon(Icons.download_outlined),
          title: const Text('Import from a backup'),
          subtitle: const Text('Restore a JSON file you exported'),
          onTap: () => _import(context, ref),
        ),
        ListTile(
          leading: const Icon(Icons.delete_forever_outlined),
          title: const Text('Delete all data'),
          subtitle: const Text('Start over from the beginning'),
          onTap: () => _deleteAll(context, ref),
        ),
      ],
    );
  }
}
