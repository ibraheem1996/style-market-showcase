import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/translations/locale_keys.dart';
import '../../../products/domain/entities/product_catalog_filter_entity.dart';
import '../../../products/domain/entities/product_catalog_source.dart';
import '../../domain/entities/filter_options_entity.dart';
import '../../domain/entities/sort_options_entity.dart';
import '../../domain/usecases/get_listing_controls_usecase.dart';
import '../models/listing_controls_selection.dart';
import '../models/listing_ui_models.dart';
import '../states/listing_controls_state.dart';

class ListingControlsController extends GetxController {
  ListingControlsController({
    required GetListingControlsUseCase useCase,
    required this.audienceId,
  }) : _useCase = useCase;

  final GetListingControlsUseCase _useCase;
  final int audienceId;

  final state = Rx<ListingControlsState>(const ListingControlsState.initial());
  var _requestGeneration = 0;

  ListingControlsSelection get currentSelection => state.value.maybeWhen(
    loading: (previousSelection) => previousSelection,
    success: (_, __, appliedFilter, ___, currentSort) =>
        ListingControlsSelection(filters: appliedFilter, sort: currentSort),
    error: (_, fallbackSelection) => fallbackSelection,
    orElse: ListingControlsSelection.empty,
  );

  Future<ListingControlsLoadResult> loadForSource({
    required ProductCatalogSource source,
    String? preferredSort,
  }) async {
    final generation = ++_requestGeneration;
    final previousSelection = currentSelection;
    state.value = ListingControlsState.loading(
      previousSelection: previousSelection,
    );

    final result = await _useCase(audienceId: audienceId, source: source);
    if (isClosed || generation != _requestGeneration) {
      return const ListingControlsLoadResult.stale();
    }
    return result.fold(
      (failure) {
        final fallback = ListingControlsSelection.empty();
        state.value = ListingControlsState.error(
          failure,
          fallbackSelection: fallback,
        );
        return ListingControlsLoadResult.accepted(fallback);
      },
      (controls) {
        final (filterOptions, sortOptions) = controls;
        final adjustedFilter = _adjustFilter(
          previousSelection.filters,
          filterOptions,
        );
        final adjustedSort = _selectSort(
          preferredSort?.trim().isNotEmpty == true
              ? preferredSort!.trim()
              : previousSelection.sort,
          sortOptions,
        );

        state.value = ListingControlsState.success(
          filterOptions: filterOptions,
          sortOptions: sortOptions,
          appliedFilter: adjustedFilter,
          draftFilter: adjustedFilter,
          currentSort: adjustedSort,
        );

        return ListingControlsLoadResult.accepted(
          ListingControlsSelection(filters: adjustedFilter, sort: adjustedSort),
        );
      },
    );
  }

  void openDraft() {
    state.value.maybeMap(
      success: (success) =>
          state.value = success.copyWith(draftFilter: success.appliedFilter),
      orElse: () => state.value,
    );
  }

  void toggleDraftColor(int id) => _updateDraft((draft) {
    final selected = draft.selectedColorIds;
    final updated = selected.contains(id)
        ? selected.where((value) => value != id).toList()
        : [...selected, id];
    return draft.copyWith(selectedColorIds: updated);
  });

  void toggleDraftSize(int id) => _updateDraft((draft) {
    final selected = draft.selectedSizeIds;
    final updated = selected.contains(id)
        ? selected.where((value) => value != id).toList()
        : [...selected, id];
    return draft.copyWith(selectedSizeIds: updated);
  });

  void updateDraftPrice(double min, double max) =>
      _updateDraft((draft) => draft.copyWith(minPrice: min, maxPrice: max));

  void clearDraft() =>
      _updateDraft((_) => ProductCatalogFilterSelection.empty());

  ListingControlsSelection applyDraft() {
    return state.value.maybeMap(
      success: (success) {
        state.value = success.copyWith(appliedFilter: success.draftFilter);
        return currentSelection;
      },
      orElse: () => currentSelection,
    );
  }

