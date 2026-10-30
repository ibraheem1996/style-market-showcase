import 'package:dartz/dartz.dart';
import 'package:get/get.dart';

import '../../../../core/errors/app_failure_key.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/errors/failure_key.dart' show FailureKey;
import '../../../../core/services/crashlytics_service.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../../domain/entities/cart_upsert_input.dart';
import '../../domain/usecases/clear_cart_usecase.dart';
import '../../domain/usecases/get_cart_usecase.dart';
import '../../domain/usecases/toggle_cart_usecase.dart';
import '../../domain/usecases/toggle_selection_usecase.dart';
import '../logic/cart_line_identity.dart';
import '../logic/cart_local_mutation.dart';
import '../store/cart_store.dart';

class CartOperations extends GetxService {
  CartOperations({
    required CartStore store,
    required this.getCartUseCase,
    required this.toggleCartUseCase,
    required this.clearCartUseCase,
    required this.toggleSelectionUseCase,
    required this.crash,
  }) : _store = store;

  final CartStore _store;
  final GetCartUseCase getCartUseCase;
  final ToggleCartUseCase toggleCartUseCase;
  final ClearCartUseCase clearCartUseCase;
  final ToggleSelectionUseCase toggleSelectionUseCase;
  final CrashlyticsService crash;

  final RxBool _isClearing = false.obs;
  final RxSet<String> _lineOperationKeys = <String>{}.obs;
  final RxMap<String, int> _lineOperationTokens = <String, int>{}.obs;
  final RxSet<int> _selectionOperationKeys = <int>{}.obs;
  final RxMap<int, int> _selectionOperationTokens = <int, int>{}.obs;

  int _latestRefreshRequest = 0;
  int _nextOperationToken = 0;
  int _mutationVersion = 0;

  bool get isClearing => _isClearing.value;

  bool get hasPendingCheckoutOperation {
    return _isClearing.value ||
        _lineOperationKeys.isNotEmpty ||
        _selectionOperationKeys.isNotEmpty;
  }

  bool isLineOperationInFlight(int itemId, int? variantId) {
    return _lineOperationKeys.contains(
      CartLineIdentity(itemId: itemId, variantId: variantId).operationKey,
    );
  }

  bool isLineOperationInFlightForItem(CartItemEntity item) {
    return isLineOperationInFlight(item.itemId, item.variantId);
  }

  bool isSelectionOperationInFlight(int cartId) {
    return _selectionOperationKeys.contains(cartId);
  }

  Future<Either<Failure, CartAction>> upsertInput(
    CartUpsertInput input, {
    required int quantityDelta,
  }) async {
    final identity = CartLineIdentity.fromInput(input);
    if (_isLineOperationActive(identity)) {
      return Left(Failure.app(key: AppFailureKey.loading));
    }

    final operationToken = _beginLineOperation(identity);
    final lineSnapshot = CartLocalMutation.snapshotLine(_store.items, identity);
    CartLocalMutation.applyInputDelta(
      _store,
      input: input,
      quantityDelta: quantityDelta,
    );

    try {
      final result = await toggleCartUseCase(
        ToggleCartParams(
          itemId: input.itemId,
          variantId: identity.variantId,
          quantity: quantityDelta,
        ),
      );
      final isSameOperation = _isLineOperationTokenActive(
        identity,
        operationToken,
      );

      return result.fold(
        (failure) {
          if (isSameOperation) {
            CartLocalMutation.restoreLine(_store, lineSnapshot);
          }
          return Left(failure);
        },
        (result) {
          if (isSameOperation) {
            CartLocalMutation.applyServerResult(
              _store,
              identity: identity,
              action: result.action,
              item: result.item,
            );
          }
          return Right(result.action);
        },
      );
    } catch (error, stackTrace) {
      crash.logError(error, stackTrace, reason: 'CartOperations.upsert input');
      if (_isLineOperationTokenActive(identity, operationToken)) {
        CartLocalMutation.restoreLine(_store, lineSnapshot);
      }
      return Left(Failure.http(key: FailureKey.unexpected));
    } finally {
      _finishLineOperation(identity, token: operationToken);
    }
  }

  Future<Either<Failure, CartAction>> changeQuantity({
    required CartItemEntity cartItem,
    required int quantityDelta,
  }) async {
    final identity = CartLineIdentity.fromItem(cartItem);
    if (_isLineOperationActive(identity)) {
      return Left(Failure.app(key: AppFailureKey.loading));
    }

    final operationToken = _beginLineOperation(identity);
    final lineSnapshot = CartLocalMutation.snapshotLine(_store.items, identity);
    CartLocalMutation.applyCartLineDelta(
      _store,
      item: cartItem,
      quantityDelta: quantityDelta,
    );

    try {
      final result = await toggleCartUseCase(
        ToggleCartParams(
          itemId: cartItem.itemId,
          variantId: identity.variantId,
          quantity: quantityDelta,
        ),
      );

      return result.fold(
        (failure) {
          if (_isLineOperationTokenActive(identity, operationToken)) {
            CartLocalMutation.restoreLine(_store, lineSnapshot);
          }
          return Left(failure);
        },
        (result) {
          if (_isLineOperationTokenActive(identity, operationToken)) {
            CartLocalMutation.applyServerResult(
              _store,
              identity: identity,
              action: result.action,
              item: result.item,
            );
          }
          return Right(result.action);
        },
      );
    } catch (error, stackTrace) {
      crash.logError(
        error,
        stackTrace,
        reason: 'CartOperations.change quantity',
      );
      if (_isLineOperationTokenActive(identity, operationToken)) {
        CartLocalMutation.restoreLine(_store, lineSnapshot);
      }
      return Left(Failure.http(key: FailureKey.unexpected));
    } finally {
      _finishLineOperation(identity, token: operationToken);
    }
  }

