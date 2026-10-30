import 'package:flutter/widgets.dart';

import 'app_window_class.dart';
import 'app_responsive_value.dart';

/// Fixed spacing values that do not scale with the application window.
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
}

/// Semantic icon sizes resolved from the current application window class.
///
/// Each responsive role owns its Compact, Medium, and Expanded calibration;
/// explicitly fixed micro roles remain constant. Icon sizes do not use a
/// global multiplier and do not include padding, constraints, or hit target
/// geometry.
abstract final class AppIconSizes {
  /// Back, close, search, and overflow glyphs inside an AppBar.
  static double appBarAction(BuildContext context) => _responsive(
    context,
    compact: _increaseSize(context, 24),
    medium: _increaseSize(context, 26),
    expanded: _increaseSize(context, 28),
  );

  /// Standalone IconButton glyphs outside AppBar chrome.
  static double standardAction(BuildContext context) =>
      _responsive(context, compact: 20, medium: 23, expanded: 26);

  /// Icons representing primary application destinations.
  static double navigationDestination(BuildContext context) =>
      _responsive(context, compact: 20, medium: 22, expanded: 24);

  /// Leading, suffix, and visibility glyphs in input and search surfaces.
  static double fieldIcon(BuildContext context) => _responsive(
    context,
    compact: _increaseSize(context, 20),
    medium: _increaseSize(context, 22),
    expanded: _increaseSize(context, 24),
  );

  /// Leading icons for list rows, settings, and summary content.
  static double listLeading(BuildContext context) => _responsive(
    context,
    compact: _increaseSize(context, 20),
    medium: _increaseSize(context, 22),
    expanded: _increaseSize(context, 24),
  );

  /// Chevrons and directional indicators at the edge of a row.
  static double listDisclosure(BuildContext context) =>
      _responsive(context, compact: 20, medium: 22, expanded: 24);

  /// Dense interactive glyphs such as quantity and chip actions.
  static double compactAction(BuildContext context) => _responsive(
    context,
    compact: _increaseSize(context, 17),
    medium: _increaseSize(context, 19),
    expanded: _increaseSize(context, 21),
  );

  /// Glyphs paired with labels inside text, outlined, or filled buttons.
  static double buttonAction(BuildContext context) => _responsive(
    context,
    compact: _increaseSize(context, 22),
    medium: _increaseSize(context, 23),
    expanded: _increaseSize(context, 24),
  );

  /// Primary selected and unselected indicators.
  static double selectionIndicator(BuildContext context) => _responsive(
    context,
    compact: _increaseSize(context, 24),
    medium: _increaseSize(context, 26),
    expanded: _increaseSize(context, 28),
  );

  /// Selection indicators constrained by color and variant swatches.
  static double swatchSelectionIndicator(BuildContext context) =>
      _responsive(context, compact: 20, medium: 22, expanded: 24);

  /// Cart action glyph over product media.
  static double productCartAction(BuildContext context) =>
      _responsive(context, compact: 20, medium: 22, expanded: 24);

  /// Favorite action glyph over product media.
  static double productFavoriteAction(BuildContext context) =>
      _responsive(context, compact: 32, medium: 34, expanded: 36);

  /// Store identity glyph in Home chrome.
  static double homeBrand(BuildContext context) =>
      _responsive(context, compact: 24, medium: 26, expanded: 28);

  /// Disclosure glyph placed directly beside expandable text.
  static double inlineDisclosure(BuildContext context) =>
      _responsive(context, compact: 20, medium: 22, expanded: 24);

  /// Glyph representing an order lifecycle status.
  static double orderStatus(BuildContext context) =>
      _responsive(context, compact: 24, medium: 26, expanded: 28);

  /// Placeholder glyph inside an account identity avatar.
  static double avatarPlaceholder(BuildContext context) => _responsive(
    context,
    compact: _increaseSize(context, 24),
    medium: _increaseSize(context, 26),
    expanded: _increaseSize(context, 28),
  );

  /// Glyph representing a step in Checkout progress chrome.
  static double checkoutStep(BuildContext context) => _responsive(
    context,
    compact: _increaseSize(context, 24),
    medium: _increaseSize(context, 26),
    expanded: _increaseSize(context, 28),
  );

  /// Error or unavailable glyph inside a small media thumbnail.
  static double mediaStatusSmall(BuildContext context) =>
      _responsive(context, compact: 18, medium: 20, expanded: 22);

  /// Error or unavailable glyph inside regular card media.
  static double mediaStatus(BuildContext context) =>
      _responsive(context, compact: 20, medium: 22, expanded: 24);

  /// Error or unavailable glyph inside prominent media.
  static double prominentMediaStatus(BuildContext context) =>
      _responsive(context, compact: 24, medium: 26, expanded: 28);

  /// Media-unavailable glyph in a large or full-screen media frame.
  static double largeMediaStatus(BuildContext context) =>
      _responsive(context, compact: 44, medium: 48, expanded: 52);

  /// Artwork-scale fallback glyph for a hero media surface.
  static double heroMediaStatus(BuildContext context) =>
      _responsive(context, compact: 100, medium: 104, expanded: 108);

  /// Centered glyph supporting an empty, unavailable, or failure page state.
  static double pageState(BuildContext context) =>
      _responsive(context, compact: 64, medium: 68, expanded: 72);

  /// Illustration-like glyph used by a visually prominent page state.
  static double prominentPageState(BuildContext context) =>
      _responsive(context, compact: 72, medium: 76, expanded: 80);

  /// Micro decoration that intentionally remains stable on wider windows.
  static const double decorativeMicro = 16;

  static double _responsive(
    BuildContext context, {
    required double compact,
    required double medium,
    required double expanded,
  }) {
    return switch (_windowClass(context)) {
      AppWindowClass.compact => compact,
      AppWindowClass.medium => medium,
      AppWindowClass.expanded => expanded,
    };
  }

  static AppWindowClass _windowClass(BuildContext context) {
    final width = MediaQuery.maybeSizeOf(context)?.width ?? 0;
    return AppWindowClass.fromWidth(width);
  }

  static double _increaseSize(BuildContext context, double size) {
    return AppTextScaleValue.resolve<double>(
      context,
      normal: size,
      large: size + 4,
      extraLarge: size + 6,
    );
  }
}

/// Fixed dimensions for controls and their interactive hit areas.
abstract final class AppControlSizes {
  static const double small = 32;
  static const double medium = 40;
  static const double minimumTapTarget = 48;

  static const double defaultProgressIndicatorImageSize = 20;

  /// Width reserved for leading and action controls in shared chrome.
  static const double appBarActionLane = minimumTapTarget;

  static double appBarToolbarHeight(BuildContext context) {
    return switch (_windowClass(context)) {
      AppWindowClass.compact => 56,
      AppWindowClass.medium => 60,
      AppWindowClass.expanded => 64,
    };
  }

  static AppWindowClass _windowClass(BuildContext context) {
    final width = MediaQuery.maybeSizeOf(context)?.width ?? 0;
    return AppWindowClass.fromWidth(width);
  }
}
