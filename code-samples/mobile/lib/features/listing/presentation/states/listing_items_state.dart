import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/errors/failure.dart';
import '../../../products/domain/entities/pagination_entity.dart';
import '../../../products/domain/entities/product_card_entity.dart';

part 'listing_items_state.freezed.dart';

enum ListingEmptyReason { catalog, search }

@freezed
sealed class ListingItemsState with _$ListingItemsState {
  const factory ListingItemsState.initial() = _Initial;
  const factory ListingItemsState.loading() = _Loading;
  const factory ListingItemsState.success({
    required List<ProductCardEntity> items,
    required PaginationEntity pagination,
    @Default(false) bool isRefreshing,
    @Default(false) bool isLoadingMore,
    Failure? loadMoreFailure,
  }) = _Success;
  const factory ListingItemsState.empty({
    required ListingEmptyReason reason,
    required PaginationEntity pagination,
  }) = _Empty;
  const factory ListingItemsState.error(Failure failure) = _Error;
}
