import 'package:flutter/material.dart';

import '../theme/app_typography.dart';
import '../utils/responsive/app_home_layout_tokens.dart';
import '../utils/responsive/app_responsive_value.dart';
import '../utils/responsive/app_text_scale_limits.dart';
import '../utils/responsive/app_window_class.dart';

class AppHorizontalProductRail extends StatelessWidget {
  const AppHorizontalProductRail({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.padding = EdgeInsets.zero,
  });

  final int itemCount;
  final Widget Function(BuildContext context, int index) itemBuilder;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final textScale = AppTextScaleValue.scaleFactor(
      context,
      fontSize: context.appTypography.productCard.name.fontSize!,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final windowClass = AppWindowClass.fromWidth(constraints.maxWidth);

        final cardWidth = AppProductCardSizes.horizontalRailWidth(
          windowClass: windowClass,
          textScale: textScale,
        );

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: padding,
          child: MediaQuery.withClampedTextScaling(
            maxScaleFactor: AppTextScaleLimits.productCard,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var index = 0; index < itemCount; index++) ...[
                  SizedBox(
                    key: ValueKey('app-horizontal-product-card-$index'),
                    width: cardWidth,
                    child: itemBuilder(context, index),
                  ),
                  if (index != itemCount - 1) const SizedBox(width: 12),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
