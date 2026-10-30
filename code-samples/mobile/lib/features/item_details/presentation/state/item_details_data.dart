import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../products/domain/entities/item_entity.dart';

part 'item_details_data.freezed.dart';

@freezed
abstract class ItemDetailsData with _$ItemDetailsData {
  const factory ItemDetailsData({
    @Default(0) int pageIndex,
    @Default(0) int quantity,

    VariantEntity? selectedVariant,

    @Default(<String>[]) List<String> images,

    @Default("") String selectedColorCode,
    @Default("") String selectedColorLabel,
    @Default("") String selectedSize,

    @Default(0.0) double price,
  }) = _ItemDetailsState;
}
