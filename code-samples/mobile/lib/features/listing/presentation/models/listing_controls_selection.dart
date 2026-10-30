import '../../../products/domain/entities/product_catalog_filter_entity.dart';

class ListingControlsSelection {
  const ListingControlsSelection({required this.filters, required this.sort});

  final ProductCatalogFilterSelection filters;
  final String sort;

  factory ListingControlsSelection.empty() => ListingControlsSelection(
    filters: ProductCatalogFilterSelection.empty(),
    sort: '',
  );

  ListingControlsSelection copyWith({
    ProductCatalogFilterSelection? filters,
    String? sort,
  }) {
    return ListingControlsSelection(
      filters: filters ?? this.filters,
      sort: sort ?? this.sort,
    );
  }
}
