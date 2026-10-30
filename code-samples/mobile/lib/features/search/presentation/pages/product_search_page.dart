import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';

import '../../../../binding_route_middleware/route.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/navigation/items_details_route_args.dart';
import '../../../../core/overlays/app_snackbar.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/translations/locale_keys.dart';
import '../../../../core/utils/responsive/app_catalog_grid_layout.dart';
import '../../../../core/utils/responsive/app_design_tokens.dart';
import '../../../../core/utils/responsive/app_responsive_value.dart';
import '../../../../core/widgets/error/app_error_view.dart';
import '../../../../core/widgets/error/extension_failure_to_dialog.dart';
import '../../../../core/widgets/error/extension_failure_to_snak_bar.dart';
import '../../../../core/widgets/error/extension_failure_to_ui.dart';
import '../../../../core/widgets/rx_event_listener.dart';
import '../../../../core/widgets/responsive_content.dart';
import '../../../cart/domain/entities/cart_item_entity.dart';
import '../../../auth/presentation/navigation/login_route_args.dart';
import '../../../products/domain/entities/pagination_entity.dart';
import '../../../products/domain/entities/product_card_entity.dart';
import '../controllers/product_search_controller.dart';
import '../events/product_search_event.dart';
import '../state/product_search_state.dart';
import '../widgets/product_search_field.dart';
import '../widgets/product_search_result_card.dart';

class ProductSearchPage extends StatefulWidget {
  const ProductSearchPage({super.key});

  @override
  State<ProductSearchPage> createState() => _ProductSearchPageState();
}

class _ProductSearchPageState extends State<ProductSearchPage> {
  late final ProductSearchController _controller;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();

    _controller = Get.find<ProductSearchController>();

    _scrollController = ScrollController()..addListener(_onScroll);

