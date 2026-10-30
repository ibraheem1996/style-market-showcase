import 'dart:async';

// Package imports:
import 'package:get/get.dart';

// Project imports:

import '../../../../binding_route_middleware/route.dart';
import '../../../../core/errors/failure.dart';
import '../../../audience/domain/entities/audience_entity.dart';
import '../../../audience/presentation/manager/audience_manager.dart';
import '../../../audience/presentation/store/audience_store.dart';
import '../../../cart/presentation/extensions/cart_upsert_input_extensions.dart';
import '../../../cart/presentation/operations/cart_operations.dart';
import '../../../cart/presentation/services/cart_recommended_service.dart';
import '../../../cart/presentation/store/cart_store.dart';
import '../../../favorites/presentation/services/favorites_recommended_service.dart';
import '../../../favorites/presentation/services/favorites_service.dart';
import '../services/home_categories_service.dart';
import '../../../products/domain/entities/product_card_entity.dart';
import '../../../../core/navigation/items_details_route_args.dart';
import '../services/home_banner_service.dart';
import '../services/home_collections_service.dart';
import '../services/home_featured_products_service.dart';
import '../services/home_new_arrivals_service.dart';
import '../services/home_offers_service.dart';
import '../services/home_recommended_service.dart';
import '../state/home_categories_state.dart';
import '../state/home_collections_state.dart';
import '../state/home_featured_products_state.dart';
import '../state/home_new_arrivals_state.dart';
import '../state/home_offers_state.dart';
import '../state/home_recommended_state.dart';
import '../../../recently_viewed/presentation/services/recently_viewed_service.dart';
import '../events/home_cart_event.dart';
import '../events/home_favorite_event.dart';
import '../../../../core/translations/locale_keys.dart';
import '../store/home_store.dart';

class HomeController extends GetxController {
  final favoriteEvents = Rxn<HomeFavoriteEvent>();
  final cartEvents = Rxn<HomeCartEvent>();
  final HomeStore homeStore;
  final AudienceStore audienceStore;
  final AudienceManager audienceManager;
  final HomeCategoriesService categoriesService;
  final HomeBannerService bannerService;
  final HomeCollectionsService collectionsService;
  final HomeNewArrivalsService newArrivalsService;
  final HomeOffersService offersService;
  final HomeFeaturedProductsService featuredProductsService;
  final RecentlyViewedService recentlyViewedService;
  final HomeRecommendedService recommendedService;
  final FavoritesRecommendedService favoritesRecommendedService;
  final CartRecommendedService cartRecommendedService;
  final FavoritesService favoritesService;
  final CartOperations cartOperations;
  final CartStore cartStore;

  HomeController({
    required this.homeStore,
    required this.audienceManager,
    required this.categoriesService,
    required this.audienceStore,
    required this.bannerService,
    required this.collectionsService,
    required this.newArrivalsService,
    required this.offersService,
    required this.featuredProductsService,
    required this.recentlyViewedService,
    required this.recommendedService,
    required this.favoritesRecommendedService,
    required this.cartRecommendedService,
    required this.favoritesService,
    required this.cartOperations,
    required this.cartStore,
  });

  @override
  void onReady() {
    super.onReady();
    unawaited(
      _runHomeOperation(() async {
        await Future.wait([
          categoriesService.fetchCategories(),
          bannerService.fetchBanners(),
          collectionsService.fetchCollections(),
          newArrivalsService.fetchNewArrivals(),
          offersService.fetchOffers(),
          featuredProductsService.fetchFeaturedProducts(),
          recommendedService.fetchFirstPage(),
        ]);
      }),
    );
    unawaited(recentlyViewedService.fetchForHomeBootstrap());
  }

  final pageRefreshFailure = Rxn<Failure>();
  final _homeOperationsInFlight = 0.obs;
  bool _isRefreshing = false;

  /// Disables audience changes while Home work can change its visible scope.
  bool get isAudienceSwitchEnabled {
    final recommendations = recommendedService.state.value;
    final recommendationsBusy = recommendations.maybeWhen(
      loading: () => true,
      success: (_, _, isLoadingMore) => isLoadingMore,
      orElse: () => false,
    );
    return _homeOperationsInFlight.value == 0 && !recommendationsBusy;
  }

  bool get isFullHomeError =>
      categoriesService.state.value.maybeWhen(
        error: (_) => true,
        orElse: () => false,
      ) &&
      newArrivalsService.newArrivalsState.value.maybeWhen(
        error: (_) => true,
        orElse: () => false,
      ) &&
      offersService.offersState.value.maybeWhen(
        error: (_) => true,
        orElse: () => false,
      ) &&
      collectionsService.collectionsState.value.maybeWhen(
        error: (_) => true,
        orElse: () => false,
      ) &&
      featuredProductsService.featuredProductsState.value.maybeWhen(
        error: (_) => true,
        orElse: () => false,
      );

