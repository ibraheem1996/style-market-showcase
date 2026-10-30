import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/admin_order_entities.dart';
import '../../domain/entities/admin_order_filters.dart';
import '../../domain/entities/admin_orders_pagination.dart';
import 'admin_order_effect.dart';

part 'admin_orders_state.freezed.dart';

@freezed
abstract class AdminOrdersState with _$AdminOrdersState {
  const factory AdminOrdersState({
    @Default(AdminOrderFilters()) AdminOrderFilters filters,
    @Default(1) int page,
    @Default(20) int pageSize,
    @Default(<AdminOrderSummaryEntity>[]) List<AdminOrderSummaryEntity> orders,
    AdminOrdersPagination? pagination,
    @Default(false) bool isLoading,
    @Default(false) bool isRefreshing,
    @Default(false) bool isActionSubmitting,
    String? errorMessage,
    AdminOrderEffect? effect,
    @Default(0) int effectId,
  }) = _AdminOrdersState;
}
