import 'package:injectable/injectable.dart';

import '../../../../core/network/api_response.dart';
import '../../../../core/network/network_error_mapper.dart';
import '../../../../core/result/app_result.dart';
import '../../domain/entities/admin_order_entities.dart';
import '../../domain/entities/admin_order_enums.dart';
import '../../domain/entities/admin_order_filters.dart';
import '../../domain/repositories/admin_orders_repository.dart';
import '../datasources/admin_orders_remote_data_source.dart';
import '../mappers/admin_order_mapper.dart';
import '../models/admin_order_request_models.dart';
import '../models/admin_order_response_models.dart';

@LazySingleton(as: AdminOrdersRepository)
class AdminOrdersRepositoryImpl implements AdminOrdersRepository {
  const AdminOrdersRepositoryImpl(this._remoteDataSource, this._errorMapper);

  final AdminOrdersRemoteDataSource _remoteDataSource;
  final NetworkErrorMapper _errorMapper;

  @override
  Future<AppResult<AdminOrdersPageEntity>> getOrders({
    required int page,
    required int pageSize,
    required AdminOrderFilters filters,
  }) async {
    try {
      final response = await _remoteDataSource.getOrders(
        filters.toQuery(page: page, pageSize: pageSize),
      );
      return mapAdminOrderResponse(
        response: response,
        mapper: (model) => model.toEntity(),
        errorMapper: _errorMapper,
      );
    } catch (error) {
      return AppResult.failure(_errorMapper.map(error));
    }
  }

  @override
  Future<AppResult<AdminOrderDetailEntity>> getOrderDetail(int orderId) async {
    try {
      final response = await _remoteDataSource.getOrderDetail(orderId);
      return mapAdminOrderResponse(
        response: response,
        mapper: (model) => model.toEntity(),
        errorMapper: _errorMapper,
      );
    } catch (error) {
      return AppResult.failure(_errorMapper.map(error));
    }
  }

  @override
  Future<AppResult<AdminOrderDetailEntity>> approveOrder({
    required int orderId,
    String? internalNote,
  }) async {
    try {
      final response = await _remoteDataSource.approveOrder(
        orderId,
        AdminOrderApproveRequestModel(
          internalNote: _trimOptional(internalNote),
        ),
      );
      return mapAdminOrderResponse(
        response: response,
        mapper: (model) => model.toEntity(),
        errorMapper: _errorMapper,
      );
    } catch (error) {
      return AppResult.failure(_errorMapper.map(error));
    }
  }

  @override
  Future<AppResult<AdminOrderDetailEntity>> rejectOrder({
    required int orderId,
    required String reason,
    String? internalNote,
  }) async {
    return _reasonAction(
      orderId: orderId,
      reason: reason,
      internalNote: internalNote,
      call: _remoteDataSource.rejectOrder,
    );
  }

  @override
  Future<AppResult<AdminOrderDetailEntity>> cancelOrder({
    required int orderId,
    required String reason,
    String? internalNote,
  }) async {
    return _reasonAction(
      orderId: orderId,
      reason: reason,
      internalNote: internalNote,
      call: _remoteDataSource.cancelOrder,
    );
  }

  @override
  Future<AppResult<AdminOrderDetailEntity>> updateOrderStatus({
    required int orderId,
    required AdminOrderStatus status,
    String? reason,
    String? internalNote,
  }) async {
    try {
      final response = await _remoteDataSource.updateOrderStatus(
        orderId,
        AdminOrderStatusUpdateRequestModel(
          status: status.name,
          reason: _trimOptional(reason),
          internalNote: _trimOptional(internalNote),
        ),
      );
      return mapAdminOrderResponse(
        response: response,
        mapper: (model) => model.toEntity(),
        errorMapper: _errorMapper,
      );
    } catch (error) {
      return AppResult.failure(_errorMapper.map(error));
    }
  }

  @override
  Future<AppResult<AdminOrderDetailEntity>> updateInternalNote({
    required int orderId,
    String? internalNote,
  }) async {
    try {
      final response = await _remoteDataSource.updateInternalNote(
        orderId,
        AdminOrderInternalNoteRequestModel(
          internalNote: _trimOptional(internalNote),
        ),
      );
      return mapAdminOrderResponse(
        response: response,
        mapper: (model) => model.toEntity(),
        errorMapper: _errorMapper,
      );
    } catch (error) {
      return AppResult.failure(_errorMapper.map(error));
    }
  }

  Future<AppResult<AdminOrderDetailEntity>> _reasonAction({
    required int orderId,
    required String reason,
    required String? internalNote,
    required Future<ApiResponse<AdminOrderDetailModel>> Function(
      int,
      AdminOrderReasonRequestModel,
    )
    call,
  }) async {
    try {
      final response = await call(
        orderId,
        AdminOrderReasonRequestModel(
          reason: reason.trim(),
          internalNote: _trimOptional(internalNote),
        ),
      );
      return mapAdminOrderResponse(
        response: response,
        mapper: (model) => model.toEntity(),
        errorMapper: _errorMapper,
      );
    } catch (error) {
      return AppResult.failure(_errorMapper.map(error));
    }
  }

  String? _trimOptional(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }
    return trimmed;
  }
}
