import 'package:json_annotation/json_annotation.dart';

part 'product_catalog_shared_models.g.dart';

@JsonSerializable()
class ProductColorOptionModel {
  @JsonKey(name: 'value_id')
  final int? valueId;
  @JsonKey(name: 'name_ar')
  final String? nameAr;
  @JsonKey(name: 'name_en')
  final String? nameEn;
  final String? hex;

  ProductColorOptionModel({this.valueId, this.nameAr, this.nameEn, this.hex});

  factory ProductColorOptionModel.fromJson(Map<String, dynamic> json) =>
      _$ProductColorOptionModelFromJson(json);
  Map<String, dynamic> toJson() => _$ProductColorOptionModelToJson(this);
}

@JsonSerializable()
class ProductSizeOptionModel {
  @JsonKey(name: 'size_value_id')
  final int? sizeValueId;
  @JsonKey(name: 'name_ar')
  final String? nameAr;
  @JsonKey(name: 'name_en')
  final String? nameEn;

  ProductSizeOptionModel({this.sizeValueId, this.nameAr, this.nameEn});

  factory ProductSizeOptionModel.fromJson(Map<String, dynamic> json) =>
      _$ProductSizeOptionModelFromJson(json);
  Map<String, dynamic> toJson() => _$ProductSizeOptionModelToJson(this);
}
