import 'package:flutter/material.dart';

/// Equal-width tiles in [columns], where each row grows to fit its tallest
/// tile. Unlike a fixed aspect ratio, nothing overflows at large text sizes.
class TileGrid extends StatelessWidget {
  const TileGrid({super.key, required this.columns, required this.children, this.spacing = 10});

  final int columns;
  final List<Widget> children;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var start = 0; start < children.length; start += columns) {
      final cells = children.sublist(start, (start + columns).clamp(0, children.length));
      rows.add(
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < columns; i++) ...[
                if (i > 0) SizedBox(width: spacing),
                Expanded(child: i < cells.length ? cells[i] : const SizedBox.shrink()),
              ],
            ],
          ),
        ),
      );
      if (start + columns < children.length) rows.add(SizedBox(height: spacing));
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: rows);
  }
}
