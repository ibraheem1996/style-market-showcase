import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../domain/entities/admin_product_enums.dart';
import '../../../domain/entities/admin_product_media_entities.dart';

part 'admin_product_media_state.freezed.dart';

@freezed
abstract class AdminProductMediaTargetOperationState
    with _$AdminProductMediaTargetOperationState {
  const factory AdminProductMediaTargetOperationState({
    required String targetKey,
    AdminProductMediaOperation? operation,
    int? imageId,
    String? errorMessage,
  }) = _AdminProductMediaTargetOperationState;
}

@freezed
abstract class AdminProductMediaState with _$AdminProductMediaState {
  const AdminProductMediaState._();

  const factory AdminProductMediaState({
    int? productId,
    AdminProductMediaBootstrapEntity? media,
    @Default(false) bool isLoading,
    @Default(false) bool isRefreshing,
    String? loadErrorMessage,
    @Default({})
    Map<String, AdminProductMediaTargetOperationState> targetOperations,
    @Default(false) bool hasSuccessfulMutation,
    AdminProductMediaEffect? effect,
    @Default(0) int effectId,
  }) = _AdminProductMediaState;

  bool get hasActiveMutation =>
      targetOperations.values.any((operation) => operation.operation != null);

  AdminProductMediaTargetOperationState? operationFor(String targetKey) {
    return targetOperations[targetKey];
  }
}

sealed class AdminProductMediaEffect {
  const AdminProductMediaEffect(this.message);

  final String message;
}

class AdminProductMediaSuccessEffect extends AdminProductMediaEffect {
  const AdminProductMediaSuccessEffect(super.message);
}

class AdminProductMediaFailureEffect extends AdminProductMediaEffect {
  const AdminProductMediaFailureEffect(super.message);
}

class AdminProductMediaConflictEffect extends AdminProductMediaEffect {
  const AdminProductMediaConflictEffect(super.message);
}
