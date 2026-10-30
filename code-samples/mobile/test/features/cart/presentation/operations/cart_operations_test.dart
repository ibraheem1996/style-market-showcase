import 'package:my_project/core/services/crashlytics_service.dart';
import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:my_project/core/errors/api_result.dart';
import 'package:my_project/core/errors/app_failure_key.dart';
import 'package:my_project/core/errors/failure.dart';
import 'package:my_project/core/errors/failure_key.dart';
import 'package:my_project/features/cart/domain/entities/cart_item_entity.dart';
import 'package:my_project/features/cart/domain/entities/cart_upsert_input.dart';
import 'package:my_project/features/cart/domain/repositories/cart_repository.dart';
import 'package:my_project/features/cart/domain/usecases/clear_cart_usecase.dart';
import 'package:my_project/features/cart/domain/usecases/get_cart_usecase.dart';
import 'package:my_project/features/cart/domain/usecases/toggle_cart_usecase.dart';
import 'package:my_project/features/cart/domain/usecases/toggle_selection_usecase.dart';
import 'package:my_project/features/cart/presentation/operations/cart_operations.dart';
import 'package:my_project/features/cart/presentation/store/cart_store.dart';

void main() {
  group('CartOperations', () {
    late CartStore store;
    late _FakeCartRepository repository;
    late CartOperations operations;
    late _NoopCrashlyticsService crash;

    setUp(() {
      store = CartStore();
      repository = _FakeCartRepository();
      crash = _NoopCrashlyticsService();
      operations = CartOperations(
        store: store,
        getCartUseCase: GetCartUseCase(repository),
        toggleCartUseCase: ToggleCartUseCase(repository),
        clearCartUseCase: ClearCartUseCase(repository),
        toggleSelectionUseCase: ToggleSelectionUseCase(repository),
        crash: crash,
      );
    });

    test('replaces optimistic item with server item on success', () async {
      final serverItem = CartItemEntity.local(
        cartId: 12,
        itemId: 5,
        cartQuantity: 1,
        image: 'server.jpg',
        price: 10,
        lineTotal: 10,
      );
      repository.toggleResult = Right(
        ToggleCartResult(action: CartAction.updated, item: serverItem),
      );

      final result = await operations.upsertInput(
        _input(itemId: 5),
        quantityDelta: 1,
      );

      result.fold(
        (failure) => fail('Expected success, got $failure'),
        (action) => expect(action, CartAction.updated),
      );
      expect(store.items.single.cartId, 12);
      expect(store.items.single.image, 'server.jpg');
      expect(repository.toggleCalls, 1);
    });

    test('reports a thrown upsert error once and rolls back', () async {
      store.replaceItems([
        CartItemEntity.local(itemId: 1, cartQuantity: 1, image: 'old.jpg'),
      ]);
      repository.throwOnToggle = true;

      final result = await operations.upsertInput(
        _input(itemId: 2),
        quantityDelta: 1,
      );

      expect(
        result.fold((failure) => failure.key, (_) => null),
        FailureKey.unexpected,
      );
      expect(store.items.single.itemId, 1);
      expect(crash.errors, hasLength(1));
      expect(crash.errors.single, isA<StateError>());
      expect(crash.stacks.single, isNotNull);
    });

    test('restores snapshot on failure', () async {
      store.replaceItems([
        CartItemEntity.local(itemId: 1, cartQuantity: 1, image: 'old.jpg'),
      ]);
      repository.toggleResult = const Left(
        Failure.http(key: FailureKey.serverGeneric),
      );

      final result = await operations.upsertInput(
        _input(itemId: 2),
        quantityDelta: 1,
      );

      result.fold(
        (failure) =>
            expect(failure, const Failure.http(key: FailureKey.serverGeneric)),
        (_) => fail('Expected failure'),
      );
      expect(store.items, hasLength(1));
      expect(store.items.single.itemId, 1);
    });

    test(
      'returns loading failure while an upsert is already running',
      () async {
        final pending = repository.enqueueToggle();
        final first = operations.upsertInput(
          _input(itemId: 3),
          quantityDelta: 1,
        );

        final second = await operations.upsertInput(
          _input(itemId: 3),
          quantityDelta: 1,
        );

        second.fold(
          (failure) => expect(failure, Failure.app(key: AppFailureKey.loading)),
          (_) => fail('Expected loading failure'),
        );
        expect(repository.toggleCalls, 1);
        pending.complete(Right(ToggleCartResult(action: CartAction.added)));
        await first;
      },
    );

    test('clears upsert key after success, failure, and throw', () async {
      repository.toggleResult = Right(
        ToggleCartResult(
          action: CartAction.updated,
          item: CartItemEntity.local(
            itemId: 4,
            cartQuantity: 1,
            image: 'server.jpg',
            lineTotal: 10,
          ),
        ),
      );
      await operations.upsertInput(_input(itemId: 4), quantityDelta: 1);
      expect(operations.isLineOperationInFlight(4, null), isFalse);

      repository.toggleResult = const Left(
        Failure.http(key: FailureKey.serverGeneric),
      );
      await operations.upsertInput(_input(itemId: 4), quantityDelta: 1);
      expect(operations.isLineOperationInFlight(4, null), isFalse);

      repository.throwOnToggle = true;
      await operations.upsertInput(_input(itemId: 4), quantityDelta: 1);
      expect(operations.isLineOperationInFlight(4, null), isFalse);
    });

    test(
      'per-line rollback keeps a newer success on a different line',
      () async {
        store.replaceItems([
          CartItemEntity.local(
            cartId: 1,
            itemId: 1,
            cartQuantity: 1,
            price: 10,
            lineTotal: 10,
            image: 'one.jpg',
          ),
          CartItemEntity.local(
            cartId: 2,
            itemId: 2,
            cartQuantity: 1,
            price: 20,
            lineTotal: 20,
            image: 'two.jpg',
          ),
        ]);
        final first = repository.enqueueToggle();
        final second = repository.enqueueToggle();

        final firstResult = operations.changeQuantity(
          cartItem: store.items[0],
          quantityDelta: 1,
        );
        final secondResult = operations.changeQuantity(
          cartItem: store.items[1],
          quantityDelta: 1,
        );

        second.complete(
          Right(
            ToggleCartResult(
              action: CartAction.updated,
              item: CartItemEntity.local(
                cartId: 2,
                itemId: 2,
                cartQuantity: 2,
                price: 20,
                lineTotal: 40,
                image: 'two-server.jpg',
              ),
            ),
          ),
        );
        await secondResult;
        first.complete(const Left(Failure.http(key: FailureKey.serverGeneric)));
        await firstResult;

        expect(store.findLine(1, null)?.cartQuantity, 1);
        expect(store.findLine(2, null)?.cartQuantity, 2);
        expect(store.findLine(2, null)?.image, 'two-server.jpg');
      },
    );

    test('line loading does not block another cart line', () async {
      store.replaceItems([
        CartItemEntity.local(cartId: 1, itemId: 1, image: 'one.jpg'),
        CartItemEntity.local(cartId: 2, itemId: 2, image: 'two.jpg'),
      ]);
      final first = repository.enqueueToggle();
      repository.toggleResult = Right(
        ToggleCartResult(
          action: CartAction.updated,
          item: CartItemEntity.local(
            cartId: 2,
            itemId: 2,
            cartQuantity: 2,
            image: 'two-server.jpg',
          ),
        ),
      );

      final firstResult = operations.changeQuantity(
        cartItem: store.items[0],
        quantityDelta: 1,
      );
      final secondResult = await operations.changeQuantity(
        cartItem: store.items[1],
        quantityDelta: 1,
      );
      first.complete(
        Right(
          ToggleCartResult(action: CartAction.updated, item: store.items[0]),
        ),
      );
      await firstResult;

      secondResult.fold(
        (failure) => fail('Expected second line success, got $failure'),
        (_) {},
      );
      expect(repository.toggleCalls, 2);
    });

    test('update sends null variant id for simple line', () async {
      store.replaceItems([
        CartItemEntity.local(cartId: 1, itemId: 1, image: 'a.jpg'),
      ]);

      await operations.changeQuantity(
        cartItem: store.items.single,
        quantityDelta: 1,
      );

      expect(repository.variantIds.single, isNull);
    });

    test('different variants use different operation keys', () async {
      store.replaceItems([
        CartItemEntity.local(
          cartId: 1,
          itemId: 1,
          variantId: 7,
          image: 'red.jpg',
        ),
        CartItemEntity.local(
          cartId: 2,
          itemId: 1,
          variantId: 8,
          image: 'blue.jpg',
        ),
      ]);
      final first = repository.enqueueToggle();
      final second = repository.enqueueToggle();

      final firstResult = operations.changeQuantity(
        cartItem: store.items[0],
        quantityDelta: 1,
      );
      final secondResult = operations.changeQuantity(
        cartItem: store.items[1],
        quantityDelta: 1,
      );
      first.complete(
        Right(
          ToggleCartResult(action: CartAction.updated, item: store.items[0]),
        ),
      );
      second.complete(
        Right(
          ToggleCartResult(action: CartAction.updated, item: store.items[1]),
        ),
      );

      await firstResult;
      await secondResult;

      expect(repository.variantIds, [7, 8]);
    });

    test('selection rollback restores only the targeted selection', () async {
      store.replaceItems([
        CartItemEntity.local(
          cartId: 1,
          itemId: 1,
          image: 'one.jpg',
          isSelected: true,
        ),
        CartItemEntity.local(
          cartId: 2,
          itemId: 2,
          image: 'two.jpg',
          isSelected: true,
        ),
      ]);
      repository.selectionResult = const Left(
        Failure.http(key: FailureKey.serverGeneric),
      );

      await operations.toggleSelection(cartId: 1, isSelected: false);

      expect(store.items.first.isSelected, isTrue);
      expect(store.items.last.isSelected, isTrue);
      expect(operations.isSelectionOperationInFlight(1), isFalse);
    });

    test(
      'checkout stays pending while selected line is being unselected',
      () async {
        store.replaceItems([
          CartItemEntity.local(
            cartId: 1,
            itemId: 1,
            image: 'one.jpg',
            isSelected: true,
          ),
          CartItemEntity.local(
            cartId: 2,
            itemId: 2,
            image: 'two.jpg',
            isSelected: true,
          ),
        ]);
        final selection = repository.enqueueSelection();

        final result = operations.toggleSelection(cartId: 1, isSelected: false);

        expect(store.items.first.isSelected, isFalse);
        expect(operations.isSelectionOperationInFlight(1), isTrue);
        expect(operations.hasPendingCheckoutOperation, isTrue);

        selection.complete(const Right(null));
        await result;

        expect(operations.hasPendingCheckoutOperation, isFalse);
      },
    );

    test('stale refresh response does not replace a newer refresh', () async {
      final first = repository.enqueueGetCart();
      final second = repository.enqueueGetCart();

      final firstRefresh = operations.refreshCart();
      final secondRefresh = operations.refreshCart();

      second.complete(
        Right([
          CartItemEntity.local(itemId: 2, cartQuantity: 2, image: 'new.jpg'),
        ]),
      );
      final secondResult = await secondRefresh;
      first.complete(
        Right([
          CartItemEntity.local(itemId: 1, cartQuantity: 1, image: 'old.jpg'),
        ]),
      );
      final firstResult = await firstRefresh;

      expect(store.items.single.itemId, 2);
      secondResult.fold(
        (failure) => fail('Expected second refresh success, got $failure'),
        (outcome) => expect(outcome, CartRefreshOutcome.applied),
      );
      firstResult.fold(
        (failure) => fail('Expected stale refresh success, got $failure'),
        (outcome) => expect(outcome, CartRefreshOutcome.ignoredStaleRefresh),
      );
    });

    test(
      'refresh started before mutation does not replace mutation state',
      () async {
        store.replaceItems([
          CartItemEntity.local(
            itemId: 1,
            cartQuantity: 1,
            price: 10,
            lineTotal: 10,
            image: 'current.jpg',
          ),
        ]);
        final refreshCompleter = repository.enqueueGetCart();
        final mutationCompleter = repository.enqueueToggle();

        final refresh = operations.refreshCart();
        final mutation = operations.changeQuantity(
          cartItem: store.items.single,
          quantityDelta: 1,
        );
        refreshCompleter.complete(
          Right([
            CartItemEntity.local(
              itemId: 1,
              cartQuantity: 1,
              image: 'stale.jpg',
            ),
          ]),
        );
        final refreshResult = await refresh;

        expect(store.items.single.cartQuantity, 2);
        refreshResult.fold(
          (failure) => fail('Expected refresh success, got $failure'),
          (outcome) =>
              expect(outcome, CartRefreshOutcome.ignoredDuringMutation),
        );
        mutationCompleter.complete(
          Right(
            ToggleCartResult(
              action: CartAction.updated,
              item: store.items.single,
            ),
          ),
        );
        await mutation;
      },
    );

    test(
      'clearLocalOnly clears cart store for logout or user switch cleanup',
      () {
        store.replaceItems([
          CartItemEntity.local(itemId: 1, cartQuantity: 1, image: 'cart.jpg'),
        ]);

        operations.clearLocalOnly();

        expect(store.items, isEmpty);
      },
    );

    test(
      'clearAllCart loading lives in operations and resets in finally',
      () async {
        final clear = repository.enqueueClear();
        final first = operations.clearAllCart();

        expect(operations.isClearing, isTrue);
        final second = await operations.clearAllCart();
        second.fold(
          (failure) => expect(failure, Failure.app(key: AppFailureKey.loading)),
          (_) => fail('Expected loading failure'),
        );

        clear.complete(const Right(null));
        await first;
        expect(operations.isClearing, isFalse);
      },
    );
  });
}

