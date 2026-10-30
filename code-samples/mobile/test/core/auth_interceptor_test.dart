import 'package:my_project/core/services/crashlytics_service.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_project/core/network/interceptors/auth_interceptor.dart';
import 'package:my_project/core/storage/token_storage.dart';

void main() {
  test('decorates requests with the current Bearer token', () async {
    final harness = _AuthHarness(
      tokenStorage: _MemoryTokenStorage(
        accessToken: 'login-access',
        refreshToken: 'login-refresh',
      ),
    );

    final response = await harness.mainDio.get('/profile');

    expect(response.statusCode, 200);
    expect(harness.mainAdapter.loginAuthorizationCount, 1);
    expect(harness.refreshAdapter.callCount, 0);
  });

  test('skipAuth does not decorate or recover the request', () async {
    final harness = _AuthHarness();

    await expectLater(
      harness.mainDio.get(
        '/public',
        options: Options(extra: {'skipAuth': true}),
      ),
      throwsA(isA<DioException>()),
    );

    expect(harness.mainAdapter.unauthenticatedRequestCount, 1);
    expect(harness.refreshAdapter.callCount, 0);
    expect(harness.sessionExpiredCalls, 0);
  });

  test('non-401 errors pass without session recovery', () async {
    final harness = _AuthHarness(initialRequestStatusCode: 500);

    await expectLater(
      harness.mainDio.get('/orders'),
      throwsA(isA<DioException>()),
    );

    expect(harness.refreshAdapter.callCount, 0);
    expect(harness.tokenStorage.clearCount, 0);
    expect(harness.sessionExpiredCalls, 0);
  });

  test(
    'late Guest 401 cannot affect or replay into the authenticated session',
    () async {
      final harness = _AuthHarness(
        tokenStorage: _MemoryTokenStorage(),
        holdFirstRequest: true,
      );

      final request = harness.mainDio.get('/recommendations');
      await harness.mainAdapter.firstCallStarted.future;
      await harness.startNewSession(
        accessToken: 'login-access',
        refreshToken: 'login-refresh',
      );
      harness.mainAdapter.releaseFirstCall();

      await expectLater(request, throwsA(isA<DioException>()));

      expect(harness.mainAdapter.loginAuthorizationCount, 0);
      expect(harness.refreshAdapter.callCount, 0);
      expect(harness.sessionExpiredCalls, 0);
      expect(harness.tokenStorage.accessToken, 'login-access');
      expect(harness.tokenStorage.refreshToken, 'login-refresh');
    },
  );

  test('late stale-token 401 cannot affect a newer Login session', () async {
    final harness = _AuthHarness(holdFirstRequest: true);

    final request = harness.mainDio.get('/cart');
    await harness.mainAdapter.firstCallStarted.future;
    await harness.startNewSession(
      accessToken: 'login-access',
      refreshToken: 'login-refresh',
    );
    harness.mainAdapter.releaseFirstCall();

    await expectLater(request, throwsA(isA<DioException>()));

    expect(harness.mainAdapter.loginAuthorizationCount, 0);
    expect(harness.refreshAdapter.callCount, 0);
    expect(harness.sessionExpiredCalls, 0);
    expect(harness.tokenStorage.accessToken, 'login-access');
    expect(harness.tokenStorage.refreshToken, 'login-refresh');
  });

  test('delayed refresh failure cannot expire a newer Login session', () async {
    final harness = _AuthHarness(
      refreshStatusCode: 401,
      holdFirstRefresh: true,
    );

    final request = harness.mainDio.get('/cart');
    await harness.refreshAdapter.firstCallStarted.future;
    await harness.startNewSession(
      accessToken: 'login-access',
      refreshToken: 'login-refresh',
    );
    harness.refreshAdapter.releaseFirstCall();

    await expectLater(request, throwsA(isA<DioException>()));

    expect(harness.tokenStorage.accessToken, 'login-access');
    expect(harness.tokenStorage.refreshToken, 'login-refresh');
    expect(harness.tokenStorage.clearCount, 0);
    expect(harness.sessionExpiredCalls, 0);
  });

  test(
    'delayed refresh success cannot overwrite a newer Login session',
    () async {
      final harness = _AuthHarness(holdFirstRefresh: true);

      final request = harness.mainDio.get('/cart');
      await harness.refreshAdapter.firstCallStarted.future;
      await harness.startNewSession(
        accessToken: 'login-access',
        refreshToken: 'login-refresh',
      );
      harness.refreshAdapter.releaseFirstCall();

      await expectLater(request, throwsA(isA<DioException>()));

      expect(harness.tokenStorage.accessToken, 'login-access');
      expect(harness.tokenStorage.refreshToken, 'login-refresh');
      expect(harness.sessionExpiredCalls, 0);
    },
  );

  test('three concurrent 401s share one refresh and retry once each', () async {
    final harness = _AuthHarness(holdFirstRefresh: true);
    final requests = [
      harness.mainDio.get('/orders'),
      harness.mainDio.get('/addresses'),
      harness.mainDio.get('/recommendations'),
    ];

    await harness.refreshAdapter.firstCallStarted.future;
    expect(harness.refreshAdapter.callCount, 1);
    harness.refreshAdapter.releaseFirstCall();

    final responses = await Future.wait(requests);
    expect(responses.map((response) => response.statusCode), everyElement(200));
    expect(harness.refreshAdapter.callCount, 1);
    expect(harness.mainAdapter.freshAuthorizationCount, 3);
    expect(harness.tokenStorage.accessToken, 'fresh-access');
    expect(harness.tokenStorage.refreshToken, 'fresh-refresh');
    expect(harness.sessionExpiredCalls, 0);
  });

  test('late 401 retries after another request refreshes its token', () async {
    final harness = _AuthHarness(holdFirstRequest: true);

    final lateRequest = harness.mainDio.get('/cart');
    await harness.mainAdapter.firstCallStarted.future;

    final refreshTriggerResponse = await harness.mainDio.get('/orders');
    harness.mainAdapter.releaseFirstCall();
    final lateResponse = await lateRequest;

    expect(refreshTriggerResponse.statusCode, 200);
    expect(lateResponse.statusCode, 200);
    expect(harness.refreshAdapter.callCount, 1);
    expect(harness.mainAdapter.requestCount, 4);
    expect(harness.mainAdapter.freshAuthorizationCount, 2);
    expect(harness.sessionExpiredCalls, 0);
  });

  test('refresh failure expires the current session once', () async {
    final harness = _AuthHarness(
      refreshStatusCode: 401,
      holdFirstRefresh: true,
    );
    final requests = [
      harness.mainDio.get('/orders'),
      harness.mainDio.get('/addresses'),
      harness.mainDio.get('/recommendations'),
    ];

    await harness.refreshAdapter.firstCallStarted.future;
    harness.refreshAdapter.releaseFirstCall();
    final errors = await Future.wait(
      requests.map(
        (request) => request
            .then<Object>((value) => value)
            .catchError(
              (Object error) => error,
              test: (Object error) => error is DioException,
            ),
      ),
    );

    expect(errors, everyElement(isA<DioException>()));
    expect(harness.refreshAdapter.callCount, 1);
    expect(harness.tokenStorage.clearCount, 1);
    expect(harness.sessionExpiredCalls, 1);
    expect(harness.tokenStorage.accessToken, isNull);
    expect(harness.tokenStorage.refreshToken, isNull);
  });

  test('refresh 500 leaves the current session untouched', () async {
    final harness = _AuthHarness(refreshStatusCode: 500);

    await expectLater(
      harness.mainDio.get('/orders'),
      throwsA(isA<DioException>()),
    );

    expect(harness.tokenStorage.accessToken, 'expired-access');
    expect(harness.tokenStorage.refreshToken, 'valid-refresh');
    expect(harness.tokenStorage.clearCount, 0);
    expect(harness.sessionExpiredCalls, 0);
  });

  test('refresh timeout leaves the current session untouched', () async {
    final harness = _AuthHarness(
      refreshExceptionType: DioExceptionType.connectionTimeout,
    );

    await expectLater(
      harness.mainDio.get('/orders'),
      throwsA(isA<DioException>()),
    );

    expect(harness.tokenStorage.accessToken, 'expired-access');
    expect(harness.tokenStorage.refreshToken, 'valid-refresh');
    expect(harness.tokenStorage.clearCount, 0);
    expect(harness.sessionExpiredCalls, 0);
  });

  test(
    'malformed refresh success leaves the current session untouched',
    () async {
      final harness = _AuthHarness(malformedRefreshSuccess: true);

      await expectLater(
        harness.mainDio.get('/orders'),
        throwsA(isA<DioException>()),
      );

      expect(harness.tokenStorage.accessToken, 'expired-access');
      expect(harness.tokenStorage.refreshToken, 'valid-refresh');
      expect(harness.tokenStorage.clearCount, 0);
      expect(harness.sessionExpiredCalls, 0);
      expect(harness.crash.errors, hasLength(1));
      expect(harness.crash.errors.single, isA<TypeError>());
    },
  );

  test('local token write failure restores the pre-refresh pair', () async {
    final tokenStorage = _MemoryTokenStorage(
      accessToken: 'expired-access',
      refreshToken: 'valid-refresh',
    )..failNextSave = true;
    final harness = _AuthHarness(tokenStorage: tokenStorage);

    await expectLater(
      harness.mainDio.get('/orders'),
      throwsA(isA<DioException>()),
    );

    expect(harness.tokenStorage.accessToken, 'expired-access');
    expect(harness.tokenStorage.refreshToken, 'valid-refresh');
    expect(harness.tokenStorage.clearCount, 0);
    expect(harness.sessionExpiredCalls, 0);
    expect(harness.crash.errors, hasLength(1));
    expect(harness.crash.errors.single, isA<StateError>());
  });

  test(
    'missing local refresh token definitively expires the session',
    () async {
      final harness = _AuthHarness(
        tokenStorage: _MemoryTokenStorage(accessToken: 'expired-access'),
      );

      await expectLater(
        harness.mainDio.get('/orders'),
        throwsA(isA<DioException>()),
      );

      expect(harness.refreshAdapter.callCount, 0);
      expect(harness.tokenStorage.clearCount, 1);
      expect(harness.sessionExpiredCalls, 1);
    },
  );

  test('retried original 401 expires once without a refresh loop', () async {
    final harness = _AuthHarness(retriedRequestStatusCode: 401);

    await expectLater(
      harness.mainDio.get('/orders'),
      throwsA(isA<DioException>()),
    );

    expect(harness.refreshAdapter.callCount, 1);
    expect(harness.mainAdapter.requestCount, 2);
    expect(harness.tokenStorage.clearCount, 1);
    expect(harness.sessionExpiredCalls, 1);
  });
}