  ListingControlsSelection resetApplied() {
    final empty = ProductCatalogFilterSelection.empty();
    final current = state.value;
    return current.maybeMap(
      success: (success) {
        state.value = success.copyWith(
          appliedFilter: empty,
          draftFilter: empty,
        );

        return ListingControlsSelection(
          filters: empty,
          sort: success.currentSort,
        );
      },
      orElse: () => ListingControlsSelection(filters: empty, sort: ''),
    );
  }

  ListingControlsSelection selectSort(String sort) {
    final current = state.value;

    return current.maybeMap(
      success: (success) {
        final selectedSort = _selectSort(sort, success.sortOptions);

        state.value = success.copyWith(currentSort: selectedSort);

        return ListingControlsSelection(
          filters: success.appliedFilter,
          sort: selectedSort,
        );
      },
      orElse: () => currentSelection,
    );
  }

  ListingControlsSelection removeAppliedFilter(ActiveFilterType type, int? id) {
    final currentSelectionValue = currentSelection;
    final current = currentSelectionValue.filters;

    final updated = switch (type) {
      ActiveFilterType.color => current.copyWith(
        selectedColorIds: current.selectedColorIds
            .where((value) => value != id)
            .toList(),
      ),
      ActiveFilterType.size => current.copyWith(
        selectedSizeIds: current.selectedSizeIds
            .where((value) => value != id)
            .toList(),
      ),
      ActiveFilterType.price => current.copyWith(
        minPrice: null,
        maxPrice: null,
      ),
    };

    state.value.maybeMap(
      success: (success) {
        state.value = success.copyWith(
          appliedFilter: updated,
          draftFilter: updated,
        );
      },
      orElse: () {},
    );

    return ListingControlsSelection(
      filters: updated,
      sort: currentSelectionValue.sort,
    );
  }

  bool get filterOptionsAvailable => state.value.maybeWhen(
    success: (filterOptions, _, __, ___, ____) =>
        filterOptions.colors.isNotEmpty ||
        filterOptions.sizes.isNotEmpty ||
        filterOptions.priceRange.max > 0,
    orElse: () => false,
  );

  bool get hasSortOptions => state.value.maybeWhen(
    success: (_, sortOptions, __, ___, ____) =>
        sortOptions.availableSorts.isNotEmpty,
    orElse: () => false,
  );

  bool get hasActiveFilters => !currentSelection.filters.isEmpty;

  String get currentSortName {
    final sort = currentSelection.sort;
    return sort.isEmpty ? LocaleKeys.listingSortRelevance.tr : label(sort);
  }