CartUpsertInput _input({required int itemId, int? variantId}) {
  return CartUpsertInput(
    itemId: itemId,
    variantId: variantId,
    itemName: 'Item',
    itemDescription: '',
    image: 'item.jpg',
    price: 10,
    discount: 0,
  );
}

class _FakeCartRepository implements CartRepository {
  ApiResult<ToggleCartResult> toggleResult = Right(
    ToggleCartResult(action: CartAction.added),
  );
  ApiResult<void> selectionResult = const Right(null);
  int toggleCalls = 0;
  bool throwOnToggle = false;
  final variantIds = <int?>[];
  final _toggleQueue = <Completer<ApiResult<ToggleCartResult>>>[];
  final _getCartQueue = <Completer<ApiResult<List<CartItemEntity>>>>[];
  final _clearQueue = <Completer<ApiResult<void>>>[];
  final _selectionQueue = <Completer<ApiResult<void>>>[];

  Completer<ApiResult<ToggleCartResult>> enqueueToggle() {
    final completer = Completer<ApiResult<ToggleCartResult>>();
    _toggleQueue.add(completer);
    return completer;
  }

  Completer<ApiResult<List<CartItemEntity>>> enqueueGetCart() {
    final completer = Completer<ApiResult<List<CartItemEntity>>>();
    _getCartQueue.add(completer);
    return completer;
  }

