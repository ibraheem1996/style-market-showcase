import 'dart:async';

import 'package:get/get.dart';

import '../../../../core/errors/app_failure_key.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/errors/failure_key.dart';
import '../../../../core/errors/failure_i18n.dart';
import '../../../../core/localization/languages.dart';
import '../../../../core/navigation/items_details_route_args.dart';
import '../../../../core/translations/locale_keys.dart';
import '../../../auth/session/session_service.dart';
import '../../../favorites/presentation/services/favorites_service.dart';
import '../../../addresses/domain/entities/address_entity.dart';
import '../../../addresses/domain/repositories/selected_address_reader.dart';
import '../../../home/presentation/store/home_store.dart';
import '../../../products/domain/entities/product_card_entity.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../event/cart_event.dart';
import '../extensions/cart_upsert_input_extensions.dart';
import '../logic/cart_line_rules.dart';
import '../operations/cart_operations.dart';
import '../services/cart_recommended_service.dart';
import '../state/cart_recommended_state.dart';
import '../state/cart_state.dart';
import '../store/cart_store.dart';
import '../view_data/cart_checkout_bar_view_data.dart';
import '../view_data/cart_line_view_data.dart';
import '../view_data/cart_view_data_mapper.dart';

class CartController extends GetxController {
  CartController({
    required CartOperations cartOperations,
    required CartStore cartStore,
    required HomeStore homeStore,
    required this.recommendedService,
    required FavoritesService favoritesService,
    required SelectedAddressReader selectedAddressReader,
    required this.sessionService,
  }) : _cartOperations = cartOperations,
       _cartStore = cartStore,
       _homeStore = homeStore,
       _favoritesService = favoritesService,
       _selectedAddressReader = selectedAddressReader;

  final SessionService sessionService;

  final Rxn<CartEvent> cartEvent = Rxn<CartEvent>();
  final Rx<CartState> state = const CartState.initial().obs;

  /// Retains the last page refresh failure while either section has content.
  final pageRefreshFailure = Rxn<Failure>();
  final RxBool _showCheckoutBlockMessage = false.obs;

  final CartOperations _cartOperations;
  final CartRecommendedService recommendedService;
  final CartStore _cartStore;
  final HomeStore _homeStore;
  final FavoritesService _favoritesService;
  final SelectedAddressReader _selectedAddressReader;

  AddressEntity? get selectedDeliveryAddress =>
      _selectedAddressReader.selectedAddress;

  StreamSubscription<int>? _sessionSubscription;

  bool get isCartTabSelected => _homeStore.isCartSelected;

  bool get isLoaded =>
      state.value.maybeWhen(loaded: () => true, orElse: () => false);

  bool get isClearing => _cartOperations.isClearing;

  int get cartCount => _cartStore.selectedItems.length;

  List<CartLineViewData> get lineViewData {
    final isArabic = Get.find<Languages>().isArabic;
    return _cartStore.items
        .map(
          (item) => CartViewDataMapper.line(
            item: item,
            isArabic: isArabic,
            isLineMutating: _cartOperations.isLineOperationInFlightForItem(
              item,
            ),
            isSelectionMutating: _cartOperations.isSelectionOperationInFlight(
              item.cartId,
            ),
          ),
        )
        .toList(growable: false);
  }

  CartCheckoutBarViewData get checkoutBar {
    return CartViewDataMapper.checkoutBar(
      items: isLoaded ? _cartStore.items : const <CartItemEntity>[],
      hasPendingCheckoutOperation: _cartOperations.hasPendingCheckoutOperation,
      shouldShowBlockedMessage: _showCheckoutBlockMessage.value,
    );
  }

  @override
  void onReady() {
    super.onReady();
    _sessionSubscription = sessionService.sessionChanges.listen(
      (_) => _handleSessionChange(),
    );
    if (!sessionService.isAuthenticated) {
      requireLogin();
    } else {
      unawaited(refreshCart());
      unawaited(recommendedService.fetchFirstPage());
    }
  }

  @override
  void onClose() {
    _sessionSubscription?.cancel();
    super.onClose();
  }

  void requireLogin() {
    _cartOperations.clearLocalOnly();
    state.value = const CartState.failure(
      failure: Failure.app(key: AppFailureKey.loginRequired),
    );
  }

