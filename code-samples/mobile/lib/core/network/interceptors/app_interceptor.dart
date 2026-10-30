// Package imports:
import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_performance/firebase_performance.dart';

// Project imports:
import '../../errors/backend_error_code_resolver.dart';
import '../../services/analytics_service.dart';
import '../../services/crashlytics_service.dart';
import '../../services/performance_service.dart';

class AppInterceptor extends Interceptor {
  AppInterceptor({
    this.reportErrors = true,
    CrashlyticsService? crash,
    AnalyticsService? analytics,
    PerformanceService? performance,
  }) : _crash = crash ?? CrashlyticsService(),
       _analytics = analytics ?? AnalyticsService(),
       _perf = performance ?? PerformanceService();

  final bool reportErrors;
  static const _errorReportedKey = 'app_interceptor_error_reported';
  final AnalyticsService _analytics;
  final CrashlyticsService _crash;
  final PerformanceService _perf;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final metric = _tryTelemetry(
      () => _perf.createHttpMetric(
        options.uri.replace(query: '').toString(),
        _methodFromString(options.method),
      ),
    );
    if (metric != null) {
      options.extra['metric'] = metric;
      _runTelemetry(metric.start);
    }

    _runTelemetry(
      () => _analytics.logApiRequest(options.method, _safePath(options)),
    );
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    final metric = response.requestOptions.extra['metric'] as HttpMetric?;
    if (metric != null) {
      _tryTelemetry(() => metric.httpResponseCode = response.statusCode);
      _runTelemetry(metric.stop);
    }

    _runTelemetry(
      () => _analytics.logApiResponse(
        _safePath(response.requestOptions),
        response.statusCode ?? 0,
      ),
    );

    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final metric = err.requestOptions.extra['metric'] as HttpMetric?;
    if (metric != null) {
      _tryTelemetry(() => metric.httpResponseCode = err.response?.statusCode);
      _runTelemetry(metric.stop);
    }

    if (reportErrors &&
        !_isExpectedError(err) &&
        err.requestOptions.extra[_errorReportedKey] != true) {
      err.requestOptions.extra[_errorReportedKey] = true;
      _runTelemetry(
        () => _crash.logError(
          err,
          err.stackTrace,
          reason: "API Error: ${_safePath(err.requestOptions)}",
        ),
      );
    }
    _runTelemetry(
      () => _analytics.logApiError(
        _safePath(err.requestOptions),
        '${err.type.name}:${err.response?.statusCode ?? 'no_status'}',
      ),
    );

    super.onError(err, handler);
  }

  HttpMethod _methodFromString(String method) {
    switch (method.toUpperCase()) {
      case 'POST':
        return HttpMethod.Post;
      case 'PUT':
        return HttpMethod.Put;
      case 'DELETE':
        return HttpMethod.Delete;
      default:
        return HttpMethod.Get;
    }
  }

  String _safePath(RequestOptions options) => Uri.parse(options.path).path;

  bool _isExpectedError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.connectionError:
      case DioExceptionType.cancel:
        return true;
      case DioExceptionType.unknown:
        return error.error is SocketException;
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final extra = error.requestOptions.extra;
        if (statusCode != null && statusCode >= 500) return false;
        final data = error.response?.data;
        final code = data is Map ? data['error_code'] : null;
        // These codes describe server or catalog defects even on a 4xx response.
        if (code == 'INTERNAL_SERVER_ERROR' ||
            code == 'PRODUCT_VARIANT_CONFIGURATION_INVALID' ||
            code == 'EMAIL_DELIVERY_FAILED') {
          return false;
        }
        if (code is String &&
            (BackendErrorCodeResolver.httpFailureKeyOf(code) != null ||
                BackendErrorCodeResolver.authFailureKeyOf(code) != null)) {
          return true;
        }
        if (statusCode == 401 || statusCode == 429) return true;

        if (extra['skipAuth'] == true) {
          return statusCode == 401 ||
              statusCode == 403 ||
              statusCode == 409 ||
              statusCode == 410 ||
              statusCode == 422 ||
              statusCode == 429;
        }
        return false;
      default:
        return false;
    }
  }

  T? _tryTelemetry<T>(T Function() action) {
    try {
      return action();
    } catch (_) {
      return null;
    }
  }

  void _runTelemetry(Future<void> Function() action) {
    try {
      unawaited(action().catchError((_) {}));
    } catch (_) {
      // Telemetry is best-effort and must not affect Dio handlers.
    }
  }
}
