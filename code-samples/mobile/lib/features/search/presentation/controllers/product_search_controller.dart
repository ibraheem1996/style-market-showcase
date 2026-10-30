import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../../core/errors/api_result.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/errors/failure_key.dart';
import '../../../cart/presentation/extensions/cart_upsert_input_extensions.dart';
import '../../../cart/presentation/operations/cart_operations.dart';
import '../../../cart/presentation/store/cart_store.dart';
import '../../../favorites/presentation/services/favorites_service.dart';
import '../../../products/domain/entities/product_card_entity.dart';
import '../../../products/domain/entities/product_search_response_entity.dart';
import '../../../products/domain/usecases/search_products_usecase.dart';
import '../events/product_search_event.dart';
import '../state/product_search_state.dart';

const _productSearchPageLimit = 16;

class ProductSearchController extends GetxController {
  ProductSearchController({
    required SearchProductsUseCase searchProductsUseCase,
    required this.audienceId,
    required FavoritesService favoritesService,
    required CartOperations cartOperations,
    required CartStore cartStore,
  }) : _searchProductsUseCase = searchProductsUseCase,
       _favoritesService = favoritesService,
       _cartOperations = cartOperations,
       _cartStore = cartStore;

  static const debounceDuration = Duration(milliseconds: 450);
  static const minimumQueryLength = 2;
  static const maximumQueryLength = 100;

  /// Identifies local length validation on the existing failure-event path.
  static const queryTooLongErrorCode = 'SEARCH_QUERY_TOO_LONG';

  final SearchProductsUseCase _searchProductsUseCase;
  final FavoritesService _favoritesService;
  final CartOperations _cartOperations;
  final CartStore _cartStore;
  final int audienceId;

  final textController = TextEditingController();
  final focusNode = FocusNode();
  final state = Rx<ProductSearchState>(const ProductSearchState.initial());
  final event = Rxn<ProductSearchEvent>();

  Timer? _debounce;
  var _requestGeneration = 0;
  var _hasReportedOverlongQuery = false;

  @override
  void onReady() {
    super.onReady();
    focusNode.requestFocus();
  }

  void onQueryChanged(String value) {
    _debounce?.cancel();
    final query = normalizeQuery(value);
    final queryLength = query.runes.length;
    if (queryLength <= maximumQueryLength) {
      _hasReportedOverlongQuery = false;
    }
    if (queryLength < minimumQueryLength) {
      _invalidateRequests();
      state.value = const ProductSearchState.initial();
      return;
    }
    if (queryLength > maximumQueryLength) {
      _rejectOverlongQuery();
      return;
    }
    _invalidateRequests();

    _debounce = Timer(debounceDuration, () => _searchFirstPage(query));
  }

  Future<void> submit() async {
    _debounce?.cancel();
    final query = normalizeQuery(textController.text);
    final queryLength = query.runes.length;
    if (queryLength <= maximumQueryLength) {
      _hasReportedOverlongQuery = false;
    }
    if (queryLength < minimumQueryLength) {
      _invalidateRequests();
      state.value = const ProductSearchState.initial();
      return;
    }
    if (queryLength > maximumQueryLength) {
      _rejectOverlongQuery();
      return;
    }
    await _searchFirstPage(query);
  }

  void clear() {
    _debounce?.cancel();
    textController.clear();
    _hasReportedOverlongQuery = false;
    _invalidateRequests();
    state.value = const ProductSearchState.initial();
    focusNode.requestFocus();
  }

  Future<void> retryFirstPage() async {
    final query = state.value.mapOrNull(failure: (value) => value.query);
    if (query == null) return;
    await _searchFirstPage(query);
  }

