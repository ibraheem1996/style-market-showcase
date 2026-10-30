import 'app_screen_info.dart';

abstract final class AppTextSizes {
  static double title(AppScreenInfo screen) {
    if (screen.isCompact) return 22;
    if (screen.isWide) return 26;
    return 24;
  }

  static double sectionTitle(AppScreenInfo screen) {
    if (screen.isExpanded || screen.isWide) return 20;
    return 18;
  }

  static double body(AppScreenInfo screen) {
    if (screen.isExpanded || screen.isWide) return 15;
    return 14;
  }

  static double label(AppScreenInfo screen) {
    if (screen.isWide) return 14;
    return 13;
  }

  static double button(AppScreenInfo screen) {
    if (screen.isWide) return 15;
    return 14;
  }

  static double table(AppScreenInfo screen) {
    if (screen.isExpanded || screen.isWide) return 14;
    return 13;
  }

  static double tooltip(AppScreenInfo screen) {
    if (screen.isExpanded || screen.isWide) return 12;
    return 10;
  }
}
