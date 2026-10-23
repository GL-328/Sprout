import 'package:flutter/material.dart';

import '../../ui/widgets/coming_soon.dart';

class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      const ComingSoon(title: 'Today', emoji: '☀️', message: 'Your gentle quests will live here soon.');
}
