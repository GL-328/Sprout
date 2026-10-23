import 'package:flutter/material.dart';

import '../../ui/widgets/coming_soon.dart';

class JournalScreen extends StatelessWidget {
  const JournalScreen({super.key});

  @override
  Widget build(BuildContext context) => const ComingSoon(
    title: 'Journal',
    emoji: '📖',
    message: 'Your moods, plants and garden friends will be collected here.',
  );
}
