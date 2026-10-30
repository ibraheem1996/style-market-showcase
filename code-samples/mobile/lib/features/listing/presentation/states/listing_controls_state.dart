import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/errors/failure.dart';
import '../../../products/domain/entities/product_catalog_filter_entity.dart';
import '../../domain/entities/filter_options_entity.dart';
import '../../domain/entities/sort_options_entity.dart';
import '../models/listing_controls_selection.dart';

part 'listing_controls_state.freezed.dart';

@freezed
sealed class ListingControlsState with _$ListingControlsState {
  const factory ListingControlsState.initial() = _Initial;
  const factory ListingControlsState.loading({
    required ListingControlsSelection previousSelection,
  }) = _Loading;
  const factory ListingControlsState.success({
    required FilterOptionsEntity filterOptions,
    required SortOptionsEntity sortOptions,
    required ProductCatalogFilterSelection appliedFilter,
    required ProductCatalogFilterSelection draftFilter,
    required String currentSort,
  }) = _Success;
  const factory ListingControlsState.error(
    Failure failure, {
    required ListingControlsSelection fallbackSelection,
  }) = _Error;
}
