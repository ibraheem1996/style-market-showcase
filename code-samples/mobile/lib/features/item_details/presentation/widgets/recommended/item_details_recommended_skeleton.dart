import 'package:flutter/material.dart';

import '../../../../../core/media/app_media_profile.dart';
import '../../../../../core/utils/responsive/app_design_tokens.dart';
import '../../../../../core/utils/responsive/app_radius.dart';

class ItemDetailsRecommendedSkeleton extends StatelessWidget {
  const ItemDetailsRecommendedSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.surfaceContainerHighest;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.md(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AspectRatio(
            key: const Key('item-details-recommended-skeleton-image'),
            aspectRatio: AppMediaProfile.productCard.aspectRatio,
            child: ColoredBox(color: color),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FractionallySizedBox(
                  widthFactor: 0.8,
                  child: SizedBox(
                    height: AppSpacing.md,
                    child: ColoredBox(color: color),
                  ),
                ),
                SizedBox(height: AppSpacing.sm),
                FractionallySizedBox(
                  widthFactor: 0.55,
                  child: SizedBox(
                    height: AppSpacing.md,
                    child: ColoredBox(color: color),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
