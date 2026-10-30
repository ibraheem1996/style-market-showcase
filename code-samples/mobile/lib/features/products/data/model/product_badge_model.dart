import 'package:json_annotation/json_annotation.dart';

part 'product_badge_model.g.dart';

@JsonSerializable()
class ProductBadgeModel {
  @JsonKey(name: 'type')
  final String? type;
  @JsonKey(name: 'label_ar')
  final String? labelAr;
  @JsonKey(name: 'label_en')
  final String? labelEn;

  ProductBadgeModel({this.type, this.labelAr, this.labelEn});

  factory ProductBadgeModel.fromJson(Map<String, dynamic> json) =>
      _$ProductBadgeModelFromJson(json);
  Map<String, dynamic> toJson() => _$ProductBadgeModelToJson(this);
}
