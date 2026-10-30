import 'package:dartz/dartz.dart';
import 'package:get/get.dart';

import '../../../../core/errors/app_failure_key.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/errors/failure_key.dart';
import 'package:my_project/features/auth/session/session_service.dart';

import '../../domain/entities/favorite_entity.dart';
import '../../domain/entities/favorites_toggle_result.dart';
import '../../domain/usecases/get_favorites_usecase.dart';
import '../../domain/usecases/clear_favorites_usecase.dart';
import '../../domain/usecases/toggle_favorite_usecase.dart';
import '../state/fav_state.dart';
import '../store/favorites_store.dart';

class FavoritesService extends GetxService {
  FavoritesService({
    required this.store,
    required this.toggleFavoriteUseCase,
    required this.getFavoritesUseCase,
    required this.clearFavoritesUseCase,
    required this.sessionService,
  });

  final FavoritesStore store;
  final ToggleFavoriteUseCase toggleFavoriteUseCase;
  final GetFavoritesUseCase getFavoritesUseCase;
  final ClearFavoritesUseCase clearFavoritesUseCase;
  final SessionService sessionService;

  final state = const FavState.initial().obs;
  final Rxn<(int, int?)> _pendingToggle = Rxn<(int, int?)>();
  final RxBool _isClearing = false.obs;

  Future<Failure?>? _loadFuture;
  int _revision = 0;
  int? _ownerUserId;

  List<FavoriteEntity> get favorites => store.favorites;

  bool get hasPendingToggle => _pendingToggle.value != null;

  bool get isClearing => _isClearing.value;

  bool isFavorite(int itemId, int? variantId) {
    return store.isFav(itemId, variantId);
  }

  bool isTogglePending(int itemId, int? variantId) {
    return _pendingToggle.value == (itemId, variantId);
  }

  bool canToggle(int itemId, int? variantId) {
    return !hasPendingToggle && !isClearing;
  }

  void requireLogin() {
    reset();
    state.value = const FavState.error(
      Failure.app(key: AppFailureKey.loginRequired),
    );
  }

  /// Invalidates prior requests and removes all user-scoped Favorites data.
  void reset() {
    _revision++;
    _loadFuture = null;
    _pendingToggle.value = null;
    _isClearing.value = false;
    _ownerUserId = null;
    store.clearAll();
    state.value = const FavState.initial();
  }

  Future<void> loadFavorites() async {
    await _requestFavorites(preserveSnapshot: false);
  }

  /// Refreshes the authoritative list without hiding an already loaded view.
  Future<Failure?> refreshFavorites() {
    return _requestFavorites(preserveSnapshot: true);
  }

  Future<Failure?> _requestFavorites({required bool preserveSnapshot}) {
    final userId = _authenticatedUserId();
    if (userId == null) {
      final failure = Failure.app(key: AppFailureKey.loginRequired);
      requireLogin();
      return Future.value(failure);
    }
    _enterUserScope(userId);

    final activeLoad = _loadFuture;
    if (activeLoad != null) return activeLoad;

    final future = _loadFavorites(userId, preserveSnapshot: preserveSnapshot);
    _loadFuture = future;
    future.whenComplete(() {
      if (identical(_loadFuture, future)) {
        _loadFuture = null;
      }
    });
    return future;
  }

  Future<Failure?> _loadFavorites(
    int userId, {
    required bool preserveSnapshot,
  }) async {
    final requestRevision = _revision;
    final keepSnapshot = preserveSnapshot && state.value is FavStateLoaded;
    if (!keepSnapshot) {
      state.value = const FavState.loading();
    }
    final result = await getFavoritesUseCase();

    if (!_isCurrent(requestRevision, userId)) return null;

    return result.fold(
      (failure) {
        state.value = keepSnapshot
            ? const FavState.loaded()
            : FavState.error(failure);
        return failure;
      },
      (favoritesList) {
        store.setAllFavorites(favoritesList);
        state.value = const FavState.loaded();
        return null;
      },
    );
  }

