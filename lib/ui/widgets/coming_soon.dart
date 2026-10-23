import 'package:flutter/material.dart';

import 'soft_card.dart';

/// Friendly placeholder for screens that arrive in a later stage.
class ComingSoon extends StatelessWidget {
  const ComingSoon({super.key, required this.title, required this.emoji, required this.message});

  final String title;
  final String emoji;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
        children: [
          SoftCard(
            padding: const EdgeInsets.all(28),
            child: Column(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 56)),
                const SizedBox(height: 16),
                Text(message, style: theme.textTheme.titleMedium, textAlign: TextAlign.center),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
