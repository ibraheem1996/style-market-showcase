import 'package:flutter/material.dart';

import '../../../../../core/layout/app_product_card_layout.dart';
import '../../../../../core/media/app_media_profile.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/utils/responsive/app_design_tokens.dart';
import '../../../../../core/utils/responsive/app_radius.dart';
import '../../../../../core/widgets/app_product_price_block.dart';
import '../../../../../core/widgets/app_media_badge.dart';
import '../../../../../core/widgets/app_remote_image.dart';
import '../../../../../core/widgets/favorite_button.dart';
import '../../../../products/domain/entities/product_card_entity.dart';
import '../../../../products/domain/entities/product_card_entity_extensions.dart';

class ItemDetailsRecommendedCard extends StatelessWidget {
  const ItemDetailsRecommendedCard({
    super.key,
    required this.item,
    required this.heroTag,
    required this.onTap,
    required this.onToggleFavorite,
    required this.isFavorite,
    required this.isFavoritePending,
    required this.canToggleFavorite,
  });

  final ProductCardEntity item;
  final String heroTag;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;
  final bool isFavorite;
  final bool isFavoritePending;
  final bool canToggleFavorite;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final nameStyle = context.appTypography.productCard.name;

    return Material(
      color: theme.colorScheme.surface,
      elevation: 0,
      borderRadius: BorderRadius.circular(AppRadius.md(context)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              key: const Key('item-details-recommended-loaded-image'),
              aspectRatio: AppMediaProfile.productCard.aspectRatio,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: heroTag,
                    child: AppRemoteImage.productCard(
                      source: item.itemDisplayImage,
                      semanticLabel: item.displayName,
                      placeholderBuilder: (_) => ColoredBox(
                        color: theme.colorScheme.surfaceContainerHighest,
                      ),
                      errorBuilder: (_) => ColoredBox(
                        color: theme.colorScheme.surfaceContainerHighest,
                        child: Icon(
                          Icons.image_not_supported_outlined,
                          color: theme.colorScheme.onSurfaceVariant,
                          size: AppIconSizes.mediaStatus(context),
                        ),
                      ),
                    ),
                  ),
                  if (item.hasDiscount && item.maxDiscountPct > 0)
                    PositionedDirectional(
                      top: AppProductCardLayout.badgePosition.top,
                      bottom: AppProductCardLayout.badgePosition.bottom,
                      start: AppProductCardLayout.badgePosition.start,
                      end: AppProductCardLayout.badgePosition.end,
                      child: _DiscountBadge(pct: item.maxDiscountPct),
                    ),
                  PositionedDirectional(
                    top: AppProductCardLayout.favoritePosition.top,
                    bottom: AppProductCardLayout.favoritePosition.bottom,
                    start: AppProductCardLayout.favoritePosition.start,
                    end: AppProductCardLayout.favoritePosition.end,
                    child: FavoriteButton(
                      isFavorite: isFavorite,
                      isLoading: isFavoritePending,
                      enabled: canToggleFavorite,
                      onPressed: onToggleFavorite,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.displayName,
                    maxLines: AppProductCardLayout.nameMaxLines(
                      context: context,
                      fontSize: nameStyle.fontSize!,
                    ),
                    overflow: TextOverflow.ellipsis,
                    style: nameStyle,
                  ),
                  SizedBox(height: AppSpacing.xs),
                  AppProductPriceBlock(item: item),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DiscountBadge extends StatelessWidget {
  const _DiscountBadge({required this.pct});

  final int pct;

  @override
  Widget build(BuildContext context) {
    return AppMediaBadge(
      label: '-$pct%',
      semanticLabel: '-$pct%',
      backgroundColor: Theme.of(context).colorScheme.errorContainer,
      foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
    );
  }
}
