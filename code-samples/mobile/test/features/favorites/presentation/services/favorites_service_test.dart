import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_project/core/errors/api_result.dart';
import 'package:my_project/core/errors/failure.dart';
import 'package:my_project/core/errors/failure_key.dart';
import 'package:my_project/features/favorites/domain/entities/favorite_entity.dart';
import 'package:my_project/features/favorites/domain/entities/favorites_toggle_result.dart';
import 'package:my_project/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:my_project/features/favorites/domain/usecases/get_favorites_usecase.dart';
import 'package:my_project/features/favorites/domain/usecases/clear_favorites_usecase.dart';
import 'package:my_project/features/favorites/domain/usecases/toggle_favorite_usecase.dart';
import 'package:my_project/features/favorites/presentation/services/favorites_service.dart';
import 'package:my_project/features/favorites/presentation/state/fav_state.dart';
import 'package:my_project/features/favorites/presentation/store/favorites_store.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:my_project/core/storage/prefs_storage.dart';
import 'package:my_project/core/storage/token_storage.dart';
import 'package:my_project/features/auth/domain/entities/user_entity.dart';
import 'package:my_project/features/auth/session/session_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeTokenStorage extends TokenStorage {
  _FakeTokenStorage() : super(const FlutterSecureStorage());
}

void main() {
  group('FavoritesService characterization', () {
    late FavoritesStore store;
    late _FakeFavoritesRepository repository;
    late SessionService sessionService;
    late FavoritesService service;

    setUp(() async {
      store = FavoritesStore();
      repository = _FakeFavoritesRepository();
      SharedPreferences.setMockInitialValues({});
      sessionService = SessionService(
        PrefsStorage(await SharedPreferences.getInstance()),
        _FakeTokenStorage(),
      );
      sessionService.setUser(
        UserEntity(userId: 1, userName: 'User', userEmail: 'user@example.com'),
      );
      service = FavoritesService(
        store: store,
        toggleFavoriteUseCase: ToggleFavoriteUseCase(repository),
        getFavoritesUseCase: GetFavoritesUseCase(repository),
        clearFavoritesUseCase: ClearFavoritesUseCase(repository),
        sessionService: sessionService,
      );
    });

    test('optimistically changes only the exact target', () async {
      store.setFav(4, null, true);
      final pending = repository.enqueueToggle();

      final result = service.toggle(4, variantId: 9);

      expect(store.isFav(4, null), isTrue);
      expect(store.isFav(4, 9), isTrue);

      pending.complete(
        right(
          FavoritesToggleResult(
            favorite: _favorite(itemId: 4, variantId: 9),
            action: FavoritesToggleAction.added,
          ),
        ),
      );
      await result;
    });

    test('rolls back only the submitted key on failure', () async {
      store.setFav(6, null, true);
      final pending = repository.enqueueToggle();

      final result = service.toggle(6, variantId: 2);
      expect(store.isFav(6, 2), isTrue);

      pending.complete(const Left(Failure.http(key: FailureKey.serverGeneric)));
      final outcome = await result;

      expect(outcome.isLeft(), isTrue);
      expect(store.isFav(6, null), isTrue);
      expect(store.isFav(6, 2), isFalse);
      expect(repository.loadCalls, 0);
    });

    test(
      'uncertain toggle transport failure reconciles with GET once',
      () async {
        store.setAllFavorites([_favorite(itemId: 1)]);
        repository
          ..enqueueToggleResult(
            const Left(Failure.http(key: FailureKey.networkTimeout)),
          )
          ..enqueueLoadResult(
            right([_favorite(itemId: 1), _favorite(itemId: 2)]),
          );

        final result = await service.toggle(2);
        expect(result.isLeft(), isTrue);
        expect(repository.loadCalls, 1);
        expect(store.isFav(2, null), isTrue);
      },
    );

    test(
      'malformed 2xx toggle reconciles, plain invalid data does not',
      () async {
        repository
          ..enqueueToggleResult(
            const Left(
              Failure.http(key: FailureKey.invalidData, statusCode: 200),
            ),
          )
          ..enqueueLoadResult(right([_favorite(itemId: 4)]))
          ..enqueueToggleResult(
            const Left(Failure.http(key: FailureKey.invalidData)),
          );
        await service.toggle(4);
        expect(repository.loadCalls, 1);
        expect(store.isFav(4, null), isTrue);
        await service.toggle(5);
        expect(repository.loadCalls, 1);
      },
    );

    test(
      'blocks duplicate and competing toggles while one target is pending',
      () async {
        final pending = repository.enqueueToggle();
        final first = service.toggle(7, variantId: 3);

        expect(service.isTogglePending(7, 3), isTrue);
        expect(service.canToggle(7, 3), isFalse);
        expect(service.canToggle(8, null), isFalse);

        final duplicate = await service.toggle(7, variantId: 3);
        expect(duplicate.isLeft(), isTrue);

        pending.complete(
          right(
            FavoritesToggleResult(
              favorite: _favorite(itemId: 7, variantId: 3),
              action: FavoritesToggleAction.added,
            ),
          ),
        );
        await first;

        expect(service.canToggle(8, null), isTrue);
      },
    );

    test('shares one load and stores its result', () async {
      final pending = repository.enqueueLoad();

      final first = service.loadFavorites();
      final second = service.loadFavorites();

      expect(repository.loadCalls, 1);
      pending.complete(right([_favorite(itemId: 8)]));
      await Future.wait([first, second]);

      expect(store.isFav(8, null), isTrue);
      expect(service.state.value, const FavState.loaded());
    });

    test('refresh failure preserves the loaded snapshot', () async {
      repository
        ..enqueueLoadResult(right([_favorite(itemId: 8)]))
        ..enqueueLoadResult(
          const Left(Failure.http(key: FailureKey.serverGeneric)),
        );

      await service.loadFavorites();
      final failure = await service.refreshFavorites();

      expect(failure, const Failure.http(key: FailureKey.serverGeneric));
      expect(service.state.value, const FavState.loaded());
      expect(store.favorites.single.itemId, 8);
    });

    test('clear calls the endpoint once even with an empty snapshot', () async {
      repository.enqueueClearResult(right(null));
      final result = await service.clearAllFavorites();
      expect(result.isRight(), isTrue);
      expect(repository.clearCalls, 1);
      expect(repository.toggleCalls, 0);
      expect(store.favorites, isEmpty);
    });

    test('clear failure preserves cards and permits manual retry', () async {
      store.setAllFavorites([_favorite(itemId: 1)]);
      repository
        ..enqueueClearResult(
          const Left(Failure.http(key: FailureKey.serverGeneric)),
        )
        ..enqueueClearResult(right(null));
      final first = await service.clearAllFavorites();
      expect(first.isLeft(), isTrue);
      expect(store.isFav(1, null), isTrue);
      expect(repository.loadCalls, 0);
      final second = await service.clearAllFavorites();
      expect(second.isRight(), isTrue);
      expect(store.favorites, isEmpty);
      expect(repository.clearCalls, 2);
    });

    test('late clear after reset leaves new scope untouched', () async {
      store.setAllFavorites([_favorite(itemId: 1)]);
      final pending = repository.enqueueClear();
      final clearing = service.clearAllFavorites();
      service.reset();
      store.setAllFavorites([_favorite(itemId: 2)]);
      pending.complete(right(null));
      await clearing;
      expect(store.isFav(2, null), isTrue);
    });

    test('older GET cannot restore favorites after clear success', () async {
      final pendingLoad = repository.enqueueLoad();
      repository.enqueueClearResult(right(null));
      final load = service.loadFavorites();
      await service.clearAllFavorites();
      pendingLoad.complete(right([_favorite(itemId: 9)]));
      await load;
      expect(store.favorites, isEmpty);
    });

    test('older load cannot overwrite a completed toggle', () async {
      final pendingLoad = repository.enqueueLoad();
      final pendingToggle = repository.enqueueToggle();

      final load = service.loadFavorites();
      final toggle = service.toggle(9);
      pendingToggle.complete(
        right(
          FavoritesToggleResult(
            favorite: _favorite(itemId: 9),
            action: FavoritesToggleAction.added,
          ),
        ),
      );
      await toggle;
      pendingLoad.complete(right([_favorite(itemId: 3)]));
      await load;

      expect(store.isFav(9, null), isTrue);
      expect(store.isFav(3, null), isFalse);
    });

    test('reset prevents a late toggle from restoring user data', () async {
      final pending = repository.enqueueToggle();
      final toggle = service.toggle(5);

      service.reset();
      pending.complete(
        right(
          FavoritesToggleResult(
            favorite: _favorite(itemId: 5),
            action: FavoritesToggleAction.added,
          ),
        ),
      );
      await toggle;

      expect(store.favorites, isEmpty);
      expect(store.isFav(5, null), isFalse);
    });

    test('guest load does not call the repository', () async {
      final guestSession = SessionService(
        PrefsStorage(await SharedPreferences.getInstance()),
        _FakeTokenStorage(),
      );
      final guestService = FavoritesService(
        store: FavoritesStore(),
        toggleFavoriteUseCase: ToggleFavoriteUseCase(repository),
        getFavoritesUseCase: GetFavoritesUseCase(repository),
        clearFavoritesUseCase: ClearFavoritesUseCase(repository),
        sessionService: guestSession,
      );

      await guestService.loadFavorites();

      expect(repository.loadCalls, 0);
      expect(guestService.state.value, isA<FavStateError>());
    });

    test('user switch starts a new load and ignores the prior user', () async {
      final prefs = PrefsStorage(await SharedPreferences.getInstance());
      final switchSession = SessionService(prefs, _FakeTokenStorage());
      switchSession.setUser(
        UserEntity(userId: 1, userName: 'U1', userEmail: 'u1@example.com'),
      );
      final scopedStore = FavoritesStore();
      final scopedService = FavoritesService(
        store: scopedStore,
        toggleFavoriteUseCase: ToggleFavoriteUseCase(repository),
        getFavoritesUseCase: GetFavoritesUseCase(repository),
        clearFavoritesUseCase: ClearFavoritesUseCase(repository),
        sessionService: switchSession,
      );
      final userOneLoad = repository.enqueueLoad();
      final userTwoLoad = repository.enqueueLoad();

      final first = scopedService.loadFavorites();
      switchSession.setUser(
        UserEntity(userId: 2, userName: 'U2', userEmail: 'u2@example.com'),
      );
      final second = scopedService.loadFavorites();
      userTwoLoad.complete(right([_favorite(itemId: 2)]));
      await second;
      userOneLoad.complete(right([_favorite(itemId: 1)]));
      await first;

      expect(scopedStore.isFav(2, null), isTrue);
      expect(scopedStore.isFav(1, null), isFalse);
      expect(repository.loadCalls, 2);
    });
  });
}

