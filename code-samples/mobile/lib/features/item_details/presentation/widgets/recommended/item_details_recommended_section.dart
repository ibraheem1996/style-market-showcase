import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';

import '../../../../../core/errors/failure.dart';
import '../../../../../core/errors/failure_i18n.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/translations/locale_keys.dart';
import '../../../../../core/utils/hero_tag.dart';
import '../../../../../core/utils/responsive/app_catalog_grid_layout.dart';
import '../../../../../core/utils/responsive/app_design_tokens.dart';
import '../../../../../core/utils/responsive/app_responsive_value.dart';
import '../../../../products/domain/entities/product_card_entity.dart';
import '../../../../recommendations/presentation/widgets/recommendation_first_load_error_view.dart';
import '../../../../recommendations/presentation/widgets/recommendation_load_more_error_footer.dart';
import '../../state/item_details_recommended_state.dart';
import '../section_title_underline.dart';
import 'item_details_recommended_card.dart';
import 'item_details_recommended_skeleton.dart';

class ItemDetailsRecommendedSection extends StatelessWidget {
  const ItemDetailsRecommendedSection({
    super.key,
    required this.sectionKey,
    required this.state,
    required this.onTapItem,
    required this.onRetryFirstLoad,
    required this.onRetryLoadMore,
    required this.onToggleFavorite,
    required this.isFavorite,
    required this.isFavoritePending,
    required this.canToggleFavorite,
  });

  final GlobalKey sectionKey;
  final ItemDetailsRecommendedState state;
  final void Function({
    required String heroTag,
    required int itemId,
    int? variantId,
    int? colorGroupId,
  })
  onTapItem;
  final VoidCallback onRetryFirstLoad;
  final VoidCallback onRetryLoadMore;
  final void Function(ProductCardEntity item) onToggleFavorite;
  final bool Function(ProductCardEntity item) isFavorite;
  final bool Function(ProductCardEntity item) isFavoritePending;
  final bool Function(ProductCardEntity item) canToggleFavorite;

  @override
  Widget build(BuildContext context) {
    return state.when(
      initial: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
      loading: () => _loadingGroup(context),
      success: (items, pagination, isLoadingMore, loadMoreFailure) {
        if (items.isEmpty) {
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        }

        return SliverMainAxisGroup(
          slivers: [
            _headerSliver(context),
            _loadedGrid(context, items),
            _footerSliver(
              context,
              isLoadingMore: isLoadingMore,
              failure: loadMoreFailure,
            ),
          ],
        );
      },
      empty: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
      error: (failure) => SliverMainAxisGroup(
        slivers: [
          _headerSliver(context),
          SliverToBoxAdapter(
            child: RecommendationFirstLoadErrorView(
              message: failure.message,
              retryLabel: LocaleKeys.itemDetailsRecommendedRetry.tr,
              onRetry: onRetryFirstLoad,
            ),
          ),
        ],
      ),
    );
  }

  Widget _loadingGroup(BuildContext context) {
    return SliverMainAxisGroup(
      slivers: [
        _headerSliver(context),
        SliverLayoutBuilder(
          builder: (context, constraints) {
            final layout = _resolveLayout(context, constraints.crossAxisExtent);
            return SliverMasonryGrid.count(
              crossAxisCount: layout.crossAxisCount,
              mainAxisSpacing: layout.verticalGap,
              crossAxisSpacing: layout.horizontalGap,
              childCount: 8,
              itemBuilder: (_, __) => const ItemDetailsRecommendedSkeleton(),
            );
          },
        ),
      ],
    );
  }

  Widget _loadedGrid(BuildContext context, List<ProductCardEntity> items) {
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final layout = _resolveLayout(context, constraints.crossAxisExtent);
        return SliverMasonryGrid.count(
          crossAxisCount: layout.crossAxisCount,
          mainAxisSpacing: layout.verticalGap,
          crossAxisSpacing: layout.horizontalGap,
          childCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            final heroTag = HeroTags.productCard(
              source: 'item_details_recommended',
            );

            return KeyedSubtree(
              key: ValueKey(
                'item-details-recommended-${item.itemId}:${item.colorGroupId ?? 'simple'}',
              ),
              child: Obx(
                () => ItemDetailsRecommendedCard(
                  item: item,
                  heroTag: heroTag,
                  onTap: () => onTapItem(
                    heroTag: heroTag,
                    itemId: item.itemId,
                    variantId: item.representativeVariantId,
                    colorGroupId: item.colorGroupId,
                  ),
                  onToggleFavorite: () => onToggleFavorite(item),
                  isFavorite: isFavorite(item),
                  isFavoritePending: isFavoritePending(item),
                  canToggleFavorite: canToggleFavorite(item),
                ),
              ),
            );
          },
        );
      },
    );
  }

  AppCatalogGridLayout _resolveLayout(
    BuildContext context,
    double availableWidth,
  ) {
    return AppCatalogGridLayout.resolve(
      availableWidth: availableWidth,
      textScaleFactor: AppTextScaleValue.scaleFactor(
        context,
        fontSize: context.appTypography.productCard.name.fontSize!,
      ),
    );
  }

  Widget _headerSliver(BuildContext context) {
    return SliverToBoxAdapter(
      child: KeyedSubtree(
        key: sectionKey,
        child: Padding(
          padding: const EdgeInsets.only(
            top: AppSpacing.xl,
            bottom: AppSpacing.md,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                LocaleKeys.itemDetailsRecommendedTitle.tr,
                style: context.appTypography.sectionHeader.title,
              ),
              SizedBox(height: AppSpacing.xs),
              const SectionTitleUnderline(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _footerSliver(
    BuildContext context, {
    required bool isLoadingMore,
    required Failure? failure,
  }) {
    return SliverToBoxAdapter(
      child: AnimatedSize(
        duration: const Duration(milliseconds: 200),
        child: isLoadingMore
            ? Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                child: const Center(
                  child: CircularProgressIndicator.adaptive(),
                ),
              )
            : failure != null
            ? RecommendationLoadMoreErrorFooter(
                message: LocaleKeys.homeRecommendedLoadMoreError.tr,
                retryLabel: LocaleKeys.itemDetailsRecommendedRetry.tr,
                onRetry: onRetryLoadMore,
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}
