import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/errors/app_failure.dart';
import '../../../../../core/errors/backend_error_code.dart';
import '../../../../../core/result/app_result.dart';
import '../../../domain/entities/admin_product_enums.dart';
import '../../../domain/entities/admin_product_media_entities.dart';
import '../../../domain/usecases/delete_admin_product_media_image_use_case.dart';
import '../../../domain/usecases/get_admin_product_media_use_case.dart';
import '../../../domain/usecases/reorder_admin_product_media_target_use_case.dart';
import '../../../domain/usecases/set_admin_product_media_primary_use_case.dart';
import '../../../domain/usecases/upload_admin_product_media_images_use_case.dart';
import 'admin_product_media_state.dart';

@injectable
class AdminProductMediaCubit extends Cubit<AdminProductMediaState> {
  AdminProductMediaCubit(
    this._getMedia,
    this._uploadImages,
    this._deleteImage,
    this._reorderTarget,
    this._setPrimary,
  ) : super(const AdminProductMediaState());

  final GetAdminProductMediaUseCase _getMedia;
  final UploadAdminProductMediaImagesUseCase _uploadImages;
  final DeleteAdminProductMediaImageUseCase _deleteImage;
  final ReorderAdminProductMediaTargetUseCase _reorderTarget;
  final SetAdminProductMediaPrimaryUseCase _setPrimary;

  void Function()? _onMutationSucceeded;

  void attachChangedCallback(void Function() callback) {
    _onMutationSucceeded = callback;
  }

  Future<void> load(int productId) async {
    if (state.isLoading) return;
    emit(
      state.copyWith(
        productId: productId,
        isLoading: true,
        loadErrorMessage: null,
        effect: null,
      ),
    );

    final result = await _getMedia(productId);
    if (isClosed) return;
    switch (result) {
      case AppResultSuccess(:final data):
        emit(
          state.copyWith(
            productId: data.product.id,
            media: data,
            isLoading: false,
            loadErrorMessage: null,
          ),
        );
      case AppResultFailure(:final failure):
        emit(
          state.copyWith(
            isLoading: false,
            loadErrorMessage: _loadMessageForFailure(failure),
          ),
        );
    }
  }

  Future<void> refresh() async {
    final productId = state.productId;
    if (productId == null || !canRefresh()) return;
    emit(state.copyWith(isRefreshing: true, loadErrorMessage: null));

    final result = await _getMedia(productId);
    if (isClosed) return;
    switch (result) {
      case AppResultSuccess(:final data):
        emit(state.copyWith(media: data, isRefreshing: false));
      case AppResultFailure(:final failure):
        emit(
          state.copyWith(
            isRefreshing: false,
            effect: AdminProductMediaFailureEffect(failure.message),
            effectId: state.effectId + 1,
          ),
        );
    }
  }

  Future<void> upload({
    required AdminProductMediaTargetEntity target,
    required List<AdminProductMediaUploadFileEntity> files,
  }) async {
    if (!_startMutation(target, AdminProductMediaOperation.upload)) return;

    final productId = state.productId;
    if (productId == null) return;
    final result = await _uploadImages(
      productId: productId,
      scope: target.scope,
      targetId: target.targetId,
      files: files,
    );
    if (isClosed) return;
    await _handleMutationResult(target: target, result: result);
  }

  Future<void> deleteImage({
    required AdminProductMediaTargetEntity target,
    required int imageId,
  }) async {
    if (!_startMutation(
      target,
      AdminProductMediaOperation.delete,
      imageId: imageId,
    )) {
      return;
    }

    final productId = state.productId;
    if (productId == null) return;
    final result = await _deleteImage(productId: productId, imageId: imageId);
    if (isClosed) return;
    await _handleMutationResult(target: target, result: result);
  }

  Future<void> reorder({
    required AdminProductMediaTargetEntity target,
    required List<int> imageIds,
  }) async {
    if (!_startMutation(target, AdminProductMediaOperation.reorder)) return;

    final productId = state.productId;
    if (productId == null) return;
    final result = await _reorderTarget(
      productId: productId,
      scope: target.scope,
      targetId: target.targetId,
      imageIds: imageIds,
    );
    if (isClosed) return;
    await _handleMutationResult(target: target, result: result);
  }

  Future<void> setPrimary({
    required AdminProductMediaTargetEntity target,
    required int? imageId,
  }) async {
    if (!_startMutation(
      target,
      AdminProductMediaOperation.primary,
      imageId: imageId,
    )) {
      return;
    }

    final productId = state.productId;
    if (productId == null) return;
    final result = await _setPrimary(
      productId: productId,
      scope: target.scope,
      targetId: target.targetId,
      imageId: imageId,
    );
    if (isClosed) return;
    await _handleMutationResult(target: target, result: result);
  }

