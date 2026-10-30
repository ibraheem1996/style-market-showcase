// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import '../../config/api_config.dart';
import '../../storage/token_storage.dart';
import '../../services/crashlytics_service.dart';
import '../response_token_model.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required TokenStorage tokenStorage,
    required CrashlyticsService crash,
    required Dio dio,
    required Dio refreshDio,
    required int Function() currentSessionRevision,
    this.refreshPath = ApiConfig.refresh,
    this.onSessionExpired,
  }) : _tokenStorage = tokenStorage,
       _crash = crash,
       _dio = dio,
       _refreshDio = refreshDio,
       _currentSessionRevision = currentSessionRevision;

  final TokenStorage _tokenStorage;
  final CrashlyticsService _crash;
  final Dio _dio;
  final Dio _refreshDio;
  final int Function() _currentSessionRevision;
  final String refreshPath;
  final Future<void> Function()? onSessionExpired;

  Future<_RefreshOutcome>? _refreshFuture;
  String? _refreshSourceAccessToken;
  Future<void>? _sessionExpiryFuture;

  static const String _retryKey = 'retry_after_refresh';
  static const String _sessionRevisionKey = 'auth_session_revision';
  static const String _skipAuthKey = 'skipAuth';

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Public authentication endpoints must not inherit a stale session token.
    if (options.extra[_skipAuthKey] == true) {
      handler.next(options);
      return;
    }

    options.extra[_sessionRevisionKey] = _currentSessionRevision();
    final accessToken = await _tokenStorage.readAccessToken;
    if (accessToken != null && accessToken.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }

    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final request = err.requestOptions;
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    final sourceAccessToken = _requestAccessToken(request);
    if (sourceAccessToken == null) {
      return handler.next(err);
    }

    if (request.extra[_sessionRevisionKey] != _currentSessionRevision()) {
      return handler.next(err);
    }
    final currentAccessToken = await _tokenStorage.readAccessToken;

    if (request.extra[_retryKey] == true) {
      if (sourceAccessToken == currentAccessToken) {
        await _expireSession(sourceAccessToken);
        request.extra['auth_session_expired'] = true;
      }
      return handler.next(err);
    }

    if (sourceAccessToken != currentAccessToken) {
      if (currentAccessToken == null || currentAccessToken.isEmpty) {
        return handler.next(err);
      }
      await _retryWithAccessToken(
        err,
        handler,
        accessToken: currentAccessToken,
      );
      return;
    }

    await _refreshAndRetry(err, handler, sourceAccessToken);
  }

  Future<void> _refreshAndRetry(
    DioException err,
    ErrorInterceptorHandler handler,
    String sourceAccessToken,
  ) async {
    if (_refreshFuture != null &&
        _refreshSourceAccessToken != sourceAccessToken) {
      return handler.next(err);
    }

    final refreshOutcome = await _getOrStartRefresh(sourceAccessToken);
    switch (refreshOutcome.type) {
      case _RefreshOutcomeType.success:
        await _retryWithAccessToken(
          err,
          handler,
          accessToken: refreshOutcome.accessToken!,
        );
        return;
      case _RefreshOutcomeType.definitiveAuthFailure:
        await _expireSession(sourceAccessToken);
        err.requestOptions.extra['auth_session_expired'] = true;
        return handler.next(err);
      case _RefreshOutcomeType.transientFailure:
      case _RefreshOutcomeType.staleSession:
        return handler.next(err);
    }
  }

  Future<_RefreshOutcome> _getOrStartRefresh(String sourceAccessToken) {
    if (_refreshFuture != null) return _refreshFuture!;

    _refreshSourceAccessToken = sourceAccessToken;

    final refreshFuture = _refreshTokens(sourceAccessToken).whenComplete(() {
      _refreshFuture = null;
      _refreshSourceAccessToken = null;
    });
    _refreshFuture = refreshFuture;
    return refreshFuture;
  }

  Future<_RefreshOutcome> _refreshTokens(String sourceAccessToken) async {
    try {
      final refreshToken = await _tokenStorage.readRefreshToken;
      if (refreshToken == null || refreshToken.isEmpty) {
        return const _RefreshOutcome.definitiveAuthFailure();
      }

      final response = await _refreshDio.post(
        refreshPath,
        data: {'refresh_token': refreshToken},
      );
      final tokens = TokenResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
      final newAccessToken = tokens.data?.accessToken;
      final newRefreshToken = tokens.data?.refreshToken;
      if (newAccessToken == null ||
          newAccessToken.isEmpty ||
          newRefreshToken == null ||
          newRefreshToken.isEmpty) {
        _crash.logError(
          const FormatException('Refresh response missing required tokens'),
          StackTrace.current,
          reason: 'AuthInterceptor.refresh response',
        );
        return const _RefreshOutcome.transientFailure();
      }

      if (await _tokenStorage.readAccessToken != sourceAccessToken) {
        return const _RefreshOutcome.staleSession();
      }

      try {
        await _tokenStorage.saveTokensIfPresent(
          accessToken: newAccessToken,
          refreshToken: newRefreshToken,
        );
      } catch (error, stackTrace) {
        _crash.logError(
          error,
          stackTrace,
          reason: 'AuthInterceptor.save refresh tokens',
        );
        // Refresh is not idempotent. Restore the pre-refresh pair when possible;
        // if local storage remains unavailable, preserve the session in memory
        // and let a later authoritative 401 decide whether it has expired.
        try {
          await _tokenStorage.saveTokensIfPresent(
            accessToken: sourceAccessToken,
            refreshToken: refreshToken,
          );
        } catch (_) {}
        return const _RefreshOutcome.transientFailure();
      }
      return _RefreshOutcome.success(newAccessToken);
    } on DioException catch (error) {
      if (error.response?.statusCode == 401) {
        return const _RefreshOutcome.definitiveAuthFailure();
      }
      return const _RefreshOutcome.transientFailure();
    } catch (error, stackTrace) {
      _crash.logError(error, stackTrace, reason: 'AuthInterceptor.refresh');
      return const _RefreshOutcome.transientFailure();
    }
  }

  Future<void> _expireSession(String sourceAccessToken) {
    if (_sessionExpiryFuture != null) return _sessionExpiryFuture!;

    final expiryFuture = _expireCurrentSession(sourceAccessToken).whenComplete(
      () {
        _sessionExpiryFuture = null;
      },
    );
    _sessionExpiryFuture = expiryFuture;
    return expiryFuture;
  }

  Future<void> _expireCurrentSession(String sourceAccessToken) async {
    if (await _tokenStorage.readAccessToken != sourceAccessToken) return;

    await _tokenStorage.clearTokens();
    await onSessionExpired?.call();
  }

  Future<void> _retryWithAccessToken(
    DioException err,
    ErrorInterceptorHandler handler, {
    required String accessToken,
  }) async {
    final request = err.requestOptions;
    request.extra[_retryKey] = true;
    request.headers['Authorization'] = 'Bearer $accessToken';

    try {
      final response = await _dio.fetch(request);
      handler.resolve(response);
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }

  String? _requestAccessToken(RequestOptions request) {
    final authorization = request.headers['Authorization'];
    if (authorization is! String || !authorization.startsWith('Bearer ')) {
      return null;
    }
    return authorization.substring('Bearer '.length);
  }
}

enum _RefreshOutcomeType {
  success,
  definitiveAuthFailure,
  transientFailure,
  staleSession,
}

class _RefreshOutcome {
  const _RefreshOutcome._(this.type, [this.accessToken]);

  const _RefreshOutcome.success(String accessToken)
    : this._(_RefreshOutcomeType.success, accessToken);

  const _RefreshOutcome.definitiveAuthFailure()
    : this._(_RefreshOutcomeType.definitiveAuthFailure);

  const _RefreshOutcome.transientFailure()
    : this._(_RefreshOutcomeType.transientFailure);

  const _RefreshOutcome.staleSession()
    : this._(_RefreshOutcomeType.staleSession);

  final _RefreshOutcomeType type;
  final String? accessToken;
}
