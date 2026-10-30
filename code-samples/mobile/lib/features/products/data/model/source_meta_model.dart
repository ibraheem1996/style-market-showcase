import 'package:json_annotation/json_annotation.dart';

part 'source_meta_model.g.dart';

@JsonSerializable()
class SourceMetaModel {
  @JsonKey(name: 'name_ar')
  final String? nameAr;
  @JsonKey(name: 'name_en')
  final String? nameEn;
  @JsonKey(name: 'source_type')
  final String? sourceType;
  @JsonKey(name: 'source_id')
  final String? sourceId;

  SourceMetaModel({this.nameAr, this.nameEn, this.sourceType, this.sourceId});

  factory SourceMetaModel.fromJson(Map<String, dynamic> json) =>
      _$SourceMetaModelFromJson(json);
  Map<String, dynamic> toJson() => _$SourceMetaModelToJson(this);
}
