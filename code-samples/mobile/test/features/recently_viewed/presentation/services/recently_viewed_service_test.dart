import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_project/core/errors/api_result.dart';
import 'package:my_project/core/errors/failure.dart';
import 'package:my_project/core/errors/failure_key.dart';
import 'package:my_project/core/constants/app_pref_key.dart';
import 'package:my_project/features/products/domain/entities/product_card_entity.dart';
import 'package:my_project/features/recently_viewed/domain/repositories/recently_viewed_repository.dart';
import 'package:my_project/features/recently_viewed/domain/usecases/clear_recently_viewed_usecase.dart';
import 'package:my_project/features/recently_viewed/domain/usecases/get_recently_viewed_usecase.dart';
import 'package:my_project/features/recently_viewed/domain/usecases/record_recently_viewed_usecase.dart';
import 'package:my_project/features/recently_viewed/domain/usecases/sync_recently_viewed_usecase.dart';
import 'package:my_project/features/recently_viewed/presentation/services/recently_viewed_service.dart';
import 'package:my_project/features/recently_viewed/presentation/states/recently_viewed_state.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:my_project/core/storage/prefs_storage.dart';
import 'package:my_project/core/storage/token_storage.dart';
import 'package:my_project/features/auth/domain/entities/user_entity.dart';
import 'package:my_project/features/auth/session/session_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeTokenStorage extends TokenStorage {
  _FakeTokenStorage({this.accessToken, this.refreshToken})
    : super(const FlutterSecureStorage());

  final String? accessToken;
  final String? refreshToken;

  @override
  Future<String?> get readAccessToken async => accessToken;

  @override
  Future<String?> get readRefreshToken async => refreshToken;
}

