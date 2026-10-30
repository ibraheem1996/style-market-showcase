import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../domain/entities/admin_product_entities.dart';
import '../../../domain/entities/admin_product_lifecycle_entities.dart';

part 'admin_product_lifecycle_state.freezed.dart';

sealed class AdminProductLifecycleEffect {
  const AdminProductLifecycleEffect();
}

class AdminProductVisibilitySucceeded extends AdminProductLifecycleEffect {
  const AdminProductVisibilitySucceeded(this.product, this.message);
  final AdminProductDetailEntity product;
  final String message;
}

class AdminProductDeleteSucceeded extends AdminProductLifecycleEffect {
  const AdminProductDeleteSucceeded(this.result, this.message);
  final AdminProductDeleteResultEntity result;
  final String message;
}

class AdminProductLifecycleFailed extends AdminProductLifecycleEffect {
  const AdminProductLifecycleFailed(this.message);
  final String message;
}

@freezed
abstract class AdminProductLifecycleState with _$AdminProductLifecycleState {
  const AdminProductLifecycleState._();

  const factory AdminProductLifecycleState({
    AdminProductDeletionImpactEntity? impact,
    @Default(false) bool isLoadingImpact,
    @Default(false) bool isRefreshingImpact,
    @Default(false) bool isUpdatingVisibility,
    @Default(false) bool isDeleting,
    String? impactErrorMessage,
    String? deleteErrorMessage,
    AdminProductLifecycleEffect? effect,
    @Default(0) int effectId,
  }) = _AdminProductLifecycleState;

  bool get isMutating => isUpdatingVisibility || isDeleting;
}
