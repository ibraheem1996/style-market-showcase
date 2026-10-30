// Package imports:
import 'package:dartz/dartz.dart';
import 'package:my_project/core/errors/failure.dart';
import 'package:my_project/core/network/api_response.dart';
import 'package:my_project/features/auth/session/session_service.dart';

// Project imports:
import '../../../../core/base/base_repository.dart';
import '../../../../core/errors/api_result.dart';
import '../../../../core/errors/app_failure_key.dart';
import '../../../../core/errors/backend_error_code_resolver.dart';
import '../../../../core/errors/failure_key.dart';
import '../../../../core/errors/error_handler.dart';
import '../../../../core/services/crashlytics_service.dart';
import '../../../../core/services/logger_service.dart';
import '../../domain/entities/order_item_entity.dart';
import '../../domain/entities/checkout_preview_entity.dart';
import '../../domain/params/create_order_params.dart';
import '../../domain/params/order_action_params.dart';
import '../../domain/repositories/orders_repository.dart';
import '../datasources/remote/orders_remote_datasource.dart';
import '../mapper/checkout_preview_mapper.dart';
import '../mapper/create_order_mapper.dart';
import '../mapper/order_details_mapper.dart';
import '../mapper/order_summary_mapper.dart';
import '../models/order_details_response.dart';
import '../models/order_summary_model.dart';
import '../../domain/entities/order_details_entity.dart';
import '../../domain/entities/order_summary_entity.dart';
import '../../../../core/network/response_mapper.dart';

//! Repository implementation for orders feature
class OrdersRepositoryImpl extends BaseRepository implements OrdersRepository {
  final OrdersRemoteDataSource remoteDataSource;
  final CrashlyticsService crash;
  final SessionService sessionService;
  OrdersRepositoryImpl({
    required this.remoteDataSource,
    required this.crash,
    required this.sessionService,
  }) : super(crash: crash);

  @override
  Future<ApiResult<CreateOrderResultEntity>> createOrder(
    CreateOrderParams params,
  ) async {
    LoggerService.info("OrdersRepository: Creating order");
    if (sessionService.userId == null) {
      return Left(Failure.app(key: AppFailureKey.loginRequired));
    }
    final request = params.toRequest();

    final result = await handleApiCall(
      () => remoteDataSource.createOrder(request),
    );

    return result.fold((l) => Left(l), (r) {
      if (!r.isSuccess || !r.isOkAction) {
        return Left(_failureFromResponse(r));
      }

      final data = r.data;
      if (data == null) {
        LoggerService.error(
          "OrdersRepository: Response success but data is null. ${r.message}",
        );
        return Left(Failure.http(key: FailureKey.missingServerData));
      }

      try {
        return Right(data.toEntity());
      } catch (e, s) {
        LoggerService.error(
          "OrdersRepository: Mapping failed ${r.message}",
          e,
          s,
        );
        crash.logError(
          e,
          s,
          reason: "OrdersRepository: Invalid mapping ${r.message}",
        );
        return Left(Failure.http(key: FailureKey.invalidData));
      }
    });
  }

  @override
  Future<ApiResult<CheckoutPreviewEntity>> previewOrder(
    CheckoutPreviewParams params,
  ) async {
    if (sessionService.userId == null) {
      return Left(Failure.app(key: AppFailureKey.loginRequired));
    }

    final result = await handleApiCall(
      () => remoteDataSource.previewOrder(params.toRequest()),
    );

    return result.fold((l) => Left(l), (r) {
      if (!r.isSuccess) {
        return Left(_failureFromResponse(r));
      }

      final data = r.data;
      if (data == null) {
        LoggerService.error(
          "OrdersRepository: Preview success but data is null. ${r.message}",
        );
        return Left(Failure.http(key: FailureKey.missingServerData));
      }

      try {
        return Right(data.toEntity());
      } catch (e, s) {
        LoggerService.error(
          "OrdersRepository: Preview mapping failed ${r.message}",
          e,
          s,
        );
        crash.logError(
          e,
          s,
          reason: "OrdersRepository: Invalid preview mapping ${r.message}",
        );
        return Left(Failure.http(key: FailureKey.invalidData));
      }
    });
  }

  @override
  Future<ApiResult<OrderDetailsEntity>> getOrderDetails(int orderId) async {
    LoggerService.info(
      "OrdersRepository: Fetching details for Order: $orderId ",
    );
    final userId = sessionService.userId;
    if (userId == null) {
      return Left(Failure.app(key: AppFailureKey.loginRequired));
    }
    final result = await handleApiCall(
      () => remoteDataSource.getOrderDetails(orderId),
    );

    return result.fold((l) => Left(l), (r) {
      if (!r.isSuccess) {
        return Left(_failureFromResponse(r));
      }

      final data = r.data;
      if (data == null) {
        LoggerService.error(
          "OrdersRepository: Response success but details data is null. ${r.message}",
        );
        return Left(Failure.http(key: FailureKey.missingServerData));
      }

      try {
        return Right(data.toEntity());
      } catch (e, s) {
        LoggerService.error(
          "OrdersRepository: Mapping details failed ${r.message}",
          e,
          s,
        );
        crash.logError(
          e,
          s,
          reason: "OrdersRepository: Invalid mapping details ${r.message}",
        );
        return Left(ErrorHandler.handle(e));
      }
    });
  }

  @override
  Future<ApiResult<void>> cancelOrder(CancelOrderParams params) async {
    final userId = sessionService.userId;
    if (userId == null) {
      return Left(Failure.app(key: AppFailureKey.loginRequired));
    }

    final result = await handleApiCall(
      () => remoteDataSource.cancelOrder(
        params.orderId,
        CancelOrderRequest(reason: _normalizedOptionalText(params.reason)),
      ),
    );

    return _mapActionResponse(result);
  }

  @override
  Future<ApiResult<void>> submitOrderNote(SubmitOrderNoteParams params) async {
    final userId = sessionService.userId;
    if (userId == null) {
      return Left(Failure.app(key: AppFailureKey.loginRequired));
    }

    final result = await handleApiCall(
      () => remoteDataSource.submitOrderNote(
        params.orderId,
        SubmitOrderNoteRequest(note: params.note.trim()),
      ),
    );

    return _mapActionResponse(result);
  }

  @override
  Future<ApiResult<List<OrderSummaryEntity>>> getOrders() async {
    LoggerService.info("OrdersRepository: Fetching orders history");
    final userId = sessionService.userId;
    if (userId == null) {
      return Left(Failure.app(key: AppFailureKey.loginRequired));
    }
    final apiResult = await handleApiCall(() => remoteDataSource.getOrders());
    return apiResult.fold((l) => Left(l), (r) {
      return mapListResponse<OrderSummaryModel, OrderSummaryEntity>(
        r: r,
        mapper: (m) => m.toEntity(),
        logTag: "OrdersRepository",
        crash: crash,
        requireAllItems: true,
      );
    });
  }

  Failure _failureFromResponse(ApiResponse<dynamic> response) {
    return Failure.http(
      key:
          BackendErrorCodeResolver.httpFailureKeyOf(response.errorCode) ??
          FailureKey.serverGeneric,
      rawServerMessage: response.message,
      errorCode: response.errorCode,
    );
  }

  ApiResult<void> _mapActionResponse(ApiResult<ApiResponse<void>> result) {
    return result.fold((l) => Left(l), (r) {
      if (!r.isSuccess) {
        return Left(_failureFromResponse(r));
      }
      return const Right(null);
    });
  }
}

String? _normalizedOptionalText(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) {
    return null;
  }
  return trimmed;
}
