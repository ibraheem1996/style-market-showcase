import 'package:flutter_test/flutter_test.dart';
import 'package:my_project/core/errors/failure.dart';
import 'package:my_project/core/errors/failure_key.dart';

void main() {
  test(
    'only transport failures without an HTTP response permit clear retry',
    () {
      for (final key in [
        FailureKey.networkNoInternet,
        FailureKey.networkTimeout,
        FailureKey.serverUnavailable,
      ]) {
        expect(Failure.http(key: key).isTransportFailure, isTrue);
        expect(
          Failure.http(key: key, statusCode: 503).isTransportFailure,
          isFalse,
        );
      }
      expect(
        const Failure.http(key: FailureKey.invalidData).isTransportFailure,
        isFalse,
      );
      expect(
        const Failure.http(key: FailureKey.cancelled).isTransportFailure,
        isFalse,
      );
    },
  );
}
