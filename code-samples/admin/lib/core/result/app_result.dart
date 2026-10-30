import 'package:freezed_annotation/freezed_annotation.dart';

import '../errors/app_failure.dart';

part 'app_result.freezed.dart';

@freezed
sealed class AppResult<T> with _$AppResult<T> {
  const factory AppResult.success(T data) = AppResultSuccess<T>;
  const factory AppResult.failure(AppFailure failure) = AppResultFailure;
}
