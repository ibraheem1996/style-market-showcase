import 'package:json_annotation/json_annotation.dart';

import 'api_status.dart';

part 'api_response.g.dart';

@JsonSerializable(genericArgumentFactories: true)
class ApiResponse<T> {
  const ApiResponse({
    required this.status,
    this.message,
    this.data,
    this.errorCode,
    this.action,
  });

  final String? status;
  final String? message;
  final T? data;
  @JsonKey(name: 'error_code')
  final String? errorCode;
  final String? action;

  ApiStatus get parsedStatus => ApiStatus.parse(status);
  bool get isSuccess => parsedStatus.isSuccess;

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) => _$ApiResponseFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object? Function(T value) toJsonT) =>
      _$ApiResponseToJson(this, toJsonT);
}
