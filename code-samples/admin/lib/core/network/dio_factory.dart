import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../config/api_config.dart';
import '../logging/app_logger.dart';
import '../storage/token_storage.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/logging_interceptor.dart';
import 'interceptors/request_headers_interceptor.dart';

@lazySingleton
class DioFactory {
  const DioFactory(this._tokenStorage, this._logger);

  final TokenStorage _tokenStorage;
  final AppLogger _logger;

  Dio createAuthDio() {
    final dio = _createBaseDio();

    dio.interceptors.addAll([
      RequestHeadersInterceptor(),
      LoggingInterceptor(_logger),
    ]);

    return dio;
  }

  Dio createProtectedDio({
    required Future<bool> Function() refreshSession,
    Future<void> Function()? onSessionExpired,
    Future<void> Function()? onForbidden,
  }) {
    final dio = _createBaseDio();

    dio.interceptors.addAll([
      RequestHeadersInterceptor(),
      AuthInterceptor(
        dio: dio,
        tokenStorage: _tokenStorage,
        refreshSession: refreshSession,
        onSessionExpired: onSessionExpired,
        onForbidden: onForbidden,
      ),
      LoggingInterceptor(_logger),
    ]);

    return dio;
  }

  Dio _createBaseDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: const {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    return dio;
  }
}