void main() {
  group('RecentlyViewedService', () {
    late _FakeRecentlyViewedRepository repository;
    late PrefsStorage prefsStorage;

    setUp(() async {
      repository = _FakeRecentlyViewedRepository();
      SharedPreferences.setMockInitialValues({});
      prefsStorage = PrefsStorage(await SharedPreferences.getInstance());
    });

    RecentlyViewedService createService({
      bool authenticated = false,
      int userId = 1,
      SessionService? session,
    }) {
      final sessionService =
          session ?? SessionService(prefsStorage, _FakeTokenStorage());
      if (authenticated && session == null) {
        sessionService.setUser(
          UserEntity(
            userId: userId,
            userName: 'User',
            userEmail: 'user@example.com',
          ),
        );
      }
      final service = RecentlyViewedService(
        recordUseCase: RecordRecentlyViewedUseCase(repository),
        getUseCase: GetRecentlyViewedUseCase(repository),
        syncUseCase: SyncRecentlyViewedUseCase(repository),
        clearUseCase: ClearRecentlyViewedUseCase(repository),
        sessionService: sessionService,
      );
      service.onInit();
      addTearDown(service.onClose);
      return service;
    }

    test('coalesces concurrent fetches for the same scope', () async {
      final pending = repository.enqueueGet();
      final service = createService();

      final first = service.fetch();
      final second = service.fetch();

      expect(repository.getCalls, 1);
      pending.complete(right([_card(1)]));
      await Future.wait([first, second]);

      expect(
        service.state.value.maybeWhen(
          success: (_) => true,
          orElse: () => false,
        ),
        isTrue,
      );
    });

    test('authenticated fetch attempts sync before reading history', () async {
      final service = createService(authenticated: true, userId: 7);

      await service.fetch();

      expect(repository.events, ['sync', 'get']);
    });

    test(
      'Guest to authenticated Session transition syncs then reads once',
      () async {
        repository.defaultItems = [_card(3)];
        final session = SessionService(prefsStorage, _FakeTokenStorage());
        final service = createService(session: session);

        session.setUser(
          UserEntity(
            userId: 7,
            userName: 'User',
            userEmail: 'user@example.com',
          ),
        );
        await Future<void>.delayed(Duration.zero);

        expect(repository.events, ['sync', 'get']);
        expect(
          service.state.value.maybeWhen(
            success: (items) => items.single.itemId,
            orElse: () => null,
          ),
          3,
        );
      },
    );

    test(
      'cold Session restore plus Home bootstrap performs one sync and read',
      () async {
        SharedPreferences.setMockInitialValues({
          AppStorageKey.isLogin: true,
          AppStorageKey.userId: 7,
          AppStorageKey.userName: 'User',
          AppStorageKey.userEmail: 'user@example.com',
        });
        final restoredPrefs = PrefsStorage(
          await SharedPreferences.getInstance(),
        );
        final session = SessionService(
          restoredPrefs,
          _FakeTokenStorage(accessToken: 'access', refreshToken: 'refresh'),
        );
        final service = createService(session: session);

        expect(await session.restoreStoredSession(), isTrue);
        await service.fetchForHomeBootstrap();
        await Future<void>.delayed(Duration.zero);

        expect(repository.events, ['sync', 'get']);
      },
    );

    test(
      'failed sync stays non-blocking and account history still loads',
      () async {
        repository.syncResult = const Left(
          Failure.http(key: FailureKey.serverGeneric),
        );
        repository.defaultItems = [_card(2)];
        final service = createService(authenticated: true, userId: 7);

        await service.fetch();

        expect(repository.events, ['sync', 'get']);
        expect(
          service.state.value.maybeWhen(
            success: (items) => items.single.itemId,
            orElse: () => null,
          ),
          2,
        );
      },
    );

    test(
      'reset prevents a late response from publishing old user data',
      () async {
        final pending = repository.enqueueGet();
        final service = createService(authenticated: true, userId: 1);

        final fetch = service.fetch();
        service.reset();
        pending.complete(right([_card(1)]));
        await fetch;

        expect(service.state.value, const RecentlyViewedState.initial());
      },
    );

    test(
      'successful record invalidates older work and refreshes quietly',
      () async {
        repository.defaultItems = [_card(8)];
        final service = createService();

        final result = await service.recordView(itemId: 8, colorGroupId: 3);

        expect(result.isRight(), isTrue);
        expect(repository.recordCalls, 1);
        expect(repository.getCalls, 1);
        expect(repository.recordedKey, (8, 3));
        expect(
          service.state.value.maybeWhen(
            success: (_) => true,
            orElse: () => false,
          ),
          isTrue,
        );
      },
    );

    test(
      'serializes concurrent records by invocation order when B completes first',
      () async {
        final firstPending = repository.enqueueRecord(1);
        final secondPending = repository.enqueueRecord(2);
        final service = createService();

        final first = service.recordView(itemId: 1);
        final second = service.recordView(itemId: 2);
        secondPending.complete(const Right(null));
        await Future<void>.delayed(Duration.zero);

        expect(repository.recordedItems, [1]);

        firstPending.complete(const Right(null));
        await Future.wait([first, second]);

        expect(repository.recordedItems, [1, 2]);
        expect(repository.serverOrder, [2, 1]);
        expect(
          service.state.value.maybeWhen(
            success: (items) => items.map((item) => item.itemId).toList(),
            orElse: () => null,
          ),
          [2, 1],
        );
      },
    );

    test('record failure does not refresh history', () async {
      repository.recordResult = const Left(
        Failure.http(key: FailureKey.serverGeneric),
      );
      final service = createService();

      final result = await service.recordView(itemId: 8, colorGroupId: 3);

      expect(result.isLeft(), isTrue);
      expect(repository.getCalls, 0);
    });

    test(
      'refresh reports failure while preserving an existing snapshot',
      () async {
        repository.defaultItems = [_card(4)];
        final service = createService();
        await service.fetch();
        const failure = Failure.http(key: FailureKey.serverGeneric);
        repository.getResult = const Left(failure);

        final refreshFailure = await service.refreshWithFailure();

        expect(refreshFailure, failure);
        expect(
          service.state.value.maybeWhen(
            success: (items) => items.single.itemId,
            orElse: () => null,
          ),
          4,
        );
      },
    );

    test(
      'first-load failure stays full-screen and is not also reported',
      () async {
        const failure = Failure.http(key: FailureKey.serverGeneric);
        repository.getResult = const Left(failure);
        final service = createService();

        final refreshFailure = await service.refreshWithFailure();

        expect(refreshFailure, isNull);
        expect(service.state.value, const RecentlyViewedState.error(failure));
      },
    );

    test(
      'queued record is skipped after the authenticated scope changes',
      () async {
        final session = SessionService(prefsStorage, _FakeTokenStorage());
        session.setUser(
          UserEntity(userId: 1, userName: 'User1', userEmail: 'u1@example.com'),
        );
        final firstPending = repository.enqueueRecord(1);
        repository.enqueueRecord(2);
        final service = createService(session: session);

        final first = service.recordView(itemId: 1);
        final queued = service.recordView(itemId: 2);
        await Future<void>.delayed(Duration.zero);
        session.setUser(
          UserEntity(userId: 2, userName: 'User2', userEmail: 'u2@example.com'),
        );
        await Future<void>.delayed(Duration.zero);
        firstPending.complete(const Right(null));

        expect((await first).isRight(), isTrue);
        expect((await queued).isRight(), isTrue);
        expect(repository.recordedItems, [1]);
        expect(service.state.value, const RecentlyViewedState.empty());
      },
    );

    test(
      'user switch starts a new scope and ignores the older response',
      () async {
        final session = SessionService(prefsStorage, _FakeTokenStorage());
        session.setUser(
          UserEntity(userId: 1, userName: 'User1', userEmail: 'u1@example.com'),
        );
        final firstPending = repository.enqueueGet();
        final secondPending = repository.enqueueGet();
        final service = createService(session: session);

        final first = service.fetch();
        await Future<void>.delayed(Duration.zero);
        session.setUser(
          UserEntity(userId: 2, userName: 'User2', userEmail: 'u2@example.com'),
        );
        await Future<void>.delayed(Duration.zero);
        final second = service.fetch();
        await Future<void>.delayed(Duration.zero);
        secondPending.complete(right([_card(2)]));
        await second;
        firstPending.complete(right([_card(1)]));
        await first;

        expect(
          service.state.value.maybeWhen(
            success: (items) => items.single.itemId,
            orElse: () => null,
          ),
          2,
        );
      },
    );
  });
}

