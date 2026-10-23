import 'package:flutter/material.dart';

import '../../ui/widgets/coming_soon.dart';

class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context) => const ComingSoon(
    title: 'Shop',
    emoji: '🧺',
    message: 'New plots, cosy decorations and recipes are on their way.',
  );
}