  Completer<ApiResult<void>> enqueueClear() {
    final completer = Completer<ApiResult<void>>();
    _clearQueue.add(completer);
    return completer;
  }

  Completer<ApiResult<void>> enqueueSelection() {
    final completer = Completer<ApiResult<void>>();
    _selectionQueue.add(completer);
    return completer;
  }

  @override
  Future<ApiResult<void>> clearCart() async {
    if (_clearQueue.isNotEmpty) return _clearQueue.removeAt(0).future;
    return const Right(null);
  }

  @override
  Future<ApiResult<List<CartItemEntity>>> getCart() async {
    if (_getCartQueue.isNotEmpty) return _getCartQueue.removeAt(0).future;
    return const Right([]);
  }

  @override
  Future<ApiResult<ToggleCartResult>> toggleCart({
    required int itemId,
    int? variantId,
    required int quantity,
  }) async {
    toggleCalls++;
    variantIds.add(variantId);
    if (throwOnToggle) throw StateError('boom');
    if (_toggleQueue.isNotEmpty) return _toggleQueue.removeAt(0).future;
    return toggleResult;
  }

  @override
  Future<ApiResult<void>> toggleSelection({
    required int cartId,
    required bool isSelected,
  }) async {
    if (_selectionQueue.isNotEmpty) return _selectionQueue.removeAt(0).future;
    return selectionResult;
  }
}

class _NoopCrashlyticsService implements CrashlyticsService {
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

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