  Future<void> increaseLine(CartLineViewData line) async {
    final item = _itemFor(line);
    if (item == null) return;
    if (!line.canIncrease) {
      if (item.canEditQuantity(isLinePending: line.isLineMutating)) {
        cartEvent.value = CartEvent.maxQuantityReached(
          maxQuantity: line.maxQuantity,
        );
      }
      return;
    }

    final result = await _cartOperations.changeQuantity(
      cartItem: item,
      quantityDelta: 1,
    );
    result.fold(
      (failure) => cartEvent.value = CartEvent.failureQuantityUpdate(failure),
      (_) {},
    );
  }

  Future<void> decreaseLine(CartLineViewData line) async {
    final item = _itemFor(line);
    if (item == null || !line.canDecrease) return;

    final result = await _cartOperations.changeQuantity(
      cartItem: item,
      quantityDelta: -1,
    );
    result.fold(
      (failure) => cartEvent.value = CartEvent.failureQuantityUpdate(failure),
      (_) {},
    );
  }

  Future<void> deleteLine(CartLineViewData line) async {
    if (!line.canDelete) return;
    final item = _itemFor(line);
    if (item == null) return;

    final result = await _cartOperations.removeLine(cartItem: item);
    result.fold(
      (failure) => cartEvent.value = CartEvent.failureQuantityUpdate(failure),
      (_) {},
    );
  }

  Future<Failure?> refreshCart() async {
    if (!sessionService.isAuthenticated) return null;

    final hadLoadedSnapshot = isLoaded;
    final requestSessionVersion = sessionService.sessionVersion;
    final requestUserId = sessionService.userId;
    final requestAuthenticated = sessionService.isAuthenticated;
    if (!hadLoadedSnapshot) {
      state.value = const CartState.loading();
    }
    final result = await _cartOperations.refreshCart();
    if (isClosed) return null;
    if (!_isSameSession(
      version: requestSessionVersion,
      userId: requestUserId,
      isAuthenticated: requestAuthenticated,
    )) {
      return null;
    }

    return result.fold(
      (failure) {
        if (!hadLoadedSnapshot || _clearsSnapshotOnFailure(failure)) {
          state.value = CartState.failure(failure: failure);
        }
        return failure;
      },
      (outcome) {
        switch (outcome) {
          case CartRefreshOutcome.applied:
          case CartRefreshOutcome.ignoredDuringMutation:
            state.value = const CartState.loaded();
          case CartRefreshOutcome.ignoredStaleRefresh:
            break;
        }
        return null;
      },
    );
  }

  bool _clearsSnapshotOnFailure(Failure failure) {
    return failure.maybeWhen(
      http: (key, _, __, ___, ____) => switch (key) {
        FailureKey.userNotFound ||
        FailureKey.forbidden ||
        FailureKey.unauthorized => true,
        _ => false,
      },
      orElse: () => false,
    );
  }

  Future<void> refreshPage() async {
    if (!sessionService.isAuthenticated) return;
    final sessionVersion = sessionService.sessionVersion;
    final failures = await Future.wait<Failure?>([
      refreshCart(),
      recommendedService.refresh(silent: true),
    ]);
    if (isClosed || sessionService.sessionVersion != sessionVersion) return;

    final failure = failures[0] ?? failures[1];
    final hasVisibleSnapshot =
        isLoaded ||
        recommendedService.state.value is CartRecommendedSuccess ||
        recommendedService.state.value == const CartRecommendedState.empty();
    pageRefreshFailure.value = hasVisibleSnapshot ? failure : null;
    if (failure != null) {
      cartEvent.value = CartEvent.pageRefreshFailed(failure);
    }
  }

  /// Retries only the cart section after its own error.
  Future<void> retryCart() async {
    pageRefreshFailure.value = null;
    await refreshCart();
  }

  /// Retries only the first recommendations page after its own error.
  Future<void> retryRecommended() async {
    pageRefreshFailure.value = null;
    await recommendedService.fetchFirstPage();
  }

  Future<void> clearCart() async {
    final result = await _cartOperations.clearAllCart();
    result.fold((failure) {
      cartEvent.value = CartEvent.failureClearAll(failure);
    }, (_) => unawaited(recommendedService.refresh()));
  }

  Future<void> setLineSelected(CartLineViewData line, bool isSelected) async {
    if (!line.canSelect) return;
    final result = await _cartOperations.toggleSelection(
      cartId: line.cartId,
      isSelected: isSelected,
    );
    result.fold((failure) {
      cartEvent.value = CartEvent.failureSelection(failure);
    }, (_) {});
  }

