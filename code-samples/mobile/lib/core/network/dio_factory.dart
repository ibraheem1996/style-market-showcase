// Flutter imports:

// Package imports:
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

// Project imports:
import '../config/api_config.dart';
import '../config/app_config.dart';
import '../storage/token_storage.dart';
import '../services/crashlytics_service.dart';
import 'interceptors/app_interceptor.dart';
import 'interceptors/audience_interceptor.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/debug_network_log_interceptor.dart';

class DioFactory {
  DioFactory(
    this.tokenStorage, {
    required this.currentSessionRevision,
    required this.crash,
    this.onSessionExpired,
  });

  final TokenStorage tokenStorage;
  final CrashlyticsService crash;
  final int Function() currentSessionRevision;
  final Future<void> Function()? onSessionExpired;

  final _options = BaseOptions(
    baseUrl: ApiConfig.baseUrl,
    connectTimeout: AppConfig.connectTimeout,
    receiveTimeout: AppConfig.receiveTimeout,
    sendTimeout: AppConfig.sendTimeout,
    headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
  );

  Dio? _refreshDio;

  Dio createMain() {
    final dio = Dio(_options);

    if (kDebugMode) dio.interceptors.add(DebugNetworkLogInterceptor());

    dio.interceptors.add(AudienceInterceptor());
    dio.interceptors.add(
      AuthInterceptor(
        tokenStorage: tokenStorage,
        crash: crash,
        dio: dio,
        refreshDio: _getRefreshDio(),
        currentSessionRevision: currentSessionRevision,
        onSessionExpired: onSessionExpired,
      ),
    );
    dio.interceptors.add(AppInterceptor(crash: crash));

    return dio;
  }

  Dio _getRefreshDio() {
    _refreshDio ??= createRefresh();
    return _refreshDio!;
  }

  Dio createRefresh() {
    Dio dio = Dio(_options);

    if (kDebugMode) dio.interceptors.add(DebugNetworkLogInterceptor());

    dio.interceptors.add(AppInterceptor(reportErrors: false, crash: crash));
    return dio;
  }
}
