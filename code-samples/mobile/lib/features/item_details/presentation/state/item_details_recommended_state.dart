import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/errors/failure.dart';
import '../../../products/domain/entities/product_card_entity.dart';
import '../../../recommendations/domain/entities/recommendations_pagination_entity.dart';

part 'item_details_recommended_state.freezed.dart';

@freezed
sealed class ItemDetailsRecommendedState with _$ItemDetailsRecommendedState {
  const factory ItemDetailsRecommendedState.initial() = _Initial;
  const factory ItemDetailsRecommendedState.loading() = _Loading;
  const factory ItemDetailsRecommendedState.success({
    required List<ProductCardEntity> items,
    required RecommendationsPaginationEntity pagination,
    @Default(false) bool isLoadingMore,
    Failure? loadMoreFailure,
  }) = ItemDetailsRecommendedSuccess;
  const factory ItemDetailsRecommendedState.empty() = _Empty;
  const factory ItemDetailsRecommendedState.error(Failure failure) = _Error;
}
