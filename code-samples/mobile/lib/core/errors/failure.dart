// Package imports:
import 'package:freezed_annotation/freezed_annotation.dart';

// Project imports:
import 'app_failure_key.dart';
import 'auth_error_key.dart';
import 'failure_key.dart';

part 'failure.freezed.dart';

@freezed
sealed class Failure with _$Failure {
  const Failure._();

  const factory Failure.http({
    required FailureKey key,
    int? statusCode,
    String? rawServerMessage,
    Map<String, dynamic>? data,
    String? errorCode,
  }) = HttpFailure;

  const factory Failure.auth({required AuthErrorKey key}) = AuthFailure;
  const factory Failure.app({required AppFailureKey key}) = AppFailure;
}

extension FailureTransport on Failure {
  bool get isTransportFailure => maybeWhen(
    http: (key, statusCode, _, __, ___) =>
        statusCode == null &&
        (key == FailureKey.networkNoInternet ||
            key == FailureKey.networkTimeout ||
            key == FailureKey.serverUnavailable),
    orElse: () => false,
  );
}