  Future<void> loadNextPage() async {
    await state.value.maybeMap(
      results: (oldResults) async {
        if (!oldResults.pagination.hasMore || oldResults.isLoadingMore) {
          return;
        }

        final generation = _requestGeneration;
        final nextPage = oldResults.pagination.page + 1;

        state.value = oldResults.copyWith(
          isLoadingMore: true,
          loadMoreFailure: null,
        );

        final result = await _fetch(query: oldResults.query, page: nextPage);

        if (!_canWrite(generation)) return;

        result.fold(
          (failure) {
            state.value = oldResults.copyWith(
              isLoadingMore: false,
              loadMoreFailure: failure,
            );
          },
          (response) {
            state.value = ProductSearchState.results(
              query: oldResults.query,
              isLoadingMore: false,
              items: _mergeWithoutDuplicateCards(
                oldResults.items,
                response.items,
              ),
              pagination: response.pagination,
            );
          },
        );
      },
      orElse: () async {},
    );
  }

  Future<void> retryNextPage() => loadNextPage();

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
      (failure) => event.value = ProductSearchEvent.interactionFailure(failure),
      (_) {},
    );
  }

  int cartQuantity(ProductCardEntity item) {
    return _cartStore.getCartQuantity(
      item.itemId,
      item.representativeVariantId,
    );
  }

  bool isCartOperationPending(ProductCardEntity item) {
    return _cartOperations.isLineOperationInFlight(
      item.itemId,
      item.representativeVariantId,
    );
  }

  Future<void> addToCart(ProductCardEntity item) async {
    final input = item.toCartUpsertInput();
    if (!input.isAvailable || (input.stock ?? 1) <= 0) {
      event.value = const ProductSearchEvent.cartUnavailable();
      return;
    }

    final result = await _cartOperations.upsertInput(input, quantityDelta: 1);
    if (isClosed) return;
    result.fold(
      (failure) => event.value = ProductSearchEvent.interactionFailure(failure),
      (action) => event.value = ProductSearchEvent.cartSuccess(action),
    );
  }

  void clearEvent() => event.value = null;

  static String normalizeQuery(String value) {
    return value.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  Future<void> _searchFirstPage(String query) async {
    final generation = ++_requestGeneration;
    state.value = ProductSearchState.loading(query: query);

    final result = await _fetch(query: query, page: 1);
    if (!_canWrite(generation)) return;

    result.fold(
      (failure) => state.value = ProductSearchState.failure(
        query: query,
        failure: failure,
      ),
      (response) {
        if (response.items.isEmpty) {
          state.value = ProductSearchState.empty(
            query: query,
            pagination: response.pagination,
          );
          return;
        }
        state.value = ProductSearchState.results(
          query: query,
          items: _mergeWithoutDuplicateCards(const [], response.items),
          pagination: response.pagination,
        );
      },
    );
  }

  Future<ApiResult<ProductSearchResponseEntity>> _fetch({
    required String query,
    required int page,
  }) {
    return _searchProductsUseCase(
      audienceId: audienceId,
      query: query,
      page: page,
      limit: _productSearchPageLimit,
    );
  }

  bool _canWrite(int generation) {
    return !isClosed && generation == _requestGeneration;
  }

  void _invalidateRequests() {
    _requestGeneration++;
  }

  void _rejectOverlongQuery() {
    _invalidateRequests();
    state.value = const ProductSearchState.initial(isLongQuery: true);
    if (_hasReportedOverlongQuery) return;
    _hasReportedOverlongQuery = true;
    event.value = const ProductSearchEvent.interactionFailure(
      Failure.http(
        key: FailureKey.validation,
        errorCode: queryTooLongErrorCode,
      ),
    );
  }

  List<ProductCardEntity> _mergeWithoutDuplicateCards(
    List<ProductCardEntity> current,
    List<ProductCardEntity> incoming,
  ) {
    final seen = <String>{};
    return <ProductCardEntity>[
      for (final item in [...current, ...incoming])
        if (seen.add('${item.itemId}:${item.colorGroupId ?? 'simple'}')) item,
    ];
  }

  @override
  void onClose() {
    _debounce?.cancel();
    _invalidateRequests();
    textController.dispose();
    focusNode.dispose();
    super.onClose();
  }
}
