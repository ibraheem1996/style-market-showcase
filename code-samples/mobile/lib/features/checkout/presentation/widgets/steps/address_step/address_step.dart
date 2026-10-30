import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../core/utils/responsive/app_design_tokens.dart';
import '../../../../../addresses/domain/entities/address_entity.dart';
import '../../../controllers/checkout_controller.dart';
import '../summary_step/summary_address_card.dart';

class AddressStep extends GetView<CheckoutController> {
  const AddressStep({super.key, required this.onChange, required this.onEdit});

  final Future<void> Function() onChange;
  final Future<void> Function(AddressEntity address) onEdit;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Obx(
        () => SummaryAddressCard(
          address: controller.selectedDeliveryAddress,
          onChange: onChange,
          onEdit: onEdit,
        ),
      ),
    );
  }
}
