import 'package:flutter/material.dart';

/// Sprout's hand-made look: a soft outline and a solid "lip" along the bottom,
/// like a little painted button you can press down.
class Chunky {
  static const _warm = Color(0xFF8C6E5A);

  /// The outline for something filled with [fill].
  static Color edge(Color fill, {bool dark = false}) =>
      dark ? Color.lerp(fill, Colors.white, 0.10)! : Color.lerp(fill, _warm, 0.26)!;

  /// The lip under something filled with [fill].
  static Color lip(Color fill, {bool dark = false}) =>
      dark ? Color.lerp(fill, Colors.black, 0.45)! : Color.lerp(fill, _warm, 0.2)!;

  /// A box with an outline and a lip, for cards, pills and panels.
  static BoxDecoration box(
    Color fill, {
    required BorderRadius radius,
    bool dark = false,
    double lipHeight = 3,
    double outline = 1.5,
  }) => BoxDecoration(
    color: fill,
    borderRadius: radius,
    border: Border.all(
      color: edge(fill, dark: dark),
      width: outline,
    ),
    boxShadow: [
      BoxShadow(
        color: lip(fill, dark: dark),
        offset: Offset(0, lipHeight),
      ),
    ],
  );
}

/// A rounded button shape with a soft outline and a darker band along its
/// bottom edge. It doesn't know the fill, so it darkens whatever is under it.
class ChunkyBorder extends OutlinedBorder {
  const ChunkyBorder({this.radius = 100, this.lipHeight = 4, super.side});

  final double radius;
  final double lipHeight;

  static const _lip = Color(0x38593A2A);
  static const _edge = Color(0x40593A2A);

  /// Pressed buttons sink: their lip gets thinner.
  static WidgetStateProperty<OutlinedBorder> pressable({double radius = 100}) => WidgetStateProperty.resolveWith(
    (states) => ChunkyBorder(radius: radius, lipHeight: states.contains(WidgetState.pressed) ? 1.5 : 4),
  );

  RRect _rrect(Rect rect) => RRect.fromRectAndRadius(rect, Radius.circular(radius));

  @override
  EdgeInsetsGeometry get dimensions => const EdgeInsets.all(1.5);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) => Path()..addRRect(_rrect(rect).deflate(1.5));

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) => Path()..addRRect(_rrect(rect));

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final shape = _rrect(rect);
    canvas.save();
    canvas.clipRRect(shape);
    canvas.drawRect(Rect.fromLTRB(rect.left, rect.bottom - lipHeight, rect.right, rect.bottom), Paint()..color = _lip);
    canvas.restore();
    canvas.drawRRect(
      shape.deflate(0.75),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = side.style == BorderStyle.none ? 1.5 : side.width
        ..color = side.style == BorderStyle.none ? _edge : side.color,
    );
  }

  @override
  ShapeBorder scale(double t) => ChunkyBorder(radius: radius * t, lipHeight: lipHeight * t, side: side.scale(t));

  @override
  ChunkyBorder copyWith({BorderSide? side, double? radius, double? lipHeight}) =>
      ChunkyBorder(radius: radius ?? this.radius, lipHeight: lipHeight ?? this.lipHeight, side: side ?? this.side);

  @override
  ShapeBorder? lerpFrom(ShapeBorder? a, double t) => a is ChunkyBorder
      ? ChunkyBorder(
          radius: lerpDouble(a.radius, radius, t),
          lipHeight: lerpDouble(a.lipHeight, lipHeight, t),
          side: BorderSide.lerp(a.side, side, t),
        )
      : super.lerpFrom(a, t);

  @override
  ShapeBorder? lerpTo(ShapeBorder? b, double t) => b is ChunkyBorder
      ? ChunkyBorder(
          radius: lerpDouble(radius, b.radius, t),
          lipHeight: lerpDouble(lipHeight, b.lipHeight, t),
          side: BorderSide.lerp(side, b.side, t),
        )
      : super.lerpTo(b, t);

  static double lerpDouble(double a, double b, double t) => a + (b - a) * t;

  @override
  bool operator ==(Object other) =>
      other is ChunkyBorder && other.radius == radius && other.lipHeight == lipHeight && other.side == side;

  @override
  int get hashCode => Object.hash(radius, lipHeight, side);
}
