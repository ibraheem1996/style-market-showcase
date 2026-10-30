import '../../../../core/errors/failure.dart';
import '../../../../core/errors/failure_key.dart';

/// Identifies recommendation failures that may succeed on another request.
extension RecommendationFailureRetryability on Failure {
  bool get isRecommendationRetryable => when(
    http: (key, statusCode, _, _, _) => switch (key) {
      FailureKey.networkNoInternet ||
      FailureKey.networkTimeout ||
      FailureKey.tooManyRequests ||
      FailureKey.serverInternal ||
      FailureKey.serverUnavailable ||
      FailureKey.unexpected => true,
      FailureKey.serverGeneric =>
        statusCode != null && statusCode >= 500 && statusCode < 600,
      _ => false,
    },
    auth: (_) => false,
    app: (_) => false,
  );
}
