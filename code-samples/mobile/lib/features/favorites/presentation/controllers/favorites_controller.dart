import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:get/get.dart';

import '../../../../binding_route_middleware/route.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/errors/failure_i18n.dart';
import '../../../../core/navigation/items_details_route_args.dart';
import '../../../auth/session/session_service.dart';

import '../../../cart/presentation/operations/cart_operations.dart';
import '../../../cart/presentation/store/cart_store.dart';
import '../../../cart/presentation/extensions/cart_upsert_input_extensions.dart';
import '../../../products/domain/entities/product_card_entity.dart';
import '../../domain/entities/favorite_entity.dart';
import '../../domain/entities/favorite_entity_extensions.dart';
import '../extension/fav_entity_extnsion.dart';
import '../favorites_ui_event.dart';
import '../services/favorites_recommended_service.dart';
import '../services/favorites_service.dart';
import '../state/fav_state.dart';
import '../state/favorites_recommended_state.dart';

class FavoritesController extends GetxController {
  final FavoritesService favoritesService;
  final FavoritesRecommendedService recommendedService;
  final CartOperations cartOperations;
  final CartStore cartStore;
  final SessionService sessionService;

  FavoritesController({
    required this.favoritesService,
    required this.recommendedService,
    required this.cartOperations,
    required this.cartStore,
    required this.sessionService,
  });

  List<FavoriteEntity> get favorites => favoritesService.favorites;

  final event = Rxn<FavoritesUiEvent>();
  /// Failure retained for the inline notice while page content remains visible.
  final pageRefreshFailure = Rxn<Failure>();
  StreamSubscription<int>? _sessionSubscription;
  int? _clearRetrySessionVersion;

  FavState get state => favoritesService.state.value;

  bool get isClearingFavorites => favoritesService.isClearing;

  @override
  void onReady() {
    super.onReady();
    _sessionSubscription = sessionService.sessionChanges.listen(
      (_) => _handleSessionChange(),
    );
    if (!sessionService.isAuthenticated) {
      favoritesService.requireLogin();
    } else {
      unawaited(favoritesService.loadFavorites());
      unawaited(recommendedService.fetchFirstPage());
    }
  }

  @override
  void onClose() {
    _clearRetrySessionVersion = null;
    _sessionSubscription?.cancel();
    super.onClose();
  }

  bool isFavorite(int itemId, int? variantId) {
    return favoritesService.isFavorite(itemId, variantId);
  }

  bool isFavoritePending(int itemId, int? variantId) {
    return favoritesService.isTogglePending(itemId, variantId);
  }

  bool canToggleFavorite(int itemId, int? variantId) {
    return favoritesService.canToggle(itemId, variantId);
  }

  Future<Either<Failure, ToggleFavoriteResult>> _toggle(
    int itemId, {
    int? variantId,
  }) async {
    final result = await favoritesService.toggle(itemId, variantId: variantId);
    return result.fold((failure) {
      event.value = FavoritesUiEvent.toggleError(failure);
      return Left(failure);
    }, (isAdded) => Right(isAdded));
  }

  Future<bool> removeFavorite(FavoriteEntity favorite) async {
    final result = await _toggle(
      favorite.itemId,
      variantId: _cartVariantId(favorite),
    );

    return result.fold((_) => false, (action) {
      if (action != ToggleFavoriteResult.removed) {
        return false;
      }

      event.value = const FavoritesUiEvent.removed();
      unawaited(recommendedService.refresh());
      return true;
    });
  }

  Future<void> addToCart(FavoriteEntity favorite) async {
    if (!favorite.canAddToCart || favorite.stockQuantity <= 0) {
      event.value = const FavoritesUiEvent.addToCartUnavailable();
      return;
    }

    final input = favorite.toCartUpsertInput();
    final result = await cartOperations.upsertInput(input, quantityDelta: 1);

    result.fold(
      (failure) => event.value = FavoritesUiEvent.addToCartFailure(failure),
      (action) => event.value = FavoritesUiEvent.addToCartSuccess(action),
    );
  }

  int cartQuantityForFavorite(FavoriteEntity favorite) {
    return cartStore.getCartQuantity(favorite.itemId, _cartVariantId(favorite));
  }

  bool isCartUpsertLoading(FavoriteEntity favorite) {
    return cartOperations.isLineOperationInFlight(
      favorite.itemId,
      _cartVariantId(favorite),
    );
  }

  Future<void> loadFavorites() => favoritesService.loadFavorites();

