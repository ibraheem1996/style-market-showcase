import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/mockito.dart';
import 'package:my_project/core/constants/app_pref_key.dart';
import 'package:my_project/core/di/service_locator.dart';
import 'package:my_project/core/errors/failure.dart';
import 'package:my_project/core/errors/failure_key.dart';
import 'package:my_project/core/network/api_response.dart';
import 'package:my_project/core/services/analytics_service.dart';
import 'package:my_project/core/services/crashlytics_service.dart';
import 'package:my_project/core/services/performance_service.dart';
import 'package:my_project/core/storage/prefs_storage.dart';
import 'package:my_project/features/auth/domain/entities/user_entity.dart';
import 'package:my_project/features/auth/session/session_service.dart';
import 'package:my_project/features/favorites/data/datasources/remote/favorites_remote_datasource.dart';
import 'package:my_project/features/favorites/data/models/favorite_model.dart';
import 'package:my_project/features/favorites/data/models/toggle_favorite_request.dart';
import 'package:my_project/features/favorites/data/repositories/favorites_repository_impl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:my_project/core/storage/token_storage.dart';

class _FakeTokenStorage extends TokenStorage {
  _FakeTokenStorage() : super(const FlutterSecureStorage());
}

void main() {
  late SessionService session;
  setUp(() async {
    Get.testMode = true;
    Get.reset();
    await getIt.reset();
    SharedPreferences.setMockInitialValues({AppStorageKey.userId: 1});
    final prefs = await SharedPreferences.getInstance();
    final prefsStorage = PrefsStorage(prefs);
    getIt.registerSingleton<PrefsStorage>(prefsStorage);
    session = Get.put<SessionService>(
      SessionService(prefsStorage, _FakeTokenStorage()),
    );
    session.setUser(
      UserEntity(
        userId: 1,
        userName: 'Test User',
        userEmail: 'test@example.com',
      ),
    );
  });

  tearDown(() async {
    Get.reset();
    await getIt.reset();
  });

  test('rejects an unknown toggle action as invalid data', () async {
    final remote = _FakeFavoritesRemoteDataSource(
      const ApiResponse<Object?>(
        status: 'success',
        data: [],
        action: 'unexpected',
      ),
    );
    final repository = FavoritesRepositoryImpl(
      remoteDataSource: remote,
      crash: _MockCrashlyticsService(),
      analytics: _MockAnalyticsService(),
      performance: _MockPerformanceService(),
      sessionService: session,
    );

    final result = await repository.toggleFavorite(itemId: 7);

    expect(
      result.fold((failure) => failure, (_) => null),
      const Failure.http(key: FailureKey.invalidData, statusCode: 200),
    );
  });

  test('added requires one matching card', () async {
    final remote = _FakeFavoritesRemoteDataSource(
      ApiResponse(
        status: 'success',
        action: 'added',
        data: _validFavorite().toJson(),
      ),
    );
    final result = await _repository(remote, session).toggleFavorite(itemId: 7);
    expect(result.fold((_) => null, (value) => value.favorite?.itemId), 7);
    expect(remote.getCalls, 0);
  });

  test('removed requires absent data', () async {
    final remote = _FakeFavoritesRemoteDataSource(
      const ApiResponse(status: 'success', action: 'removed'),
    );
    final result = await _repository(remote, session).toggleFavorite(itemId: 7);
    expect(result.fold((_) => null, (value) => value.favorite), isNull);
  });

  test('added card must match the submitted variant identity', () async {
    final remote = _FakeFavoritesRemoteDataSource(
      ApiResponse(
        status: 'success',
        action: 'added',
        data: _validFavorite().toJson(),
      ),
    );
    final result = await _repository(
      remote,
      session,
    ).toggleFavorite(itemId: 7, variantId: 4);
    expect(
      result.fold((failure) => failure, (_) => null),
      const Failure.http(key: FailureKey.invalidData, statusCode: 200),
    );
  });

  test('removed rejects an unexpected card', () async {
    final remote = _FakeFavoritesRemoteDataSource(
      ApiResponse(
        status: 'success',
        action: 'removed',
        data: _validFavorite().toJson(),
      ),
    );
    final result = await _repository(remote, session).toggleFavorite(itemId: 7);
    expect(
      result.fold((failure) => failure, (_) => null),
      const Failure.http(key: FailureKey.invalidData, statusCode: 200),
    );
  });

  test('malformed success is marked as an HTTP 200 contract failure', () async {
    final remote = _FakeFavoritesRemoteDataSource(
      const ApiResponse(status: 'success', action: 'added'),
    );
    final result = await _repository(remote, session).toggleFavorite(itemId: 7);
    expect(
      result.fold((failure) => failure, (_) => null),
      const Failure.http(key: FailureKey.invalidData, statusCode: 200),
    );
  });

  test('reports a thrown favorite mapping error once', () async {
    final crash = _MockCrashlyticsService();
    final remote = _FakeFavoritesRemoteDataSource(
      const ApiResponse(
        status: 'success',
        action: 'added',
        data: {'item_id': 'invalid'},
      ),
    );
    final repository = FavoritesRepositoryImpl(
      remoteDataSource: remote,
      crash: crash,
      analytics: _MockAnalyticsService(),
      performance: _MockPerformanceService(),
      sessionService: session,
    );

    final result = await repository.toggleFavorite(itemId: 7);

    expect(
      result.fold((failure) => failure.key, (_) => null),
      FailureKey.invalidData,
    );
    expect(crash.errors, hasLength(1));
    expect(crash.stacks.single, isNotNull);
  });

  test('clear accepts success without data and sends one request', () async {
    final remote = _FakeFavoritesRemoteDataSource(
      const ApiResponse(status: 'success', action: 'removed'),
    );
    final result = await _repository(remote, session).clearFavorites();
    expect(result.isRight(), isTrue);
    expect(remote.clearCalls, 1);
  });

  test('get favorites uses a token-owned remote call', () async {
    final remote = _FakeFavoritesRemoteDataSource(
      const ApiResponse<Object?>(status: 'success', data: [], action: 'added'),
    );
    final repository = FavoritesRepositoryImpl(
      remoteDataSource: remote,
      crash: _MockCrashlyticsService(),
      analytics: _MockAnalyticsService(),
      performance: _MockPerformanceService(),
      sessionService: session,
    );

    final result = await repository.getFavorites();

    expect(result.isRight(), isTrue);
    expect(remote.getCalls, 1);
  });

  test(
    'get favorites keeps valid items when one item cannot be mapped',
    () async {
      final remote = _FakeFavoritesRemoteDataSource(
        const ApiResponse(status: 'success', data: []),
        getResponse: ApiResponse(
          status: 'success',
          data: [_validFavorite(), const FavoriteModel()],
        ),
      );
      final repository = _repository(remote, session);

      final result = await repository.getFavorites();

      expect(result.fold((_) => null, (items) => items.length), 1);
    },
  );

  test('get favorites fails when every non-empty item is invalid', () async {
    final remote = _FakeFavoritesRemoteDataSource(
      const ApiResponse(status: 'success', data: []),
      getResponse: const ApiResponse(
        status: 'success',
        data: [FavoriteModel()],
      ),
    );

    final result = await _repository(remote, session).getFavorites();

    expect(
      result.fold((failure) => failure, (_) => null),
      const Failure.http(key: FailureKey.invalidData),
    );
  });

  test(
    'toggle preserves a backend error code from a 2xx error envelope',
    () async {
      final remote = _FakeFavoritesRemoteDataSource(
        const ApiResponse(
          status: 'error',
          errorCode: 'ITEM_NOT_FOUND',
          message: 'Item was not found',
        ),
      );

      final result = await _repository(
        remote,
        session,
      ).toggleFavorite(itemId: 7);

      result.fold(
        (failure) => failure.when(
          http: (key, _, __, ___, errorCode) {
            expect(key, FailureKey.itemNotFound);
            expect(errorCode, 'ITEM_NOT_FOUND');
          },
          auth: (_) => fail('Expected HTTP failure'),
          app: (_) => fail('Expected HTTP failure'),
        ),
        (_) => fail('Expected failure'),
      );
    },
  );
}