class _AuthHarness {
  _AuthHarness({
    int refreshStatusCode = 200,
    int retriedRequestStatusCode = 200,
    bool holdFirstRefresh = false,
    bool holdFirstRequest = false,
    int initialRequestStatusCode = 401,
    DioExceptionType? refreshExceptionType,
    bool malformedRefreshSuccess = false,
    _MemoryTokenStorage? tokenStorage,
    _NoopCrashlyticsService? crash,
  }) : crash = crash ?? _NoopCrashlyticsService(),
       tokenStorage =
           tokenStorage ??
           _MemoryTokenStorage(
             accessToken: 'expired-access',
             refreshToken: 'valid-refresh',
           ),
       mainDio = Dio(BaseOptions(baseUrl: 'https://example.test')),
       refreshDio = Dio(BaseOptions(baseUrl: 'https://example.test')),
       mainAdapter = _AuthRetryAdapter(
         retriedRequestStatusCode: retriedRequestStatusCode,
         holdFirstRequest: holdFirstRequest,
         initialRequestStatusCode: initialRequestStatusCode,
       ),
       refreshAdapter = _RefreshAdapter(
         statusCode: refreshStatusCode,
         holdFirstCall: holdFirstRefresh,
         exceptionType: refreshExceptionType,
         malformedSuccess: malformedRefreshSuccess,
       ) {
    mainDio.httpClientAdapter = mainAdapter;
    refreshDio.httpClientAdapter = refreshAdapter;
    mainDio.interceptors.add(
      AuthInterceptor(
        tokenStorage: this.tokenStorage,
        crash: this.crash,
        dio: mainDio,
        refreshDio: refreshDio,
        currentSessionRevision: () => sessionRevision,
        refreshPath: '/refresh',
        onSessionExpired: () async => sessionExpiredCalls++,
      ),
    );
  }

