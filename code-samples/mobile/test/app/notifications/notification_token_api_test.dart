import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_project/app/notifications/notification_token_api.dart';
import 'package:my_project/core/errors/failure_key.dart';
import 'package:my_project/core/network/interceptors/auth_interceptor.dart';
import 'package:my_project/core/services/analytics_service.dart';
import 'package:my_project/core/services/crashlytics_service.dart';
import 'package:my_project/core/services/performance_service.dart';

import 'app_notifications_test.dart' show MemoryTokens;

class _Adapter implements HttpClientAdapter {
  _Adapter(this.handle);
  final Future<ResponseBody> Function(RequestOptions) handle;
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) => handle(options);
  @override
  void close({bool force = false}) {}
}

class _Crash implements CrashlyticsService {
  @override
  Future<void> logError(
    dynamic error,
    StackTrace? stackTrace, {
    String? reason,
  }) async {}
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Analytics implements AnalyticsService {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Performance implements PerformanceService {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

NotificationTokenApi _api(Dio dio) => NotificationTokenApi(
  NotificationTokenRemoteApi(dio),
  analytics: _Analytics(),
  crash: _Crash(),
  performance: _Performance(),
);

ResponseBody _response(String json, int status) => ResponseBody.fromString(
  json,
  status,
  headers: {
    Headers.contentTypeHeader: [Headers.jsonContentType],
  },
);

const _success = '{"status":"success","error_code":null,"data":null}';

void main() {
  test(
    'Retrofit PUT/DELETE send exact JSON using shared authentication',
    () async {
      final tokens = MemoryTokens();
      final dio = Dio(BaseOptions(baseUrl: 'https://test.invalid/api/v1'));
      final refresh = Dio();
      addTearDown(dio.close);
      addTearDown(refresh.close);
      dio.interceptors.add(
        AuthInterceptor(
          tokenStorage: tokens,
          crash: _Crash(),
          dio: dio,
          refreshDio: refresh,
          currentSessionRevision: () => 0,
        ),
      );
      final requests = <RequestOptions>[];
      dio.httpClientAdapter = _Adapter((options) async {
        requests.add(options);
        return _response(_success, 200);
      });
      final api = _api(dio);
      expect(
        (await api.register(
          'opaque-installation',
          cancelToken: CancelToken(),
          canDispatch: () => true,
        )).isRight(),
        isTrue,
      );
      tokens.bearer = 'new-session';
      expect(
        (await api.remove(
          'opaque-installation',
          cancelToken: CancelToken(),
        )).isRight(),
        isTrue,
      );
      expect(requests, hasLength(2));
      expect(requests.map((r) => r.method), ['PUT', 'DELETE']);
      expect(requests.first.headers['Authorization'], 'Bearer session-one');
      expect(requests.last.headers['Authorization'], 'Bearer new-session');
      for (final request in requests) {
        expect(request.data, {'token': 'opaque-installation'});
        expect(request.uri.path, '/api/v1/users/me/fcm-token');
        expect(request.extra['sensitiveNotificationToken'], isTrue);
        expect(request.extra['skipAuth'], isNot(true));
      }
    },
  );

  test('shared auth retries a 401 with an updated access token', () async {
    final tokens = MemoryTokens();
    final dio = Dio(BaseOptions(baseUrl: 'https://test.invalid/api/v1'));
    final refresh = Dio();
    addTearDown(dio.close);
    addTearDown(refresh.close);
    var refreshCalls = 0;
    refresh.httpClientAdapter = _Adapter((_) async {
      refreshCalls++;
      return _response('{}', 500);
    });
    dio.interceptors.add(
      AuthInterceptor(
        tokenStorage: tokens,
        crash: _Crash(),
        dio: dio,
        refreshDio: refresh,
        currentSessionRevision: () => 0,
      ),
    );
    final dispatched = Completer<void>();
    final pending = Completer<ResponseBody>();
    final authorizations = <Object?>[];
    dio.httpClientAdapter = _Adapter((options) async {
      authorizations.add(options.headers['Authorization']);
      if (authorizations.length == 1) {
        dispatched.complete();
        return pending.future;
      }
      return _response(_success, 200);
    });
    final put = _api(dio).register(
      'opaque-installation',
      cancelToken: CancelToken(),
      canDispatch: () => true,
    );
    await dispatched.future;
    tokens.bearer = 'updated-access';
    pending.complete(
      _response('{"status":"error","error_code":"TOKEN_EXPIRED"}', 401),
    );
    expect((await put).isRight(), isTrue);
    expect(authorizations, ['Bearer session-one', 'Bearer updated-access']);
    expect(refreshCalls, 0);
  });

  test('dispatch guard and cancelled requests never reach transport', () async {
    final dio = Dio();
    addTearDown(dio.close);
    var calls = 0;
    dio.httpClientAdapter = _Adapter((_) async {
      calls++;
      return _response(_success, 200);
    });
    final api = _api(dio);
    expect(
      (await api.register(
        'token',
        cancelToken: CancelToken(),
        canDispatch: () => false,
      )).isLeft(),
      isTrue,
    );
    final cancelled = CancelToken()..cancel();
    expect(
      (await api.register(
        'token',
        cancelToken: cancelled,
        canDispatch: () => true,
      )).isLeft(),
      isTrue,
    );
    expect(
      (await api.remove('token', cancelToken: cancelled)).isLeft(),
      isTrue,
    );
    expect(calls, 0);
  });

  test(
    'rejects malformed/error envelopes and maps transport failures',
    () async {
      final dio = Dio(BaseOptions(baseUrl: 'https://test.invalid'));
      addTearDown(dio.close);
      final api = _api(dio);
      for (final json in [
        '{}',
        '{"status":"error","error_code":null,"data":null}',
        '{"status":"unknown","data":null}',
        '{"status":"success","error_code":"ERROR","data":null}',
      ]) {
        dio.httpClientAdapter = _Adapter((_) async => _response(json, 200));
        expect(
          (await api.register(
            'token',
            cancelToken: CancelToken(),
            canDispatch: () => true,
          )).isLeft(),
          isTrue,
        );
        expect(
          (await api.remove('token', cancelToken: CancelToken())).isLeft(),
          isTrue,
        );
      }
      dio.httpClientAdapter = _Adapter(
        (options) async => throw DioException(
          requestOptions: options,
          type: DioExceptionType.connectionTimeout,
        ),
      );
      final result = await api.register(
        'token',
        cancelToken: CancelToken(),
        canDispatch: () => true,
      );
      result.fold(
        (failure) => expect(failure.key, FailureKey.networkTimeout),
        (_) => fail('Expected timeout failure'),
      );
    },
  );
}
