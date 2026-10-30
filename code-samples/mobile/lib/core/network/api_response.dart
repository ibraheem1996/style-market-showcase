import 'package:json_annotation/json_annotation.dart';
import 'package:my_project/core/network/api_status.dart';

part 'api_response.g.dart';

@JsonSerializable(genericArgumentFactories: true)
class ApiResponse<T> {
  final String status;
  final T? data;
  final String? message;

  final String? action;
  @JsonKey(name: "error_code")
  final String? errorCode;

  const ApiResponse({
    required this.status,
    this.data,
    this.message,
    this.action,
    this.errorCode,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) => _$ApiResponseFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object? Function(T value) toJsonT) =>
      _$ApiResponseToJson(this, toJsonT);
}

extension ApiResponseExtension on ApiResponse<dynamic> {
  bool get isSuccess => parseApiStatus(status).isSuccess;
  bool get isOkAction => parseActionType(action).isOk;
}
