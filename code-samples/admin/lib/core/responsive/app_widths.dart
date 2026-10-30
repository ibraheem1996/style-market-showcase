import 'dart:math' as math;

import 'app_spacing.dart';

abstract final class AppWidths {
  static const double sidebarExpanded = 260;
  static const double sidebarCollapsed = 80;
  static const double navigationRail = 80;
  static const double drawer = 304;

  static const double loginFormMax = 420;
  static const double standardFormMax = 560;
  static const double wideFormMax = 640;

  static const double standardPageMax = 1280;
  static const double detailPageMax = 1120;
  static const double dashboardContentMax = 1440;
  static const double errorViewMax = 460;

  static const double statCardMin = 220;
  static const double statCardMax = 360;
  static const double formCardMax = 640;
  static const double settingsCardMax = 760;

  static const double tableMinCompact = 720;
  static const double tableMinStandard = 960;
  static const double tableMinDenseAdmin = 1120;

  static double drawerForScreen(double screenWidth) {
    return math.min(drawer, math.max(0, screenWidth - AppSpacing.xxxl));
  }
}