class _FakeFavoritesRemoteDataSource implements FavoritesRemoteDataSource {
  _FakeFavoritesRemoteDataSource(this.toggleResponse, {this.getResponse});

  final ApiResponse<Object?> toggleResponse;
  final ApiResponse<List<FavoriteModel>>? getResponse;
  int getCalls = 0;
  int clearCalls = 0;

  @override
  Future<ApiResponse<void>> clearFavorites() async {
    clearCalls++;
    return const ApiResponse(status: 'success');
  }

  @override
  Future<ApiResponse<List<FavoriteModel>>> getFavorites() async {
    getCalls++;
    return getResponse ?? const ApiResponse(status: 'success', data: []);
  }

  @override
  Future<ApiResponse<dynamic>> toggleFavorite(
    ToggleFavoriteRequest request,
  ) async {
    return toggleResponse;
  }
}

FavoriteModel _validFavorite() => const FavoriteModel(
  favId: 1,
  itemId: 7,
  targetType: 'item',
  itemNameAr: 'منتج',
  itemNameEn: 'Product',
  displayPrice: 10,
  originalPrice: 10,
  status: 'OK',
  createdAt: '2026-09-23T00:00:00Z',
);

FavoritesRepositoryImpl _repository(
  _FakeFavoritesRemoteDataSource remote,
  SessionService session,
) => FavoritesRepositoryImpl(
  remoteDataSource: remote,
  crash: _MockCrashlyticsService(),
  analytics: _MockAnalyticsService(),
  performance: _MockPerformanceService(),
  sessionService: session,
);

class _MockCrashlyticsService extends Mock implements CrashlyticsService {
  final errors = <Object>[];
  final stacks = <StackTrace?>[];
  @override
  Future<void> logError(
    dynamic error,
    StackTrace? stackTrace, {
    String? reason,
  }) async {
    errors.add(error);
    stacks.add(stackTrace);
  }
}

class _MockAnalyticsService extends Mock implements AnalyticsService {}

class _MockPerformanceService extends Mock implements PerformanceService {}
