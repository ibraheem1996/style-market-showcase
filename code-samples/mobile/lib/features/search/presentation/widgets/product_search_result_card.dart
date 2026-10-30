import 'package:flutter/material.dart';

import '../../../../core/layout/app_product_card_layout.dart';
import '../../../../core/media/app_media_profile.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/hero_tag.dart';
import '../../../../core/utils/responsive/app_design_tokens.dart';
import '../../../../core/widgets/add_to_cart_button.dart';
import '../../../../core/widgets/app_product_price_block.dart';
import '../../../../core/widgets/app_remote_image.dart';
import '../../../../core/widgets/favorite_button.dart';
import '../../../products/domain/entities/product_card_entity.dart';
import '../../../products/domain/entities/product_card_entity_extensions.dart';

class ProductSearchResultCard extends StatelessWidget {
  const ProductSearchResultCard({
    super.key,
    required this.item,
    required this.isFavorite,
    required this.isFavoritePending,
    required this.canToggleFavorite,
    required this.cartQuantity,
    required this.isCartPending,
    required this.onTap,
    required this.onToggleFavorite,
    required this.onAddToCart,
  });

  final ProductCardEntity item;
  final bool isFavorite;
  final bool isFavoritePending;
  final bool canToggleFavorite;
  final int Function() cartQuantity;
  final bool Function() isCartPending;
  final ValueChanged<String> onTap;
  final VoidCallback onToggleFavorite;
  final VoidCallback onAddToCart;
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final heroTag = HeroTags.productCard(source: 'search');
    final nameStyle = context.appTypography.productCard.name;

    return Card(
      color: Theme.of(context).scaffoldBackgroundColor,
      shadowColor: Theme.of(context).shadowColor,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => onTap(heroTag),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: AppMediaProfile.productCard.aspectRatio,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: heroTag,
                    child: AppRemoteImage.productCard(
                      source: item.itemDisplayImage,
                      semanticLabel: item.displayName,
                      placeholderBuilder: (_) {
                        return const Center(
                          child: CircularProgressIndicator.adaptive(),
                        );
                      },
                      errorBuilder: (_) {
                        return Icon(
                          Icons.image_not_supported_outlined,
                          color: colors.outline,
                          size: AppIconSizes.mediaStatus(context),
                        );
                      },
                    ),
                  ),
                  PositionedDirectional(
                    top: AppProductCardLayout.searchCardFavoritePosition.top,
                    end: AppProductCardLayout.searchCardFavoritePosition.end,
                    bottom:
                        AppProductCardLayout.searchCardFavoritePosition.bottom,
                    start:
                        AppProductCardLayout.searchCardFavoritePosition.start,
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
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
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

                  const SizedBox(height: AppSpacing.sm),
                  AppProductPriceBlock(item: item),
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: SizedBox.square(
                      dimension: AppControlSizes.minimumTapTarget,
                      child: Center(
                        child: ReactiveCartActionButton(
                          quantity: cartQuantity,
                          isLoading: isCartPending,
                          onPressed: onAddToCart,
                          enabled: (item.stockQuantity ?? 1) > 0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
