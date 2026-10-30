import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../core/utils/responsive/app_design_tokens.dart';
import '../../../../../../core/translations/locale_keys.dart';
import '../../../controllers/checkout_controller.dart';
import '../../../state/state.dart';
import 'payment_method_tile.dart';

class PaymentStep extends GetView<CheckoutController> {
  const PaymentStep({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => ListView(
        padding: const EdgeInsets.all(AppSpacing.sm),
        children: [
          PaymentMethodTile(
            method: PaymentMethod.cash,
            title: LocaleKeys.checkoutPaymentMethodCashOnDelivery.tr,
            description:
                LocaleKeys.checkoutPaymentMethodCashOnDeliveryDescription.tr,
            selected:
                controller.state.value.selectedPaymentMethod ==
                PaymentMethod.cash,
            onSelected: controller.changePaymentMethod,
          ),
          const SizedBox(height: AppSpacing.lg),
          PaymentMethodTile(
            method: PaymentMethod.visa,
            title: LocaleKeys.checkoutPaymentMethodOnline.tr,
            description: LocaleKeys.checkoutPaymentMethodOnlineDescription.tr,
            unavailableText: LocaleKeys.checkoutOnlinePaymentUnavailable.tr,
            selected:
                controller.state.value.selectedPaymentMethod ==
                PaymentMethod.visa,
            onSelected: controller.changePaymentMethod,
            enabled: false,
          ),
        ],
      ),
    );
  }
}
