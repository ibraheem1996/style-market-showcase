import 'dart:async';

import 'package:dartz/dartz.dart' show Right;
import 'package:get/get.dart';

import '../../../../core/errors/api_result.dart';
import '../../../../core/errors/app_failure_key.dart';
import '../../../../core/errors/failure.dart';
import '../../../../features/products/domain/entities/category_entity.dart';
import '../../../../features/products/domain/entities/product_card_entity.dart';
import '../../../../features/products/domain/entities/product_catalog_filter_entity.dart';
import '../../../../features/products/domain/entities/product_catalog_response_entity.dart';
import '../../../../features/products/domain/entities/product_catalog_source.dart';
import '../../../../features/products/domain/usecases/get_product_catalog_usecase.dart';
import '../../../favorites/presentation/services/favorites_service.dart';
import '../../../cart/presentation/extensions/cart_upsert_input_extensions.dart';
import '../../../cart/presentation/operations/cart_operations.dart';
import '../../../cart/presentation/store/cart_store.dart';
import '../../domain/usecases/get_subcategories_usecase.dart';
import '../events/listing_interaction_event.dart';
import '../models/listing_criteria.dart';
import '../models/listing_ui_models.dart';
import '../states/listing_items_state.dart';
import '../states/listing_subcategories_state.dart';

const _listingPageLimit = 16;

class ListingController extends GetxController {
  ListingController({
    required GetProductCatalogUseCase getProductCatalogUseCase,
    required GetSubcategoriesUseCase getSubcategoriesUseCase,
    required this.audienceId,
    required this.source,
    required FavoritesService favoritesService,
    required CartOperations cartOperations,
    required CartStore cartStore,
  }) : _getProductCatalogUseCase = getProductCatalogUseCase,
       _getSubcategoriesUseCase = getSubcategoriesUseCase,
       _favoritesService = favoritesService,
       _cartOperations = cartOperations,
       _cartStore = cartStore;

  final GetProductCatalogUseCase _getProductCatalogUseCase;
  final GetSubcategoriesUseCase _getSubcategoriesUseCase;
  final FavoritesService _favoritesService;
  final CartOperations _cartOperations;
  final CartStore _cartStore;
  final int audienceId;
  final ProductCatalogSource source;

  final itemsState = Rx<ListingItemsState>(const ListingItemsState.initial());
  final subcategoriesState = Rx<ListingSubcategoriesState>(
    const ListingSubcategoriesState.initial(),
  );
  final criteria = Rx<ListingCriteria>(
    ListingCriteria.initial(
      audienceId: 1,
      source: const ProductCatalogSource(
        sourceType: ProductCatalogSourceType.category,
        sourceId: '',
        titleAr: '',
        titleEn: '',
      ),
    ),
  );
  final selectedSubcategoryId = RxnInt();
  final Rxn<ListingInteractionEvent> interactionEvent =
      Rxn<ListingInteractionEvent>();

  bool isFavorite(ProductCardEntity item) {
    return _favoritesService.isFavorite(
      item.itemId,
      item.representativeVariantId,
    );
  }

  bool isFavoritePending(ProductCardEntity item) {
    return _favoritesService.isTogglePending(
      item.itemId,
      item.representativeVariantId,
    );
  }

  bool canToggleFavorite(ProductCardEntity item) {
    return _favoritesService.canToggle(
      item.itemId,
      item.representativeVariantId,
    );
  }

  Future<void> toggleFavorite(ProductCardEntity item) async {
    final result = await _favoritesService.toggle(
      item.itemId,
      variantId: item.representativeVariantId,
    );
    if (isClosed) return;
    result.fold(
      (failure) => interactionEvent.value = ListingInteractionFailure(failure),
      (result) => interactionEvent.value = ListingFavoriteSuccess(
        added: result == ToggleFavoriteResult.added,
      ),
    );
  }

  int cartQuantity(ProductCardEntity item) =>
      _cartStore.getCartQuantity(item.itemId, item.representativeVariantId);

  bool isCartOperationPending(ProductCardEntity item) => _cartOperations
      .isLineOperationInFlight(item.itemId, item.representativeVariantId);

