import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Tells screens inside the tab shell how much room the floating navigation
/// bar takes at the bottom. Screens outside the shell (pushed pages, sheets,
/// dialogs) don't see it, so only the system bar counts for them.
class ShellInsets extends InheritedWidget {
  const ShellInsets({super.key, required this.navBarHeight, required super.child});

  /// From the bottom of the screen to the top of the floating nav bar,
  /// including the phone's own system bar underneath it.
  final double navBarHeight;

  static ShellInsets? maybeOf(BuildContext context) => context.dependOnInheritedWidgetOfExactType<ShellInsets>();

  @override
  bool updateShouldNotify(ShellInsets old) => old.navBarHeight != navBarHeight;
}

/// The one place that knows what covers the bottom of the screen: the
/// floating nav bar, the gesture or three-button system bar, the keyboard,
/// and a floating "+" button.
abstract final class AppInsets {
  /// Height of the floating nav bar itself.
  static const navBar = 68.0;

  /// Gap kept between the nav bar and the screen edge or system bar.
  static const navBarMargin = 12.0;

  /// Space a floating action button needs above the last list item.
  static const fab = 80.0;

  /// Breathing room after the last item of a list.
  static const endGap = 24.0;

  /// Height of the phone's system navigation (gesture bar or buttons).
  static double system(BuildContext context) => MediaQuery.viewPaddingOf(context).bottom;

  static double keyboard(BuildContext context) => MediaQuery.viewInsetsOf(context).bottom;

  /// Space covered at the bottom: nav bar (inside the shell) or system bar,
  /// or the keyboard when it is taller.
  static double covered(BuildContext context) {
    final shell = ShellInsets.maybeOf(context);
    final base = shell?.navBarHeight ?? system(context);
    return math.max(base, keyboard(context));
  }

  /// Bottom padding for any scrolling list, grid or sheet, so its last item
  /// can scroll fully clear of everything covering the bottom.
  static double scrollEnd(BuildContext context, {bool withFab = false}) =>
      covered(context) + endGap + (withFab ? fab : 0);

  /// Standard list padding: [horizontal] at the sides, [top], and a safe end.
  static EdgeInsets list(BuildContext context, {double horizontal = 20, double top = 8, bool withFab = false}) =>
      EdgeInsets.fromLTRB(horizontal, top, horizontal, scrollEnd(context, withFab: withFab));

  /// Total height reserved by the shell for its nav bar, given the system bar.
  static double shellNavHeight(double systemBottom) => navBar + math.max(systemBottom, navBarMargin) + 8;
}

/// Opens a full-screen page above the tab bar, so nothing covers it.
Future<T?> pushPage<T>(BuildContext context, Widget page) =>
    Navigator.of(context, rootNavigator: true).push<T>(MaterialPageRoute<T>(builder: (_) => page));

/// A bottom sheet that never hides behind the system bar or keyboard. Short
/// content sizes itself and scrolls when it gets too tall. Pass [heightFactor]
/// for sheets with their own scrolling list or tabs.
Future<T?> showSproutSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  double? heightFactor,
  bool scrollable = true,
}) => showModalBottomSheet<T>(
  context: context,
  useRootNavigator: true,
  isScrollControlled: true,
  useSafeArea: true,
  builder: (sheetContext) {
    final media = MediaQuery.of(sheetContext);
    final keyboard = media.viewInsets.bottom;
    final system = media.viewPadding.bottom;
    Widget content = Builder(builder: builder);
    if (heightFactor != null) {
      content = SizedBox(height: (media.size.height - keyboard) * heightFactor, child: content);
      return Padding(
        padding: EdgeInsets.only(bottom: keyboard),
        child: content,
      );
    }
    if (scrollable) {
      content = SingleChildScrollView(
        padding: EdgeInsets.only(bottom: system + 8),
        child: content,
      );
    } else {
      content = Padding(
        padding: EdgeInsets.only(bottom: system + 8),
        child: content,
      );
    }
    return Padding(
      padding: EdgeInsets.only(bottom: keyboard),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: (media.size.height - keyboard) * 0.92),
        child: content,
      ),
    );
  },
);
