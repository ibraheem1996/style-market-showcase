import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_typography.dart';
import '../../../../core/translations/locale_keys.dart';
import '../../../../core/utils/responsive/app_design_tokens.dart';
import '../../../../core/utils/responsive/app_text_scale_limits.dart';
import '../../../../core/widgets/responsive_content.dart';
import '../controllers/checkout_controller.dart';
import 'steps/summary_step/place_order_button.dart';

class CheckoutBottomNav extends GetView<CheckoutController> {
  const CheckoutBottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme.colorScheme;

    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: AppTextScaleLimits.checkoutBottomBar,
      child: SafeArea(
        top: false,
        child: ColoredBox(
          color: theme.surface,
          child: Obx(() {
            final state = controller.state.value;
            final step = state.currentStepIndex;
            final isAdvancing =
                state.isRefreshingCart || state.isPreviewingOrder;
            final isPlacingOrder = isAdvancing || state.isPlacingOrder;

            return ResponsiveContent.form(
              child: Row(
                children: [
                  if (controller.canGoBack)
                    _Btn(
                      text: LocaleKeys.back.tr,
                      onPressed: isPlacingOrder
                          ? null
                          : controller.previousStep,
                      isPrimary: false,
                    ),
                  if (controller.canGoBack)
                    const SizedBox(width: AppSpacing.sm),
                  if (step < 2) ...[
                    const Spacer(),
                    _Btn(
                      text: LocaleKeys.next.tr,
                      onPressed: controller.canGoNext && !isAdvancing
                          ? controller.nextStep
                          : null,
                      isPrimary: true,
                      isLoading: isAdvancing,
                    ),
                  ] else
                    Expanded(
                      child: PlaceOrderButton(
                        isLoading: isPlacingOrder,
                        onConfirmOrder: controller.placeOrder,
                      ),
                    ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _Btn extends StatelessWidget {
  const _Btn({
    required this.text,
    required this.onPressed,
    required this.isPrimary,
    this.isLoading = false,
  });

  final String text;
  final VoidCallback? onPressed;
  final bool isPrimary;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme.colorScheme;

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isPrimary ? theme.primary : theme.surface,
        foregroundColor: isPrimary ? theme.onPrimary : theme.onSurface,
        side: isPrimary ? null : BorderSide(color: theme.outlineVariant),
        minimumSize: const Size(
          AppControlSizes.minimumTapTarget,
          AppControlSizes.minimumTapTarget,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.md,
        ),
      ),
      onPressed: onPressed,
      child: isLoading
          ? const SizedBox.square(
              dimension: _progressIndicatorSize,
              child: CircularProgressIndicator.adaptive(strokeWidth: 2),
            )
          : Text(text, style: context.appTypography.button.label),
    );
  }

  static const double _progressIndicatorSize = 20;
}
