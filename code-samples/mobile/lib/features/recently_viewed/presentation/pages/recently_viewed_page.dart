import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';

import '../../../../binding_route_middleware/route.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/errors/failure_i18n.dart';
import '../../../../core/navigation/items_details_route_args.dart';
import '../../../../core/overlays/app_snackbar.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/translations/locale_keys.dart';
import '../../../../core/utils/responsive/app_catalog_grid_layout.dart';
import '../../../../core/utils/responsive/app_responsive_value.dart';
import '../../../../core/widgets/error/app_error_view.dart';
import '../../../../core/widgets/error/extension_failure_to_dialog.dart';
import '../../../../core/widgets/error/extension_failure_to_snak_bar.dart';
import '../../../../core/widgets/error/extension_failure_to_ui.dart';
import '../../../../core/widgets/rx_event_listener.dart';
import '../../../../core/widgets/responsive_content.dart';
import '../../../cart/domain/entities/cart_item_entity.dart';
import '../../../auth/presentation/navigation/login_route_args.dart';
import '../controllers/recently_viewed_view_all_controller.dart';
import '../event/recently_viewed_event_ui.dart';
import '../states/recently_viewed_state.dart';
import '../widgets/home_recently_viewed_card.dart';
import '../../recently_viewed_constants.dart';

class RecentlyViewedPage extends GetView<RecentlyViewedViewAllController> {
  const RecentlyViewedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return RxEventListener<RecentlyViewedCartEvent>(
      rxnEvent: controller.cartEvent,
      clearEvent: controller.clearCartEvent,
      onEvent: _onCartEvent,
      child: RxEventListener(
        rxnEvent: controller.favoriteFailureEvent,
        clearEvent: controller.clearFavoriteFailureEvent,
        onEvent: _onFavoriteFailure,
        child: RxEventListener(
          rxnEvent: controller.refreshFailureEvent,
          clearEvent: controller.clearRefreshFailureEvent,
          onEvent: _onRefreshFailure,
          child: Scaffold(
            appBar: AppBar(
              title: Text(
                LocaleKeys.recentlyViewedTitle.tr,
                style: context.appTypography.appBar.title,
              ),
            ),
            body: ResponsiveContent.catalog(
              child: Obx(() {
                final state = controller.service.state.value;

                return state.maybeWhen(
                  loading: () => _buildGrid(
                    context,
                    itemCount: RecentlyViewedConstants.homeGridCount,
                    itemBuilder: (_, __) =>
                        const HomeRecentlyViewedCardSkeleton(),
                  ),
                  success: (items) => RefreshIndicator.adaptive(
                    onRefresh: controller.onPullToRefresh,
                    child: _buildGrid(
                      context,
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];

                        return Obx(
                          () => HomeRecentlyViewedCard(
                            item: item,
                            onToggleFavorite: () =>
                                controller.toggleFavorite(item),
                            isFavorite: controller.isFavorite(item),
                            isFavoritePending: controller.isFavoritePending(
                              item,
                            ),
                            canToggleFavorite: controller.canToggleFavorite(
                              item,
                            ),
                            onAddToCart: () => controller.addToCart(item),
                            cartQuantityForProduct: controller.cartQuantity,
                            isCartUpsertLoading: controller.isCartUpsertLoading,
                            onGoToItemDetails:
                                ({
                                  colorGroupId,
                                  required heroTag,
                                  required itemId,
                                  variantId,
                                }) {
                                  final ItemsDetailsRouteArgs args =
                                      ItemsDetailsRouteArgs(
                                        heroTag: heroTag,
                                        itemId: itemId,
                                        colorGroupId: colorGroupId,
                                        variantId: variantId,
                                      );
                                  Get.toNamed(
                                    RouteName.itemDetails,
                                    arguments: args,
                                  );
                                },
                          ),
                        );
                      },
                    ),
                  ),
                  empty: () => RefreshIndicator.adaptive(
                    onRefresh: controller.onPullToRefresh,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: SizedBox(
                        height: MediaQuery.sizeOf(context).height * 0.6,
                        child: Center(
                          child: Text(
                            LocaleKeys.recentlyViewedEmpty.tr,
                            textAlign: TextAlign.center,
                            style: context.appTypography.stateMessage.message,
                          ),
                        ),
                      ),
                    ),
                  ),
                  error: (failure) => AppErrorView(
                    model: failure.toUI(retry: controller.onPullToRefresh),
                  ),
                  orElse: () => const SizedBox.shrink(),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGrid(
    BuildContext context, {
    required int itemCount,
    required IndexedWidgetBuilder itemBuilder,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final layout = AppCatalogGridLayout.resolve(
          availableWidth: constraints.maxWidth,
          textScaleFactor: AppTextScaleValue.scaleFactor(
            context,
            fontSize: context.appTypography.productCard.name.fontSize!,
          ),
        );

        return MasonryGridView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: itemCount,
          gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: layout.crossAxisCount,
          ),
          crossAxisSpacing: layout.horizontalGap,
          mainAxisSpacing: layout.verticalGap,
          itemBuilder: itemBuilder,
        );
      },
    );
  }

  Future<void> _onFavoriteFailure(Failure failure) async {
    await failure.handleSnackBar();
    await failure.handleDialog(
      goLogin: () {
        Get.toNamed(
          RouteName.loginFlow,
          arguments: const LoginRouteArgs.flow(),
        );
      },
    );
  }

  Future<void> _onRefreshFailure(Failure failure) {
    return AppSnackbar.show(failure.message, tone: AppSnackbarTone.error);
  }

  Future<void> _onCartEvent(RecentlyViewedCartEvent event) {
    return event.when<Future<void>>(
      success: (action) async {
        await AppSnackbar.show(
          _cartActionMessage(action),
          tone: AppSnackbarTone.success,
        );
      },
      failure: (failure) async {
        await failure.handleSnackBar();

        await failure.handleDialog(
          goLogin: () {
            Get.toNamed(
              RouteName.loginFlow,
              arguments: const LoginRouteArgs.flow(),
            );
          },
        );
      },
      unavailable: () async {
        await AppSnackbar.show(
          LocaleKeys.addToCartUnavailable.tr,
          tone: AppSnackbarTone.warning,
        );
      },
    );
  }

  String _cartActionMessage(CartAction action) {
    return switch (action) {
      CartAction.added => LocaleKeys.cartAddSuccess.tr,
      CartAction.updated => LocaleKeys.cartUpdateSuccess.tr,
      CartAction.removed => LocaleKeys.cartRemoveSuccess.tr,
    };
  }
}
