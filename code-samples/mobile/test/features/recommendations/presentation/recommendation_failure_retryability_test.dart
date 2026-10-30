import 'package:flutter_test/flutter_test.dart';
import 'package:my_project/core/errors/app_failure_key.dart';
import 'package:my_project/core/errors/auth_error_key.dart';
import 'package:my_project/core/errors/failure.dart';
import 'package:my_project/core/errors/failure_key.dart';
import 'package:my_project/features/recommendations/presentation/extensions/recommendation_failure_retryability.dart';

void main() {
  test('retries transient recommendation failures only', () {
    const retryable = <Failure>[
      Failure.http(key: FailureKey.networkNoInternet),
      Failure.http(key: FailureKey.networkTimeout),
      Failure.http(key: FailureKey.tooManyRequests, statusCode: 429),
      Failure.http(key: FailureKey.serverUnavailable, statusCode: 503),
    ];

    const permanent = <Failure>[
      Failure.http(key: FailureKey.unauthorized, statusCode: 401),
      Failure.http(key: FailureKey.validation, statusCode: 422),
      Failure.auth(key: AuthErrorKey.invalidToken),
      Failure.app(key: AppFailureKey.invalidArgument),
    ];

    expect(
      retryable.every((failure) => failure.isRecommendationRetryable),
      isTrue,
    );
    expect(
      permanent.every((failure) => !failure.isRecommendationRetryable),
      isTrue,
    );
  });
}