FavoriteEntity _favorite({required int itemId, int? variantId}) {
  return FavoriteEntity(
    favId: itemId * 10 + (variantId ?? 0),
    itemId: itemId,
    variantId: variantId,
    targetType: variantId == null
        ? FavoriteTargetType.item
        : FavoriteTargetType.variant,
    itemNameAr: 'منتج',
    itemNameEn: 'Product',
    displayImage: 'product.jpg',
    displayPrice: 10,
    originalPrice: 10,
    discount: 0,
    stockQuantity: 2,
    isAvailable: true,
    status: FavoriteStatus.ok,
    createdAt: DateTime.utc(2026, 1, 1),
  );
}

class _FakeFavoritesRepository implements FavoritesRepository {
  final List<Completer<ApiResult<void>>> _clearQueue = [];
  int clearCalls = 0;

  Completer<ApiResult<void>> enqueueClear() {
    final completer = Completer<ApiResult<void>>();
    _clearQueue.add(completer);
    return completer;
  }

  void enqueueClearResult(ApiResult<void> result) =>
      enqueueClear().complete(result);

  @override
  Future<ApiResult<void>> clearFavorites() {
    clearCalls++;
    return _clearQueue.removeAt(0).future;
  }

  final List<Completer<ApiResult<FavoritesToggleResult>>> _toggleQueue = [];
  final List<Completer<ApiResult<List<FavoriteEntity>>>> _loadQueue = [];
  int loadCalls = 0;
  int toggleCalls = 0;

  Completer<ApiResult<FavoritesToggleResult>> enqueueToggle() {
    final completer = Completer<ApiResult<FavoritesToggleResult>>();
    _toggleQueue.add(completer);
    return completer;
  }

  Completer<ApiResult<List<FavoriteEntity>>> enqueueLoad() {
    final completer = Completer<ApiResult<List<FavoriteEntity>>>();
    _loadQueue.add(completer);
    return completer;
  }

  void enqueueToggleResult(ApiResult<FavoritesToggleResult> result) {
    final completer = enqueueToggle();
    completer.complete(result);
  }

  void enqueueLoadResult(ApiResult<List<FavoriteEntity>> result) {
    final completer = enqueueLoad();
    completer.complete(result);
  }

  @override
  Future<ApiResult<List<FavoriteEntity>>> getFavorites() async {
    loadCalls++;
    if (_loadQueue.isEmpty) return right([]);
    return _loadQueue.removeAt(0).future;
  }

  @override
  Future<ApiResult<FavoritesToggleResult>> toggleFavorite({
    required int itemId,
    int? variantId,
  }) {
    toggleCalls++;
    return _toggleQueue.removeAt(0).future;
  }
}