  Future<void> addToCart(ProductCardEntity item) async {
    if (isCartOperationPending(item)) return;
    final input = item.toCartUpsertInput();
    if (!input.isAvailable || (input.stock ?? 1) <= 0) {
      interactionEvent.value = const ListingCartUnavailable();
      return;
    }

    final result = await _cartOperations.upsertInput(input, quantityDelta: 1);
    if (isClosed) return;
    result.fold(
      (failure) => interactionEvent.value = ListingInteractionFailure(failure),
      (action) => interactionEvent.value = ListingCartSuccess(action),
    );
  }

  void clearInteractionEvent() => interactionEvent.value = null;

  var _requestGeneration = 0;
  var _isFirstPageLoading = false;
  var _isRefreshing = false;
  var _isLoadingMore = false;
  var _initialized = false;

  Future<void> initialize(ListingCriteria initialCriteria) async {
    if (_initialized) return;
    _initialized = true;

    if (source.sourceId.trim().isEmpty) {
      itemsState.value = const ListingItemsState.error(
        Failure.app(key: AppFailureKey.invalidArgument),
      );
      return;
    }

    if (source.sourceType == ProductCatalogSourceType.category) {
      unawaited(_loadSubcategories());
    }
    final normalizedCriteria = _normalizeCriteria(initialCriteria);
    criteria.value = normalizedCriteria;
    await _loadFirstPage(normalizedCriteria);
  }

  Future<void> applyCriteria(ListingCriteria nextCriteria) async {
    final normalized = _normalizeCriteria(nextCriteria);
    if (normalized == criteria.value) return;
    criteria.value = normalized;
    await _loadFirstPage(normalized);
  }

  Future<void> retryFirstPage() => _loadFirstPage(criteria.value);

  Future<void> retrySubcategories() => _loadSubcategories();

  Future<void> refreshListing() async {
    if (_isRefreshing) return;
    final current = itemsState.value;
    final currentCriteria = criteria.value;
    final generation = ++_requestGeneration;
    _isRefreshing = true;

    current.mapOrNull(
      success: (success) {
        itemsState.value = success.copyWith(isRefreshing: true);
      },
    );

    final result = await _fetchPage(criteria: currentCriteria, page: 1);
    if (isClosed || generation != _requestGeneration) return;

    _isRefreshing = false;
    result.fold(
      (failure) {
        current.mapOrNull(
          success: (success) {
            itemsState.value = success.copyWith(isRefreshing: false);
          },
        );
        interactionEvent.value = ListingInteractionFailure(failure);
      },
      (response) {
        _writeFirstPageResult(currentCriteria, Right(response));
      },
    );
  }

  Future<void> loadNextPage() async {
    if (_isLoadingMore || _isRefreshing || _isFirstPageLoading) return;

    final current = itemsState.value;
    await current.maybeWhen(
      success:
          (
            items,
            pagination,
            isRefreshing,
            isLoadingMore,
            loadMoreFailure,
          ) async {
            if (!pagination.hasMore ||
                isLoadingMore ||
                isRefreshing ||
                loadMoreFailure != null) {
              return;
            }

            _isLoadingMore = true;
            final requestedCriteria = criteria.value;
            final generation = _requestGeneration;
            final nextPage = pagination.page + 1;

            itemsState.value = ListingItemsState.success(
              items: items,
              pagination: pagination,
              isLoadingMore: true,
            );

            final result = await _fetchPage(
              criteria: requestedCriteria,
              page: nextPage,
            );
            if (isClosed || generation != _requestGeneration) {
              _isLoadingMore = false;
              return;
            }

            _isLoadingMore = false;
            result.fold(
              (failure) {
                itemsState.value = ListingItemsState.success(
                  items: items,
                  pagination: pagination,
                  isLoadingMore: false,
                  loadMoreFailure: failure,
                );
              },
              (response) {
                final merged = _mergeWithoutDuplicateCards(
                  items,
                  response.items,
                );
                itemsState.value = ListingItemsState.success(
                  items: merged,
                  pagination: response.pagination,
                  isLoadingMore: false,
                );
              },
            );
          },
      orElse: () async => null,
    );
  }

  Future<void> retryNextPage() async {
    final current = itemsState.value;
    current.mapOrNull(
      success: (success) {
        itemsState.value = success.copyWith(loadMoreFailure: null);
      },
    );
    await loadNextPage();
  }

