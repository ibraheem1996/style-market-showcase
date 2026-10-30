import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/admin_order_entities.dart';
import 'admin_order_effect.dart';

part 'admin_order_detail_state.freezed.dart';

@freezed
abstract class AdminOrderDetailState with _$AdminOrderDetailState {
  const factory AdminOrderDetailState({
    AdminOrderDetailEntity? order,
    @Default(false) bool isLoading,
    @Default(false) bool isSubmitting,
    String? errorMessage,
    AdminOrderEffect? effect,
    @Default(0) int effectId,
  }) = _AdminOrderDetailState;
}
