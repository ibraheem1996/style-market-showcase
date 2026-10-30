import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../binding_route_middleware/address_flow.dart';
import '../../../../binding_route_middleware/route.dart';
import '../../../../core/errors/app_failure_key.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/errors/failure_i18n.dart';
import '../../../../core/errors/failure_key.dart';
import '../../../../core/overlays/app_snackbar.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/translations/locale_keys.dart';
import '../../../../core/utils/responsive/app_design_tokens.dart';
import '../../../../core/utils/responsive/app_window_class.dart';
import '../../../../core/widgets/error/app_error_view.dart';
import '../../../../core/widgets/error/app_inline_refresh_failure.dart';
import '../../../../core/widgets/error/back_to_top_button.dart';
import '../../../../core/widgets/error/extension_failure_to_snak_bar.dart';
import '../../../../core/widgets/error/extension_failure_to_ui.dart';
import '../../../../core/widgets/responsive_content.dart';
import '../../../../core/widgets/rx_event_listener.dart';
import '../../../auth/presentation/navigation/login_route_args.dart';
import '../../../home/presentation/navigation/home_navigation_coordinator.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../controllers/cart_controller.dart';
import '../event/cart_event.dart';
import '../state/cart_state.dart';
import '../widgets/cart_loaded_body.dart';
import '../widgets/cart_recommended_section.dart';
import '../widgets/cart_scroll_coordinator.dart';
import '../widgets/checkout_bottom_bar.dart';
import '../widgets/init/loding_widget.dart';

class CartPage extends GetView<CartController> {
  const CartPage({super.key});

  Future<void> _showOperationFailure(Failure failure) async {
    final needsCartMessage = failure.maybeWhen(
      http: (key, _, __, ___, ____) =>
          key == FailureKey.outOfStock || key == FailureKey.variantRequired,
      orElse: () => false,
    );
    if (needsCartMessage) {
      await AppSnackbar.show(failure.message, tone: AppSnackbarTone.warning);
      return;
    }
    await failure.handleSnackBar();
  }

