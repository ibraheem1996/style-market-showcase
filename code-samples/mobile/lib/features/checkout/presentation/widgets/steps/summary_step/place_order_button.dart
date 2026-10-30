import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../core/theme/app_typography.dart';
import '../../../../../../core/utils/responsive/app_design_tokens.dart';
import '../../../../../../core/translations/locale_keys.dart';

class PlaceOrderButton extends StatelessWidget {
  const PlaceOrderButton({
    super.key,
    required this.isLoading,
    required this.onConfirmOrder,
  });
  final bool isLoading;
  final Future<void> Function() onConfirmOrder;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(AppControlSizes.minimumTapTarget),
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          shadowColor: context.theme.colorScheme.onSecondary.withValues(
            alpha: 0.6,
          ),
          elevation: 4,
        ),
        onPressed: isLoading ? null : onConfirmOrder,
        child: isLoading
            ? SizedBox(
                height: _progressIndicatorSize,
                width: _progressIndicatorSize,
                child: CircularProgressIndicator.adaptive(
                  strokeWidth: _progressStrokeWidth,
                ),
              )
            : Text(
                LocaleKeys.checkoutConfirmOrder.tr,
                style: context.appTypography.button.label,
              ),
      ),
    );
  }

  static const double _progressIndicatorSize = 20;
  static const double _progressStrokeWidth = 2;
}