  final _MemoryTokenStorage tokenStorage;
  final _NoopCrashlyticsService crash;
  final Dio mainDio;
  final Dio refreshDio;
  final _AuthRetryAdapter mainAdapter;
  final _RefreshAdapter refreshAdapter;
  var sessionExpiredCalls = 0;
  var sessionRevision = 0;

  Future<void> startNewSession({
    required String accessToken,
    required String refreshToken,
  }) async {
    sessionRevision++;
    await tokenStorage.saveTokensIfPresent(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }
}

class _MemoryTokenStorage extends TokenStorage {
  _MemoryTokenStorage({this.accessToken, this.refreshToken})
    : super(const FlutterSecureStorage());

  String? accessToken;
  String? refreshToken;
  var clearCount = 0;
  bool failNextSave = false;

  @override
  Future<String?> get readAccessToken async => accessToken;

  @override
  Future<String?> get readRefreshToken async => refreshToken;

  @override
  Future<void> saveTokensIfPresent({
    required String? accessToken,
    required String? refreshToken,
  }) async {
    if (failNextSave) {
      failNextSave = false;
      throw StateError('secure storage unavailable');
    }
    if (accessToken?.isNotEmpty ?? false) this.accessToken = accessToken;
    if (refreshToken?.isNotEmpty ?? false) this.refreshToken = refreshToken;
  }

