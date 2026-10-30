// Package imports:
import 'package:json_annotation/json_annotation.dart';

part 'response_token_model.g.dart';

@JsonSerializable()
class TokenResponse {
  final String? status;
  final String? message;
  @JsonKey(name: 'data')
  final TokenData? data;

  TokenResponse({this.status, this.message, this.data});

  factory TokenResponse.fromJson(Map<String, dynamic> json) =>
      _$TokenResponseFromJson(json);
  Map<String, dynamic> toJson() => _$TokenResponseToJson(this);
}

@JsonSerializable()
class TokenData {
  @JsonKey(name: 'access_token')
  final String accessToken;
  @JsonKey(name: 'refresh_token')
  final String refreshToken;
  TokenData({required this.accessToken, required this.refreshToken});
  factory TokenData.fromJson(Map<String, dynamic> json) =>
      _$TokenDataFromJson(json);
  Map<String, dynamic> toJson() => _$TokenDataToJson(this);
}