ProductCardEntity _card(int itemId) {
  return ProductCardEntity(
    itemId: itemId,
    itemNameAr: 'منتج',
    itemNameEn: 'Product',
    displayPrice: 10,
    originalPrice: 10,
    hasDiscount: false,
    maxDiscountPct: 0,
    itemDisplayImage: 'item.jpg',
    availableColors: const [],
    availableSizes: const [],
    isFeatured: false,
    images: const ['item.jpg'],
    stockQuantity: 2,
    badges: const [],
  );
}

class _FakeRecentlyViewedRepository implements RecentlyViewedRepository {
  final List<Completer<ApiResult<List<ProductCardEntity>>>> _getQueue = [];
  final List<String> events = [];
  ApiResult<void> syncResult = const Right(null);
  ApiResult<void> recordResult = const Right(null);
  ApiResult<List<ProductCardEntity>>? getResult;
  List<ProductCardEntity> defaultItems = [];
  final List<int> recordedItems = [];
  final List<int> serverOrder = [];
  final Map<int, Completer<ApiResult<void>>> _recordQueue = {};
  int getCalls = 0;
  int recordCalls = 0;
  (int, int?)? recordedKey;

  Completer<ApiResult<List<ProductCardEntity>>> enqueueGet() {
    final completer = Completer<ApiResult<List<ProductCardEntity>>>();
    _getQueue.add(completer);
    return completer;
  }

  Completer<ApiResult<void>> enqueueRecord(int itemId) {
    final completer = Completer<ApiResult<void>>();
    _recordQueue[itemId] = completer;
    return completer;
  }

  @override
  Future<ApiResult<List<ProductCardEntity>>> getRecentlyViewed() {
    events.add('get');
    getCalls++;
    if (_getQueue.isNotEmpty) return _getQueue.removeAt(0).future;
    final queuedResult = getResult;
    if (queuedResult != null) return Future.value(queuedResult);
    final items = serverOrder.isEmpty
        ? defaultItems
        : serverOrder.map(_card).toList();
    return Future.value(right(items));
  }

  @override
  Future<ApiResult<void>> syncGuestKeysIfAny() async {
    events.add('sync');
    return syncResult;
  }

  @override
  Future<ApiResult<void>> recordView({
    required int itemId,
    int? colorGroupId,
  }) async {
    recordCalls++;
    recordedItems.add(itemId);
    recordedKey = (itemId, colorGroupId);
    final pending = _recordQueue.remove(itemId);
    final result = pending == null ? recordResult : await pending.future;
    if (result.isRight()) {
      serverOrder
        ..remove(itemId)
        ..insert(0, itemId);
    }
    return result;
  }

  @override
  Future<ApiResult<void>> clearRecentlyViewed() async => const Right(null);

  @override
  Future<void> clearLocalKeys() async {}
}
