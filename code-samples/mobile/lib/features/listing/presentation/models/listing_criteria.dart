import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../products/domain/entities/product_catalog_filter_entity.dart';
import '../../../products/domain/entities/product_catalog_source.dart';

part 'listing_criteria.freezed.dart';

/// Immutable identity for one Listing product request.
///
/// Pagination is intentionally excluded so page 1, refresh, and load-more can
/// share the same criteria while the controller validates stale responses.
@freezed
abstract class ListingCriteria with _$ListingCriteria {
  const factory ListingCriteria({
    required int audienceId,
    required ProductCatalogSource source,
    @Default('') String searchQuery,
    required ProductCatalogFilterSelection filters,
    @Default('') String sort,
  }) = _ListingCriteria;

  factory ListingCriteria.initial({
    required int audienceId,
    required ProductCatalogSource source,
    ProductCatalogFilterSelection? filters,
    String searchQuery = '',
    String sort = '',
  }) {
    return ListingCriteria(
      audienceId: audienceId,
      source: source,
      searchQuery: searchQuery.trim(),
      filters: filters ?? ProductCatalogFilterSelection.empty(),
      sort: sort,
    );
  }
}