  Future<void> addRecommendedToCart(ProductCardEntity item) async {
    final input = item.toCartUpsertInput();
    if (!input.isAvailable || (input.stock ?? 1) <= 0) {
      cartEvent.value = const CartEvent.addToCartUnavailable();
      return;
    }

    final result = await _cartOperations.upsertInput(input, quantityDelta: 1);
    result.fold(
      (failure) =>
          cartEvent.value = CartEvent.addToCartFailure(failure: failure),
      (action) {
        recommendedService.removeItemLocally(item);
        unawaited(recommendedService.refresh(silent: true));
        cartEvent.value = CartEvent.addToCartSuccess(action: action);
      },
    );
  }

  Future<void> toggleRecommendedFavorite(ProductCardEntity item) async {
    final result = await _favoritesService.toggle(
      item.itemId,
      variantId: item.representativeVariantId,
    );

    result.fold(
      (failure) =>
          cartEvent.value = CartEvent.favoriteToggleFailure(failure: failure),
      (toggleResult) {
        final message = toggleResult == ToggleFavoriteResult.added
            ? LocaleKeys.addedToFavorites.tr
            : LocaleKeys.removedFromFavorites.tr;
        cartEvent.value = CartEvent.favoriteToggleSuccess(message: message);
      },
    );
  }

  bool isRecommendedFavorite(ProductCardEntity item) {
    return _favoritesService.isFavorite(
      item.itemId,
      item.representativeVariantId,
    );
  }

  bool isRecommendedFavoritePending(ProductCardEntity item) {
    return _favoritesService.isTogglePending(
      item.itemId,
      item.representativeVariantId,
    );
  }

  bool canToggleRecommendedFavorite(ProductCardEntity item) {
    return _favoritesService.canToggle(
      item.itemId,
      item.representativeVariantId,
    );
  }

  int cartQuantityForProductCard(ProductCardEntity item) {
    return _cartStore.getCartQuantity(
      item.itemId,
      item.representativeVariantId,
    );
  }

  bool isProductCardCartUpsertLoading(ProductCardEntity item) {
    return _cartOperations.isLineOperationInFlight(
      item.itemId,
      item.representativeVariantId,
    );
  }

  Future<void> loadMoreRecommended() => recommendedService.loadMore();

  void openCartLineDetails(CartLineViewData line, {required String heroTag}) {
    cartEvent.value = CartEvent.navigateToProductDetails(
      args: ItemsDetailsRouteArgs(
        itemId: line.identity.itemId,
        variantId: line.identity.variantId,
        heroTag: heroTag,
      ),
    );
  }

  void openVariantSelection(CartLineViewData line, {required String heroTag}) {
    cartEvent.value = CartEvent.navigateToProductDetails(
      args: ItemsDetailsRouteArgs(
        itemId: line.identity.itemId,
        heroTag: heroTag,
      ),
    );
  }

  void openRecommendedDetails(
    ProductCardEntity item, {
    required String heroTag,
  }) {
    cartEvent.value = CartEvent.navigateToProductDetails(
      args: ItemsDetailsRouteArgs(
        itemId: item.itemId,
        variantId: item.representativeVariantId,
        colorGroupId: item.colorGroupId,
        heroTag: heroTag,
      ),
    );
  }

  void startCheckout() {
    final bar = checkoutBar;
    if (!bar.canCheckout) {
      _showCheckoutBlockMessage.value = true;
      return;
    }
    _showCheckoutBlockMessage.value = false;
    cartEvent.value = const CartEvent.navigateToCheckout();
  }

  String getMessageError(Failure failure) => FailureI18n.keyOf(failure).tr;

  CartItemEntity? _itemFor(CartLineViewData line) {
    if (line.cartId != 0) {
      final byCartId = _cartStore.items.firstWhereOrNull(
        (item) => item.cartId == line.cartId,
      );
      if (byCartId != null) return byCartId;
    }
    return _cartStore.find(line.identity);
  }

  void _handleSessionChange() {
    pageRefreshFailure.value = null;
    cartEvent.value = null;
    _showCheckoutBlockMessage.value = false;
    recommendedService.reset();
    if (sessionService.isAuthenticated) {
      // Clearing the old store also invalidates its pending refresh result.
      _cartOperations.clearLocalOnly();
      state.value = const CartState.initial();
      unawaited(refreshCart());
      unawaited(recommendedService.fetchFirstPage());
      return;
    }

    requireLogin();
  }

  bool _isSameSession({
    required int version,
    required int? userId,
    required bool isAuthenticated,
  }) {
    return sessionService.sessionVersion == version &&
        sessionService.userId == userId &&
        sessionService.isAuthenticated == isAuthenticated;
  }
}
