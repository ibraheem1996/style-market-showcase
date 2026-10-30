import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/errors/failure_i18n.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/errors/failure_key.dart';
import '../../../../core/navigation/order_details_route_args.dart';
import '../../../../core/overlays/app_dialog.dart';
import '../../../../core/overlays/app_snackbar.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/translations/locale_keys.dart';
import '../../../../core/utils/responsive/app_design_tokens.dart';
import '../../../../core/widgets/responsive_content.dart';
import '../../../../core/widgets/rx_event_listener.dart';
import '../../../../binding_route_middleware/route.dart';
import '../../../../binding_route_middleware/address_flow.dart';
import '../../../addresses/domain/entities/address_entity.dart';
import '../controllers/checkout_controller.dart';
import '../event/check_out_event.dart';
import '../widgets/checkout_appbar.dart';
import '../widgets/checkout_bottom_nav.dart';
import '../widgets/steps/payment_step/payment_step.dart';
import '../widgets/steps/address_step/address_step.dart';
import '../widgets/steps/summary_step/summary_step.dart';

class CheckoutPage extends GetView<CheckoutController> {
  const CheckoutPage({super.key});

  Future<void> _openAddressEdit(AddressEntity address) async {
    await AddressFlow.openAddressForm(address: address);
  }

  Future<void> _resolveAddressPhoneFailure(
    Failure failure,
    AddressEntity address,
  ) async {
    final isPhoneNotVerified = failure.maybeWhen(
      http: (key, _, __, ___, ____) => key == FailureKey.phoneNotVerified,
      orElse: () => false,
    );
    if (!isPhoneNotVerified) {
      await _openAddressEdit(address);
      return;
    }

    final shouldVerify = await AppDialog.confirm(
      FailureI18n.keyOf(failure).tr,
      confirmLabel: LocaleKeys.continueAction.tr,
      cancelLabel: LocaleKeys.back.tr,
    );
    if (shouldVerify) {
      await _openAddressEdit(address);
    }
  }

  Future<void> _openAddressPicker() async {
    await AddressFlow.openDeliveryAddressPicker();
  }

  @override
  Widget build(BuildContext context) {
    return RxEventListener<CheckoutEvent>(
      rxnEvent: controller.event,
      clearEvent: () => controller.event.value = null,
      onEvent: (e) async {
        await e.when<Future<void>>(
          errorMessage: (msg) async {
            controller.showInlineFeedback(msg);
          },
          successMessage: (msg) async {
            await AppSnackbar.show(msg, tone: AppSnackbarTone.success);
          },
          failure: (f) async {
            await AppDialog.alert(
              FailureI18n.keyOf(f).tr,
              actionLabel: LocaleKeys.close.tr,
            );
          },
          addressPhoneVerificationRequired: (failure, address) async {
            await _resolveAddressPhoneFailure(failure, address);
          },
          successOrder: (msg, orderId) async {
            await AppSnackbar.show(msg, tone: AppSnackbarTone.success);
            Get.until(
              (route) =>
                  route.settings.name == RouteName.homeScreen || route.isFirst,
            );
            Get.toNamed(RouteName.myOrders);
            await Future<void>.delayed(Duration.zero);
            Get.toNamed(
              RouteName.orderDetails,
              arguments: OrderDetailsRouteArgs.fromCheckoutSuccess(orderId),
            );
          },
        );
      },
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            const CheckoutAppBar(),
            Obx(() {
              final feedback = controller.inlineFeedback.value;
              return feedback == null
                  ? const SliverToBoxAdapter(child: SizedBox.shrink())
                  : SliverToBoxAdapter(
                      child: ResponsiveContent.form(
                        child: Padding(
                          padding: const EdgeInsetsDirectional.only(
                            start: AppSpacing.sm,
                            end: AppSpacing.sm,
                            top: AppSpacing.sm,
                          ),
                          child: Text(
                            feedback,
                            style: context
                                .appTypography
                                .stateMessage
                                .inlineMessage
                                .copyWith(
                                  color: context.theme.colorScheme.error,
                                ),
                          ),
                        ),
                      ),
                    );
            }),
            SliverFillRemaining(
              child: PageView(
                controller: controller.pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  const ResponsiveContent.form(child: PaymentStep()),
                  ResponsiveContent.form(
                    alignment: Alignment.topCenter,
                    child: AddressStep(
                      onChange: _openAddressPicker,
                      onEdit: _openAddressEdit,
                    ),
                  ),
                  ResponsiveContent.form(
                    child: SummaryStep(
                      onChangeAddress: _openAddressPicker,
                      onEditAddress: _openAddressEdit,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: const CheckoutBottomNav(),
      ),
    );
  }
}
