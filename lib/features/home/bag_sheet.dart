import 'package:flutter/material.dart';

import '../shop/basket_sheet.dart';
import 'seed_sheets.dart';

/// The Bag: seeds and fruit in one place.
Future<void> showBagSheet(BuildContext context, {int initialTab = 0}) => showModalBottomSheet<void>(
  context: context,
  useRootNavigator: true,
  isScrollControlled: true,
  useSafeArea: true,
  builder: (_) => FractionallySizedBox(
    heightFactor: 0.8,
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
