import 'package:freezed_annotation/freezed_annotation.dart';

part 'admin_orders_pagination.freezed.dart';

@freezed
abstract class AdminOrdersPagination with _$AdminOrdersPagination {
  const factory AdminOrdersPagination({
    required int page,
    required int pageSize,
    required int total,
    required int totalPages,
    required bool hasNext,
    required bool hasPrevious,
  }) = _AdminOrdersPagination;
}
