import 'app_window_class.dart';

/// Semantic width profiles for centered application content.
enum ResponsiveContentProfile {
  form(maxWidth: 560),
  standard(maxWidth: 760),
  catalog(maxWidth: 900);

  const ResponsiveContentProfile({required this.maxWidth});

  /// Maximum width of the surface, including its horizontal gutters.
  final double maxWidth;
}

/// Central horizontal gutters shared by all responsive content profiles.
abstract final class ResponsiveContentGutters {
  static const double compact = 12;
  static const double mediumAndExpanded = 24;

  static double forWindowClass(AppWindowClass windowClass) {
    return switch (windowClass) {
      AppWindowClass.compact => compact,
      AppWindowClass.medium || AppWindowClass.expanded => mediumAndExpanded,
    };
  }
}

/// Resolves the horizontal inset needed to keep content centered
/// while preserving the minimum responsive gutter.
abstract final class ResponsiveContentInsets {
  static double horizontal({
    required double availableWidth,
    required ResponsiveContentProfile profile,
  }) {
    final windowClass = AppWindowClass.fromWidth(availableWidth);

    final minimumGutter = ResponsiveContentGutters.forWindowClass(windowClass);

    final extraWidth = availableWidth - profile.maxWidth;

    final centeredInset = extraWidth > 0 ? extraWidth / 2 : 0.0;

    return centeredInset > minimumGutter ? centeredInset : minimumGutter;
  }
}
