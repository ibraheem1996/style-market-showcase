import 'package:freezed_annotation/freezed_annotation.dart';
import 'pagination_entity.dart';
import 'product_card_entity.dart';
import 'source_meta_entity.dart';

part 'product_catalog_response_entity.freezed.dart';

@freezed
abstract class ProductCatalogResponseEntity
    with _$ProductCatalogResponseEntity {
  const factory ProductCatalogResponseEntity({
    @Default([]) List<ProductCardEntity> items,
    @Default(PaginationEntity()) PaginationEntity pagination,
    @Default(SourceMetaEntity()) SourceMetaEntity sourceMeta,
  }) = _ProductCatalogResponseEntity;
}
