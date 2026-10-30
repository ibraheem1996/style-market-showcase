import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../products/domain/entities/product_card_entity.dart';
import 'recommendation_context.dart';
import 'recommendations_pagination_entity.dart';

part 'recommendations_response_entity.freezed.dart';

@freezed
abstract class RecommendationsResponseEntity
    with _$RecommendationsResponseEntity {
  const factory RecommendationsResponseEntity({
    required RecommendationContext context,
    required String strategy,
    required List<ProductCardEntity> items,
    required RecommendationsPaginationEntity pagination,
  }) = _RecommendationsResponseEntity;
}
