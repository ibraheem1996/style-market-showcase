import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../core/translations/locale_keys.dart';
import '../../../../../../core/utils/responsive/app_design_tokens.dart';
import '../../../../../addresses/domain/entities/address_entity.dart';
import '../../../../../cart/presentation/logic/cart_pricing.dart';
import '../../../controllers/checkout_controller.dart';
import '../../../state/state.dart';
import 'summary_address_card.dart';
import 'summary_note_card.dart';
import 'summary_payment_card.dart';
import 'summary_totals_card.dart';

class SummaryStep extends GetView<CheckoutController> {
  const SummaryStep({
    super.key,
    required this.onChangeAddress,
    required this.onEditAddress,
  });

  final Future<void> Function() onChangeAddress;
  final Future<void> Function(AddressEntity address) onEditAddress;

  @override
  Widget build(BuildContext context) {
    final payment = controller.state.value.selectedPaymentMethod;
    return SingleChildScrollView(
      child: Column(
        children: [
          SummaryPaymentCard(
            paymentText: payment == PaymentMethod.visa
                ? LocaleKeys.checkoutPaymentMethodOnline.tr
                : LocaleKeys.checkoutPaymentMethodCashOnDelivery.tr,
          ),
          const SizedBox(height: AppSpacing.md),

          Obx(
            () => SummaryTotalsCard(
              subTotal: controller.state.value.previewSubtotal > 0
                  ? controller.state.value.previewSubtotal
                  : selectedCartSubtotal(controller.cartStore.selectedItems),
              delivery: controller.state.value.deliveryFee,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Obx(() {
            return SizedBox(
              width: double.infinity,
              child: SummaryAddressCard(
                address: controller.selectedDeliveryAddress,
                onChange: onChangeAddress,
                onEdit: onEditAddress,
              ),
            );
          }),
          const SizedBox(height: AppSpacing.lg),
          const SummaryNoteCard(),
          const SizedBox(height: AppSpacing.sm),
        ],
      ),
    );
  }
}
