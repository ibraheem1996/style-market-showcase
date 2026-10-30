import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:my_project/features/products/domain/entities/product_card_entity.dart';
import 'package:my_project/core/errors/failure.dart';

part 'recently_viewed_state.freezed.dart';

@freezed
class RecentlyViewedState with _$RecentlyViewedState {
  const factory RecentlyViewedState.initial() = _Initial;
  const factory RecentlyViewedState.loading() = _Loading;
  const factory RecentlyViewedState.success(List<ProductCardEntity> items) =
      _Success;
  const factory RecentlyViewedState.empty() = _Empty;
  const factory RecentlyViewedState.error(Failure failure) = _Error;
}