  @override
  Future<void> clearTokens() async {
    clearCount++;
    accessToken = null;
    refreshToken = null;
  }
}

class _AuthRetryAdapter implements HttpClientAdapter {
  _AuthRetryAdapter({
    required this.retriedRequestStatusCode,
    required this.holdFirstRequest,
    required this.initialRequestStatusCode,
  });

  final int retriedRequestStatusCode;
  final bool holdFirstRequest;
  final int initialRequestStatusCode;
  final firstCallStarted = Completer<void>();
  final _firstCallGate = Completer<void>();
  var requestCount = 0;
  var freshAuthorizationCount = 0;
  var loginAuthorizationCount = 0;
  var unauthenticatedRequestCount = 0;

  void releaseFirstCall() {
    if (!_firstCallGate.isCompleted) _firstCallGate.complete();
  }

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requestCount++;
    if (requestCount == 1) {
      if (!firstCallStarted.isCompleted) firstCallStarted.complete();
      if (holdFirstRequest) await _firstCallGate.future;
    }
    final authorization = options.headers['Authorization'] as String?;
    if (authorization == 'Bearer fresh-access') {
      freshAuthorizationCount++;
      return _jsonResponse(retriedRequestStatusCode, {'status': 'success'});
    }
    if (authorization == 'Bearer login-access') {
      loginAuthorizationCount++;
      return _jsonResponse(200, {'status': 'success'});
    }
    if (authorization == null) unauthenticatedRequestCount++;
    return _jsonResponse(initialRequestStatusCode, {'status': 'error'});
  }

  @override
  void close({bool force = false}) {}
}

class _RefreshAdapter implements HttpClientAdapter {
  _RefreshAdapter({
    required this.statusCode,
    required this.holdFirstCall,
    required this.exceptionType,
    required this.malformedSuccess,
  });

  final int statusCode;
  final bool holdFirstCall;
  final DioExceptionType? exceptionType;
  final bool malformedSuccess;
  final firstCallStarted = Completer<void>();
  final _firstCallGate = Completer<void>();
  var callCount = 0;

  void releaseFirstCall() {
    if (!_firstCallGate.isCompleted) _firstCallGate.complete();
  }

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    callCount++;
    if (callCount == 1) {
      if (!firstCallStarted.isCompleted) firstCallStarted.complete();
      if (holdFirstCall) await _firstCallGate.future;
    }

    if (exceptionType != null) {
      throw DioException(requestOptions: options, type: exceptionType!);
    }

    if (statusCode != 200) {
      return _jsonResponse(statusCode, {
        'status': 'error',
        'message': 'Refresh token has been replaced or revoked',
        'error_code': statusCode == 401
            ? 'REFRESH_TOKEN_REPLACED'
            : 'REFRESH_UNAVAILABLE',
      });
    }
    if (malformedSuccess) {
      return _jsonResponse(200, {
        'status': 'success',
        'data': {'access_token': 'fresh-access'},
      });
    }
    return _jsonResponse(200, {
      'status': 'success',
      'data': {
        'access_token': 'fresh-access',
        'refresh_token': 'fresh-refresh',
      },
    });
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _jsonResponse(int statusCode, Map<String, dynamic> body) {
  return ResponseBody.fromString(
    jsonEncode(body),
    statusCode,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}

class _NoopCrashlyticsService implements CrashlyticsService {
  final errors = <Object>[];
  @override
  Future<void> logError(
    dynamic error,
    StackTrace? stackTrace, {
    String? reason,
  }) async {
    errors.add(error);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
