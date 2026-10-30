import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/errors/failure.dart';
import '../../../products/domain/entities/pagination_entity.dart';
import '../../../products/domain/entities/product_card_entity.dart';

part 'product_search_state.freezed.dart';

@freezed
sealed class ProductSearchState with _$ProductSearchState {
  const factory ProductSearchState.initial({@Default(false) bool isLongQuery}) =
      _Initial;
  const factory ProductSearchState.loading({required String query}) = _Loading;
  const factory ProductSearchState.empty({
    required String query,
    required PaginationEntity pagination,
  }) = _Empty;
  const factory ProductSearchState.failure({
    required String query,
    required Failure failure,
  }) = _Failure;
  const factory ProductSearchState.results({
    required String query,
    required List<ProductCardEntity> items,
    required PaginationEntity pagination,
    @Default(false) bool isLoadingMore,
    Failure? loadMoreFailure,
  }) = _Results;
}
