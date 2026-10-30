import 'package:freezed_annotation/freezed_annotation.dart';

import 'admin_order_enums.dart';

part 'admin_order_filters.freezed.dart';

@freezed
abstract class AdminOrderFilters with _$AdminOrderFilters {
  const factory AdminOrderFilters({
    AdminOrderStatus? status,
    AdminPaymentMethod? paymentMethod,
    AdminPaymentStatus? paymentStatus,
    DateTime? dateFrom,
    DateTime? dateTo,
    String? search,
    @Default(AdminOrderSort.newest) AdminOrderSort sort,
  }) = _AdminOrderFilters;
}
