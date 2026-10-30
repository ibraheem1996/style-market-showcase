import 'package:json_annotation/json_annotation.dart';
import 'product_badge_model.dart';
import 'product_catalog_shared_models.dart';

part 'product_card_model.g.dart';

@JsonSerializable()
class ProductCardModel {
  @JsonKey(name: 'item_id')
  final int? itemId;
  @JsonKey(name: 'item_name_ar')
  final String? itemNameAr;
  @JsonKey(name: 'item_name_en')
  final String? itemNameEn;
  @JsonKey(name: 'display_price')
  final double? displayPrice;
  @JsonKey(name: 'original_price')
  final double? originalPrice;
  @JsonKey(name: 'has_discount')
  final bool? hasDiscount;
  @JsonKey(name: 'max_discount_pct')
  final int? maxDiscountPct;
  @JsonKey(name: 'item_display_image')
  final String? itemDisplayImage;
  @JsonKey(name: 'available_colors')
  final List<ProductColorOptionModel>? availableColors;
  @JsonKey(name: 'available_sizes')
  final List<ProductSizeOptionModel>? availableSizes;
  @JsonKey(name: 'is_featured')
  final bool? isFeatured;
  @JsonKey(name: 'representative_variant_id')
  final int? representativeVariantId;
  @JsonKey(name: 'color_group_id')
  final int? colorGroupId;
  @JsonKey(name: 'images')
  final List<String>? images;
  @JsonKey(name: 'stock_quantity')
  final int? stockQuantity;
  @JsonKey(name: 'badges')
  final List<ProductBadgeModel>? badges;

  ProductCardModel({
    this.itemId,
    this.itemNameAr,
    this.itemNameEn,
    this.displayPrice,
    this.originalPrice,
    this.hasDiscount,
    this.maxDiscountPct,
    this.itemDisplayImage,
    this.availableColors,
    this.availableSizes,
    this.isFeatured,
    this.representativeVariantId,
    this.colorGroupId,
    this.images,
    this.stockQuantity,
    this.badges,
  });

  factory ProductCardModel.fromJson(Map<String, dynamic> json) =>
      _$ProductCardModelFromJson(json);
  Map<String, dynamic> toJson() => _$ProductCardModelToJson(this);
}
