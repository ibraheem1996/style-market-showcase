// Package imports:
import 'package:json_annotation/json_annotation.dart';

part 'toggle_selection_request.g.dart';

@JsonSerializable()
class ToggleSelectionRequest {
  @JsonKey(name: 'cart_id')
  final int cartId;

  @JsonKey(name: 'is_selected')
  final int isSelected;

  ToggleSelectionRequest({required this.cartId, required this.isSelected});

  Map<String, dynamic> toJson() => _$ToggleSelectionRequestToJson(this);
  factory ToggleSelectionRequest.fromJson(Map<String, dynamic> json) =>
      _$ToggleSelectionRequestFromJson(json);
}
