import 'package:json_annotation/json_annotation.dart';

part 'recommendations_pagination_model.g.dart';

@JsonSerializable()
class RecommendationsPaginationModel {
  final int? page;
  final int? limit;
  @JsonKey(name: 'has_more')
  final bool? hasMore;

  const RecommendationsPaginationModel({this.page, this.limit, this.hasMore});

  factory RecommendationsPaginationModel.fromJson(Map<String, dynamic> json) =>
      _$RecommendationsPaginationModelFromJson(json);
  Map<String, dynamic> toJson() => _$RecommendationsPaginationModelToJson(this);
}
