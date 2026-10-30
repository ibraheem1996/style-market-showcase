import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_project/core/errors/auth_error_key.dart';
import 'package:my_project/core/errors/backend_error_code_resolver.dart';
import 'package:my_project/core/errors/error_handler.dart';
import 'package:my_project/core/errors/failure.dart';
import 'package:my_project/core/errors/failure_key.dart';

void main() {
  group('BackendErrorCodeResolver', () {
    test('maps critical checkout and address codes to user-safe failures', () {
      expect(
        BackendErrorCodeResolver.httpFailureKeyOf('INVALID_CHECKOUT_DATA'),
        FailureKey.invalidCheckoutData,
      );
      expect(
        BackendErrorCodeResolver.httpFailureKeyOf('ADDRESS_NOT_FOUND'),
        FailureKey.addressNotFound,
      );
      expect(
        BackendErrorCodeResolver.httpFailureKeyOf('PRICE_CHANGED'),
        FailureKey.priceChanged,
      );
      expect(
        BackendErrorCodeResolver.httpFailureKeyOf('CHECKOUT_OUT_OF_STOCK'),
        FailureKey.checkoutOutOfStock,
      );
      expect(
        BackendErrorCodeResolver.httpFailureKeyOf('PHONE_NOT_VERIFIED'),
        FailureKey.phoneNotVerified,
      );
    });

    test('maps critical auth codes to auth failures', () {
      expect(
        BackendErrorCodeResolver.authFailureKeyOf('INVALID_CREDENTIALS'),
        AuthErrorKey.invalidCredentials,
      );
      expect(
        BackendErrorCodeResolver.authFailureKeyOf('ACCOUNT_NOT_VERIFIED'),
        AuthErrorKey.accountNotVerified,
      );
      expect(
        BackendErrorCodeResolver.authFailureKeyOf('INVALID_TOKEN'),
        AuthErrorKey.invalidToken,
      );
      expect(
        BackendErrorCodeResolver.authFailureKeyOf(
          'INVALID_TOKEN',
          isGoogleAuth: true,
        ),
        AuthErrorKey.googleVerificationFailed,
      );
      expect(
        BackendErrorCodeResolver.authFailureKeyOf('CODE_ATTEMPTS_EXHAUSTED'),
        AuthErrorKey.codeAttemptsExhausted,
      );
      expect(
        BackendErrorCodeResolver.authFailureKeyOf('CODE_RESEND_COOLDOWN'),
        AuthErrorKey.codeResendCooldown,
      );
      expect(
        BackendErrorCodeResolver.authFailureKeyOf('EMAIL_DELIVERY_FAILED'),
        AuthErrorKey.emailDeliveryFailed,
      );
      expect(
        BackendErrorCodeResolver.authFailureKeyOf('REFRESH_TOKEN_REPLACED'),
        AuthErrorKey.invalidToken,
      );
    });
  });

  group('ErrorHandler network classification', () {
    test('connection timeout is not classified as unexpected', () {
      final failure = ErrorHandler.handle(
        DioException(
          requestOptions: RequestOptions(path: '/items'),
          type: DioExceptionType.connectionTimeout,
        ),
      );

      expect(_httpKey(failure), FailureKey.networkTimeout);
    });

    test('connectionError with DNS/socket failure maps to no internet', () {
      final failure = ErrorHandler.handle(
        DioException(
          requestOptions: RequestOptions(path: '/items'),
          type: DioExceptionType.connectionError,
          error: const SocketException('Failed host lookup'),
        ),
      );

      expect(_httpKey(failure), FailureKey.networkNoInternet);
    });

    test('connectionError with refused socket maps to server unavailable', () {
      final failure = ErrorHandler.handle(
        DioException(
          requestOptions: RequestOptions(path: '/items'),
          type: DioExceptionType.connectionError,
          error: const SocketException('Connection refused'),
        ),
      );

      expect(_httpKey(failure), FailureKey.serverUnavailable);
    });

    test('unknown backend code falls back without exposing raw code', () {
      final failure = ErrorHandler.handle(
        DioException(
          requestOptions: RequestOptions(path: '/orders'),
          type: DioExceptionType.badResponse,
          response: Response<Map<String, dynamic>>(
            requestOptions: RequestOptions(path: '/orders'),
            statusCode: 400,
            data: const {
              'status': 'error',
              'error_code': 'FUTURE_BACKEND_CODE',
              'message': 'technical details',
            },
          ),
        ),
      );

      failure.when(
        http: (key, _, rawServerMessage, __, errorCode) {
          expect(key, FailureKey.badRequest);
          expect(rawServerMessage, 'technical details');
          expect(errorCode, 'FUTURE_BACKEND_CODE');
        },
        auth: (_) => fail('Expected HTTP failure'),
        app: (_) => fail('Expected HTTP failure'),
      );
    });
  });
}

FailureKey _httpKey(Failure failure) {
  return failure.when(
    http: (key, _, __, ___, ____) => key,
    auth: (_) => fail('Expected HTTP failure'),
    app: (_) => fail('Expected HTTP failure'),
  );
}
