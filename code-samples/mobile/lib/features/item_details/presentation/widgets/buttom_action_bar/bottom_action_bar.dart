import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_project/core/utils/responsive/app_window_class.dart';

import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/translations/locale_keys.dart';
import '../../../../../core/utils/responsive/app_design_tokens.dart';
import '../../../../../core/utils/responsive/app_radius.dart';
import '../../../../../core/utils/responsive/app_text_scale_limits.dart';
import 'bottom_bar_button.dart';
import 'qte_widget.dart';

class BottomActionBar extends StatelessWidget {
  const BottomActionBar({
    super.key,
    this.cartQuantity,
    required this.addToCart,
    required this.updateQuantity,
    required this.quantity,
    required this.stock,
    required this.isAddingToCart,
    required this.needsVariant,
  });

  final int? cartQuantity;
  final VoidCallback? addToCart;
  final void Function(int quantity) updateQuantity;
  final int quantity;
  final int stock;
  final bool isAddingToCart;
  final bool needsVariant;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final shortWindow = isShortWindow(MediaQuery.sizeOf(context));
    final topPadding = shortWindow ? AppSpacing.xs : AppSpacing.sm;
    final height = AppControlSizes.minimumTapTarget;
    final radius = AppRadius.sm(context);
    final isUnavailable = stock <= 0 || needsVariant;
    final buttonText = isAddingToCart
        ? LocaleKeys.loading.tr
        : needsVariant
        ? LocaleKeys.selectVariant.tr
        : stock <= 0
        ? LocaleKeys.outOfStock.tr
        : LocaleKeys.addToCart.tr;

    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: AppTextScaleLimits.bottomActionBar,
      child: Padding(
        padding: EdgeInsetsDirectional.only(
          top: topPadding,
          bottom: AppSpacing.sm,
          start: AppSpacing.md,
          end: AppSpacing.md,
        ),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Semantics(
                label: LocaleKeys.productQuantity.tr,
                enabled: !isUnavailable && !isAddingToCart,
                child: QteWidget(
                  height: height,
                  radius: radius,
                  stock: stock,
                  quantity: quantity,
                  enabled: !isUnavailable && !isAddingToCart,
                  updateQuantity: updateQuantity,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              flex: 5,
              child: Semantics(
                button: true,
                enabled: addToCart != null && !isAddingToCart,
                child: BottomBarButton(
                  height: height,
                  radius: radius,
                  text: Text.rich(
                    textAlign: TextAlign.center,
                    TextSpan(
                      children: [
                        TextSpan(
                          text: buttonText,
                          style: context.appTypography.button.label.copyWith(
                            color: theme.colorScheme.onPrimary,
                          ),
                        ),
                        if (cartQuantity != null && cartQuantity! > 0)
                          TextSpan(
                            text: ' ($cartQuantity)',
                            style: context.appTypography.button.label.copyWith(
                              color: theme.colorScheme.onPrimary.withValues(
                                alpha: 0.85,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  color: theme.colorScheme.primary,
                  onPressed: isUnavailable || isAddingToCart ? null : addToCart,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