  Future<Either<Failure, ToggleFavoriteResult>> toggle(
    int itemId, {
    int? variantId,
  }) async {
    if (isClearing) {
      return left(Failure.app(key: AppFailureKey.loading));
    }
    return _toggle(itemId, variantId: variantId);
  }

  Future<Either<Failure, ToggleFavoriteResult>> _toggle(
    int itemId, {
    int? variantId,
  }) async {
    final userId = _authenticatedUserId();
    if (userId == null) {
      return left(Failure.app(key: AppFailureKey.loginRequired));
    }
    _enterUserScope(userId);
    if (hasPendingToggle) {
      return left(Failure.app(key: AppFailureKey.loading));
    }

    final requestRevision = ++_revision;
    _loadFuture = null;
    _pendingToggle.value = (itemId, variantId);
    final wasFav = store.isFav(itemId, variantId);
    store.toggleLocal(itemId, variantId);

    try {
      final result = await toggleFavoriteUseCase(
        ToggleFavoriteParams(itemId: itemId, variantId: variantId),
      );

      if (!_isCurrent(requestRevision, userId)) {
        return left(Failure.app(key: AppFailureKey.loginRequired));
      }

      return await result.fold(
        (failure) async {
          store.setFav(itemId, variantId, wasFav);
          if (state.value is FavStateLoading) {
            state.value = const FavState.loaded();
          }
          if (failure.isTransportFailure ||
              failure.maybeWhen(
                http: (key, statusCode, _, __, ___) =>
                    key == FailureKey.invalidData && statusCode == 200,
                orElse: () => false,
              )) {
            await refreshFavorites();
          }
          return left(failure);
        },
        (toggleRes) async {
          if (toggleRes.action == FavoritesToggleAction.added) {
            store.upsert(toggleRes.favorite!);
          } else {
            store.remove(itemId, variantId);
          }
          state.value = const FavState.loaded();
          return right(
            toggleRes.action == FavoritesToggleAction.added
                ? ToggleFavoriteResult.added
                : ToggleFavoriteResult.removed,
          );
        },
      );
    } finally {
      if (_revision == requestRevision) {
        _pendingToggle.value = null;
      }
    }
  }

  /// Clears the authenticated user's favorites with one server mutation.
  Future<Either<Failure, void>> clearAllFavorites() async {
    final userId = _authenticatedUserId();
    if (userId == null) {
      return left(Failure.app(key: AppFailureKey.loginRequired));
    }
    _enterUserScope(userId);

    if (isClearing || hasPendingToggle) {
      return left(Failure.app(key: AppFailureKey.loading));
    }

    final requestRevision = ++_revision;
    _loadFuture = null;
    _isClearing.value = true;
    try {
      final result = await clearFavoritesUseCase();
      if (!_isCurrent(requestRevision, userId)) {
        return left(Failure.app(key: AppFailureKey.loginRequired));
      }
      return result.fold(
        (failure) {
          if (store.favorites.isNotEmpty) state.value = const FavState.loaded();
          return left(failure);
        },
        (_) {
          _revision++;
          _loadFuture = null;
          store.clearAll();
          state.value = const FavState.loaded();
          _isClearing.value = false;
          return right(null);
        },
      );
    } finally {
      if (_revision == requestRevision) _isClearing.value = false;
    }
  }

  int? _authenticatedUserId() {
    if (!sessionService.isAuthenticated) return null;
    return sessionService.userId;
  }

  bool _isCurrent(int requestRevision, int userId) {
    return requestRevision == _revision &&
        sessionService.isAuthenticated &&
        sessionService.userId == userId;
  }

  void _enterUserScope(int userId) {
    if (_ownerUserId != null && _ownerUserId != userId) {
      reset();
    }
    _ownerUserId = userId;
  }
}

enum ToggleFavoriteResult { added, removed }
