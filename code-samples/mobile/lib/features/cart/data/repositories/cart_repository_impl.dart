// Package imports:
import 'package:dartz/dartz.dart';
import 'package:my_project/features/auth/session/session_service.dart';

// Project imports:
import '../../../../core/base/base_repository.dart';
import '../../../../core/errors/api_result.dart';
import '../../../../core/errors/app_failure_key.dart';
import '../../../../core/errors/backend_error_code_resolver.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/errors/failure_key.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/response_mapper.dart';
import '../../../../core/services/crashlytics_service.dart';
import '../../../../core/services/logger_service.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../../domain/repositories/cart_repository.dart';
import '../datasources/remote/cart_remote_datasource.dart';
import '../mappers/cart_item_mapper.dart';
import '../models/cart_item_model.dart';
import '../models/toggle_cart_request.dart';

import '../models/toggle_selection_request.dart';

class CartRepositoryImpl extends BaseRepository implements CartRepository {
  final CartRemoteDataSource remoteDataSource;
  final CrashlyticsService crash;
  final SessionService sessionService;
  CartRepositoryImpl({
    required this.remoteDataSource,
    required super.analytics,
    required this.crash,
    required super.performance,
    required this.sessionService,
  }) : super(crash: crash);

  @override
  Future<ApiResult<List<CartItemEntity>>> getCart() async {
    if (sessionService.userId == null) {
      return Left(Failure.app(key: AppFailureKey.loginRequired));
    }
    final result = await handleApiCall<ApiResponse<List<CartItemModel>>>(
      remoteDataSource.getCart,
    );
    return result.fold((f) => Left(f), (r) {
      return mapListResponse<CartItemModel, CartItemEntity>(
        r: r,
        mapper: (model) => model.toEntity(),
        logTag: 'getCart repository ',
        crash: crash,
        requireAllItems: true,
      );
    });
  }

  @override
  Future<ApiResult<ToggleCartResult>> toggleCart({
    required int itemId,
    int? variantId,
    required int quantity,
  }) async {
    if (sessionService.userId == null) {
      return Left(Failure.app(key: AppFailureKey.loginRequired));
    }
    final request = ToggleCartRequest(
      itemId: itemId,
      variantId: variantId,
      quantity: quantity,
    );

    final result = await handleApiCall<ApiResponse<CartItemModel?>>(
      () => remoteDataSource.toggleCart(request),
    );

    return result.fold((failure) => Left(failure), (response) {
      if (!response.isSuccess) {
        return Left(
          Failure.http(
            key:
                BackendErrorCodeResolver.httpFailureKeyOf(response.errorCode) ??
                FailureKey.serverGeneric,
            errorCode: response.errorCode,
            rawServerMessage: response.message,
          ),
        );
      }
      final CartAction action;
      try {
        action = response.toCartAction();
      } catch (e, st) {
        LoggerService.error("CartRepository: Toggle cart failed", e, st);
        crash.logError(e, st, reason: "fill cart action failed");
        return Left(
          Failure.http(
            key: FailureKey.invalidData,
            rawServerMessage: "Failed to toggle cart",
          ),
        );
      }
      final data = response.data;
      if (data == null) {
        if (action == CartAction.removed) {
          return Right(ToggleCartResult(action: action, item: null));
        }
        return const Left(Failure.http(key: FailureKey.missingServerData));
      }
      try {
        return Right(ToggleCartResult(action: action, item: data.toEntity()));
      } catch (error, stackTrace) {
        LoggerService.error(
          'CartRepository: Invalid toggle item',
          error,
          stackTrace,
        );
        crash.logError(
          error,
          stackTrace,
          reason: 'CartRepository: Invalid toggle item',
        );
        return const Left(Failure.http(key: FailureKey.invalidData));
      }
    });
  }

  @override
  Future<ApiResult<void>> toggleSelection({
    required int cartId,
    required bool isSelected,
  }) async {
    final userId = sessionService.userId;
    if (userId == null) {
      return Left(Failure.app(key: AppFailureKey.loginRequired));
    }
    final request = ToggleSelectionRequest(
      cartId: cartId,
      isSelected: isSelected ? 1 : 0,
    );

    final result = await handleApiCall<ApiResponse<void>>(
      () => remoteDataSource.toggleSelection(request),
    );

    return result.fold(
      (failure) => Left(failure),
      (response) => response.isSuccess
          ? const Right(null)
          : Left(
              Failure.http(
                key:
                    BackendErrorCodeResolver.httpFailureKeyOf(
                      response.errorCode,
                    ) ??
                    FailureKey.serverGeneric,
                errorCode: response.errorCode,
                rawServerMessage: response.message,
              ),
            ),
    );
  }

  @override
  Future<ApiResult<void>> clearCart() async {
    if (sessionService.userId == null) {
      return Left(Failure.app(key: AppFailureKey.loginRequired));
    }
    final result = await handleApiCall(remoteDataSource.clearCart);
    return result.fold(
      (failure) => Left(failure),
      (response) => response.isSuccess
          ? const Right(null)
          : Left(
              Failure.http(
                key:
                    BackendErrorCodeResolver.httpFailureKeyOf(
                      response.errorCode,
                    ) ??
                    FailureKey.serverGeneric,
                errorCode: response.errorCode,
                rawServerMessage: response.message,
              ),
            ),
    );
  }
}
