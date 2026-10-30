import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../theme/app_typography.dart';
import '../translations/locale_keys.dart';
import '../utils/responsive/app_design_tokens.dart';
import '../utils/responsive/app_radius.dart';

const double _cartActionProgressExtent = 20;
const double _cartQuantityBadgeMinimumExtent = 16;

/// Shared reactive cart action for product cards.
class ReactiveCartActionButton extends StatelessWidget {
  const ReactiveCartActionButton({
    super.key,
    required this.quantity,
    required this.isLoading,
    required this.onPressed,
    this.enabled = true,
    this.tooltip,
    this.disabledTooltip,
  });

  final int Function() quantity;
  final bool Function() isLoading;
  final VoidCallback onPressed;
  final bool enabled;
  final String? tooltip;
  final String? disabledTooltip;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Obx(() {
      final currentQuantity = quantity();
      final loading = isLoading();
      final isActive = currentQuantity > 0;
      final canPress = enabled && !loading;

      final actionLabel = loading
          ? LocaleKeys.loading.tr
          : canPress
          ? tooltip ?? LocaleKeys.addToCart.tr
          : disabledTooltip ?? tooltip ?? LocaleKeys.addToCart.tr;

      final iconColor = !enabled
          ? colorScheme.onSurfaceVariant.withValues(alpha: 0.5)
          : isActive
          ? colorScheme.primary
          : colorScheme.onSurfaceVariant;

      return Semantics(
        button: true,
        enabled: canPress,
        label: actionLabel,
        value: isActive
            ? '${LocaleKeys.productQuantity.tr}: $currentQuantity'
            : null,
        excludeSemantics: true,
        child: Tooltip(
          message: actionLabel,
          child: SizedBox.square(
            dimension: AppControlSizes.small,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: Material(
                    color: colorScheme.surface.withValues(alpha: 0.96),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppRadius.md(context),
                      ),
                      side: BorderSide(
                        color: isActive
                            ? colorScheme.primary.withValues(alpha: 0.4)
                            : colorScheme.outlineVariant,
                      ),
                    ),
                    child: InkWell(
                      onTap: canPress ? onPressed : () {},
                      borderRadius: BorderRadius.circular(
                        AppRadius.md(context),
                      ),
                      child: Center(
                        child: loading
                            ? SizedBox.square(
                                dimension: _cartActionProgressExtent,
                                child: const CircularProgressIndicator.adaptive(
                                  strokeWidth: 2,
                                ),
                              )
                            : Icon(
                                isActive
                                    ? Icons.shopping_cart
                                    : Icons.shopping_cart_outlined,
                                size: AppIconSizes.productCartAction(context),
                                color: iconColor,
                              ),
                      ),
                    ),
                  ),
                ),
                if (isActive)
                  PositionedDirectional(
                    top: -AppSpacing.xs,
                    end: -AppSpacing.xs,
                    child: _CartQuantityBadge(quantity: currentQuantity),
                  ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

class _CartQuantityBadge extends StatelessWidget {
  const _CartQuantityBadge({required this.quantity});

  final int quantity;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      constraints: const BoxConstraints(
        minWidth: _cartQuantityBadgeMinimumExtent,
        minHeight: _cartQuantityBadgeMinimumExtent,
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colorScheme.error,
        borderRadius: BorderRadius.circular(AppRadius.circular(context)),
      ),
      child: Text(
        quantity.toString(),
        maxLines: 1,
        textScaler: TextScaler.noScaling,
        style: context.appTypography.badge.count.copyWith(
          color: colorScheme.onError,
        ),
      ),
    );
  }
}
