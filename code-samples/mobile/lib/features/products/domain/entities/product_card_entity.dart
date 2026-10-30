import 'package:freezed_annotation/freezed_annotation.dart';
import 'product_badge_entity.dart';
part 'product_card_entity.freezed.dart';

@freezed
abstract class ProductCardEntity with _$ProductCardEntity {
  /// Backend-resolved product card shown in reusable catalog surfaces.
  ///
  /// The card may represent a simple item or a backend-resolved variant card.
  /// Simple recommendation items can omit the representative variant id.
  const factory ProductCardEntity({
    required int itemId,
    required String itemNameAr,
    required String itemNameEn,
    required double displayPrice,
    required double originalPrice,
    required bool hasDiscount,
    required int maxDiscountPct,
    required String itemDisplayImage,
    required List<ProductColorOption> availableColors,
    required List<ProductSizeOption> availableSizes,
    required bool isFeatured,
    int? representativeVariantId,
    int? colorGroupId,
    required List<String> images,
    int? stockQuantity,
    required List<ProductBadgeEntity> badges,
  }) = _ProductCardEntity;
}

@freezed
abstract class ProductColorOption with _$ProductColorOption {
  const factory ProductColorOption({
    required int valueId,
    required String hex,
    required String nameAr,
    required String nameEn,
  }) = _ProductColorOption;
}

@freezed
abstract class ProductSizeOption with _$ProductSizeOption {
  const factory ProductSizeOption({
    required int sizeValueId,
    required String nameAr,
    required String nameEn,
  }) = _ProductSizeOption;
}
