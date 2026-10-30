import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_project/core/utils/responsive/app_text_scale_limits.dart';

import '../../../../binding_route_middleware/route.dart';
import '../../../../core/navigation/items_details_route_args.dart';
import '../../../../core/overlays/app_snackbar.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/translations/locale_keys.dart';
import '../../../../core/utils/responsive/app_design_tokens.dart';
import '../../../../core/utils/responsive/app_responsive_value.dart';
import '../../../../core/widgets/error/extension_failure_to_dialog.dart';
import '../../../../core/widgets/error/extension_failure_to_snak_bar.dart';
import '../../../../core/widgets/responsive_content.dart';
import '../../../../core/widgets/rx_event_listener.dart';
import '../../../cart/domain/entities/cart_item_entity.dart';
import '../../../auth/presentation/navigation/login_route_args.dart';
import '../../../products/domain/entities/product_catalog_filter_entity.dart';
import '../controllers/listing_controls_controller.dart';
import '../controllers/listing_controller.dart';
import '../controllers/listing_search_controller.dart';
import '../events/listing_interaction_event.dart';
import '../models/listing_controls_selection.dart';
import '../models/listing_criteria.dart';
import '../navigation/listing_route_args.dart';
import '../states/listing_items_state.dart';
import '../states/listing_controls_state.dart';
import '../widgets/app_bar/listing_sliver_appbar.dart';
import '../widgets/app_bar/listing_sort_and_filter_bar_sliver.dart';
import '../widgets/filter_sheet/filter_bottom_sheet.dart';
import '../widgets/grid/listing_empty_sliver.dart';
import '../widgets/grid/listing_error_sliver.dart';
import '../widgets/grid/listing_grid_sliver.dart';
import '../widgets/grid/listing_skeleton_sliver.dart';
import '../widgets/sort_sheet/sort_bottom_sheet.dart';
import '../widgets/subcategories/listing_subcategories_sliver.dart';

class ListingPage extends StatefulWidget {
  const ListingPage({super.key});

  @override
  State<ListingPage> createState() => _ListingPageState();
}

class _ListingPageState extends State<ListingPage> {
  late final ScrollController _scrollController;
  late final ListingController _listing;
  late final ListingControlsController _controls;
  late final ListingSearchController _search;
  late final ListingRouteArgs _routeArgs;
  late final ValueNotifier<bool> _subcategoriesCollapsed;

