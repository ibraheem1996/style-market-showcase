import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../binding_route_middleware/route.dart';
import '../../../../core/navigation/items_details_route_args.dart';
import '../../../../core/overlays/app_snackbar.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/translations/locale_keys.dart';
import '../../../../core/utils/responsive/app_text_scale_limits.dart';
import '../../../../core/widgets/error/app_error_view.dart';
import '../../../../core/widgets/error/extension_failure_to_dialog.dart';
import '../../../../core/widgets/error/extension_failure_to_snak_bar.dart';
import '../../../../core/widgets/error/extension_failure_to_ui.dart';
import '../../../../core/widgets/responsive_content.dart';
import '../../../../core/widgets/rx_event_listener.dart';
import '../../../auth/presentation/navigation/login_route_args.dart';
import '../bindings/item_details_bindings.dart';
import '../controller/item_details_controller.dart';
import '../event/item_details_event.dart';
import '../state/item_details_state.dart';
import '../widgets/buttom_action_bar/bottom_action_bar.dart';
import '../widgets/init_page/loading_view.dart';
import '../widgets/item_details_body.dart';
import '../widgets/item_details_scroll_coordinator.dart';
import '../widgets/item_details_scroll_tabs.dart';

class ItemDetailsPage extends StatefulWidget {
  const ItemDetailsPage({super.key, required this.controllerTag});

  final String controllerTag;

  @override
  State<ItemDetailsPage> createState() => _ItemDetailsPageState();
}

class _ItemDetailsPageState extends State<ItemDetailsPage> {
  late final ItemDetailsController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find(tag: widget.controllerTag);
  }

  void _goToRecommendedItem({
    required String heroTag,
    required int itemId,
    int? variantId,
    int? colorGroupId,
  }) {
    final args = ItemsDetailsRouteArgs(
      itemId: itemId,
      heroTag: heroTag,
      variantId: variantId,
      colorGroupId: colorGroupId,
    );

    Get.off(
      () => ItemDetailsPage(controllerTag: args.controllerTag),
      routeName: RouteName.itemDetails,
      arguments: args,
      binding: BindingItemDetails(args),
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return RxEventListener<ItemDetailsEvent>(
      rxnEvent: controller.events,
      clearEvent: () => controller.events.value = null,
      onEvent: (event) async {
        event.when(
          errToggleFav: (error) {
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
          toggleFavSuccess: (action) {
            AppSnackbar.show(action, tone: AppSnackbarTone.success);
          },
          errAddToCart: (failure) {
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
          addToCartSuccess: (action) {
            AppSnackbar.show(action, tone: AppSnackbarTone.success);
          },
          errUpdateCart: (message) {
            AppSnackbar.show(message, tone: AppSnackbarTone.error);
          },
        );
      },
      child: ItemDetailsScrollCoordinator(
        onLoadMore: controller.recommendedService.loadMore,
        builder:
            (
              scrollController,
              recommendedKey,
              showTabs,
              activeTab,
              showBottomBar,
            ) {
              return Scaffold(
                appBar: AppBar(
                  title: Text(
                    LocaleKeys.itemDetailsTitle.tr,
                    style: context.appTypography.appBar.title,
                  ),
                ),
                body: Stack(
                  children: [
                    Obx(() {
                      return controller.state.value.when(
                        initial: () => const ResponsiveContent.standard(
                          child: LoadingView(),
                        ),
                        loading: () => const ResponsiveContent.standard(
                          child: LoadingView(),
                        ),
                        error: (failure) => AppErrorView(
                          model: failure.toUI(
                            retry: controller.load,
                            goLogin: () => Get.toNamed(
                              RouteName.loginFlow,
                              arguments: const LoginRouteArgs.flow(),
                            ),
                            goBack: () => Get.back(),
                          ),
                        ),
                        loaded: (item) => ResponsiveContent.standard(
                          child: ItemDetailsBody(
                            controller: controller,
                            item: item,
                            scrollController: scrollController,
                            recommendedKey: recommendedKey,
                            onTapRecommendedItem: _goToRecommendedItem,
                          ),
                        ),
                      );
                    }),
                    ResponsiveContent.standard(
                      includeTopPadding: false,
                      includeBottomPadding: false,
                      child: MediaQuery.withClampedTextScaling(
                        maxScaleFactor: AppTextScaleLimits.compactNavigation,
                        child: ItemDetailsScrollTabs(
                          showTabs: showTabs,
                          activeTab: activeTab,
                          onTabDetails: () => scrollController.animateTo(
                            0,
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                          ),
                          onTabRecommended: () {
                            final recommendationContext =
                                recommendedKey.currentContext;
                            if (recommendationContext == null) return;
                            Scrollable.ensureVisible(
                              recommendationContext,
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeInOut,
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                bottomNavigationBar: ValueListenableBuilder<bool>(
                  valueListenable: showBottomBar,
                  builder: (context, isVisible, child) {
                    return AnimatedSlide(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.bounceOut,
                      offset: isVisible ? Offset.zero : const Offset(0, 1),
                      child: AnimatedSize(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                        child: isVisible
                            ? child
                            : const SizedBox(width: double.infinity),
                      ),
                    );
                  },
                  child: Obx(() {
                    final isLoaded = controller.state.value.maybeWhen(
                      loaded: (_) => true,
                      orElse: () => false,
                    );
                    if (!isLoaded) return const SizedBox.shrink();

                    final item = controller.item;
                    final data = controller.data.value;
                    final needsVariant =
                        item.variants.isNotEmpty &&
                        data.selectedVariant == null;

                    return ResponsiveContent.standard(
                      includeBottomPadding: false,
                      includeTopPadding: false,
                      child: ColoredBox(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        child: SafeArea(
                          top: false,
                          child: BottomActionBar(
                            cartQuantity: controller.cartQuantityById(),
                            addToCart: needsVariant || controller.isAddingToCart
                                ? null
                                : () => controller.addToCart(
                                    item: item,
                                    quantity: data.quantity,
                                    variant: data.selectedVariant,
                                  ),
                            updateQuantity: (quantity) =>
                                controller.updateQuantity = quantity,
                            quantity: data.quantity,
                            stock: controller.stock(),
                            isAddingToCart: controller.isAddingToCart,
                            needsVariant: needsVariant,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              );
            },
      ),
    );
  }
}
