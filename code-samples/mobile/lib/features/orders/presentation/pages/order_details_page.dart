import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_project/binding_route_middleware/route.dart';

import '../../../../core/overlays/app_bottom_sheet.dart';
import '../../../../core/overlays/app_snackbar.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/errors/failure_i18n.dart';
import '../../../../core/navigation/items_details_route_args.dart';
import '../../../../core/navigation/order_details_route_args.dart';
import '../../../../core/translations/locale_keys.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/responsive/app_design_tokens.dart';
import '../../../../core/widgets/error/app_error_view.dart';
import '../../../../core/widgets/error/extension_failure_to_ui.dart';
import '../../../../core/widgets/responsive_content.dart';
import '../../../../core/widgets/rx_event_listener.dart';
import '../../../home/presentation/store/home_store.dart';
import '../../../auth/presentation/navigation/login_route_args.dart';
import '../../domain/entities/order_details_entity.dart';
import '../controllers/order_details_controller.dart';
import '../controllers/order_details_ui_event.dart';
import '../state/order_state.dart';
import '../widgets/delivery_information/delivery_information.dart';
import '../widgets/details/cancel_order_sheet.dart';
import '../widgets/details/order_actions_section.dart';
import '../widgets/details/order_detail_section_container.dart';
import '../widgets/details/order_items_section.dart';
import '../widgets/details/order_payment_section.dart';
import '../widgets/details/order_price_summary_section.dart';
import '../widgets/details/order_status_header.dart';
import '../widgets/details/submit_order_note_sheet.dart';

class OrderDetailsPage extends GetView<OrderDetailsController> {
  const OrderDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return RxEventListener<OrderDetailsUiEvent>(
      rxnEvent: controller.uiEvent,
      clearEvent: controller.clearUiEvent,
      onEvent: (event) => _handleUiEvent(context, event),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _leaveOrderDetails,
          ),
          title: Text(
            LocaleKeys.ordersDetails.tr,
            style: context.appTypography.appBar.title,
          ),
        ),
        body: Obx(() {
          return controller.state.value.map(
            initial: (_) => const SizedBox.shrink(),
            loading: (_) => const Center(child: CircularProgressIndicator.adaptive()),
            error: (state) => _buildError(state.failure),
            success: (state) => _OrderDetailsBody(
              order: state.order,
              controller: controller,
              onCancelPressed: () => _showCancelSheet(context),
              onNotePressed: () => _showNoteSheet(context),
              onOpenProduct: (item) => _openProduct(state.order, item),
            ),
          );
        }),
      ),
    );
  }

  Future<void> _handleUiEvent(
    BuildContext context,
    OrderDetailsUiEvent event,
  ) async {
    switch (event) {
      case OrderDetailsMessageEvent():
        _showSnackbar(event.messageKey.tr);
      case OrderDetailsActionFailedEvent():
        _showSnackbar(event.failure.message, tone: AppSnackbarTone.error);
      case OrderDetailsActionUnavailableEvent():
        _closeOpenModal();
        _showSnackbar(event.failure.message, tone: AppSnackbarTone.warning);
      case OrderDetailsCancelSucceededEvent():
        _closeOpenModal();
        _showSnackbar(
          LocaleKeys.ordersCancelSuccess.tr,
          tone: AppSnackbarTone.success,
        );
      case OrderDetailsNoteSucceededEvent():
        _closeOpenModal();
        _showSnackbar(
          LocaleKeys.ordersNoteSuccess.tr,
          tone: AppSnackbarTone.success,
        );
    }
  }

  void _showSnackbar(
    String message, {
    AppSnackbarTone tone = AppSnackbarTone.neutral,
  }) {
    AppSnackbar.show(message, tone: tone);
  }

  Widget _buildError(Failure failure) {
    return AppErrorView(
      model: failure.toUI(
        goBack: _leaveOrderDetails,
        retry: () => controller.fetchOrderDetails(),
        goLogin: () => Get.toNamed(
          RouteName.loginFlow,
          arguments: const LoginRouteArgs.flow(),
        ),
      ),
    );
  }

  void _leaveOrderDetails() {
    final args = controller.routeArgs;
    if (args != null) {
      if (args.entryPoint == OrderDetailsEntryPoint.checkoutSuccess) {
        Get.find<HomeStore>().selectHome();
      }
    }
    Get.back();
  }

  void _openProduct(OrderDetailsEntity order, OrderDetailItemEntity item) {
    if (item.itemId <= 0 || !item.isActive) return;
    Get.toNamed(
      RouteName.itemDetails,
      arguments: ItemsDetailsRouteArgs(
        itemId: item.itemId,
        variantId: item.variant?.variantId,
        heroTag: 'order-${order.orderId}-${item.itemId}',
      ),
    );
  }

  Future<void> _showCancelSheet(BuildContext context) {
    return AppBottomSheet.show<void>(CancelOrderSheet(controller: controller));
  }

  Future<void> _showNoteSheet(BuildContext context) {
    return AppBottomSheet.show<void>(
      SubmitOrderNoteSheet(controller: controller),
    );
  }

  void _closeOpenModal() {
    if (Get.isBottomSheetOpen == true || Get.isDialogOpen == true) {
      Get.back<void>();
    }
  }
}

class _OrderDetailsBody extends StatelessWidget {
  const _OrderDetailsBody({
    required this.order,
    required this.controller,
    required this.onCancelPressed,
    required this.onNotePressed,
    required this.onOpenProduct,
  });

  final OrderDetailsEntity order;
  final OrderDetailsController controller;
  final VoidCallback onCancelPressed;
  final VoidCallback onNotePressed;
  final void Function(OrderDetailItemEntity item) onOpenProduct;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: ResponsiveContent.standard(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              OrderStatusHeader(order: order),
              const SizedBox(height: AppSpacing.md),
              OrderActionsSection(
                order: order,
                controller: controller,
                onCancelPressed: onCancelPressed,
                onNotePressed: onNotePressed,
              ),
              const SizedBox(height: AppSpacing.lg),
              OrderDetailSectionContainer(
                child: OrderPriceSummarySection(order: order),
              ),
              const SizedBox(height: AppSpacing.lg),
              OrderDetailSectionContainer(
                child: OrderPaymentSection(order: order),
              ),
              if (order.address case final address?) ...[
                const SizedBox(height: AppSpacing.lg),
                OrderDetailSectionContainer(
                  child: DeliveryInformation(address: address),
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              OrderDetailSectionContainer(
                child: OrderItemsSection(
                  order: order,
                  onOpenProduct: onOpenProduct,
                ),
              ),

              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}