  List<ActiveFilterUiModel> get activeFilterChips {
    final filter = currentSelection.filters;
    if (filter.isEmpty) return <ActiveFilterUiModel>[];

    final filterOptions = state.value.maybeMap(
      success: (success) => success.filterOptions,
      orElse: () => null,
    );
    if (filterOptions == null) return <ActiveFilterUiModel>[];

    final isAr = Get.locale?.languageCode == 'ar';
    final chips = <ActiveFilterUiModel>[];

    for (final colorId in filter.selectedColorIds) {
      final color = filterOptions.colors.firstWhereOrNull(
        (item) => item.valueId == colorId,
      );
      chips.add(
        ActiveFilterUiModel(
          type: ActiveFilterType.color,
          id: colorId,
          label: color == null
              ? '#$colorId'
              : isAr
              ? color.nameAr
              : color.nameEn,
          color: color == null
              ? null
              : Color(
                  int.tryParse('0xFF${color.hex.replaceAll('#', '')}') ??
                      0xFFCCCCCC,
                ),
        ),
      );
    }

    for (final sizeId in filter.selectedSizeIds) {
      final size = filterOptions.sizes.firstWhereOrNull(
        (item) => item.sizeValueId == sizeId,
      );
      chips.add(
        ActiveFilterUiModel(
          type: ActiveFilterType.size,
          id: sizeId,
          label: size == null
              ? '#$sizeId'
              : isAr
              ? size.nameAr
              : size.nameEn,
        ),
      );
    }

    if (filter.minPrice != null || filter.maxPrice != null) {
      final min = LocaleKeys.price.trParams({
        'price': (filter.minPrice ?? 0).toInt().toString(),
      });
      final max = LocaleKeys.price.trParams({
        'price': (filter.maxPrice ?? 0).toInt().toString(),
      });
      chips.add(
        ActiveFilterUiModel(
          type: ActiveFilterType.price,
          id: null,
          label: '$min - $max',
        ),
      );
    }

    return chips;
  }

  FilterOptionsEntity? get filterOptions => state.value.maybeWhen(
    success: (filterOptions, _, __, ___, ____) => filterOptions,
    orElse: () => null,
  );

  ProductCatalogFilterSelection? get draftFilter => state.value.maybeWhen(
    success: (_, __, ___, draftFilter, ____) => draftFilter,
    orElse: () => null,
  );

  SortOptionsEntity? get sortOptions => state.value.maybeWhen(
    success: (_, sortOptions, __, ___, ____) => sortOptions,
    orElse: () => null,
  );

  String label(String sort) {
    switch (sort) {
      case 'newest':
        return LocaleKeys.listingSortNewest.tr;
      case 'price_asc':
        return LocaleKeys.listingSortPriceAsc.tr;
      case 'price_desc':
        return LocaleKeys.listingSortPriceDesc.tr;
      case 'discount_desc':
        return LocaleKeys.listingSortDiscountDesc.tr;
      case 'custom_order':
        return LocaleKeys.listingSortCustomOrder.tr;
      default:
        return sort;
    }
  }

  void _updateDraft(
    ProductCatalogFilterSelection Function(ProductCatalogFilterSelection draft)
    update,
  ) {
    state.value = state.value.maybeMap(
      success: (success) =>
          success.copyWith(draftFilter: update(success.draftFilter)),
      orElse: () => state.value,
    );
  }

  ProductCatalogFilterSelection _adjustFilter(
    ProductCatalogFilterSelection filter,
    FilterOptionsEntity options,
  ) {
    final colorIds = filter.selectedColorIds
        .where((id) => options.colors.any((item) => item.valueId == id))
        .toList();
    final sizeIds = filter.selectedSizeIds
        .where((id) => options.sizes.any((item) => item.sizeValueId == id))
        .toList();
    final minPrice = filter.minPrice == null
        ? null
        : max(filter.minPrice!, options.priceRange.min);
    final maxPrice = filter.maxPrice == null
        ? null
        : min(filter.maxPrice!, options.priceRange.max);

    return ProductCatalogFilterSelection(
      selectedColorIds: colorIds,
      selectedSizeIds: sizeIds,
      minPrice: minPrice,
      maxPrice: maxPrice,
    );
  }

  String _selectSort(String preferredSort, SortOptionsEntity sortOptions) {
    if (preferredSort.isNotEmpty &&
        sortOptions.availableSorts.contains(preferredSort)) {
      return preferredSort;
    }
    return sortOptions.defaultSort;
  }
}

/// Reports whether a controls response still belongs to the latest source.
sealed class ListingControlsLoadResult {
  const ListingControlsLoadResult();

  const factory ListingControlsLoadResult.accepted(
    ListingControlsSelection selection,
  ) = ListingControlsLoadAccepted;

  const factory ListingControlsLoadResult.stale() = ListingControlsLoadStale;
}

final class ListingControlsLoadAccepted extends ListingControlsLoadResult {
  const ListingControlsLoadAccepted(this.selection);

  final ListingControlsSelection selection;
}

final class ListingControlsLoadStale extends ListingControlsLoadResult {
  const ListingControlsLoadStale();
}
