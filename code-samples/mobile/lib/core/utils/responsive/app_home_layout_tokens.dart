import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/app_typography.dart';
import 'app_design_tokens.dart';
import 'app_window_class.dart';

abstract final class AppProductCardSizes {
  static double horizontalRailWidth({
    required AppWindowClass windowClass,
    required double textScale,
  }) {
    return switch ((windowClass, textScale)) {
      (AppWindowClass.compact, >= 2) => 250,
      (AppWindowClass.compact, >= 1.3) => 220,
      (AppWindowClass.compact, _) => 190,

      (AppWindowClass.medium, >= 2) => 260,
      (AppWindowClass.medium, >= 1.3) => 230,
      (AppWindowClass.medium, _) => 200,

      (AppWindowClass.expanded, >= 2) => 270,
      (AppWindowClass.expanded, >= 1.3) => 240,
      (AppWindowClass.expanded, _) => 210,
    };
  }
}

abstract final class AppHomeCategoryLayoutTokens {
  static double mediaExtent(AppWindowClass windowClass) {
    return switch (windowClass) {
      AppWindowClass.compact => 96,
      AppWindowClass.medium => 104,
      AppWindowClass.expanded => 112,
    };
  }
}

/// The same text style and geometry must be used by both the visible tabs
/// and [preferredHeight] so the SliverAppBar bottom reserves matching space.
abstract final class AppHomeAudienceLayout {
  static const double textLineHeight = 1.2;

  static const double horizontalPadding = AppSpacing.xl;
  static const double verticalPadding = AppSpacing.xs;
  static const double indicatorGap = 3;

  static TextStyle textStyle(BuildContext context) {
    return context.appTypography.navigation.selectedLabel;
  }

  static double indicatorHeight(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final windowClass = AppWindowClass.fromSize(mediaQuery.size);

    final fontSize = textStyle(context).fontSize!;
    final scaledFontSize = mediaQuery.textScaler.scale(fontSize);
    final textScale = scaledFontSize / fontSize;

    return switch ((windowClass, textScale)) {
      (AppWindowClass.compact, >= 2) => 5,
      (AppWindowClass.compact, >= 1.3) => 4.5,
      (AppWindowClass.compact, _) => 3,

      (AppWindowClass.medium, >= 2) => 4.5,
      (AppWindowClass.medium, >= 1.3) => 4,
      (AppWindowClass.medium, _) => 3,

      (AppWindowClass.expanded, >= 2) => 4,
      (AppWindowClass.expanded, >= 1.3) => 3.5,
      (AppWindowClass.expanded, _) => 3,
    };
  }

  static double preferredHeight(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final style = textStyle(context);

    final scaledFontSize = mediaQuery.textScaler.scale(style.fontSize!);

    final effectiveLineHeight =
        mediaQuery.lineHeightScaleFactorOverride ?? style.height!;

    final textHeight = scaledFontSize * effectiveLineHeight;

    final contentHeight =
        textHeight +
        verticalPadding * 2 +
        indicatorGap +
        indicatorHeight(context) +
        2;

    return math.max(kMinInteractiveDimension, contentHeight);
  }
}

abstract final class AppHomeBannerLayoutTokens {
  static const double maximumWidth = 540;
  static const double shortWindowMaximumWidth = 370;
}

abstract final class AppHomeCollectionLayoutTokens {
  static const double compactWidthFraction = 0.90;
  static const double mediumWidthFraction = 0.72;
  static const double expandedWidthFraction = 0.55;

  static const double maximumWidth = 520;
  static const double shortWindowMaximumWidth = 420;

  static double cardWidth({
    required double availableWidth,
    required AppWindowClass windowClass,
    required bool shortWindow,
  }) {
    if (!availableWidth.isFinite || availableWidth <= 0) {
      throw ArgumentError.value(
        availableWidth,
        'availableWidth',
        'must be finite and greater than zero',
      );
    }

    final widthFraction = switch (windowClass) {
      AppWindowClass.compact => compactWidthFraction,
      AppWindowClass.medium => mediumWidthFraction,
      AppWindowClass.expanded => expandedWidthFraction,
    };

    final maximumAllowedWidth = shortWindow
        ? shortWindowMaximumWidth
        : maximumWidth;

    final preferredWidth = availableWidth * widthFraction;

    return preferredWidth.clamp(1.0, maximumAllowedWidth).toDouble();
  }
}
