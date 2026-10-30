import 'package:freezed_annotation/freezed_annotation.dart';

part 'admin_products_pagination.freezed.dart';

@freezed
abstract class AdminProductsPagination with _$AdminProductsPagination {
  const factory AdminProductsPagination({
    required int page,
    required int pageSize,
    required int totalItems,
    required int totalPages,
    required bool hasNext,
    required bool hasPrevious,
  }) = _AdminProductsPagination;
}
