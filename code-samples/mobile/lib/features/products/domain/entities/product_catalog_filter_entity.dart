import 'package:freezed_annotation/freezed_annotation.dart';
part 'product_catalog_filter_entity.freezed.dart';

/// Query filters accepted by the product catalog endpoint.
///
/// Listing owns the UI that edits these values, while products owns the
/// catalog request contract that sends them to `/listing`.
@freezed
abstract class ProductCatalogFilterSelection
    with _$ProductCatalogFilterSelection {
  const factory ProductCatalogFilterSelection({
    required List<int> selectedColorIds,
    required List<int> selectedSizeIds,
    double? minPrice,
    double? maxPrice,
  }) = _ProductCatalogFilterSelection;

  /// Creates a clean, unselected filter state.
  factory ProductCatalogFilterSelection.empty() =>
      const ProductCatalogFilterSelection(
        selectedColorIds: [],
        selectedSizeIds: [],
        minPrice: null,
        maxPrice: null,
      );
}

extension ProductCatalogFilterSelectionX on ProductCatalogFilterSelection {
  /// Checks if no filters are currently applied.
  bool get isEmpty =>
      selectedColorIds.isEmpty &&
      selectedSizeIds.isEmpty &&
      minPrice == null &&
      maxPrice == null;

  /// Returns the total number of distinct active filters.
  /// Price range is considered as a single active filter.
  int get activeCount =>
      selectedColorIds.length +
      selectedSizeIds.length +
      (minPrice != null || maxPrice != null ? 1 : 0);
}