  @override
  Widget build(BuildContext context) {
    return RxEventListener<CartEvent>(
      rxnEvent: controller.cartEvent,
      clearEvent: () => controller.cartEvent.value = null,
      onEvent: (event) async {
        if (!controller.isCartTabSelected) return;
        await event.when(
          pageRefreshFailed: (failure) => AppSnackbar.show(
            controller.getMessageError(failure),
            tone: AppSnackbarTone.error,
          ),
          failureSelection: _showOperationFailure,
          failureClearAll: _showOperationFailure,
          failureQuantityUpdate: _showOperationFailure,
          addToCartSuccess: (action) => AppSnackbar.show(
            _cartMessageForAction(action),
            tone: AppSnackbarTone.success,
          ),
          addToCartFailure: _showOperationFailure,
          addToCartUnavailable: () => AppSnackbar.show(
            LocaleKeys.addToCartUnavailable.tr,
            tone: AppSnackbarTone.warning,
          ),
          favoriteToggleFailure: _showOperationFailure,
          favoriteToggleSuccess: (message) =>
              AppSnackbar.show(message, tone: AppSnackbarTone.success),
          maxQuantityReached: (maxQuantity) => AppSnackbar.show(
            LocaleKeys.cartSnackbarMaxQuantity.trParams({
              'max_quantity': maxQuantity.toString(),
            }),
            tone: AppSnackbarTone.warning,
          ),
          navigateToProductDetails: (args) =>
              Get.toNamed(RouteName.itemDetails, arguments: args),
          navigateToCheckout: () => Get.toNamed(RouteName.checkOut),
        );
      },
      child: Scaffold(
        appBar: AppBar(
          title: Obx(
            () => Text(
              '${LocaleKeys.cartAppbarTitle.tr} (${controller.cartCount})',
              style: context.appTypography.appBar.title,
            ),
          ),
        ),
        body: RefreshIndicator.adaptive(
          onRefresh: controller.refreshPage,
          child: ResponsiveContent.standard(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final shortWindow = isShortWindow(
                  Size(constraints.maxWidth, constraints.maxHeight),
                );
                final trailingSpace = shortWindow
                    ? AppSpacing.lg
                    : AppSpacing.xxl;

                return CartScrollCoordinator(
                  onLoadMore: controller.loadMoreRecommended,
                  builder: (scrollController, showBackToTop) => Stack(
                    children: [
                      Obx(() {
                        final loginRequired =
                            controller.state.value ==
                            const CartState.failure(
                              failure: Failure.app(
                                key: AppFailureKey.loginRequired,
                              ),
                            );
                        return CustomScrollView(
                          controller: scrollController,
                          physics: const AlwaysScrollableScrollPhysics(),
                          slivers: [
                            if (!loginRequired)
                              if (controller.pageRefreshFailure.value
                                  case final failure?)
                                SliverPadding(
                                  padding: const EdgeInsets.all(AppSpacing.md),
                                  sliver: SliverToBoxAdapter(
                                    child: AppInlineRefreshFailure(
                                      message: controller.getMessageError(
                                        failure,
                                      ),
                                      retryLabel: LocaleKeys.retry.tr,
                                      onRetry: controller.refreshPage,
                                    ),
                                  ),
                                ),
                            ..._cartSlivers(loginRequired: loginRequired),
                            if (!loginRequired) ...[
                              Obx(
                                () => CartRecommendedSection(
                                  state:
                                      controller.recommendedService.state.value,
                                  onRetryFirstLoad: controller.retryRecommended,
                                  onRetryLoadMore:
                                      controller.loadMoreRecommended,
                                  onAddToCart: controller.addRecommendedToCart,
                                  onToggleFavorite:
                                      controller.toggleRecommendedFavorite,
                                  cartQuantityForProduct:
                                      controller.cartQuantityForProductCard,
                                  isCartUpsertLoading:
                                      controller.isProductCardCartUpsertLoading,
                                  isFavorite: controller.isRecommendedFavorite,
                                  isFavoritePending:
                                      controller.isRecommendedFavoritePending,
                                  canToggleFavorite:
                                      controller.canToggleRecommendedFavorite,
                                  onTapItem: (item, heroTag) =>
                                      controller.openRecommendedDetails(
                                        item,
                                        heroTag: heroTag,
                                      ),
                                ),
                              ),
                              SliverToBoxAdapter(
                                child: SizedBox(height: trailingSpace),
                              ),
                            ],
                          ],
                        );
                      }),
                      PositionedDirectional(
                        end: AppSpacing.lg,
                        bottom: AppSpacing.lg,
                        child: BackToTopButton(
                          showListenable: showBackToTop,
                          onPressed: () => scrollController.animateTo(
                            0,
                            duration: const Duration(milliseconds: 450),
                            curve: Curves.easeOutCubic,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
        bottomNavigationBar: Obx(
          () => CheckoutBottomBar(
            data: controller.checkoutBar,
            onCheckOut: controller.startCheckout,
          ),
        ),
      ),
    );
  }

  List<Widget> _cartSlivers({required bool loginRequired}) {
    return controller.state.value.maybeWhen<List<Widget>>(
      initial: () => const [SliverToBoxAdapter(child: SizedBox.shrink())],
      loading: () => const [
        SliverToBoxAdapter(
          child: SizedBox(height: 300, child: LoadingWidget()),
        ),
      ],
      failure: (failure) {
        final view = AppErrorView(
          model: failure.toUI(
            goBack: Get.back,
            retry: controller.retryCart,
            goLogin: () => Get.toNamed(
              RouteName.loginFlow,
              arguments: const LoginRouteArgs.flow(),
            ),
          ),
        );
        return [
          if (loginRequired)
            SliverFillRemaining(hasScrollBody: true, child: Center(child: view))
          else
            SliverToBoxAdapter(child: view),
        ];
      },
      loaded: () => [
        CartLoadedBody(
          items: controller.lineViewData,
          onTapCartItem: (item, heroTag) =>
              controller.openCartLineDetails(item, heroTag: heroTag),
          onSelectVariant: (item, heroTag) =>
              controller.openVariantSelection(item, heroTag: heroTag),
          onDelete: controller.deleteLine,
          onSelectionChanged: controller.setLineSelected,
          onIncrease: controller.increaseLine,
          onDecrease: controller.decreaseLine,
          onMaxQuantityReached: controller.increaseLine,
          onBrowse: () => HomeNavigationCoordinator.goToRecommended(),
          selectedAddress: controller.selectedDeliveryAddress,
          onDeliveryAddressTap: AddressFlow.openDeliveryAddressPicker,
          isClearing: controller.isClearing,
          onClearAll: controller.clearCart,
        ),
      ],
      orElse: () => const [SliverToBoxAdapter(child: SizedBox.shrink())],
    );
  }

  String _cartMessageForAction(CartAction action) {
    return switch (action) {
      CartAction.added => LocaleKeys.cartAddSuccess.tr,
      CartAction.updated => LocaleKeys.cartUpdateSuccess.tr,
      CartAction.removed => LocaleKeys.cartRemoveSuccess.tr,
    };
  }
}
