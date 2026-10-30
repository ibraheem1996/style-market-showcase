import 'package:flutter/widgets.dart';

import 'app_window_class.dart';

/// Selects a value or provides helpers for the current application-window width class.
abstract final class AppResponsiveValue {
  /// Resolves a value for the current window width class (compact, medium, or expanded).
  static T resolve<T>(
    BuildContext context, {
    required T compact,
    required T medium,
    required T expanded,
  }) {
    return switch (AppWindowClass.fromSize(MediaQuery.sizeOf(context))) {
      AppWindowClass.compact => compact,
      AppWindowClass.medium => medium,
      AppWindowClass.expanded => expanded,
    };
  }

  /// Returns the current window class for the given context.
  static AppWindowClass _windowClass(BuildContext context) {
    return AppWindowClass.fromSize(MediaQuery.sizeOf(context));
  }

  /// Checks if the window width is in the compact range (< 600).
  static bool isCompact(BuildContext context) {
    return _windowClass(context) == AppWindowClass.compact;
  }

  /// Checks if the window width is in the medium range (600 - 840).
  static bool isMedium(BuildContext context) {
    return _windowClass(context) == AppWindowClass.medium;
  }

  /// Checks if the window width is in the expanded range (>= 840).
  static bool isExpanded(BuildContext context) {
    return _windowClass(context) == AppWindowClass.expanded;
  }

  /// Checks if the window width is at least medium (>= 600).
  static bool isAtLeastMedium(BuildContext context) {
    return _windowClass(context) != AppWindowClass.compact;
  }
}

/// Selects a value or provides helpers based on the effective text scale
/// at the provided font size.
abstract final class AppTextScaleValue {
  /// Default base font size used to compute relative text scale.
  static const double defaultBaseFontSize = 14.0;

  /// Resolves a value based on the effective text scale.
  static T resolve<T>(
    BuildContext context, {
    double fontSize = defaultBaseFontSize,
    required T normal,
    required T large,
    required T extraLarge,
  }) {
    final effectiveScale = scaleFactor(context, fontSize: fontSize);

    return switch (effectiveScale) {
      >= 2.0 => extraLarge,
      >= 1.5 => large,
      _ => normal,
    };
  }

  /// Computes the effective text scale factor for the given context and font size.
  static double scaleFactor(
    BuildContext context, {
    double fontSize = defaultBaseFontSize,
  }) {
    final textScaler = MediaQuery.textScalerOf(context);
    return textScaler.scale(fontSize) / fontSize;
  }

  /// Checks if the effective text scale is normal (< 1.5).
  static bool isNormal(
    BuildContext context, {
    double fontSize = defaultBaseFontSize,
  }) {
    return scaleFactor(context, fontSize: fontSize) < 1.5;
  }

  /// Checks if the effective text scale is large or higher (>= 1.5).
  static bool isLarge(
    BuildContext context, {
    double fontSize = defaultBaseFontSize,
  }) {
    return scaleFactor(context, fontSize: fontSize) >= 1.5;
  }

  /// Checks if the effective text scale is strictly large (1.5 <= scale < 2.0).
  static bool isLargeOnly(
    BuildContext context, {
    double fontSize = defaultBaseFontSize,
  }) {
    final scale = scaleFactor(context, fontSize: fontSize);
    return scale >= 1.5 && scale < 2.0;
  }

  /// Checks if the effective text scale is extra large (>= 2.0).
  static bool isExtraLarge(
    BuildContext context, {
    double fontSize = defaultBaseFontSize,
  }) {
    return scaleFactor(context, fontSize: fontSize) >= 2.0;
  }
}

/// Extension on [BuildContext] for ergonomic access to responsive and text-scale helpers.
extension AppResponsiveContextX on BuildContext {
  /// The current window width class (compact, medium, expanded).
  AppWindowClass get windowClass => AppResponsiveValue._windowClass(this);

  /// Whether the window is in the compact width class (< 600).
  bool get isCompact => AppResponsiveValue.isCompact(this);

  /// Whether the window is in the medium width class (600 - 840).
  bool get isMedium => AppResponsiveValue.isMedium(this);

  /// Whether the window is in the expanded width class (>= 840).
  bool get isExpanded => AppResponsiveValue.isExpanded(this);

  /// Whether the window width is at least medium (>= 600).
  bool get isAtLeastMedium => AppResponsiveValue.isAtLeastMedium(this);

  /// Whether the text scale is normal (< 1.5).
  bool get isNormalText => AppTextScaleValue.isNormal(this);

  /// Whether the text scale is large or extra large (>= 1.5).
  bool get isLargeText => AppTextScaleValue.isLarge(this);

  /// Whether the text scale is strictly large (1.5 <= scale < 2.0).
  bool get isLargeTextOnly => AppTextScaleValue.isLargeOnly(this);

  /// Whether the text scale is extra large (>= 2.0).
  bool get isExtraLargeText => AppTextScaleValue.isExtraLarge(this);
}