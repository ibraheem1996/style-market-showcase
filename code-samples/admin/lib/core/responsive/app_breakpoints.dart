enum AppScreenClass { compact, medium, expanded, wide }

abstract final class AppBreakpoints {
  static const double medium = 730;
  static const double expanded = 1024;
  static const double wide = 1440;

  static AppScreenClass classify(double width) {
    if (width < medium) {
      return AppScreenClass.compact;
    }

    if (width < expanded) {
      return AppScreenClass.medium;
    }

    if (width < wide) {
      return AppScreenClass.expanded;
    }

    return AppScreenClass.wide;
  }
}
