import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../../core/result/app_result.dart';
import '../../domain/entities/admin_order_entities.dart';
import '../../domain/entities/admin_order_enums.dart';
import '../../domain/entities/admin_order_filters.dart';
import '../../domain/usecases/approve_admin_order_use_case.dart';
import '../../domain/usecases/cancel_admin_order_use_case.dart';
import '../../domain/usecases/get_admin_orders_use_case.dart';
import '../../domain/usecases/reject_admin_order_use_case.dart';
import '../../domain/usecases/update_admin_order_status_use_case.dart';
import 'admin_order_effect.dart';
import 'admin_orders_state.dart';

@injectable
class AdminOrdersCubit extends Cubit<AdminOrdersState> {
  AdminOrdersCubit(
    this._getOrders,
    this._approveOrder,
    this._rejectOrder,
    this._cancelOrder,
    this._updateStatus,
  ) : super(const AdminOrdersState());

  final GetAdminOrdersUseCase _getOrders;
  final ApproveAdminOrderUseCase _approveOrder;
  final RejectAdminOrderUseCase _rejectOrder;
  final CancelAdminOrderUseCase _cancelOrder;
  final UpdateAdminOrderStatusUseCase _updateStatus;

  Future<void> loadInitial() {
    return _load(page: 1, showLoading: true);
  }

  Future<void> refresh() {
    return _load(page: state.page, showRefresh: true);
  }

  Future<void> searchChanged(String value, {bool applyFilters = true}) {
    final search = state.filters.search;
    if ((search == null || search.isEmpty) && value.isEmpty) {
      return Future.value();
    }

    if (!applyFilters) {
      return Future.value();
    }

    return _applyFilters(state.filters.copyWith(search: value));
  }

  Future<void> statusChanged(AdminOrderStatus? value) {
    return _applyFilters(state.filters.copyWith(status: value));
  }

  Future<void> paymentMethodChanged(AdminPaymentMethod? value) {
    return _applyFilters(state.filters.copyWith(paymentMethod: value));
  }

  Future<void> paymentStatusChanged(AdminPaymentStatus? value) {
    return _applyFilters(state.filters.copyWith(paymentStatus: value));
  }

  Future<void> dateFromChanged(DateTime? value) {
    return _applyFilters(state.filters.copyWith(dateFrom: value));
  }

  Future<void> dateToChanged(DateTime? value) {
    return _applyFilters(state.filters.copyWith(dateTo: value));
  }

  Future<void> sortChanged(AdminOrderSort value) {
    return _applyFilters(state.filters.copyWith(sort: value));
  }

  Future<void> clearFilters() {
    return _applyFilters(const AdminOrderFilters());
  }

  Future<void> goToPage(int page) {
    final pagination = state.pagination;
    if (page < 1 || (pagination != null && page > pagination.totalPages)) {
      return Future<void>.value();
    }
    return _load(page: page, showLoading: true);
  }

  Future<void> performAction({
    required int orderId,
    required AdminOrderAction action,
    String? reason,
  }) async {
    if (state.isActionSubmitting) {
      return;
    }

    final trimmedReason = reason?.trim();
    if (_requiresReason(action) &&
        (trimmedReason == null || trimmedReason.isEmpty)) {
      _emitEffect(const AdminOrderEffect.failure('سبب الإجراء مطلوب.'));
      return;
    }

    emit(state.copyWith(isActionSubmitting: true, effect: null));

    final AppResult<AdminOrderDetailEntity> result = switch (action) {
      AdminOrderAction.approve => await _approveOrder(orderId: orderId),
      AdminOrderAction.reject => await _rejectOrder(
        orderId: orderId,
        reason: trimmedReason!,
      ),
      AdminOrderAction.cancel => await _cancelOrder(
        orderId: orderId,
        reason: trimmedReason!,
      ),
      AdminOrderAction.delivered => await _updateStatus(
        orderId: orderId,
        status: AdminOrderStatus.delivered,
      ),
      AdminOrderAction.returned => await _updateStatus(
        orderId: orderId,
        status: AdminOrderStatus.returned,
        reason: trimmedReason!,
      ),
    };

    switch (result) {
      case AppResultSuccess():
        emit(
          state.copyWith(
            isActionSubmitting: false,
            effect: AdminOrderEffect.success(_successMessage(action)),
            effectId: state.effectId + 1,
          ),
        );
        await _load(page: state.page, showRefresh: true);
      case AppResultFailure(:final failure):
        emit(
          state.copyWith(
            isActionSubmitting: false,
            effect: AdminOrderEffect.failure(_messageForFailure(failure)),
            effectId: state.effectId + 1,
          ),
        );
    }
  }

  Future<void> _applyFilters(AdminOrderFilters filters) {
    emit(state.copyWith(filters: filters, page: 1, effect: null));
    return _load(page: 1, showLoading: true);
  }

  Future<void> _load({
    required int page,
    bool showLoading = false,
    bool showRefresh = false,
  }) async {
    if (state.isLoading || state.isRefreshing) {
      return;
    }

    emit(
      state.copyWith(
        page: page,
        isLoading: showLoading,
        isRefreshing: showRefresh,
        errorMessage: null,
        effect: null,
      ),
    );

    final result = await _getOrders(
      page: page,
      pageSize: state.pageSize,
      filters: state.filters,
    );

    switch (result) {
      case AppResultSuccess(:final data):
        emit(
          state.copyWith(
            orders: data.items,
            pagination: data.pagination,
            page: data.pagination.page,
            pageSize: data.pagination.pageSize,
            isLoading: false,
            isRefreshing: false,
            errorMessage: null,
          ),
        );
      case AppResultFailure(:final failure):
        emit(
          state.copyWith(
            isLoading: false,
            isRefreshing: false,
            errorMessage: _messageForFailure(failure),
          ),
        );
    }
  }

  bool _requiresReason(AdminOrderAction action) {
    return switch (action) {
      AdminOrderAction.reject ||
      AdminOrderAction.cancel ||
      AdminOrderAction.returned => true,
      AdminOrderAction.approve || AdminOrderAction.delivered => false,
    };
  }

  void _emitEffect(AdminOrderEffect effect) {
    emit(state.copyWith(effect: effect, effectId: state.effectId + 1));
  }

  String _successMessage(AdminOrderAction action) {
    return switch (action) {
      AdminOrderAction.approve => 'تم قبول الطلب.',
      AdminOrderAction.reject => 'تم رفض الطلب.',
      AdminOrderAction.cancel => 'تم إلغاء الطلب.',
      AdminOrderAction.delivered => 'تم تحديث الطلب إلى تم التسليم.',
      AdminOrderAction.returned => 'تم تحديث الطلب إلى مسترجع.',
    };
  }

  String _messageForFailure(AppFailure failure) {
    return failure.message;
  }
}
