// Dart imports:

// Package imports:
import 'package:json_annotation/json_annotation.dart';

part 'cart_item_model.g.dart';

@JsonSerializable()
class CartItemModel {
  @JsonKey(name: 'cart_id')
  final int? cartId;

  @JsonKey(name: 'user_id')
  final int? userId;

  @JsonKey(name: 'item_id')
  final int? itemId;

  @JsonKey(name: 'variant_id')
  final int? variantId;

  @JsonKey(name: 'cart_quantity')
  final int? cartQuantity;

  @JsonKey(name: 'added_at')
  final String? addedAt;

  @JsonKey(name: 'item_name')
  final String? itemName;

  @JsonKey(name: 'item_name_en')
  final String? itemNameEn;

  @JsonKey(name: 'item_description')
  final String? itemDescription;

  @JsonKey(name: 'item_description_en')
  final String? itemDescriptionEn;

  @JsonKey(name: 'price')
  final double? price;

  @JsonKey(name: 'base_price')
  final double? basePrice;

  @JsonKey(name: 'discount')
  final double? discount;

  @JsonKey(name: 'stock')
  final int? stock;

  @JsonKey(name: 'display_image')
  final String? displayImage;

  @JsonKey(name: 'images')
  final List<String>? images;

  @JsonKey(name: 'variant_color')
  final String? variantColor;

  @JsonKey(name: 'variant_color_en')
  final String? variantColorEn;

  @JsonKey(name: 'color_hex')
  final String? colorHex;

  @JsonKey(name: 'variant_size')
  final String? variantSize;

  @JsonKey(name: 'variant_size_en')
  final String? variantSizeEn;

  @JsonKey(name: 'variant_description')
  final String? variantDescription;

  @JsonKey(name: 'variant_description_en')
  final String? variantDescriptionEn;

  @JsonKey(name: 'line_total')
  final double? lineTotal;

  @JsonKey(name: 'is_available')
  final int? isAvailable;

  @JsonKey(name: 'is_selected')
  final int? isSelected;

  @JsonKey(name: 'status')
  final String? status;

  @JsonKey(name: 'requires_variant_selection')
  final bool? requiresVariantSelection;

  CartItemModel({
    this.cartId,
    this.userId,
    this.itemId,
    this.variantId,
    this.cartQuantity,
    this.addedAt,
    this.itemName,
    this.itemNameEn,
    this.itemDescription,
    this.itemDescriptionEn,
    this.price,
    this.basePrice,
    this.discount,
    this.stock,
    this.displayImage,
    this.images,
    this.variantColor,
    this.variantColorEn,
    this.colorHex,
    this.variantSize,
    this.variantSizeEn,
    this.variantDescription,
    this.variantDescriptionEn,
    this.lineTotal,
    this.isAvailable,
    this.isSelected,
    this.status,
    this.requiresVariantSelection,
  });

  Map<String, dynamic> toJson() => _$CartItemModelToJson(this);
  factory CartItemModel.fromJson(Map<String, dynamic> json) =>
      _$CartItemModelFromJson(json);
}
