import 'package:freezed_annotation/freezed_annotation.dart';
part 'product_catalog_source.freezed.dart';

enum ProductCatalogSourceType { category, collection, section }

@freezed
abstract class ProductCatalogSource with _$ProductCatalogSource {
  /// Describes the backend listing source used by product catalog consumers.
  ///
  /// Home and Listing both use this contract, so it lives in products instead
  /// of being owned by the Listing page feature.
  const factory ProductCatalogSource({
    required ProductCatalogSourceType sourceType,
    required String sourceId,
    required String titleAr,
    required String titleEn,
  }) = _ProductCatalogSource;
  
}
