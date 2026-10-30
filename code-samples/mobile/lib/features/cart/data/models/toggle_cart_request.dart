// Package imports:
import 'package:json_annotation/json_annotation.dart';

part 'toggle_cart_request.g.dart';

@JsonSerializable()
class ToggleCartRequest {
  @JsonKey(name: 'item_id')
  final int itemId;

  @JsonKey(name: 'variant_id')
  final int? variantId;

  @JsonKey(name: 'quantity')
  final int quantity;

  ToggleCartRequest({
    required this.itemId,
    this.variantId,
    required this.quantity,
  });

  Map<String, dynamic> toJson() => _$ToggleCartRequestToJson(this);
  factory ToggleCartRequest.fromJson(Map<String, dynamic> json) =>
      _$ToggleCartRequestFromJson(json);
}
