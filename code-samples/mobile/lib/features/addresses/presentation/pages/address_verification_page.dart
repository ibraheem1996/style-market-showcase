import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/overlays/app_dialog.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/translations/locale_keys.dart';
import '../../../../core/utils/responsive/app_design_tokens.dart';
import '../../../../core/widgets/responsive_content.dart';
import '../../../../core/widgets/rx_event_listener.dart';
import '../controllers/address_verification_controller.dart';
import '../widgets/verification/address_phone_verification_view.dart';

class AddressVerificationPage extends GetView<AddressVerificationController> {
  const AddressVerificationPage({super.key});

  Future<void> _requestClose() async {
    if (controller.isTerminal) {
      controller.acknowledgeTerminal();
      return;
    }
    final accepted = await AppDialog.confirm(
      LocaleKeys.phoneVerificationCancelTitle.tr,
      confirmLabel: LocaleKeys.phoneVerificationCancelAction.tr,
      cancelLabel: LocaleKeys.continueAction.tr,
    );
    if (accepted) {
      await controller.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return RxEventListener<AddressVerificationCompletion>(
      rxnEvent: controller.completion,
      clearEvent: controller.clearCompletion,
      onEvent: (completion) async => Get.back(result: completion.address),
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) _requestClose();
        },
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Text(
              LocaleKeys.phoneVerificationTitle.tr,
              style: context.appTypography.appBar.title,
            ),
            actions: [
              IconButton(
                onPressed: _requestClose,
                tooltip: LocaleKeys.phoneVerificationClose.tr,
                icon: Icon(
                  Icons.close,
                  size: AppIconSizes.appBarAction(context),
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: ResponsiveContent.form(
              child: Obx(
                () => AddressPhoneVerificationView(
                  state: controller.state.value,
                  onCodeChanged: controller.onCodeChanged,
                  onSubmitCode: controller.confirm,
                  onConfirm: controller.confirm,
                  onResend: controller.resend,
                  isBusy: controller.isBusy,
                  isTerminal: controller.isTerminal,
                  onClose: _requestClose,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
