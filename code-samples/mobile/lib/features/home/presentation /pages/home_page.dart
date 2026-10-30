// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';
import 'package:my_project/core/errors/failure_i18n.dart';
import 'package:my_project/core/utils/responsive/app_design_tokens.dart';

// Project imports:
import '../../../../../core/translations/locale_keys.dart';
import '../../../../../core/overlays/app_snackbar.dart';
import '../../../../../binding_route_middleware/route.dart';
import '../../../../core/utils/responsive/app_text_scale_limits.dart';
import '../../../../core/widgets/rx_event_listener.dart';
import '../../../../core/widgets/responsive_content.dart';
import '../../../../core/widgets/error/app_error_view.dart';
import '../../../../core/widgets/error/app_inline_refresh_failure.dart';
import '../../../../core/widgets/error/extension_failure_to_ui.dart';
import '../../../cart/domain/entities/cart_item_entity.dart';
import '../../../audience/presentation/widgets/audience_switcher_widget.dart';
import '../../../auth/presentation/navigation/login_route_args.dart';
import '../../../listing/presentation/navigation/listing_route_args.dart';
import '../../../products/domain/entities/product_catalog_source.dart';
import '../../../products/domain/entities/category_entity.dart';
import '../../../recently_viewed/presentation/states/recently_viewed_state.dart';
import '../../../recently_viewed/recently_viewed_constants.dart';
import '../../../recommendations/presentation/widgets/recommendation_first_load_error_view.dart';
import '../controllers/home_controller.dart';
import '../navigation/home_navigation_coordinator.dart';
import '../store/home_store.dart';
import '../navigation/home_navigation.dart';
import '../services/home_banner_service.dart';
import '../services/home_new_arrivals_service.dart';
import '../services/home_collections_service.dart';
import '../services/home_featured_products_service.dart';
import '../state/home_collections_state.dart';
import '../state/home_featured_products_state.dart';
import '../state/home_new_arrivals_state.dart';
import '../state/home_offers_state.dart';
import '../state/home_categories_state.dart';
import '../state/home_recommended_state.dart';
import '../widgets/home_page/cat/cat_view.dart';
import '../widgets/home_page/collections/home_collections_section.dart';
import '../widgets/home_page/featured_products/home_featured_products_section.dart';
import '../widgets/home_page/home_banner_widget.dart';
import '../widgets/home_page/home_search_entry.dart';
import '../widgets/home_page/new_arrival/home_new_arrivals_section.dart';
import '../widgets/home_page/offers/home_offers_section.dart';
import '../services/home_offers_service.dart';
import '../widgets/home_page/recommended/home_recommended_skeleton.dart';
import '../widgets/home_page/recommended/home_recommended_header.dart';
import '../widgets/home_page/sliver_appbar.dart';
import '../../../../features/recently_viewed/presentation/widgets/home_recently_viewed_section.dart';
import '../events/home_cart_event.dart';
import '../events/home_recommended_event.dart';
import '../services/home_recommended_service.dart';
import '../widgets/home_page/recommended/home_recommended_section.dart';
import '../events/home_favorite_event.dart';
import '../../../../core/widgets/error/extension_failure_to_snak_bar.dart';
import '../../../../core/widgets/error/extension_failure_to_dialog.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const double _loadMoreThreshold = 600;
  static const double _bottomScrollPadding = AppSpacing.xxl;
  late final ScrollController _scrollController;
  final ValueNotifier<bool> stayBanerContollerWorking = ValueNotifier<bool>(
    true,
  );

  HomeController get controller => Get.find<HomeController>();

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - _loadMoreThreshold) {
      final service = Get.find<HomeRecommendedService>();
      if (service.event.value == null) {
        service.loadMore();
      }
    }
    _refreshBannerController();
  }

  void _refreshBannerController() {
    final shouldWork = _scrollController.offset < 500;

    if (stayBanerContollerWorking.value != shouldWork) {
      stayBanerContollerWorking.value = shouldWork;
    }
  }

  Future<void> _refreshWithFeedback() async {
    final audienceId =
        controller.audienceStore.selectedAudience.value?.audienceId;
    final failure = await controller.refreshPage();
    if (!mounted ||
        controller.isClosed ||
        failure == null ||
        controller.homeStore.selectedTab != MainTab.home ||
        controller.audienceStore.selectedAudience.value?.audienceId !=
            audienceId) {
      return;
    }
    await AppSnackbar.show(failure.message, tone: AppSnackbarTone.error);
  }

  Widget _fullHomeError(HomeController controller) {
    final failure = controller.categoriesService.state.value.maybeWhen(
      error: (value) => value,
      orElse: () => null,
    );
    if (failure == null) return const SizedBox.shrink();
    return AppErrorView(
      model: failure.toUI(
        retry: controller.retryFullHome,
        goBack: () => Get.back(),
        goLogin: () => Get.toNamed(
          RouteName.loginFlow,
          arguments: const LoginRouteArgs.flow(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    stayBanerContollerWorking.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: AppTextScaleLimits.maxHomeBody,
      child: RxEventListener<HomeCartEvent>(
        rxnEvent: controller.cartEvents,
        clearEvent: () => controller.cartEvents.value = null,
        onEvent: (event) async {
          await event.when(
            upsertSuccess: (action, _, __) async {
              await AppSnackbar.show(
                _cartActionMessage(action),
                tone: AppSnackbarTone.success,
              );
            },
            upsertFailed: (failure, _, __) async {
              failure.handleSnackBar();
              failure.handleDialog(
                goLogin: () {
                  Get.toNamed(
                    RouteName.loginFlow,
                    arguments: const LoginRouteArgs.flow(),
                  );
                },
              );
            },
          );
        },
        child: RxEventListener<HomeFavoriteEvent>(
          rxnEvent: controller.favoriteEvents,
          clearEvent: () => controller.favoriteEvents.value = null,
          onEvent: (event) async {
            event.when(
              toggleFailed: (error) {
                error.handleSnackBar();
                error.handleDialog(
                  goLogin: () {
                    Get.toNamed(
                      RouteName.loginFlow,
                      arguments: const LoginRouteArgs.flow(),
                    );
                  },
                );
              },
              toggleSuccess: (action) {
                AppSnackbar.show(action, tone: AppSnackbarTone.success);
              },
            );
          },
          child: SafeArea(
            child: Scaffold(
              body: RefreshIndicator.adaptive(
                onRefresh: _refreshWithFeedback,
                child: CustomScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    Obx(() {
                      final audiences = controller.audienceStore.audiences;
                      final selected =
                          controller.audienceStore.selectedAudience.value;
                      final hasAudience =
                          audiences.isNotEmpty &&
                          selected != null &&
                          audiences.length != 1;

                      return HomeStoreHeader(
                        onLogoTap: () => _scrollController.animateTo(
                          0,
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeOut,
                        ),
                        audienceSwitcher: hasAudience
                            ? IgnorePointer(
                                ignoring: !controller.isAudienceSwitchEnabled,
                                child: AudienceSwitcherWidget(
                                  audiences: audiences,
                                  selected: selected,
                                  onSelect: controller.changeAudience,
                                ),
                              )
                            : null,
                      );
                    }),
                    Obx(() {
                      final fullError = controller.isFullHomeError;
                      final refreshFailure =
                          controller.pageRefreshFailure.value;
                      return SliverMainAxisGroup(
                        slivers: [
                          if (fullError)
                            ResponsiveSliverContent.standard(
                              slivers: [
                                SliverToBoxAdapter(
                                  child: _fullHomeError(controller),
                                ),
                              ],
                            )
                          else ...[
                            ResponsiveSliverContent.standard(
                              slivers: [
                                if (refreshFailure != null)
                                  SliverPadding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.sm,
                                      vertical: AppSpacing.xs,
                                    ),
                                    sliver: SliverToBoxAdapter(
                                      child: AppInlineRefreshFailure(
                                        message: refreshFailure.message,
                                        retryLabel: LocaleKeys.retry.tr,
                                        onRetry: _refreshWithFeedback,
                                      ),
                                    ),
                                  ),
                                SliverToBoxAdapter(
                                  child: HomeSearchEntry(
                                    onTap: () =>
                                        Get.toNamed(RouteName.productSearch),
                                  ),
                                ),
                                SliverToBoxAdapter(
                                  child: SizedBox(height: AppSpacing.xxl),
                                ),

                                SliverToBoxAdapter(
                                  child: HomeBannerWidget(
                                    shouldWork: stayBanerContollerWorking,
                                    service: Get.find<HomeBannerService>(),
                                    onTap: handleHomeBannerAction,
                                  ),
                                ),

                                Obx(() {
                                  final state =
                                      Get.find<HomeNewArrivalsService>()
                                          .newArrivalsState
                                          .value;

                                  return state.maybeWhen(
                                    success: (products) {
                                      if (products.isEmpty) {
                                        return const SliverToBoxAdapter(
                                          child: SizedBox.shrink(),
                                        );
                                      }
                                      return SliverToBoxAdapter(
                                        child: Column(
                                          children: [
                                            HomeNewArrivalsSection(
                                              onFavTap:
                                                  controller.togleFavorites,
                                              onAddToCart: controller
                                                  .addProductCardToCart,
                                              cartQuantityForProduct: controller
                                                  .cartQuantityForProductCard,
                                              isCartUpsertLoading: controller
                                                  .isCartUpsertLoading,
                                              isFavorite: (item) =>
                                                  controller.isFavorite(
                                                    item.itemId,
                                                    item.representativeVariantId,
                                                  ),
                                              isFavoritePending: (item) =>
                                                  controller.isFavoritePending(
                                                    item.itemId,
                                                    item.representativeVariantId,
                                                  ),
                                              canToggleFavorite: (item) =>
                                                  controller.canToggleFavorite(
                                                    item.itemId,
                                                    item.representativeVariantId,
                                                  ),
                                              products: products,
                                              goToItemDetails:
                                                  controller.goToItemDetails,
                                              onViewAll: () {
                                                Get.toNamed(
                                                  RouteName.listing,
                                                  arguments: ListingRouteArgs(
                                                    source: ProductCatalogSource(
                                                      sourceType:
                                                          ProductCatalogSourceType
                                                              .section,
                                                      sourceId: 'new_arrivals',
                                                      titleAr: LocaleKeys
                                                          .homeNewArrivals
                                                          .tr,
                                                      titleEn: LocaleKeys
                                                          .homeNewArrivals
                                                          .tr,
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                            SizedBox(height: AppSpacing.xxl),
                                          ],
                                        ),
                                      );
                                    },
                                    loading: () => SliverToBoxAdapter(
                                      child: Column(
                                        children: [
                                          const HomeNewArrivalsSkeleton(),
                                          SizedBox(height: AppSpacing.xxl),
                                        ],
                                      ),
                                    ),
                                    orElse: () => const SliverToBoxAdapter(
                                      child: SizedBox.shrink(),
                                    ),
                                  );
                                }),
                                ..._remainingHomeSlivers(controller),
                              ],
                            ),
                            ResponsiveSliverContent.catalog(
                              slivers: [_recommendedHomeSliver(controller)],
                            ),
                          ],
                        ],
                      );
                    }),
                    const SliverToBoxAdapter(
                      child: SizedBox(height: _bottomScrollPadding),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _remainingHomeSlivers(HomeController controller) {
    return [
      Obx(() {
        final state = controller.categoriesService.state.value;
        return SliverToBoxAdapter(
          child: state.maybeWhen(
            success: (categories) {
              if (categories.isEmpty) {
                return const SizedBox.shrink();
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MediaQuery.withClampedTextScaling(
                    maxScaleFactor: AppTextScaleLimits.categories,
                    child: CustomCatView(
                      cats: categories,
                      onTapCat: (CategoryEntity cat) {
                        Get.toNamed(
                          RouteName.listing,
                          arguments: ListingRouteArgs(
                            source: ProductCatalogSource(
                              sourceType: ProductCatalogSourceType.category,
                              sourceId: '${cat.catId}',
                              titleAr: cat.catName,
                              titleEn: cat.catNameEn,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: AppSpacing.xl),
                ],
              );
            },
            loading: () => Column(
              children: [
                const HomeCategoriesSkeleton(),
                SizedBox(height: AppSpacing.xl),
              ],
            ),
            error: (failure) => Column(
              children: [
                SizedBox(height: AppSpacing.xxl),

                HomeCategoriesError(
                  message: failure.message,
                  onRetry: controller.retryCategories,
                ),
                SizedBox(height: AppSpacing.xl * 2),
              ],
            ),

            orElse: () => const SizedBox.shrink(),
          ),
        );
      }),

      Obx(() {
        final state = Get.find<HomeOffersService>().offersState.value;
        return SliverToBoxAdapter(
          child: state.maybeWhen(
            success: (products) {
              if (products.isEmpty) {
                return const SizedBox.shrink();
              }
              return Column(
                children: [
                  HomeOffersSection(
                    products: products,
                    goToItemDetails: controller.goToItemDetails,
                    onAddToCart: controller.addProductCardToCart,
                    cartQuantityForProduct:
                        controller.cartQuantityForProductCard,
                    isCartUpsertLoading: controller.isCartUpsertLoading,

                    onViewAll: () {
                      Get.toNamed(
                        RouteName.listing,
                        arguments: ListingRouteArgs(
                          source: ProductCatalogSource(
                            sourceType: ProductCatalogSourceType.section,
                            sourceId: 'offers',
                            titleAr: LocaleKeys.homeOffersTitle.tr,
                            titleEn: LocaleKeys.homeOffersTitle.tr,
                          ),
                          initialSort: 'discount_desc',
                        ),
                      );
                    },
                  ),
                  SizedBox(height: AppSpacing.xl * 2),
                ],
              );
            },
            loading: () => Column(
              children: [
                const HomeOffersSkeleton(),
                SizedBox(height: AppSpacing.xl * 2),
              ],
            ),
            orElse: () => const SizedBox.shrink(),
          ),
        );
      }),

      Obx(() {
        final state = Get.find<HomeCollectionsService>().collectionsState.value;
        return SliverToBoxAdapter(
          child: state.maybeWhen(
            success: (collections) {
              if (collections.isEmpty) {
                return const SizedBox.shrink();
              }
              return Column(
                children: [
                  HomeCollectionsSection(
                    collections: collections,
                    onTapCollection: openHomeCollectionListing,
                  ),
                  SizedBox(height: AppSpacing.xl * 2),
                ],
              );
            },
            loading: () => Column(
              children: [
                const HomeCollectionsSkeleton(),
                SizedBox(height: AppSpacing.xl * 2),
              ],
            ),
            orElse: () => const SizedBox.shrink(),
          ),
        );
      }),

      Obx(() {
        final state =
            Get.find<HomeFeaturedProductsService>().featuredProductsState.value;
        return SliverToBoxAdapter(
          child: state.maybeWhen(
            success: (products) {
              if (products.isEmpty) {
                return const SizedBox.shrink();
              }
              return Column(
                children: [
                  HomeFeaturedProductsSection(
                    products: products,
                    goToItemDetails: controller.goToItemDetails,
                    onAddToCart: controller.addProductCardToCart,
                    cartQuantityForProduct:
                        controller.cartQuantityForProductCard,
                    isCartUpsertLoading: (productCardEntity) =>
                        controller.isCartUpsertLoading(productCardEntity),
                    onToggleFavorite: (item) => controller.togleFavorites(
                      itemId: item.itemId,
                      variantId: item.representativeVariantId,
                    ),
                    isFavorite: (item) => controller.isFavorite(
                      item.itemId,
                      item.representativeVariantId,
                    ),
                    isFavoritePending: (item) => controller.isFavoritePending(
                      item.itemId,
                      item.representativeVariantId,
                    ),
                    canToggleFavorite: (item) => controller.canToggleFavorite(
                      item.itemId,
                      item.representativeVariantId,
                    ),
                    onViewAll: () {
                      Get.toNamed(
                        RouteName.listing,
                        arguments: ListingRouteArgs(
                          source: ProductCatalogSource(
                            sourceType: ProductCatalogSourceType.section,
                            sourceId: 'featured',
                            titleAr: LocaleKeys.homeFeaturedProducts.tr,
                            titleEn: LocaleKeys.homeFeaturedProducts.tr,
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: AppSpacing.xxl),
                ],
              );
            },
            loading: () => Column(
              children: [
                const HomeFeaturedProductsSkeleton(),
                SizedBox(height: AppSpacing.xxl),
              ],
            ),
            orElse: () => const SizedBox.shrink(),
          ),
        );
      }),
      Obx(() {
        final state = controller.recentlyViewedService.state.value;

        return SliverToBoxAdapter(
          child: state.maybeWhen(
            loading: () => Column(
              children: [
                const HomeRecentlyViewedSkeleton(),
                SizedBox(height: AppSpacing.xxl),
              ],
            ),
            success: (items) {
              if (items.isEmpty) {
                return const SizedBox.shrink();
              }
              final homeItems = items
                  .take(RecentlyViewedConstants.homeGridCount)
                  .toList(growable: false);
              return Column(
                children: [
                  HomeRecentlyViewedSection(
                    items: homeItems,
                    onGoToItemDetails: controller.goToItemDetails,
                    onAddToCart: controller.addProductCardToCart,
                    cartQuantityForProduct:
                        controller.cartQuantityForProductCard,
                    isCartUpsertLoading: controller.isCartUpsertLoading,
                    onToggleFavorite: (item) => controller.togleFavorites(
                      itemId: item.itemId,
                      variantId: item.representativeVariantId,
                    ),
                    isFavorite: (item) => controller.isFavorite(
                      item.itemId,
                      item.representativeVariantId,
                    ),
                    isFavoritePending: (item) => controller.isFavoritePending(
                      item.itemId,
                      item.representativeVariantId,
                    ),
                    canToggleFavorite: (item) => controller.canToggleFavorite(
                      item.itemId,
                      item.representativeVariantId,
                    ),
                    onViewAll: () => Get.toNamed(RouteName.recentlyViewed),
                  ),
                  SizedBox(height: AppSpacing.xxl),
                ],
              );
            },
            orElse: () => const SizedBox.shrink(),
          ),
        );
      }),
    ];
  }

  Widget _recommendedHomeSliver(HomeController controller) {
    return Obx(() {
      final service = Get.find<HomeRecommendedService>();
      final state = service.state.value;
      final loadMoreFailure = service.event.value?.when(
        loadMoreFailed: (failure) => failure,
      );
      return state.maybeWhen(
        success: (items, pagination, isLoadingMore) {
          if (items.isEmpty) {
            return const SliverToBoxAdapter(child: SizedBox.shrink());
          }
          return HomeRecommendedSection(
            headerKey: HomeNavigationCoordinator.recommendedKey,
            items: items,
            isLoadingMore: isLoadingMore,
            loadMoreErrorMessage: loadMoreFailure == null
                ? null
                : LocaleKeys.homeRecommendedLoadMoreError.tr,
            hasMore: pagination.hasMore,
            onTapItem: controller.goToItemDetails,
            onAddToCart: controller.addProductCardToCart,
            cartQuantityForProduct: controller.cartQuantityForProductCard,
            isCartUpsertLoading: controller.isCartUpsertLoading,
            onToggleFavorite: (item) => controller.togleFavorites(
              itemId: item.itemId,
              variantId: item.representativeVariantId,
            ),
            isFavorite: (item) => controller.isFavorite(
              item.itemId,
              item.representativeVariantId,
            ),
            isFavoritePending: (item) => controller.isFavoritePending(
              item.itemId,
              item.representativeVariantId,
            ),
            canToggleFavorite: (item) => controller.canToggleFavorite(
              item.itemId,
              item.representativeVariantId,
            ),
            onRetryLoadMore: service.loadMore,
          );
        },
        loading: () => const HomeRecommendedSkeleton(),
        error: (failure) => SliverMainAxisGroup(
          slivers: [
            const SliverToBoxAdapter(child: HomeRecommendedHeader()),
            SliverToBoxAdapter(
              child: RecommendationFirstLoadErrorView(
                message: failure.message,
                retryLabel: LocaleKeys.homeRecommendedRetry.tr,
                onRetry: service.fetchFirstPage,
              ),
            ),
          ],
        ),
        orElse: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
      );
    });
  }

  String _cartActionMessage(CartAction action) {
    return switch (action) {
      CartAction.added => LocaleKeys.cartAddSuccess.tr,
      CartAction.updated => LocaleKeys.cartUpdateSuccess.tr,
      CartAction.removed => LocaleKeys.cartRemoveSuccess.tr,
    };
  }
}
