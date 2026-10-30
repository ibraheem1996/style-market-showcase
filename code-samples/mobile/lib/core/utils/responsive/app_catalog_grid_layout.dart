/// Semantic catalog layouts supported by the shared width resolver.
enum AppCatalogGridProfile { productCatalog }

/// Content-local geometry for a product catalog.
///
/// Card height is intentionally absent because product metadata grows with
/// content and system text scaling.
final class AppCatalogGridLayout {
  const AppCatalogGridLayout._({
    required this.crossAxisCount,
    required this.horizontalGap,
    required this.verticalGap,
  });

  static const double normalMinimumCardWidth = 144;
  static const double mediumTextMinimumCardWidth = 176;
  static const double largeTextMinimumCardWidth = 208;
  static const int maximumColumns = 4;
  static const double defaultHorizontalGap = 12;
  static const double defaultVerticalGap = 16;

  final int crossAxisCount;
  final double horizontalGap;
  final double verticalGap;

  /// Resolves columns from the actual constrained content width.
  factory AppCatalogGridLayout.resolve({
    AppCatalogGridProfile profile = AppCatalogGridProfile.productCatalog,
    required double availableWidth,
    required double textScaleFactor,
  }) {
    if (!availableWidth.isFinite || availableWidth <= 0) {
      throw ArgumentError.value(
        availableWidth,
        'availableWidth',
        'must be finite and greater than zero',
      );
    }
    if (!textScaleFactor.isFinite || textScaleFactor <= 0) {
      throw ArgumentError.value(
        textScaleFactor,
        'textScaleFactor',
        'must be finite and greater than zero',
      );
    }

    final minimumCardWidth = switch (textScaleFactor) {
      >= 2 => largeTextMinimumCardWidth,
      >= 1.4 => mediumTextMinimumCardWidth,
      _ => normalMinimumCardWidth,
    };

    final widthPerCardWithGap = minimumCardWidth + defaultHorizontalGap;

    final availableWidthWithLastGap = availableWidth + defaultHorizontalGap;

    final fittingColumns = (availableWidthWithLastGap / widthPerCardWithGap)
        .floor();

    final columnCount = fittingColumns.clamp(1, maximumColumns);

    return AppCatalogGridLayout._(
      crossAxisCount: columnCount,
      horizontalGap: defaultHorizontalGap,
      verticalGap: defaultVerticalGap,
    );
  }
}
