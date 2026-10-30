import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:multi_product_store_admin_web/core/network/interceptors/auth_interceptor.dart';
import 'package:multi_product_store_admin_web/core/storage/memory_token_storage.dart';

void main() {
  group('AuthInterceptor', () {
    late Dio dio;
    late MemoryTokenStorage storage;
    late _FakeHttpClientAdapter adapter;
    late int refreshCalls;
    late int sessionExpiredCalls;
    late int forbiddenCalls;

    setUp(() {
      storage = MemoryTokenStorage();
      adapter = _FakeHttpClientAdapter();
      refreshCalls = 0;
      sessionExpiredCalls = 0;
      forbiddenCalls = 0;
      dio = Dio(BaseOptions(baseUrl: 'https://admin.test'));
      dio.httpClientAdapter = adapter;
      dio.interceptors.add(
        AuthInterceptor(
          dio: dio,
          tokenStorage: storage,
          refreshSession: () async {
            refreshCalls++;
            await storage.saveTokens(
              accessToken: 'new-access',
              refreshToken: 'new-refresh',
            );
            return true;
          },
          onSessionExpired: () async {
            sessionExpiredCalls++;
          },
          onForbidden: () async {
            forbiddenCalls++;
          },
        ),
      );
    });

    test('adds Authorization header for protected requests', () async {
      await storage.saveTokens(accessToken: 'access', refreshToken: 'refresh');
      adapter.onFetch = (options) {
        return _jsonResponse({'ok': true}, statusCode: 200);
      };

      await dio.get('/products');

      expect(adapter.requests.single.headers['Authorization'], 'Bearer access');
    });

    test(
      'does not refresh or add auth for signin refresh and logout endpoints',
      () async {
        await storage.saveTokens(
          accessToken: 'access',
          refreshToken: 'refresh',
        );
        adapter.onFetch = (options) {
          return _jsonResponse({
            'status': 'error',
            'error_code': 'TOKEN_EXPIRED',
            'message': 'expired',
          }, statusCode: 401);
        };

        await expectLater(
          dio.post('/admin/auth/signin'),
          throwsA(isA<DioException>()),
        );
        await expectLater(
          dio.post('/admin/auth/refresh'),
          throwsA(isA<DioException>()),
        );
        await expectLater(
          dio.post('/admin/auth/logout'),
          throwsA(isA<DioException>()),
        );

        expect(refreshCalls, 0);
        expect(
          adapter.requests.where(
            (request) => request.headers.containsKey('Authorization'),
          ),
          isEmpty,
        );
      },
    );

    test(
      'refreshes once, saves rotated tokens, and retries original request',
      () async {
        await storage.saveTokens(
          accessToken: 'old-access',
          refreshToken: 'old-r',
        );
        adapter.onFetch = (options) {
          if (options.headers['Authorization'] == 'Bearer old-access') {
            return _jsonResponse({
              'status': 'error',
              'error_code': 'TOKEN_EXPIRED',
              'message': 'expired',
            }, statusCode: 401);
          }
          return _jsonResponse({'ok': true}, statusCode: 200);
        };

        final response = await dio.get('/products');

        expect(response.data, {'ok': true});
        expect(refreshCalls, 1);
        expect(await storage.readAccessToken(), 'new-access');
        expect(await storage.readRefreshToken(), 'new-refresh');
        expect(adapter.requests.length, 2);
        expect(
          adapter.requests.last.extra[AuthInterceptor.authRetryAttemptedKey],
          isTrue,
        );
      },
    );

    test(
      'refresh failure clears tokens, notifies session, and does not retry',
      () async {
        await storage.saveTokens(
          accessToken: 'old-access',
          refreshToken: 'old-r',
        );
        dio.interceptors.clear();
        dio.interceptors.add(
          AuthInterceptor(
            dio: dio,
            tokenStorage: storage,
            refreshSession: () async {
              refreshCalls++;
              return false;
            },
            onSessionExpired: () async {
              sessionExpiredCalls++;
            },
          ),
        );
        adapter.onFetch = (options) {
          return _jsonResponse({
            'status': 'error',
            'error_code': 'TOKEN_EXPIRED',
            'message': 'expired',
          }, statusCode: 401);
        };

        await expectLater(dio.get('/products'), throwsA(isA<DioException>()));

        expect(refreshCalls, 1);
        expect(sessionExpiredCalls, 1);
        expect(adapter.requests.length, 1);
        expect(await storage.hasSession(), isFalse);
      },
    );

    test('TOKEN_INVALID clears tokens without refresh loop', () async {
      await storage.saveTokens(accessToken: 'access', refreshToken: 'refresh');
      adapter.onFetch = (options) {
        return _jsonResponse({
          'status': 'error',
          'error_code': 'TOKEN_INVALID',
          'message': 'invalid',
        }, statusCode: 401);
      };

      await expectLater(dio.get('/products'), throwsA(isA<DioException>()));

      expect(refreshCalls, 0);
      expect(sessionExpiredCalls, 1);
      expect(await storage.hasSession(), isFalse);
    });

    test(
      'ADMIN_FORBIDDEN clears tokens and notifies forbidden callback',
      () async {
        await storage.saveTokens(
          accessToken: 'access',
          refreshToken: 'refresh',
        );
        adapter.onFetch = (options) {
          return _jsonResponse({
            'status': 'error',
            'error_code': 'ADMIN_FORBIDDEN',
            'message': 'forbidden',
          }, statusCode: 403);
        };

        await expectLater(dio.get('/products'), throwsA(isA<DioException>()));

        expect(refreshCalls, 0);
        expect(forbiddenCalls, 1);
        expect(await storage.hasSession(), isFalse);
      },
    );

    test('concurrent TOKEN_EXPIRED requests share one refresh', () async {
      await storage.saveTokens(
        accessToken: 'old-access',
        refreshToken: 'old-r',
      );
      dio.interceptors.clear();
      dio.interceptors.add(
        AuthInterceptor(
          dio: dio,
          tokenStorage: storage,
          refreshSession: () async {
            refreshCalls++;
            await Future<void>.delayed(const Duration(milliseconds: 10));
            await storage.saveTokens(
              accessToken: 'new-access',
              refreshToken: 'new-refresh',
            );
            return true;
          },
        ),
      );
      adapter.onFetch = (options) {
        if (options.headers['Authorization'] == 'Bearer old-access') {
          return _jsonResponse({
            'status': 'error',
            'error_code': 'TOKEN_EXPIRED',
            'message': 'expired',
          }, statusCode: 401);
        }
        return _jsonResponse({'ok': true}, statusCode: 200);
      };

      final responses = await Future.wait([
        dio.get('/products/1'),
        dio.get('/products/2'),
      ]);

      expect(responses.map((response) => response.data), [
        {'ok': true},
        {'ok': true},
      ]);
      expect(refreshCalls, 1);
      expect(
        adapter.requests
            .where(
              (request) =>
                  request.headers['Authorization'] == 'Bearer new-access',
            )
            .length,
        2,
      );
    });
  });
}

typedef _FetchHandler = Future<ResponseBody> Function(RequestOptions options);

class _FakeHttpClientAdapter implements HttpClientAdapter {
  _FetchHandler? onFetch;
  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    requests.add(options);
    final handler = onFetch;
    if (handler == null) {
      return _jsonResponse({'ok': true}, statusCode: 200);
    }
    return handler(options);
  }

  @override
  void close({bool force = false}) {}
}

Future<ResponseBody> _jsonResponse(
  Object body, {
  required int statusCode,
}) async {
  return ResponseBody.fromString(
    jsonEncode(body),
    statusCode,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}
