import 'package:freezed_annotation/freezed_annotation.dart';

part 'validation_error.freezed.dart';
part 'validation_error.g.dart';

@freezed
sealed class ValidationError with _$ValidationError {
  const factory ValidationError({
    required String message,
    @Default(<String, List<String>>{}) Map<String, List<String>> fieldErrors,
  }) = _ValidationError;

  factory ValidationError.fromJson(Map<String, dynamic> json) =>
      _$ValidationErrorFromJson(json);
}
