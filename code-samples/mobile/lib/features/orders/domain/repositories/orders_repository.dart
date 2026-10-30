// Project imports:
import '../../../../core/errors/api_result.dart';
import '../entities/order_item_entity.dart';
import '../entities/checkout_preview_entity.dart';
import '../entities/order_details_entity.dart';
import '../entities/order_summary_entity.dart';
import '../params/order_action_params.dart';
import '../params/create_order_params.dart';

//! Abstract repository for managing orders
abstract class OrdersRepository {
  //! Create a new order
  Future<ApiResult<CreateOrderResultEntity>> createOrder(
    CreateOrderParams params,
  );

  //! Preview checkout totals before order creation
  Future<ApiResult<CheckoutPreviewEntity>> previewOrder(
    CheckoutPreviewParams params,
  );

  //! Get order details
  Future<ApiResult<OrderDetailsEntity>> getOrderDetails(int orderId);

  //! Cancel an order owned by the current authenticated user
  Future<ApiResult<void>> cancelOrder(CancelOrderParams params);

  //! Submit a one-time user note for an order owned by the current user
  Future<ApiResult<void>> submitOrderNote(SubmitOrderNoteParams params);

  //! Get user's orders history
  Future<ApiResult<List<OrderSummaryEntity>>> getOrders();
}
