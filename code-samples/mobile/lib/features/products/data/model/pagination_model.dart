import 'package:json_annotation/json_annotation.dart';

part 'pagination_model.g.dart';

@JsonSerializable()
class PaginationModel {
  final int? page;
  final int? limit;
  final int? total;
  @JsonKey(name: 'has_more')
  final bool? hasMore;

  PaginationModel({this.page, this.limit, this.total, this.hasMore});

  factory PaginationModel.fromJson(Map<String, dynamic> json) =>
      _$PaginationModelFromJson(json);
  Map<String, dynamic> toJson() => _$PaginationModelToJson(this);
}