  bool get hasValidCoreResult =>
      categoriesService.state.value.maybeWhen(
        success: (_) => true,
        orElse: () => false,
      ) ||
      newArrivalsService.newArrivalsState.value.maybeWhen(
        success: (_) => true,
        orElse: () => false,
      ) ||
      offersService.offersState.value.maybeWhen(
        success: (_) => true,
        orElse: () => false,
      ) ||
      collectionsService.collectionsState.value.maybeWhen(
        success: (_) => true,
        orElse: () => false,
      ) ||
      featuredProductsService.featuredProductsState.value.maybeWhen(
        success: (_) => true,
        orElse: () => false,
      );

  Future<T> _runHomeOperation<T>(Future<T> Function() action) async {
    _homeOperationsInFlight.value++;
    try {
      return await action();
    } finally {
      _homeOperationsInFlight.value--;
    }
  }

  Future<Failure?> refreshPage() async {
    if (_isRefreshing) return null;
    _isRefreshing = true;
    pageRefreshFailure.value = null;
    final audienceId = audienceStore.selectedAudience.value?.audienceId;
    try {
      return await _runHomeOperation(() async {
        final failures = await Future.wait<Failure?>([
          categoriesService.refreshCategories(),
          newArrivalsService.refreshNewArrivals(),
          offersService.refreshOffers(),
          collectionsService.refreshCollections(),
          featuredProductsService.refreshFeaturedProducts(),
          recommendedService.refresh(),
        ]);
        if (isClosed ||
            audienceStore.selectedAudience.value?.audienceId != audienceId) {
          return null;
        }

        Failure? failure;
        for (final candidate in failures) {
          if (candidate != null) {
            failure = candidate;
            break;
          }
        }
        if (failure == null || isFullHomeError || !hasValidCoreResult) {
          return null;
        }
        pageRefreshFailure.value = failure;
        return failure;
      });
    } finally {
      _isRefreshing = false;
    }
  }

  Future<void> retryCategories() => _runHomeOperation(() async {
    await categoriesService.fetchCategories();
  });

  /// Retries only the five core sections without page refresh feedback.
  Future<void> retryFullHome() async {
    pageRefreshFailure.value = null;
    await _runHomeOperation(() async {
      await Future.wait([
        categoriesService.fetchCategories(),
        newArrivalsService.fetchNewArrivals(),
        offersService.fetchOffers(),
        collectionsService.fetchCollections(),
        featuredProductsService.fetchFeaturedProducts(),
      ]);
    });
  }

  void goToItemDetails({
    required String heroTag,
    required int itemId,
    int? variantId,
    int? colorGroupId,
  }) {
    Get.toNamed(
      RouteName.itemDetails,
      arguments: ItemsDetailsRouteArgs(
        itemId: itemId,
        heroTag: heroTag,
        variantId: variantId,
        colorGroupId: colorGroupId,
      ),
    );
  }

  Future<void> changeAudience(AudienceEntity audience) async {
    final selectedAudienceId = audienceManager.selectedAudienceId;
    if (selectedAudienceId == audience.audienceId || !isAudienceSwitchEnabled) {
      return;
    }
    pageRefreshFailure.value = null;
    await _runHomeOperation(() async {
      final selection = audienceManager.selectAudience(audience);
      await Future.wait([
        selection,
        categoriesService.fetchCategories(),
        bannerService.fetchBanners(),
        collectionsService.fetchCollections(),
        newArrivalsService.fetchNewArrivals(),
        offersService.fetchOffers(),
        featuredProductsService.fetchFeaturedProducts(),
        recommendedService.reloadForAudience(),
        favoritesRecommendedService.refresh(),
        cartRecommendedService.refresh(),
      ]);
    });
  }

  Future<void> togleFavorites({required int itemId, int? variantId}) async {
    final result = await favoritesService.toggle(itemId, variantId: variantId);
    result.fold(
      (failure) {
        favoriteEvents.value = HomeFavoriteEvent.toggleFailed(failure);
      },
      (toggleRes) {
        final isAdded = toggleRes == ToggleFavoriteResult.added;
        favoriteEvents.value = HomeFavoriteEvent.toggleSuccess(
          isAdded
              ? LocaleKeys.addedToFavorites.tr
              : LocaleKeys.removedFromFavorites.tr,
        );
      },
    );
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

  /// Reads the shared cart quantity for the exact card line.
  int cartQuantityForProductCard(ProductCardEntity item) {
    return cartStore.getCartQuantity(item.itemId, item.representativeVariantId);
  }

  bool isCartUpsertLoading(ProductCardEntity item) => cartOperations
      .isLineOperationInFlight(item.itemId, item.representativeVariantId);

  /// Adds a product card through the shared cart service with optimistic state.
  Future<void> addProductCardToCart(ProductCardEntity item) async {
    final input = item.toCartUpsertInput();
    final result = await cartOperations.upsertInput(input, quantityDelta: 1);

    result.fold(
      (failure) {
        cartEvents.value = HomeCartEvent.upsertFailed(
          failure: failure,
          itemId: input.itemId,
          variantId: input.variantId,
        );
      },
      (action) {
        cartEvents.value = HomeCartEvent.upsertSuccess(
          action: action,
          itemId: input.itemId,
          variantId: input.variantId,
        );
      },
    );
  }
}
