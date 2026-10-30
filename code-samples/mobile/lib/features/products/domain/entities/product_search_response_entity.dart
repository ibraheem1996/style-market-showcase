import 'package:freezed_annotation/freezed_annotation.dart';

import 'pagination_entity.dart';
import 'product_card_entity.dart';

part 'product_search_response_entity.freezed.dart';

@freezed
abstract class ProductSearchResponseEntity with _$ProductSearchResponseEntity {
  /// A source-free page of backend-ranked product cards.
  const factory ProductSearchResponseEntity({
    required List<ProductCardEntity> items,
    required PaginationEntity pagination,
  }) = _ProductSearchResponseEntity;
}