  Future<Either<Failure, CartAction>> removeLine({
    required CartItemEntity cartItem,
  }) {
    return changeQuantity(cartItem: cartItem, quantityDelta: 0);
  }

  Future<Either<Failure, void>> toggleSelection({
    required int cartId,
    required bool isSelected,
  }) async {
    if (isSelectionOperationInFlight(cartId)) {
      return Left(Failure.app(key: AppFailureKey.loading));
    }

    final operationToken = _beginSelectionOperation(cartId);
    final selectionSnapshot = CartLocalMutation.snapshotSelection(
      _store.items,
      cartId,
    );
    _store.setSelectionAt(_store.indexOfCartId(cartId), isSelected);

    try {
      final result = await toggleSelectionUseCase(
        cartId: cartId,
        isSelected: isSelected,
      );

      return result.fold((failure) {
        if (_isSelectionOperationTokenActive(cartId, operationToken)) {
          CartLocalMutation.restoreSelection(_store, selectionSnapshot);
        }
        return Left(failure);
      }, (_) => const Right(null));
    } catch (error, stackTrace) {
      crash.logError(
        error,
        stackTrace,
        reason: 'CartOperations.toggle selection',
      );
      if (_isSelectionOperationTokenActive(cartId, operationToken)) {
        CartLocalMutation.restoreSelection(_store, selectionSnapshot);
      }
      return Left(Failure.http(key: FailureKey.unexpected));
    } finally {
      _finishSelectionOperation(cartId, token: operationToken);
    }
  }

  Future<Either<Failure, CartRefreshOutcome>> refreshCart() async {
    final requestId = ++_latestRefreshRequest;
    final mutationBaseline = _mutationVersion;
    final result = await getCartUseCase();
    if (requestId != _latestRefreshRequest) {
      return const Right(CartRefreshOutcome.ignoredStaleRefresh);
    }

    return result.fold(
      (failure) {
        failure.mapOrNull(
          http: (failure) {
            switch (failure.key) {
              case FailureKey.userNotFound:
              case FailureKey.forbidden:
              case FailureKey.unauthorized:
                clearLocalOnly();
              default:
            }
            return null;
          },
        );
        return Left(failure);
      },
      (items) {
        if (_mutationVersion == mutationBaseline) {
          _store.replaceItems(items);
          return const Right(CartRefreshOutcome.applied);
        }
        return const Right(CartRefreshOutcome.ignoredDuringMutation);
      },
    );
  }

  Future<Either<Failure, void>> clearAllCart() async {
    if (_isClearing.value) {
      return Left(Failure.app(key: AppFailureKey.loading));
    }

    _isClearing.value = true;
    try {
      final result = await clearCartUseCase();
      return result.fold((failure) => Left(failure), (_) {
        clearLocalOnly();
        return const Right(null);
      });
    } finally {
      _isClearing.value = false;
    }
  }

  void clearLocalOnly() {
    _mutationVersion++;
    _lineOperationKeys.clear();
    _lineOperationTokens.clear();
    _selectionOperationKeys.clear();
    _selectionOperationTokens.clear();
    _store.clearLocal();
  }

  void removePurchasedLocal(List<CartItemEntity> purchasedItems) {
    _mutationVersion++;
    CartLocalMutation.removePurchasedLocal(_store, purchasedItems);
  }

  int _beginLineOperation(CartLineIdentity identity) {
    final token = ++_nextOperationToken;
    _lineOperationKeys.add(identity.operationKey);
    _lineOperationTokens[identity.operationKey] = token;
    _mutationVersion++;
    return token;
  }

  void _finishLineOperation(CartLineIdentity identity, {int? token}) {
    final key = identity.operationKey;
    if (token != null && _lineOperationTokens[key] != token) return;
    _lineOperationTokens.remove(key);
    _lineOperationKeys.remove(key);
  }

  bool _isLineOperationActive(CartLineIdentity identity) {
    return _lineOperationKeys.contains(identity.operationKey);
  }

  bool _isLineOperationTokenActive(CartLineIdentity identity, int token) {
    return _lineOperationTokens[identity.operationKey] == token;
  }

  int _beginSelectionOperation(int cartId) {
    final token = ++_nextOperationToken;
    _selectionOperationKeys.add(cartId);
    _selectionOperationTokens[cartId] = token;
    _mutationVersion++;
    return token;
  }

  void _finishSelectionOperation(int cartId, {int? token}) {
    if (token != null && _selectionOperationTokens[cartId] != token) return;
    _selectionOperationTokens.remove(cartId);
    _selectionOperationKeys.remove(cartId);
  }

  bool _isSelectionOperationTokenActive(int cartId, int token) {
    return _selectionOperationTokens[cartId] == token;
  }
}

enum CartRefreshOutcome { applied, ignoredStaleRefresh, ignoredDuringMutation }
