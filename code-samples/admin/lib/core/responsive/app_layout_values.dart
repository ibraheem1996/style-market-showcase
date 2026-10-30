import 'package:flutter/widgets.dart';

import 'app_screen_info.dart';
import 'app_spacing.dart';
import 'app_widths.dart';

abstract final class AppLayoutValues {
  static double topBarHeight(AppScreenInfo screen) {
    if (screen.isCompact) return 116;
    if (screen.isMedium) return 76;
    return 80;
  }

  static double contentMaxWidth(AppScreenInfo screen) {
    if (screen.isWide) return AppWidths.dashboardContentMax;
    return double.infinity;
  }

  static EdgeInsets dialogInsetPadding(AppScreenInfo screen) {
    return EdgeInsets.symmetric(
      horizontal: screen.isCompact ? AppSpacing.lg : AppSpacing.xxl,
      vertical: screen.isCompact ? AppSpacing.xl : AppSpacing.xxxl,
    );
  }

  static double buttonHeight(AppScreenInfo screen) {
    if (screen.isCompact) return 46;
    return 50;
  }
}