  @override
  void initState() {
    super.initState();
    _listing = Get.find<ListingController>();
    _controls = Get.find<ListingControlsController>();
    _search = Get.find<ListingSearchController>();
    _routeArgs = Get.find<ListingRouteArgs>();
    _subcategoriesCollapsed = ValueNotifier(false);
    _scrollController = ScrollController()..addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    _subcategoriesCollapsed.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    final result = await _controls.loadForSource(
      source: _listing.source,
      preferredSort: _routeArgs.initialSort,
    );
    if (!mounted || result is! ListingControlsLoadAccepted) return;

    await _listing.initialize(
      ListingCriteria.initial(
        audienceId: _listing.audienceId,
        source: _listing.source,
        filters: result.selection.filters,
        sort: result.selection.sort,
      ),
    );
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 300) {
      unawaited(_listing.loadNextPage());
    }
    final collapsed = ListingSubcategoryGeometry.isCollapsedForOffset(
      position.pixels,
    );
    if (_subcategoriesCollapsed.value != collapsed) {
      _subcategoriesCollapsed.value = collapsed;
    }
  }

  double _maxAppBarHeight(BuildContext context) {
    final baseHeight = AppControlSizes.appBarToolbarHeight(context);
    return AppTextScaleValue.resolve<double>(
      context,
      fontSize: context.appTypography.appBar.title.fontSize!,
      normal: baseHeight + 4,
      large: baseHeight + 10,
      extraLarge: baseHeight + 14,
    );
  }

  void _openSortSheet() {
    final sortOptions = _controls.sortOptions;
    if (sortOptions == null) return;
    SortBottomSheet.show(
      context: context,
      availableSorts: sortOptions.availableSorts,
      currentSort: _controls.currentSelection.sort,
      onSortSelected: (sort) {
        _applyControlsSelection(_controls.selectSort(sort));
      },
      labelBuilder: _controls.label,
    );
  }

  void _openFilterSheet() {
    if (_controls.filterOptions == null || _controls.draftFilter == null) {
      return;
    }
    _controls.openDraft();
    FilterBottomSheet.show(
      builder: () => Obx(() {
        final options = _controls.filterOptions;
        final draft = _controls.draftFilter;
        if (options == null || draft == null) return const SizedBox.shrink();
        return FilterBottomSheet(
          filterOptions: options,
          draftFilter: draft,
          onColorToggle: _controls.toggleDraftColor,
          onSizeToggle: _controls.toggleDraftSize,
          onPriceChanged: _controls.updateDraftPrice,
          onClear: _controls.clearDraft,
          onApply: () {
            Get.back();
            _applyControlsSelection(_controls.applyDraft());
          },
        );
      }),
    );
  }

  Future<void> _onSubcategorySelected(int? id) async {
    final source = _listing.selectSubcategory(id);
    final result = await _controls.loadForSource(
      source: source,
      preferredSort: _controls.currentSelection.sort,
    );
    if (!mounted ||
        _listing.selectedSubcategoryId.value != id ||
        result is! ListingControlsLoadAccepted) {
      return;
    }
    await _listing.applyCriteria(
      _listing.copyCurrentCriteria(
        source: source,
        filters: result.selection.filters,
        sort: result.selection.sort,
      ),
    );
  }

  Future<void> _retryControls() async {
    final source = _listing.criteria.value.source;
    final result = await _controls.loadForSource(
      source: source,
      preferredSort: _controls.currentSelection.sort,
    );
    if (!mounted || result is! ListingControlsLoadAccepted) return;
    await _listing.applyCriteria(
      _listing.copyCurrentCriteria(
        filters: result.selection.filters,
        sort: result.selection.sort,
      ),
    );
  }

  void _onSearchQueryReady(String query) {
    unawaited(
      _listing.applyCriteria(_listing.copyCurrentCriteria(searchQuery: query)),
    );
  }

  void _applyControlsSelection(ListingControlsSelection selection) {
    unawaited(
      _listing.applyCriteria(
        _listing.copyCurrentCriteria(
          filters: selection.filters,
          sort: selection.sort,
        ),
      ),
    );
  }

  void _clearAppliedFilters() {
    _applyControlsSelection(_controls.resetApplied());
  }

  void _openItemDetails(
    String heroTag,
    int itemId,
    int? variantId, {
    int? colorGroupId,
  }) {
    Get.toNamed(
      RouteName.itemDetails,
      arguments: ItemsDetailsRouteArgs(
        heroTag: heroTag,
        itemId: itemId,
        variantId: variantId,
        colorGroupId: colorGroupId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RxEventListener<ListingInteractionEvent>(
      rxnEvent: _listing.interactionEvent,
      clearEvent: _listing.clearInteractionEvent,
      onEvent: _onInteractionEvent,
      child: Obx(() {
        final chips = _controls.activeFilterChips;
        final hasSort = _controls.hasSortOptions;
        final controlsLoading = _controls.state.value.maybeWhen(
          loading: (_) => true,
          orElse: () => false,
        );
        final controlsFailed = _controls.state.value.maybeWhen(
          error: (_, __) => true,
          orElse: () => false,
        );
        final showFilter =
            controlsLoading ||
            controlsFailed ||
            _controls.filterOptionsAvailable;

        return Scaffold(
          appBar: ListingAppBar(
            toolbarHeight: _maxAppBarHeight(context),
            title: _listing.pageTitle,
            totalCount: _listing.totalCount,
            onSearchTap: _search.showSearch,
            isSearchVisible: _search.isSearchVisible.value,
            searchController: _search.textController,
            searchFocusNode: _search.focusNode,
            searchText: _search.query.value,
            onSearchChanged: (value) => _search.onQueryChanged(
              value,
              onQueryReady: _onSearchQueryReady,
            ),
            onSearchClose: () =>
                _search.hideSearch(onQueryReady: _onSearchQueryReady),
            onSearchClear: () =>
                _search.clear(onQueryReady: _onSearchQueryReady),
          ),

          body: SafeArea(
            top: false,
            child: ResponsiveContent.catalog(
              includeTopPadding: false,
              child: Column(
                children: [
                  ValueListenableBuilder<bool>(
                    valueListenable: _subcategoriesCollapsed,
                    builder: (context, collapsed, _) {
                      return MediaQuery.withClampedTextScaling(
                        maxScaleFactor: AppTextScaleLimits.categories,
                        child: ListingSubcategories(
                          state: _listing.subcategoriesState.value,
                          selectedId: _listing.selectedSubcategoryId.value,
                          onSubcategoryTap: _onSubcategorySelected,
                          onRetry: _listing.retrySubcategories,
                          selectionEnabled: !controlsLoading,
                          collapsed: collapsed,
                        ),
                      );
                    },
                  ),
                  Expanded(
                    child: RefreshIndicator.adaptive(
                      onRefresh: _listing.refreshListing,
                      child: CustomScrollView(
                        controller: _scrollController,
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        physics: const AlwaysScrollableScrollPhysics(),
                        slivers: [
                          ListingSortAndFilterBarSliver(
                            hasSortOptions: hasSort,
                            currentSortName: _controls.currentSortName,
                            showFilter: showFilter,
                            filterEnabled: _controls.filterOptionsAvailable,
                            filterLoading: controlsLoading,
                            activeFilterCount:
                                _controls.currentSelection.filters.activeCount,
                            controlsFailed: controlsFailed,
                            activeFilterChips: chips,
                            onSortTap: _openSortSheet,
                            onFilterTap: _openFilterSheet,
                            onRetry: _retryControls,
                            onFilterChipRemove: (type, id) {
                              _applyControlsSelection(
                                _controls.removeAppliedFilter(type, id),
                              );
                            },
                          ),
                          _buildItemsSliver(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildItemsSliver() {
    return _listing.itemsState.value.when(
      initial: () => const ListingSkeletonSliver(),
      loading: () => const ListingSkeletonSliver(),
      error: (failure) => ListingErrorSliver(
        failure: failure,
        onRetry: _listing.retryFirstPage,
      ),
      empty: (reason, _) => ListingEmptySliver(
        reason: reason,
        hasActiveFilters: _controls.hasActiveFilters,
        onClearFilters: _clearAppliedFilters,
        onClearSearch: () => _search.clear(onQueryReady: _onSearchQueryReady),
      ),
      success: (items, _, __, isLoadingMore, loadMoreFailure) => items.isEmpty
          ? ListingEmptySliver(
              reason: ListingEmptyReason.catalog,
              hasActiveFilters: _controls.hasActiveFilters,
              onClearFilters: _clearAppliedFilters,
              onClearSearch: () =>
                  _search.clear(onQueryReady: _onSearchQueryReady),
            )
          : ListingGridSliver(
              items: items,
              isLoadingMore: isLoadingMore,
              loadMoreFailure: loadMoreFailure,
              onRetryLoadMore: _listing.retryNextPage,
              onTapProduct: _openItemDetails,
              onToggleFavorite: _listing.toggleFavorite,
              isFavorite: _listing.isFavorite,
              isFavoritePending: _listing.isFavoritePending,
              canToggleFavorite: _listing.canToggleFavorite,
              onAddToCart: _listing.addToCart,
              cartQuantity: _listing.cartQuantity,
              isCartPending: _listing.isCartOperationPending,
            ),
    );
  }

  Future<void> _onInteractionEvent(ListingInteractionEvent event) async {
    switch (event) {
      case ListingInteractionFailure(:final failure):
        await failure.handleSnackBar();
        if (!mounted) return;
        await failure.handleDialog(
          goLogin: () {
            Get.toNamed(
              RouteName.loginFlow,
              arguments: const LoginRouteArgs.flow(),
            );
          },
        );
      case ListingFavoriteSuccess(:final added):
        await AppSnackbar.show(
          added
              ? LocaleKeys.addedToFavorites.tr
              : LocaleKeys.removedFromFavorites.tr,
          tone: AppSnackbarTone.success,
        );
      case ListingCartSuccess(:final action):
        await AppSnackbar.show(
          _cartActionMessage(action),
          tone: AppSnackbarTone.success,
        );
      case ListingCartUnavailable():
        await AppSnackbar.show(
          LocaleKeys.addToCartUnavailable.tr,
          tone: AppSnackbarTone.warning,
        );
    }
  }

  String _cartActionMessage(CartAction action) {
    return switch (action) {
      CartAction.added => LocaleKeys.cartAddSuccess.tr,
      CartAction.updated => LocaleKeys.cartUpdateSuccess.tr,
      CartAction.removed => LocaleKeys.cartRemoveSuccess.tr,
    };
  }
}
