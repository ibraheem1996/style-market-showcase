import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/errors/app_failure.dart';
import '../../../../../core/errors/backend_error_code.dart';
import '../../../../../core/result/app_result.dart';
import '../../../domain/usecases/delete_admin_product_use_case.dart';
import '../../../domain/usecases/get_admin_product_deletion_impact_use_case.dart';
import '../../../domain/usecases/update_admin_product_visibility_use_case.dart';
import 'admin_product_lifecycle_state.dart';

@injectable
class AdminProductLifecycleCubit extends Cubit<AdminProductLifecycleState> {
  AdminProductLifecycleCubit(
    this._getImpact,
    this._updateVisibility,
    this._deleteProduct,
  ) : super(const AdminProductLifecycleState());

  final GetAdminProductDeletionImpactUseCase _getImpact;
  final UpdateAdminProductVisibilityUseCase _updateVisibility;
  final DeleteAdminProductUseCase _deleteProduct;
  int? _productId;

  Future<void> load(int productId) async {
    if (state.isLoadingImpact || state.isRefreshingImpact) return;
    _productId = productId;
    await _loadImpact(initial: state.impact == null);
  }

  Future<void> refreshImpact() async {
    if (_productId == null || state.isMutating) return;
    await _loadImpact(initial: false);
  }

  Future<void> setActive(bool active) async {
    final productId = _productId;
    if (productId == null || state.isMutating) return;
    emit(
      state.copyWith(
        isUpdatingVisibility: true,
        deleteErrorMessage: null,
        effect: null,
      ),
    );
    final result = await _updateVisibility(
      productId: productId,
      active: active,
    );
    switch (result) {
      case AppResultSuccess(:final data):
        final impact = state.impact;
        final updatedImpact = impact == null
            ? null
            : impact.copyWith(
                active: data.active,
                canDelete:
                    !data.active &&
                    impact.blockers.orderItemCount == 0 &&
                    impact.blockers.cartRowCount == 0,
                blockers: impact.blockers.copyWith(active: data.active),
              );
        emit(
          state.copyWith(
            impact: updatedImpact,
            isUpdatingVisibility: false,
            effect: AdminProductVisibilitySucceeded(
              data.product,
              data.active ? 'تم تفعيل المنتج.' : 'تم تعطيل المنتج.',
            ),
            effectId: state.effectId + 1,
          ),
        );
      case AppResultFailure(:final failure):
        _emitFailure(
          'تعذر تحديث حالة المنتج: ${failure.message}',
          visibility: true,
        );
    }
  }

  Future<void> delete() async {
    final productId = _productId;
    if (productId == null ||
        state.isMutating ||
        state.impact?.canDelete != true) {
      return;
    }
    emit(
      state.copyWith(isDeleting: true, deleteErrorMessage: null, effect: null),
    );
    final result = await _deleteProduct(productId);
    switch (result) {
      case AppResultSuccess(:final data):
        final message = data.storage.failed > 0
            ? 'تم حذف المنتج، لكن تعذر حذف ${data.storage.failed} من ملفات التخزين.'
            : data.storage.retainedShared > 0
            ? 'تم حذف المنتج نهائيًا، واحتُفظ بـ ${data.storage.retainedShared} من الملفات المشتركة.'
            : 'تم حذف المنتج نهائيًا.';
        emit(
          state.copyWith(
            isDeleting: false,
            effect: AdminProductDeleteSucceeded(data, message),
            effectId: state.effectId + 1,
          ),
        );
      case AppResultFailure(:final failure):
        final message = _productDeleteMessage(failure);
        emit(
          state.copyWith(
            isDeleting: false,
            deleteErrorMessage: message,
            effect: AdminProductLifecycleFailed(message),
            effectId: state.effectId + 1,
          ),
        );
        if (_isProductConflict(failure)) {
          await _loadImpact(initial: false, preserveDeleteError: true);
        }
    }
  }

  Future<void> _loadImpact({
    required bool initial,
    bool preserveDeleteError = false,
  }) async {
    final productId = _productId;
    if (productId == null) return;
    emit(
      state.copyWith(
        isLoadingImpact: initial,
        isRefreshingImpact: !initial,
        impactErrorMessage: null,
        deleteErrorMessage: preserveDeleteError
            ? state.deleteErrorMessage
            : null,
      ),
    );
    final result = await _getImpact(productId);
    switch (result) {
      case AppResultSuccess(:final data):
        emit(
          state.copyWith(
            impact: data,
            isLoadingImpact: false,
            isRefreshingImpact: false,
          ),
        );
      case AppResultFailure(:final failure):
        emit(
          state.copyWith(
            isLoadingImpact: false,
            isRefreshingImpact: false,
            impactErrorMessage: 'تعذر تحميل أثر الحذف: ${failure.message}',
          ),
        );
    }
  }

  void _emitFailure(String message, {required bool visibility}) {
    emit(
      state.copyWith(
        isUpdatingVisibility: visibility ? false : state.isUpdatingVisibility,
        isDeleting: visibility ? state.isDeleting : false,
        effect: AdminProductLifecycleFailed(message),
        effectId: state.effectId + 1,
      ),
    );
  }
}

bool _isProductConflict(AppFailure failure) =>
    failure.errorCode == BackendErrorCode.productMustBeInactive ||
    failure.errorCode == BackendErrorCode.productDeleteBlocked;

String _productDeleteMessage(AppFailure failure) {
  return switch (failure.errorCode) {
    BackendErrorCode.productMustBeInactive =>
      'يجب تعطيل المنتج قبل الحذف. تم تحديث أثر الحذف.',
    BackendErrorCode.productDeleteBlocked =>
      'تعذر حذف المنتج لوجود ارتباطات طلبات أو سلة. تم تحديث أثر الحذف.',
    BackendErrorCode.productNotFound => 'المنتج غير موجود أو تم حذفه مسبقًا.',
    _ => 'تعذر حذف المنتج: ${failure.message}',
  };
}
