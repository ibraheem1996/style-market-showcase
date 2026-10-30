import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_project/core/network/interceptors/app_interceptor.dart';
import 'package:my_project/core/services/analytics_service.dart';
import 'package:my_project/core/services/crashlytics_service.dart';
import 'package:my_project/core/services/performance_service.dart';

void main() {
  test('records only actionable HTTP responses once', () async {
    final cases = <({int status, String? code, bool report})>[
      (status: 409, code: 'CART_MAX_QTY', report: false),
      (status: 409, code: 'PRICE_CHANGED', report: false),
      (status: 422, code: 'OTP_INVALID', report: false),
      (status: 401, code: null, report: false),
      (status: 429, code: null, report: false),
      (status: 0, code: null, report: false),
      (status: 418, code: 'UNKNOWN_CODE', report: true),
      (status: 500, code: 'INTERNAL_SERVER_ERROR', report: true),
    ];
    for (final testCase in cases) {
      final crash = _RecordingCrash();
      final dio = Dio(BaseOptions(baseUrl: 'https://example.test'));
      dio.httpClientAdapter = _StatusAdapter(testCase.status, testCase.code);
      dio.interceptors.add(
        AppInterceptor(
          crash: crash,
          analytics: _NoopAnalytics(),
          performance: _NoopPerformance(),
        ),
      );

      await expectLater(
        dio.get('/cart/toggle?token=secret'),
        throwsA(isA<DioException>()),
      );
      expect(crash.errors.length, testCase.report ? 1 : 0);
      if (testCase.report) {
        expect(crash.reasons.single, contains('/cart/toggle'));
        expect(crash.reasons.single, isNot(contains('secret')));
      }
    }
  });
}

class _StatusAdapter implements HttpClientAdapter {
  _StatusAdapter(this.status, this.code);
  final int status;
  final String? code;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (status == 0) {
      throw DioException(
        requestOptions: options,
        type: DioExceptionType.connectionError,
      );
    }
    return ResponseBody.fromString(
      jsonEncode({'status': 'error', if (code != null) 'error_code': code}),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

class _RecordingCrash implements CrashlyticsService {
  final errors = <Object>[];
  final reasons = <String?>[];

  @override
  Future<void> logError(
    dynamic error,
    StackTrace? stackTrace, {
    String? reason,
  }) async {
    errors.add(error);
    reasons.add(reason);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _NoopAnalytics implements AnalyticsService {
  @override
  Future<void> logApiRequest(String method, String endpoint) async {}
  @override
  Future<void> logApiResponse(String endpoint, int statusCode) async {}
  @override
  Future<void> logApiError(String endpoint, String error) async {}
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _NoopPerformance implements PerformanceService {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
