import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../../core/result/app_result.dart';
import '../../domain/entities/admin_order_enums.dart';
import '../../domain/usecases/approve_admin_order_use_case.dart';
import '../../domain/usecases/cancel_admin_order_use_case.dart';
import '../../domain/usecases/get_admin_order_detail_use_case.dart';
import '../../domain/usecases/reject_admin_order_use_case.dart';
import '../../domain/usecases/update_admin_order_internal_note_use_case.dart';
import '../../domain/usecases/update_admin_order_status_use_case.dart';
import 'admin_order_detail_state.dart';
import 'admin_order_effect.dart';

@injectable
class AdminOrderDetailCubit extends Cubit<AdminOrderDetailState> {
  AdminOrderDetailCubit(
    this._getOrderDetail,
    this._approveOrder,
    this._rejectOrder,
    this._cancelOrder,
    this._updateStatus,
    this._updateInternalNote,
  ) : super(const AdminOrderDetailState());

  final GetAdminOrderDetailUseCase _getOrderDetail;
  final ApproveAdminOrderUseCase _approveOrder;
  final RejectAdminOrderUseCase _rejectOrder;
  final CancelAdminOrderUseCase _cancelOrder;
  final UpdateAdminOrderStatusUseCase _updateStatus;
  final UpdateAdminOrderInternalNoteUseCase _updateInternalNote;

  Future<void> load(int orderId) {
    return _load(orderId, showLoading: true);
  }

  Future<void> approve({String? internalNote}) {
    return _submit(
      successMessage: 'تم قبول الطلب.',
      action: (orderId) =>
          _approveOrder(orderId: orderId, internalNote: internalNote),
    );
  }

  Future<void> reject({required String reason, String? internalNote}) {
    return _reasonAction(
      reason: reason,
      successMessage: 'تم رفض الطلب.',
      action: (orderId, trimmedReason) => _rejectOrder(
        orderId: orderId,
        reason: trimmedReason,
        internalNote: internalNote,
      ),
    );
  }

  Future<void> cancel({required String reason, String? internalNote}) {
    return _reasonAction(
      reason: reason,
      successMessage: 'تم إلغاء الطلب.',
      action: (orderId, trimmedReason) => _cancelOrder(
        orderId: orderId,
        reason: trimmedReason,
        internalNote: internalNote,
      ),
    );
  }

  Future<void> markDelivered({String? internalNote}) {
    return _submit(
      successMessage: 'تم تحديث الطلب إلى تم التسليم.',
      action: (orderId) => _updateStatus(
        orderId: orderId,
        status: AdminOrderStatus.delivered,
        internalNote: internalNote,
      ),
    );
  }

  Future<void> markReturned({required String reason, String? internalNote}) {
    return _reasonAction(
      reason: reason,
      successMessage: 'تم تحديث الطلب إلى مسترجع.',
      action: (orderId, trimmedReason) => _updateStatus(
        orderId: orderId,
        status: AdminOrderStatus.returned,
        reason: trimmedReason,
        internalNote: internalNote,
      ),
    );
  }

  Future<void> updateInternalNote(String? internalNote) {
    return _submit(
      successMessage: 'تم حفظ ملاحظة الأدمن.',
      action: (orderId) =>
          _updateInternalNote(orderId: orderId, internalNote: internalNote),
    );
  }

  Future<void> _reasonAction({
    required String reason,
    required String successMessage,
    required Future<AppResult<dynamic>> Function(int, String) action,
  }) {
    final trimmed = reason.trim();
    if (trimmed.isEmpty) {
      _emitEffect(const AdminOrderEffect.failure('سبب الإجراء مطلوب.'));
      return Future<void>.value();
    }

    return _submit(
      successMessage: successMessage,
      action: (orderId) => action(orderId, trimmed),
    );
  }

  Future<void> _submit({
    required String successMessage,
    required Future<AppResult<dynamic>> Function(int orderId) action,
  }) async {
    final orderId = state.order?.orderId;
    if (orderId == null || state.isSubmitting) {
      return;
    }

    emit(state.copyWith(isSubmitting: true, effect: null));
    final result = await action(orderId);

    switch (result) {
      case AppResultSuccess():
        emit(
          state.copyWith(
            isSubmitting: false,
            effect: AdminOrderEffect.success(successMessage),
            effectId: state.effectId + 1,
          ),
        );
        await _load(orderId, showLoading: false);
      case AppResultFailure(:final failure):
        emit(
          state.copyWith(
            isSubmitting: false,
            effect: AdminOrderEffect.failure(_messageForFailure(failure)),
            effectId: state.effectId + 1,
          ),
        );
    }
  }

  Future<void> _load(int orderId, {required bool showLoading}) async {
    if (state.isLoading) {
      return;
    }

    emit(
      state.copyWith(isLoading: showLoading, errorMessage: null, effect: null),
    );

    final result = await _getOrderDetail(orderId);
    switch (result) {
      case AppResultSuccess(:final data):
        emit(state.copyWith(order: data, isLoading: false, errorMessage: null));
      case AppResultFailure(:final failure):
        emit(
          state.copyWith(
            isLoading: false,
            errorMessage: _messageForFailure(failure),
          ),
        );
    }
  }

  void _emitEffect(AdminOrderEffect effect) {
    emit(state.copyWith(effect: effect, effectId: state.effectId + 1));
  }

  String _messageForFailure(AppFailure failure) {
    return failure.message;
  }
}
