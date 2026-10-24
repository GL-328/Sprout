import 'package:flutter/material.dart';

import '../shop/basket_sheet.dart';
import 'seed_sheets.dart';
import '../../ui/layout/insets.dart';

/// The Bag: seeds and fruit in one place.
Future<void> showBagSheet(BuildContext context, {int initialTab = 0}) => showSproutSheet<void>(
  context,
  heightFactor: 0.8,
  builder: (_) => SizedBox.expand(
    child: DefaultTabController(
      length: 2,
      initialIndex: initialTab,
      child: const Column(
        children: [
          TabBar(
            tabs: [
              Tab(text: 'Seeds'),
              Tab(text: 'Fruit'),
            ],
          ),
          SizedBox(height: 12),
          Expanded(child: TabBarView(children: [SeedBagList(), FruitBasket()])),
        ],
      ),
    ),
  ),
);