  Future<void> refreshPage() async {
    if (!sessionService.isAuthenticated) return;

    final sessionVersion = sessionService.sessionVersion;
    final failures = await Future.wait<Failure?>([
      favoritesService.refreshFavorites(),
      recommendedService.refresh(notifyFailure: false),
    ]);
    if (isClosed || sessionService.sessionVersion != sessionVersion) return;

    final failure = failures[0] ?? failures[1];
    final hasVisibleSnapshot =
        state is FavStateLoaded ||
        recommendedService.state.value is FavoritesRecommendedSuccess;
    pageRefreshFailure.value = hasVisibleSnapshot ? failure : null;
    if (failure != null) {
      event.value = FavoritesUiEvent.loadError(failure);
    }
  }

  Future<void> clearAllFavorites() async {
    _clearRetrySessionVersion = null;
    final sessionVersion = sessionService.sessionVersion;
    final result = await favoritesService.clearAllFavorites();
    if (isClosed || sessionService.sessionVersion != sessionVersion) return;
    result.fold(
      (failure) {
        if (failure.isTransportFailure) {
          _clearRetrySessionVersion = sessionVersion;
          event.value = FavoritesUiEvent.clearRetry(failure);
        } else {
          event.value = FavoritesUiEvent.clearError(failure);
        }
      },
      (_) {
        event.value = const FavoritesUiEvent.cleared();
        unawaited(recommendedService.refresh());
      },
    );
  }

  Future<void> retryClearOnce() async {
    final version = _clearRetrySessionVersion;
    _clearRetrySessionVersion = null;
    if (version == null ||
        isClosed ||
        !sessionService.isAuthenticated ||
        sessionService.sessionVersion != version ||
        favoritesService.isClearing ||
        favoritesService.hasPendingToggle) {
      return;
    }
    final result = await favoritesService.clearAllFavorites();
    if (isClosed || sessionService.sessionVersion != version) return;
    result.fold(
      (failure) => event.value = FavoritesUiEvent.clearError(failure),
      (_) {
        event.value = const FavoritesUiEvent.cleared();
        unawaited(recommendedService.refresh());
      },
    );
  }

  Future<void> loadMoreRecommended() => recommendedService.loadMore();

  Future<void> addRecommendedToCart(ProductCardEntity item) async {
    final input = item.toCartUpsertInput();
    if (!input.isAvailable || (input.stock ?? 1) <= 0) {
      event.value = const FavoritesUiEvent.addToCartUnavailable();
      return;
    }

    final result = await cartOperations.upsertInput(input, quantityDelta: 1);
    result.fold(
      (failure) => event.value = FavoritesUiEvent.addToCartFailure(failure),
      (action) => event.value = FavoritesUiEvent.addToCartSuccess(action),
    );
  }

  int cartQuantityForProductCard(ProductCardEntity item) {
    return cartStore.getCartQuantity(item.itemId, item.representativeVariantId);
  }

  bool isProductCardCartUpsertLoading(ProductCardEntity item) {
    return cartOperations.isLineOperationInFlight(
      item.itemId,
      item.representativeVariantId,
    );
  }

  Future<void> toggleRecommendedFavorite(ProductCardEntity item) async {
    final result = await _toggle(
      item.itemId,
      variantId: item.representativeVariantId,
    );

    result.fold((_) {}, (_) {
      unawaited(recommendedService.refresh());
    });
  }

  void openDetails(FavoriteEntity favorite, {required String heroTag}) {
    if (!favorite.canOpenDetails) return;

    Get.toNamed(
      RouteName.itemDetails,
      arguments: ItemsDetailsRouteArgs(
        itemId: favorite.itemId,
        variantId: favorite.targetType == FavoriteTargetType.variant
            ? favorite.variantId
            : null,
        heroTag: heroTag,
      ),
    );
  }

  void openRecommendedDetails(
    ProductCardEntity item, {
    required String heroTag,
  }) {
    Get.toNamed(
      RouteName.itemDetails,
      arguments: ItemsDetailsRouteArgs(
        itemId: item.itemId,
        variantId: item.representativeVariantId,
        colorGroupId: item.colorGroupId,
        heroTag: heroTag,
      ),
    );
  }

  String getMessageError(Failure failure) => FailureI18n.keyOf(failure).tr;

  void clearEvent() => event.value = null;

  int? _cartVariantId(FavoriteEntity favorite) {
    return favorite.targetType == FavoriteTargetType.variant
        ? favorite.variantId
        : null;
  }

  void _handleSessionChange() {
    _clearRetrySessionVersion = null;
    pageRefreshFailure.value = null;
    recommendedService.reset();
    if (sessionService.isAuthenticated) {
      unawaited(favoritesService.loadFavorites());
      unawaited(recommendedService.fetchFirstPage());
      return;
    }

    favoritesService.requireLogin();
  }
}
