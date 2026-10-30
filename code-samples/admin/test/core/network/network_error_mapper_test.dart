import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:multi_product_store_admin_web/core/errors/app_failure.dart';
import 'package:multi_product_store_admin_web/core/errors/backend_error_code.dart';
import 'package:multi_product_store_admin_web/core/network/network_error_mapper.dart';

void main() {
  group('NetworkErrorMapper', () {
    const mapper = NetworkErrorMapper();

    test('maps connection timeout to timeout failure', () {
      final failure = mapper.map(
        DioException(
          requestOptions: RequestOptions(path: '/test'),
          type: DioExceptionType.connectionTimeout,
          message: 'timeout',
        ),
      );

      expect(failure, isA<TimeoutFailure>());
    });

    test('maps backend detail object response', () {
      final failure = mapper.mapResponse(
        statusCode: 401,
        data: {
          'detail': {
            'status': 'error',
            'message': 'انتهت الجلسة',
            'error_code': 'INVALID_CREDENTIALS',
          },
        },
      );

      expect(failure, isA<UnauthorizedFailure>());
      expect((failure as UnauthorizedFailure).message, 'انتهت الجلسة');
      expect(failure.errorCode, BackendErrorCode.invalidCredentials);
    });

    test('maps validation field errors', () {
      final failure = mapper.mapResponse(
        statusCode: 422,
        data: {
          'status': 'failure',
          'message': 'بيانات غير صالحة',
          'field_errors': {
            'email': ['مطلوب'],
          },
        },
      );

      expect(failure, isA<ValidationFailure>());
      final validationFailure = failure as ValidationFailure;
      expect(validationFailure.validation?.fieldErrors['email'], ['مطلوب']);
    });

    test('maps TOKEN_EXPIRED top-level admin response', () {
      final failure = mapper.mapResponse(
        statusCode: 401,
        data: {
          'status': 'error',
          'message': 'Token expired',
          'error_code': 'TOKEN_EXPIRED',
          'data': null,
        },
      );

      expect(failure, isA<UnauthorizedFailure>());
      expect(failure.errorCode, BackendErrorCode.tokenExpired);
    });

    test('maps ADMIN_FORBIDDEN to forbidden failure', () {
      final failure = mapper.mapResponse(
        statusCode: 403,
        data: {
          'status': 'error',
          'message': 'Forbidden',
          'error_code': 'ADMIN_FORBIDDEN',
        },
      );

      expect(failure, isA<ForbiddenFailure>());
      expect(failure.errorCode, BackendErrorCode.adminForbidden);
    });

    test('maps validation response without data field', () {
      final failure = mapper.mapResponse(
        statusCode: 422,
        data: {
          'status': 'error',
          'message': 'Validation error. Please check your input.',
          'error_code': 'VALIDATION_ERROR',
        },
      );

      expect(failure, isA<ValidationFailure>());
      expect(failure.errorCode, BackendErrorCode.validationError);
    });
  });
}
