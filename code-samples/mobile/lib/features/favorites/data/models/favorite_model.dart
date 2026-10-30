import 'package:json_annotation/json_annotation.dart';

part 'favorite_model.g.dart';

@JsonSerializable()
class FavoriteModel {
  @JsonKey(name: 'fav_id')
  final int? favId;

  @JsonKey(name: 'item_id')
  final int? itemId;

  @JsonKey(name: 'variant_id')
  final int? variantId;

  @JsonKey(name: 'target_type')
  final String? targetType;

  @JsonKey(name: 'item_name')
  final String? itemNameAr;

  @JsonKey(name: 'item_name_en')
  final String? itemNameEn;

  @JsonKey(name: 'item_description')
  final String? itemDescriptionAr;

  @JsonKey(name: 'item_description_en')
  final String? itemDescriptionEn;

  @JsonKey(name: 'display_image')
  final String? displayImage;

  @JsonKey(name: 'images')
  final List<String>? images;

  @JsonKey(name: 'display_price')
  final double? displayPrice;

  @JsonKey(name: 'original_price')
  final double? originalPrice;

  @JsonKey(name: 'discount')
  final double? discount;

  @JsonKey(name: 'stock_quantity')
  final int? stockQuantity;

  @JsonKey(name: 'is_available')
  final Object? isAvailable;

  @JsonKey(name: 'status')
  final String? status;

  @JsonKey(name: 'selected_attributes')
  final List<SelectedAttributeModel>? selectedAttributes;

  @JsonKey(name: 'price_alert')
  final PriceAlertModel? priceAlert;

  @JsonKey(name: 'created_at')
  final String? createdAt;

  const FavoriteModel({
    this.favId,
    this.itemId,
    this.variantId,
    this.targetType,
    this.itemNameAr,
    this.itemNameEn,
    this.itemDescriptionAr,
    this.itemDescriptionEn,
    this.displayImage,
    this.images,
    this.displayPrice,
    this.originalPrice,
    this.discount,
    this.stockQuantity,
    this.isAvailable,
    this.status,
    this.selectedAttributes,
    this.priceAlert,
    this.createdAt,
  });

  factory FavoriteModel.fromJson(Map<String, dynamic> json) =>
      _$FavoriteModelFromJson(json);

  Map<String, dynamic> toJson() => _$FavoriteModelToJson(this);
}

@JsonSerializable()
class SelectedAttributeModel {
  @JsonKey(name: 'attribute_type_id')
  final int? attributeTypeId;

  @JsonKey(name: 'attribute_type_key')
  final String? attributeTypeKey;

  @JsonKey(name: 'attribute_type_name')
  final String? attributeTypeNameAr;

  @JsonKey(name: 'attribute_type_name_en')
  final String? attributeTypeNameEn;

  @JsonKey(name: 'value_id')
  final int? valueId;

  @JsonKey(name: 'value_name')
  final String? valueNameAr;

  @JsonKey(name: 'value_name_en')
  final String? valueNameEn;

  @JsonKey(name: 'value_hex')
  final String? valueHex;

  const SelectedAttributeModel({
    this.attributeTypeId,
    this.attributeTypeKey,
    this.attributeTypeNameAr,
    this.attributeTypeNameEn,
    this.valueId,
    this.valueNameAr,
    this.valueNameEn,
    this.valueHex,
  });

  factory SelectedAttributeModel.fromJson(Map<String, dynamic> json) =>
      _$SelectedAttributeModelFromJson(json);

  Map<String, dynamic> toJson() => _$SelectedAttributeModelToJson(this);
}

@JsonSerializable()
class PriceAlertModel {
  @JsonKey(name: 'type')
  final String? type;

  @JsonKey(name: 'old_price')
  final double? oldPrice;

  @JsonKey(name: 'new_price')
  final double? newPrice;

  @JsonKey(name: 'amount')
  final double? amount;

  @JsonKey(name: 'percent')
  final double? percent;

  const PriceAlertModel({
    this.type,
    this.oldPrice,
    this.newPrice,
    this.amount,
    this.percent,
  });

  factory PriceAlertModel.fromJson(Map<String, dynamic> json) =>
      _$PriceAlertModelFromJson(json);

  Map<String, dynamic> toJson() => _$PriceAlertModelToJson(this);
}
