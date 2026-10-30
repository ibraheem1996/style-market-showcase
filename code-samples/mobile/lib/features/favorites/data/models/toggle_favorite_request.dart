// Package imports:
import 'package:json_annotation/json_annotation.dart';

part 'toggle_favorite_request.g.dart';

//! Request model for toggling favorite
@JsonSerializable()
class ToggleFavoriteRequest {
  @JsonKey(name: 'item_id')
  final int itemId;

  @JsonKey(name: 'variant_id')
  final int? variantId;

  const ToggleFavoriteRequest({required this.itemId, this.variantId});

  factory ToggleFavoriteRequest.fromJson(Map<String, dynamic> json) =>
      _$ToggleFavoriteRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ToggleFavoriteRequestToJson(this);
}
