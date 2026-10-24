import 'package:flutter/material.dart';

import '../../ui/widgets/soft_card.dart';
import '../../ui/layout/insets.dart';
import '../../ui/art/icon_art.dart';

/// Shared wording for the wellbeing note, also shown in the Journal.
const notMedicalAdviceNote =
    'Sprout is a gentle companion for small self-care habits. It is not medical advice, '
    'diagnosis or treatment, and it is not a substitute for professional help. '
    'If you are struggling or feel unsafe, please reach out to someone you trust, '
    'your doctor, or a local helpline or emergency service.';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('About Sprout')),
      body: ListView(
        padding: AppInsets.list(context, top: 20),
        children: [
          SoftCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ArtIcon('sprout', size: 60),
                const SizedBox(height: 12),
                Text('Sprout', style: theme.textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text(
                  'Take care of yourself, and a little garden grows with you. '
                  'Everything stays on this phone: no accounts, no tracking. Sprout goes online for a daily '
                  'check for a new version, which you can turn off in Settings → Updates, and for Friends, '
                  'only if you turn it on.',
                  style: theme.textTheme.bodyLarge?.copyWith(height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SoftCard(
            color: theme.colorScheme.primary.withValues(alpha: 0.12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('A gentle note', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(notMedicalAdviceNote, style: theme.textTheme.bodyLarge?.copyWith(height: 1.4)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Font: Nunito, by Vernon Adams and contributors, under the SIL Open Font License.',
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