  bool _startMutation(
    AdminProductMediaTargetEntity target,
    AdminProductMediaOperation operation, {
    int? imageId,
  }) {
    if (state.hasActiveMutation) {
      emit(
        state.copyWith(
          effect: const AdminProductMediaFailureEffect(
            'توجد عملية صور قيد التنفيذ. انتظر اكتمالها ثم أعد المحاولة.',
          ),
          effectId: state.effectId + 1,
        ),
      );
      return false;
    }

    emit(
      state.copyWith(
        targetOperations: {
          ...state.targetOperations,
          target.targetKey: AdminProductMediaTargetOperationState(
            targetKey: target.targetKey,
            operation: operation,
            imageId: imageId,
          ),
        },
        effect: null,
      ),
    );
    return true;
  }

  Future<void> _handleMutationResult({
    required AdminProductMediaTargetEntity target,
    required AppResult<AdminProductMediaMutationResultEntity> result,
  }) async {
    switch (result) {
      case AppResultSuccess(:final data):
        final message = _successMessage(data);
        emit(
          state.copyWith(
            media: data.media,
            targetOperations: _clearTargetOperation(target.targetKey),
            hasSuccessfulMutation: true,
            effect: AdminProductMediaSuccessEffect(message),
            effectId: state.effectId + 1,
          ),
        );
        _onMutationSucceeded?.call();
      case AppResultFailure(:final failure):
        final message = _mutationMessageForFailure(failure);
        final effect = failure.errorCode == BackendErrorCode.mediaOrderConflict
            ? AdminProductMediaConflictEffect(message)
            : AdminProductMediaFailureEffect(message);
        emit(
          state.copyWith(
            targetOperations: {
              ...state.targetOperations,
              target.targetKey: AdminProductMediaTargetOperationState(
                targetKey: target.targetKey,
                errorMessage: message,
              ),
            },
            effect: effect,
            effectId: state.effectId + 1,
          ),
        );
        if (_shouldRefreshAfterFailure(failure)) {
          await refresh();
        }
    }
  }

  Map<String, AdminProductMediaTargetOperationState> _clearTargetOperation(
    String targetKey,
  ) {
    final next = {...state.targetOperations};
    next.remove(targetKey);
    return next;
  }

  bool _shouldRefreshAfterFailure(AppFailure failure) {
    return switch (failure.errorCode) {
      BackendErrorCode.mediaOrderConflict ||
      BackendErrorCode.mediaTargetNotFound ||
      BackendErrorCode.imageNotFound ||
      BackendErrorCode.imageNotInTarget => true,
      _ => false,
    };
  }

  String _loadMessageForFailure(AppFailure failure) {
    if (failure.errorCode == BackendErrorCode.productNotFound) {
      return 'تعذر العثور على المنتج المطلوب.';
    }
    return failure.message;
  }

  String _mutationMessageForFailure(AppFailure failure) {
    return switch (failure.errorCode) {
      BackendErrorCode.mediaOrderConflict =>
        'تغير ترتيب الصور على الخادم. تم تحديث القائمة، أعد المحاولة.',
      BackendErrorCode.mediaTargetNotFound =>
        'لم يعد هدف الصور موجودًا لهذا المنتج. تم تحديث البيانات.',
      BackendErrorCode.imageNotFound =>
        'لم تعد الصورة موجودة. تم تحديث البيانات.',
      BackendErrorCode.imageNotInTarget =>
        'الصورة لا تنتمي إلى هذا الهدف. تم تحديث البيانات.',
      BackendErrorCode.validationError => 'يرجى مراجعة الصور المحددة.',
      _ => 'تعذر تنفيذ العملية: ${failure.message}',
    };
  }

  String _successMessage(AdminProductMediaMutationResultEntity data) {
    final base = switch (data.operation) {
      AdminProductMediaOperation.upload => 'تم رفع الصور.',
      AdminProductMediaOperation.delete => 'تم حذف الصورة.',
      AdminProductMediaOperation.reorder => 'تم حفظ ترتيب الصور.',
      AdminProductMediaOperation.primary => 'تم تحديث الصورة الأساسية.',
    };
    if (data.operation == AdminProductMediaOperation.delete &&
        data.storageDeleted == false) {
      return '$base الملف ما زال مستخدمًا في موضع آخر أو تعذر تنظيفه من التخزين.';
    }
    return base;
  }

  bool canRefresh() {
    if (state.hasActiveMutation || state.isRefreshing || state.isLoading) {
      return false;
    }

    return true;
  }
}
