import 'package:get/get.dart';

import '../../../../core/errors/failure.dart';
import '../../../cart/presentation/extensions/cart_upsert_input_extensions.dart';
import '../../../cart/presentation/operations/cart_operations.dart';
import '../../../cart/presentation/store/cart_store.dart';
import '../../../favorites/presentation/services/favorites_service.dart';
import '../../../products/domain/entities/product_card_entity.dart';
import '../event/recently_viewed_event_ui.dart';
import '../services/recently_viewed_service.dart';

class RecentlyViewedViewAllController extends GetxController {
  RecentlyViewedViewAllController({
    required RecentlyViewedService service,
    required FavoritesService favoritesService,
    required CartOperations cartOperations,
    required CartStore cartStore,
  }) : _service = service,
       _favoritesService = favoritesService,
       _cartOperations = cartOperations,
       _cartStore = cartStore;

  final RecentlyViewedService _service;
  final FavoritesService _favoritesService;
  final CartOperations _cartOperations;
  final CartStore _cartStore;
  final favoriteFailureEvent = Rxn<Failure>();
  final cartEvent = Rxn<RecentlyViewedCartEvent>();
  final refreshFailureEvent = Rxn<Failure>();

  RecentlyViewedService get service => _service;

  @override
  void onReady() {
    super.onReady();
    _service.fetch();
  }

  Future<void> onPullToRefresh() async {
    final failure = await _service.refreshWithFailure();
    if (isClosed || failure == null) return;
    refreshFailureEvent.value = failure;
  }

  void clearFavoriteFailureEvent() => favoriteFailureEvent.value = null;

  void clearCartEvent() => cartEvent.value = null;

  void clearRefreshFailureEvent() => refreshFailureEvent.value = null;

  bool isFavorite(ProductCardEntity item) =>
      _favoritesService.isFavorite(item.itemId, item.representativeVariantId);

  bool isFavoritePending(ProductCardEntity item) => _favoritesService
      .isTogglePending(item.itemId, item.representativeVariantId);

  bool canToggleFavorite(ProductCardEntity item) =>
      _favoritesService.canToggle(item.itemId, item.representativeVariantId);

  Future<void> toggleFavorite(ProductCardEntity item) async {
    final result = await _favoritesService.toggle(
      item.itemId,
      variantId: item.representativeVariantId,
    );
    if (isClosed) return;
    result.fold((failure) => favoriteFailureEvent.value = failure, (_) {});
  }

  int cartQuantity(ProductCardEntity item) {
    return _cartStore.getCartQuantity(
      item.itemId,
      item.representativeVariantId,
    );
  }

  bool isCartUpsertLoading(ProductCardEntity item) {
    return _cartOperations.isLineOperationInFlight(
      item.itemId,
      item.representativeVariantId,
    );
  }

  Future<void> addToCart(ProductCardEntity item) async {
    final input = item.toCartUpsertInput();
    if (!input.isAvailable || (input.stock ?? 1) <= 0) {
      cartEvent.value = const RecentlyViewedCartEvent.unavailable();
      return;
    }

    final result = await _cartOperations.upsertInput(input, quantityDelta: 1);
    if (isClosed) return;
    result.fold(
      (failure) => cartEvent.value = RecentlyViewedCartEvent.failure(failure),
      (action) => cartEvent.value = RecentlyViewedCartEvent.success(action),
    );
  }
}
