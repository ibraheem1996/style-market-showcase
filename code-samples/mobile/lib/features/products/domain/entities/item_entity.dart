import 'package:freezed_annotation/freezed_annotation.dart';
part 'item_entity.freezed.dart';

@freezed
abstract class ItemEntity with _$ItemEntity {
  const factory ItemEntity({
    required int itemId,
    required int targetAudienceId,
    required String itemNameAr,
    required String itemNameEn,
    required String itemDescriptionAr,
    required String itemDescriptionEn,
    required double itemPrice,
    required int itemCat,
    required bool itemActive,
    required int itemStock,
    required List<String> itemImages,
    required List<VariantEntity> variants,
    DateTime? itemDatetime,
    double? itemDiscount,
    int? favId,
  }) = _ItemEntity;
  factory ItemEntity.empty() => ItemEntity(
    itemId: 0,
    targetAudienceId: 0,
    itemNameAr: "",
    itemNameEn: "",
    itemDescriptionAr: "",
    itemDescriptionEn: "",
    itemPrice: 0,
    itemCat: 0,
    itemActive: false,
    itemStock: 0,
    itemImages: [],
    variants: [],
    itemDatetime: DateTime.now(),
    itemDiscount: 0,
    favId: 0,
  );
}

@freezed
abstract class VariantEntity with _$VariantEntity {
  const factory VariantEntity({
    required int variantId,
    int? colorGroupId,
    double? variantPrice, // null = admin didn't set → inherits item_price
    double? variantDiscount, // null = admin didn't set → inherits item_discount
    double?
    effectivePrice, // resolved by backend (what customer pays before discount)
    double? effectiveDiscount, // resolved by backend (actual discount %)
    double? finalPrice, // resolved by backend (price after discount)
    required int variantStock,
    required List<String> variantImages,
    required bool variantActive,
    required String variantDescriptionAr,
    required String variantDescriptionEn,
    required String variantColor,
    required String variantColorEn,
    required String colorHex,
    required String colorDescriptionAr,
    required String colorDescriptionEn,
    required String variantSize,
    required String variantSizeEn,
  }) = _VariantEntity;
}
