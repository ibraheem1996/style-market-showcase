import 'package:flutter/widgets.dart';

import 'app_screen_info.dart';

abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;

  static double pageHorizontal(AppScreenInfo screen) {
    if (screen.isCompact) return lg;
    if (screen.isMedium) return xl;
    if (screen.isExpanded) return xxl;
    return xxxl;
  }

  static double pageVertical(AppScreenInfo screen) {
    if (screen.isCompact) return lg;
    if (screen.isMedium) return xl;
    if (screen.isExpanded) return xxl;
    return xxxl;
  }

  static EdgeInsets pagePadding(AppScreenInfo screen) {
    return EdgeInsets.symmetric(
      horizontal: pageHorizontal(screen),
      vertical: pageVertical(screen),
    );
  }

  static double section(AppScreenInfo screen) {
    if (screen.isCompact) return lg;
    if (screen.isMedium) return xl;
    if (screen.isExpanded) return xxl;
    return 28;
  }

  static double cardPadding(AppScreenInfo screen) {
    if (screen.isCompact) return lg;
    if (screen.isMedium) return xl;
    return xxl;
  }
}
