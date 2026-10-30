import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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
import 'package:my_project/core/storage/token_storage.dart';
import 'package:my_project/features/auth/domain/entities/user_entity.dart';
import 'package:my_project/features/auth/session/session_service.dart';
import 'package:my_project/features/cart/data/datasources/remote/cart_remote_datasource.dart';
import 'package:my_project/features/cart/data/models/cart_item_model.dart';
import 'package:my_project/features/cart/data/models/toggle_cart_request.dart';
import 'package:my_project/features/cart/data/models/toggle_selection_request.dart';
import 'package:my_project/features/cart/data/repositories/cart_repository_impl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeTokenStorage extends TokenStorage {
  _FakeTokenStorage() : super(const FlutterSecureStorage());
}

void main() {
  late SessionService session;
  late _FakeCartRemoteDataSource remote;
  late CartRepositoryImpl repository;

  setUp(() async {
    Get.testMode = true;
    Get.reset();
    await getIt.reset();
    SharedPreferences.setMockInitialValues({AppStorageKey.userId: 1});
    final prefsStorage = PrefsStorage(await SharedPreferences.getInstance());
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
    remote = _FakeCartRemoteDataSource();
    repository = CartRepositoryImpl(
      remoteDataSource: remote,
      crash: _MockCrashlyticsService(),
      analytics: _MockAnalyticsService(),
      performance: _MockPerformanceService(),
      sessionService: session,
    );
  });

  tearDown(() async {
    Get.reset();
    await getIt.reset();
  });

  test('get and clear use token-owned remote calls', () async {
    final getResult = await repository.getCart();
    final clearResult = await repository.clearCart();

    expect(getResult.isRight(), isTrue);
    expect(clearResult.isRight(), isTrue);
    expect(remote.getCalls, 1);
    expect(remote.clearCalls, 1);
  });

  test('toggle payload contains only cart business fields', () async {
    final result = await repository.toggleCart(
      itemId: 7,
      variantId: 8,
      quantity: 2,
    );

    expect(result.isRight(), isTrue);
    expect(remote.lastToggleRequest?.toJson(), {
      'item_id': 7,
      'variant_id': 8,
      'quantity': 2,
    });
  });

  test('cart snapshot is rejected when one item cannot be mapped', () async {
    remote.getResponse = ApiResponse(
      status: 'success',
      data: [_validCartItem(), CartItemModel()],
    );

    final result = await repository.getCart();

    expect(result.isLeft(), isTrue);
  });

  test('added toggle requires an item payload', () async {
    remote.toggleResponse = const ApiResponse(
      status: 'success',
      action: 'added',
    );

    final result = await repository.toggleCart(itemId: 7, quantity: 1);

    expect(
      result.fold((failure) => failure, (_) => null),
      const Failure.http(key: FailureKey.missingServerData),
    );
  });

  test(
    'local session guard prevents token-owned remote calls for a guest',
    () async {
      session.clear();

      final result = await repository.getCart();

      expect(result.isLeft(), isTrue);
      expect(remote.getCalls, 0);
    },
  );
}

class _FakeCartRemoteDataSource implements CartRemoteDataSource {
  int getCalls = 0;
  int clearCalls = 0;
  ToggleCartRequest? lastToggleRequest;
  ApiResponse<List<CartItemModel>> getResponse = const ApiResponse(
    status: 'success',
    data: [],
  );
  ApiResponse<CartItemModel?> toggleResponse = const ApiResponse(
    status: 'success',
    action: 'removed',
  );

  @override
  Future<ApiResponse<List<CartItemModel>>> getCart() async {
    getCalls++;
    return getResponse;
  }

  @override
  Future<ApiResponse<void>> clearCart() async {
    clearCalls++;
    return const ApiResponse(status: 'success');
  }

  @override
  Future<ApiResponse<CartItemModel?>> toggleCart(
    ToggleCartRequest request,
  ) async {
    lastToggleRequest = request;
    return toggleResponse;
  }

  @override
  Future<ApiResponse<void>> toggleSelection(
    ToggleSelectionRequest request,
  ) async {
    return const ApiResponse(status: 'success');
  }
}

class _MockCrashlyticsService extends Mock implements CrashlyticsService {
  @override
  Future<void> logError(
    dynamic error,
    StackTrace? stackTrace, {
    String? reason,
  }) async {}
}

class _MockAnalyticsService extends Mock implements AnalyticsService {}

class _MockPerformanceService extends Mock implements PerformanceService {}

CartItemModel _validCartItem() => CartItemModel(
  cartId: 1,
  userId: 1,
  itemId: 7,
  cartQuantity: 1,
  itemName: 'منتج',
  itemNameEn: 'Product',
  price: 10,
  lineTotal: 10,
  isAvailable: 1,
  isSelected: 1,
);