  ProductCatalogSource selectSubcategory(int? subcategoryId) {
    selectedSubcategoryId.value = subcategoryId;
    if (source.sourceType == ProductCatalogSourceType.category &&
        subcategoryId != null) {
      return source.copyWith(sourceId: '$subcategoryId');
    }
    return source;
  }

  String get pageTitle {
    final isAr = Get.locale?.languageCode == 'ar';
    return isAr ? source.titleAr : source.titleEn;
  }

  int get totalCount => itemsState.value.maybeWhen(
    success: (_, pagination, __, ___, ____) => pagination.total,
    empty: (_, pagination) => pagination.total,
    orElse: () => 0,
  );

  List<SubcategoryUiModel> get subcategoriesUiList {
    final list = subcategoriesState.value.maybeWhen(
      success: (items) => items,
      orElse: () => <CategoryEntity>[],
    );
    final isAr = Get.locale?.languageCode == 'ar';
    return list
        .map(
          (category) => SubcategoryUiModel(
            id: category.catId,
            name: isAr ? category.catName : category.catNameEn,
            imageUrl: category.catImage,
          ),
        )
        .toList();
  }

  ListingCriteria copyCurrentCriteria({
    ProductCatalogSource? source,
    String? searchQuery,
    ProductCatalogFilterSelection? filters,
    String? sort,
  }) {
    return criteria.value.copyWith(
      source: source ?? criteria.value.source,
      searchQuery: searchQuery?.trim() ?? criteria.value.searchQuery,
      filters: filters ?? criteria.value.filters,
      sort: sort ?? criteria.value.sort,
    );
  }

  Future<void> _loadSubcategories() async {
    final categoryId = int.tryParse(source.sourceId) ?? 0;
    if (categoryId <= 0) return;

    subcategoriesState.value = const ListingSubcategoriesState.loading();
    final result = await _getSubcategoriesUseCase(
      categoryId: categoryId,
      audienceId: audienceId,
    );
    if (isClosed) return;

    result.fold(
      (failure) =>
          subcategoriesState.value = ListingSubcategoriesState.error(failure),
      (subcategories) => subcategoriesState.value =
          ListingSubcategoriesState.success(subcategories),
    );
  }

  Future<void> _loadFirstPage(ListingCriteria requestCriteria) async {
    final generation = ++_requestGeneration;
    _isFirstPageLoading = true;
    _isLoadingMore = false;
    _isRefreshing = false;
    itemsState.value = const ListingItemsState.loading();

    final result = await _fetchPage(criteria: requestCriteria, page: 1);
    if (isClosed || generation != _requestGeneration) return;

    _isFirstPageLoading = false;
    _writeFirstPageResult(requestCriteria, result);
  }

  Future<ApiResult<ProductCatalogResponseEntity>> _fetchPage({
    required ListingCriteria criteria,
    required int page,
  }) {
    return _getProductCatalogUseCase(
      audienceId: criteria.audienceId,
      source: criteria.source,
      searchQuery: criteria.searchQuery,
      page: page,
      limit: _listingPageLimit,
      sort: criteria.sort,
      filterState: criteria.filters,
    );
  }

  void _writeFirstPageResult(
    ListingCriteria requestCriteria,
    ApiResult<ProductCatalogResponseEntity> result,
  ) {
    result.fold(
      (failure) => itemsState.value = ListingItemsState.error(failure),
      (response) {
        if (response.items.isEmpty) {
          itemsState.value = ListingItemsState.empty(
            reason: requestCriteria.searchQuery.isEmpty
                ? ListingEmptyReason.catalog
                : ListingEmptyReason.search,
            pagination: response.pagination,
          );
          return;
        }

        itemsState.value = ListingItemsState.success(
          items: response.items,
          pagination: response.pagination,
        );
      },
    );
  }

  ListingCriteria _normalizeCriteria(ListingCriteria value) {
    return value.copyWith(searchQuery: value.searchQuery.trim());
  }

  List<ProductCardEntity> _mergeWithoutDuplicateCards(
    List<ProductCardEntity> current,
    List<ProductCardEntity> incoming,
  ) {
    final seen = <String>{};
    final merged = <ProductCardEntity>[];

    for (final item in [...current, ...incoming]) {
      final key = '${item.itemId}:${item.colorGroupId ?? 'simple'}';
      if (seen.add(key)) {
        merged.add(item);
      }
    }

    return merged;
  }
}
