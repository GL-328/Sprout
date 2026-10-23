import 'package:flutter/material.dart';

import '../../ui/widgets/soft_card.dart';

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
        padding: const EdgeInsets.all(20),
        children: [
          SoftCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('🌱', style: TextStyle(fontSize: 48)),
                const SizedBox(height: 12),
                Text('Sprout', style: theme.textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text(
                  'Take care of yourself, and a little garden grows with you. '
                  'Everything stays on this phone: no accounts, no tracking, no internet needed.',
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
