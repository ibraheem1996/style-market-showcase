import 'package:freezed_annotation/freezed_annotation.dart';

import 'admin_product_enums.dart';

part 'admin_product_filters.freezed.dart';

@freezed
abstract class AdminProductFilters with _$AdminProductFilters {
  const factory AdminProductFilters({
    String? search,
    bool? active,
    bool? featured,
    AdminProductSellMode? sellMode,
    AdminProductStockState? stockState,
    @Default(AdminProductSort.newest) AdminProductSort sort,
  }) = _AdminProductFilters;
}
