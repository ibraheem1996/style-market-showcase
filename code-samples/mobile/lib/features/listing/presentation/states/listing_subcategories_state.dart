import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/errors/failure.dart';
import '../../../../features/products/domain/entities/category_entity.dart';

part 'listing_subcategories_state.freezed.dart';

@freezed
sealed class ListingSubcategoriesState with _$ListingSubcategoriesState {
  const factory ListingSubcategoriesState.initial() = _Initial;
  const factory ListingSubcategoriesState.loading() = _Loading;
  const factory ListingSubcategoriesState.success(
    List<CategoryEntity> subcategories,
  ) = _Success;
  const factory ListingSubcategoriesState.error(Failure failure) = _Error;
}
