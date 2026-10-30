// Package imports:
import 'package:dartz/dartz.dart';
import 'package:get/get.dart';

// Project imports:
import '../../../../core/errors/failure.dart';

import '../../domain/entities/checkout_preview_entity.dart';
import '../../domain/entities/order_item_entity.dart';
import '../../domain/params/order_action_params.dart';
import '../../domain/params/create_order_params.dart';
import '../../domain/usecases/cancel_order_usecase.dart';
import '../../domain/usecases/create_order_usecase.dart';
import '../../domain/usecases/preview_order_usecase.dart';
import '../../domain/usecases/submit_order_note_usecase.dart';
import '../manager/orders_manager.dart';

//! Controller for orders feature
class OrderService extends GetxService {
  final CreateOrderUseCase createOrderUseCase;
  final PreviewOrderUseCase previewOrderUseCase;
  final CancelOrderUseCase cancelOrderUseCase;
  final SubmitOrderNoteUseCase submitOrderNoteUseCase;

  OrderService({
    required this.createOrderUseCase,
    required this.previewOrderUseCase,
    required this.cancelOrderUseCase,
    required this.submitOrderNoteUseCase,
  });

  Future<Either<Failure, CheckoutPreviewEntity>> previewOrder({
    required CheckoutPreviewParams params,
  }) async {
    return previewOrderUseCase(params);
  }

  //! Create a new order
  Future<Either<Failure, CreateOrderResultEntity>> createOrder({
    required CreateOrderParams params,
  }) async {
    final result = await createOrderUseCase(params);

    return result.fold(
      (failure) {
        return Left(failure);
      },
      (order) async {
        try {
          Get.find<OrdersManager>().refreshOrders(silent: true);
        } catch (_) {}
        return Right(order);
      },
    );
  }

  Future<Either<Failure, void>> cancelOrder({
    required CancelOrderParams params,
  }) async {
    return cancelOrderUseCase(params);
  }

  Future<Either<Failure, void>> submitOrderNote({
    required SubmitOrderNoteParams params,
  }) async {
    return submitOrderNoteUseCase(params);
  }
}