    _controller.focusNode.addListener(_onFocusChanged);
  }

  void _onFocusChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;

    if (position.pixels >= position.maxScrollExtent - 320) {
      _controller.loadNextPage();
    }
  }

  @override
  void dispose() {
    _controller.focusNode.removeListener(_onFocusChanged);

    _scrollController
      ..removeListener(_onScroll)
      ..dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_controller.focusNode.hasFocus,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _controller.focusNode.hasFocus) {
          _controller.focusNode.unfocus();
        }
      },
      child: RxEventListener<ProductSearchEvent>(
        rxnEvent: _controller.event,
        clearEvent: _controller.clearEvent,
        onEvent: _onEvent,
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              tooltip: LocaleKeys.back.tr,
              onPressed: Get.back,
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            title: Text(
              LocaleKeys.productSearchTitle.tr,
              style: context.appTypography.appBar.title,
            ),
          ),
          body: SafeArea(
            top: false,
            child: ResponsiveContent.catalog(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: ProductSearchField(
                      controller: _controller.textController,
                      focusNode: _controller.focusNode,
                      onChanged: _controller.onQueryChanged,
                      onSubmitted: _controller.submit,
                      onClear: _controller.clear,
                    ),
                  ),
                  Expanded(child: Obx(() => _buildState(context))),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildState(BuildContext context) {
    return _controller.state.value.when(
      initial: (isLongQuery) => _CenteredMessage(
        icon: Icons.manage_search_rounded,
        message: isLongQuery
            ? LocaleKeys.productSearchQueryTooLong.tr
            : LocaleKeys.productSearchGuidance.tr,
      ),
      loading: (_) => const Center(child: CircularProgressIndicator.adaptive()),
      empty: (_, __) => _CenteredMessage(
        icon: Icons.search_off_rounded,
        message: LocaleKeys.productSearchEmpty.tr,
      ),
      failure: (_, failure) => AppErrorView(
        model: failure.toUI(
          retry: _controller.retryFirstPage,
          goBack: Get.back,
          goLogin: () => Get.toNamed(
            RouteName.loginFlow,
            arguments: const LoginRouteArgs.flow(),
          ),
        ),
      ),
      results: (query, items, pagination, isLoadingMore, loadMoreFailure) {
        return _buildResults(
          context,
          items: items,
          pagination: pagination,
          isLoadingMore: isLoadingMore,
          loadMoreFailure: loadMoreFailure,
        );
      },
    );
  }

  Widget _buildResults(
    BuildContext context, {
    required List<ProductCardEntity> items,
    required PaginationEntity pagination,
    required bool isLoadingMore,
    required Failure? loadMoreFailure,
  }) {
    const paddingSm = AppSpacing.sm;
    return CustomScrollView(
      controller: _scrollController,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      slivers: [
        SliverPadding(
          padding: EdgeInsets.only(
            top: 2,
            left: paddingSm,
            right: paddingSm,
            bottom: paddingSm,
          ),
          sliver: SliverLayoutBuilder(
            builder: (context, constraints) {
              final layout = AppCatalogGridLayout.resolve(
                availableWidth: constraints.crossAxisExtent,
                textScaleFactor: AppTextScaleValue.scaleFactor(
                  context,
                  fontSize: context.appTypography.productCard.name.fontSize!,
                ),
              );
              return SliverMasonryGrid.count(
                crossAxisCount: layout.crossAxisCount,
                mainAxisSpacing: layout.verticalGap,
                crossAxisSpacing: layout.horizontalGap,
                childCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];

                  return Obx(() {
                    return ProductSearchResultCard(
                      key: ValueKey(
                        '${item.itemId}:${item.colorGroupId ?? 'simple'}',
                      ),
                      item: item,
                      isFavorite: _controller.isFavorite(item),
                      isFavoritePending: _controller.isFavoritePending(item),
                      canToggleFavorite: _controller.canToggleFavorite(item),
                      cartQuantity: () => _controller.cartQuantity(item),
                      isCartPending: () {
                        return _controller.isCartOperationPending(item);
                      },
                      onTap: (heroTag) {
                        _openDetails(item, heroTag);
                      },
                      onToggleFavorite: () {
                        _controller.toggleFavorite(item);
                      },
                      onAddToCart: () {
                        _controller.addToCart(item);
                      },
                    );
                  });
                },
              );
            },
          ),
        ),
        SliverToBoxAdapter(
          child: _LoadMoreFooter(
            isLoading: isLoadingMore,
            failure: loadMoreFailure,
            hasMore: pagination.hasMore,
            onRetry: _controller.retryNextPage,
          ),
        ),
      ],
    );
  }

  void _openDetails(ProductCardEntity item, String heroTag) {
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

  Future<void> _onEvent(ProductSearchEvent event) async {
    event.when(
      interactionFailure: (failure) {
        final isQueryTooLong = failure.whenOrNull(
          http: (_, __, ___, ____, errorCode) {
            return errorCode == ProductSearchController.queryTooLongErrorCode;
          },
        );
        if (isQueryTooLong == true) {
          return;
        }
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
      cartSuccess: (action) {
        AppSnackbar.show(
          _cartActionMessage(action),
          tone: AppSnackbarTone.success,
        );
      },
      cartUnavailable: () {
        AppSnackbar.show(
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

class _CenteredMessage extends StatelessWidget {
  const _CenteredMessage({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: AppIconSizes.pageState(context),
              color: colors.outline,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              message,
              textAlign: TextAlign.center,
              style: context.appTypography.stateMessage.message,
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadMoreFooter extends StatelessWidget {
  const _LoadMoreFooter({
    required this.isLoading,
    required this.failure,
    required this.hasMore,
    required this.onRetry,
  });

  final bool isLoading;
  final Failure? failure;
  final bool hasMore;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Center(child: CircularProgressIndicator.adaptive()),
      );
    }

    if (failure != null) {
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Center(
          child: TextButton.icon(
            onPressed: onRetry,
            icon: Icon(
              Icons.refresh_rounded,
              size: AppIconSizes.buttonAction(context),
            ),
            label: Text(
              LocaleKeys.productSearchLoadMoreRetry.tr,
              style: context.appTypography.button.label,
            ),
          ),
        ),
      );
    }

    return SizedBox(height: hasMore ? AppSpacing.xl : AppSpacing.md);
  }
}
