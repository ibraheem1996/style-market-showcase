import 'package:dio/dio.dart';

import '../../errors/backend_error_code.dart';
import '../../storage/token_storage.dart';

/// Adds admin bearer tokens and performs one coordinated refresh for expired access tokens.
///
/// Auth endpoints are excluded so signin, refresh, and logout never trigger a
/// recursive refresh loop.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required Dio dio,
    required TokenStorage tokenStorage,
    required Future<bool> Function() refreshSession,
    Future<void> Function()? onSessionExpired,
    Future<void> Function()? onForbidden,
  }) : _tokenStorage = tokenStorage,
       _dio = dio,
       _refreshSession = refreshSession,
       _onSessionExpired = onSessionExpired,
       _onForbidden = onForbidden;

  static const authRetryAttemptedKey = 'authRetryAttempted';
  static const skipAuthKey = 'skipAuth';
  static const skipAuthRefreshKey = 'skipAuthRefresh';

  final Dio _dio;
  final TokenStorage _tokenStorage;
  final Future<bool> Function() _refreshSession;
  final Future<void> Function()? _onSessionExpired;
  final Future<void> Function()? _onForbidden;
  Future<bool>? _refreshFuture;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (_shouldSkipAuth(options)) {
      handler.next(options);
      return;
    }

    final token = await _tokenStorage.readAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final requestOptions = err.requestOptions;
    final errorCode = BackendErrorCode.fromValue(_extractErrorCode(err));

    if (errorCode == BackendErrorCode.adminForbidden) {
      await _tokenStorage.clearTokens();
      await _onForbidden?.call();
      handler.next(err);
      return;
    }

    if (!_canRefresh(err, errorCode)) {
      if (_shouldClearSession(errorCode)) {
        await _tokenStorage.clearTokens();
        await _onSessionExpired?.call();
      }
      handler.next(err);
      return;
    }

    final refreshed = await _refreshOnce();
    if (!refreshed) {
      await _tokenStorage.clearTokens();
      await _onSessionExpired?.call();
      handler.next(err);
      return;
    }

    final accessToken = await _tokenStorage.readAccessToken();
    if (accessToken == null || accessToken.isEmpty) {
      await _tokenStorage.clearTokens();
      await _onSessionExpired?.call();
      handler.next(err);
      return;
    }

    try {
      final response = await _dio.fetch<Object?>(
        _retryOptions(requestOptions, accessToken),
      );
      handler.resolve(response);
    } catch (_) {
      handler.next(err);
    }
  }

  bool _shouldSkipAuth(RequestOptions options) {
    return options.extra[skipAuthKey] == true || _isAuthEndpoint(options.path);
  }

  bool _isAuthEndpoint(String path) {
    final normalizedPath = Uri.tryParse(path)?.path ?? path;

    return normalizedPath == '/admin/auth/signin' ||
        normalizedPath == '/admin/auth/refresh' ||
        normalizedPath == '/admin/auth/logout';
  }

  bool _canRefresh(DioException err, BackendErrorCode? errorCode) {
    return err.response?.statusCode == 401 &&
        errorCode == BackendErrorCode.tokenExpired &&
        !_isAuthEndpoint(err.requestOptions.path) &&
        err.requestOptions.extra[authRetryAttemptedKey] != true &&
        err.requestOptions.extra[skipAuthRefreshKey] != true;
  }

  bool _shouldClearSession(BackendErrorCode? errorCode) {
    return errorCode == BackendErrorCode.tokenInvalid ||
        errorCode == BackendErrorCode.tokenMissing ||
        errorCode == BackendErrorCode.sessionExpired ||
        errorCode == BackendErrorCode.adminSessionRevoked ||
        errorCode == BackendErrorCode.refreshTokenInvalid;
  }

  Future<bool> _refreshOnce() {
    final runningRefresh = _refreshFuture;

    if (runningRefresh != null) {
      return runningRefresh;
    }

    // Share the same refresh request across concurrent 401 responses.
    final refresh = _refreshSession();
    _refreshFuture = refresh;
    return refresh.whenComplete(() {
      _refreshFuture = null;
    });
  }

  RequestOptions _retryOptions(RequestOptions original, String accessToken) {
    final headers = Map<String, dynamic>.from(original.headers);
    headers['Authorization'] = 'Bearer $accessToken';

    final extra = Map<String, dynamic>.from(original.extra);
    extra[authRetryAttemptedKey] = true;

    return original.copyWith(headers: headers, extra: extra);
  }

  String? _extractErrorCode(DioException err) {
    final data = err.response?.data;
    if (data is Map) {
      final normalized = data.map((key, value) => MapEntry('$key', value));
      final direct = normalized['error_code'];
      if (direct is String && direct.trim().isNotEmpty) {
        return direct.trim();
      }

      final detail = normalized['detail'];
      if (detail is Map) {
        final detailCode = detail['error_code'];
        if (detailCode is String && detailCode.trim().isNotEmpty) {
          return detailCode.trim();
        }
      }
    }

    return null;
  }
}
