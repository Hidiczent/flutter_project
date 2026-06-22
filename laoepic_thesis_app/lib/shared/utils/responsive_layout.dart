/// Responsive sizing and scroll helpers for phone layouts.
library;

import 'package:flutter/material.dart';

/// Shared sizing helpers so screens scale on small/large phones without overflow.
class ResponsiveLayout {
  ResponsiveLayout._();

  /// Current logical screen size from [MediaQuery].
  static Size screenSize(BuildContext context) => MediaQuery.sizeOf(context);

  /// Viewport width in logical pixels.
  static double screenWidth(BuildContext context) => screenSize(context).width;

  /// Viewport height in logical pixels.
  static double screenHeight(BuildContext context) => screenSize(context).height;

  /// Shorter side of the screen (used for logo scaling).
  static double shortestSide(BuildContext context) =>
      screenSize(context).shortestSide;

  /// Horizontal page padding (16–32).
  static double hPadding(BuildContext context) =>
      (screenWidth(context) * 0.06).clamp(16.0, 32.0);

  /// Vertical gap between form blocks (8–24).
  static double gap(BuildContext context, {double factor = 0.02}) =>
      (screenHeight(context) * factor).clamp(8.0, 24.0);

  /// Auth / branding logo — scales with screen, capped so it never dominates.
  static double logoSize(BuildContext context) =>
      (shortestSide(context) * 0.28).clamp(85.0, 170.0);

  /// Scales text down slightly on smaller phones; caps large accessibility sizes.
  static double textScale(BuildContext context) {
    final width = screenWidth(context);
    final byWidth = (width / 390).clamp(0.86, 1.0);
    final system = MediaQuery.textScalerOf(context).scale(14) / 14;
    return (byWidth * system).clamp(0.86, 1.08);
  }

  /// [TextScaler] applied at the [MaterialApp] root.
  static TextScaler textScaler(BuildContext context) =>
      TextScaler.linear(textScale(context));

  /// Font size in scaled logical pixels (`sp`).
  static double sp(BuildContext context, double size) =>
      size * textScale(context);

  /// Home / package image carousel height.
  static double carouselHeight(BuildContext context) =>
      (screenWidth(context) * 0.52).clamp(160.0, 260.0);

  /// Account header banner height.
  static double profileHeaderHeight(BuildContext context) =>
      (screenHeight(context) * 0.26).clamp(180.0, 240.0);

  /// Default symmetric padding for scrollable pages.
  static EdgeInsets pagePadding(BuildContext context) => EdgeInsets.symmetric(
        horizontal: hPadding(context),
        vertical: gap(context, factor: 0.015),
      );
}

/// Scrollable body that centers content when it fits, scrolls when it does not.
class ResponsiveScrollBody extends StatelessWidget {
  const ResponsiveScrollBody({
    super.key,
    required this.child,
    this.padding,
    this.keyboardInset = true,
    this.centerWhenFits = true,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final bool keyboardInset;
  final bool centerWhenFits;

  @override
  Widget build(BuildContext context) {
    final resolved = (padding ?? ResponsiveLayout.pagePadding(context))
        .resolve(Directionality.of(context));
    final bottomInset =
        keyboardInset ? MediaQuery.viewInsetsOf(context).bottom : 0.0;
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            resolved.left,
            resolved.top,
            resolved.right,
            resolved.bottom + bottomInset,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: centerWhenFits
                ? IntrinsicHeight(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [child],
                    ),
                  )
                : child,
          ),
        );
      },
    );
  }
}

/// Lao Epic logo scaled for the current screen.
class LaoEpicLogo extends StatelessWidget {
  const LaoEpicLogo({super.key, this.size});

  final double? size;

  @override
  Widget build(BuildContext context) {
    final side = size ?? ResponsiveLayout.logoSize(context);
    return Center(
      child: Image.asset(
        'assets/images/lao_epic_logo.png',
        height: side,
        width: side,
        fit: BoxFit.contain,
      ),
    );
  }
}
