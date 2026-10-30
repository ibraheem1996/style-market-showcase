import 'dart:async';
import 'package:my_project/core/navigation/items_details_route_args.dart';
import 'package:my_project/features/item_details/domain/usecases/get_item_details_usecase.dart';
import 'package:my_project/features/products/domain/entities/item_entity.dart';
import 'package:my_project/features/item_details/presentation/controller/item_details_controller.dart';
import 'package:my_project/features/cart/presentation/operations/cart_operations.dart';
import 'package:my_project/features/cart/presentation/store/cart_store.dart';
import 'package:my_project/features/favorites/presentation/services/favorites_service.dart';
import 'package:my_project/features/recently_viewed/presentation/services/recently_viewed_service.dart';
import 'package:my_project/features/recommendations/domain/usecases/get_recommendations_usecase.dart';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:my_project/app/app.dart';
import 'package:my_project/app/notifications/local_notification_display.dart';
import 'package:my_project/app/notifications/notification_messaging.dart';
import 'package:my_project/app/notifications/notification_payload.dart';
import 'package:my_project/app/notifications/notification_token_api.dart';
import 'package:my_project/binding_route_middleware/route.dart';
import 'package:my_project/core/di/service_locator.dart';
import 'package:my_project/core/errors/api_result.dart';
import 'package:my_project/core/localization/languages.dart';
import 'package:my_project/core/navigation/order_details_route_args.dart';
import 'package:my_project/core/services/app_services.dart';
import 'package:my_project/core/storage/prefs_storage.dart';
import 'package:my_project/features/auth/session/session_service.dart';
import 'package:my_project/features/orders/domain/entities/order_details_entity.dart';
import 'package:my_project/features/orders/domain/usecases/get_order_details_usecase.dart';
import 'package:my_project/features/orders/presentation/controllers/order_details_controller.dart';
import 'package:my_project/features/orders/presentation/pages/order_details_page.dart';
import 'package:my_project/features/orders/presentation/services/order_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_notifications_test.dart'
    show MemoryTokens, FakeMessaging, FakeDisplay, FakeTokenApi;

class _Details implements GetOrderDetailsUseCase {
  final ids = <int>[];
  @override
  Future<ApiResult<OrderDetailsEntity>> call(int id) {
    ids.add(id);
    return Completer<ApiResult<OrderDetailsEntity>>().future;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _OrderService extends GetxService implements OrderService {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Items implements GetItemDetailsUseCase {
  final ids = <int>[];
  @override
  Future<ApiResult<ItemEntity>> call(GetItemDetailsParams params) {
    ids.add(params.itemId);
    return Completer<ApiResult<ItemEntity>>().future;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Cart extends GetxService implements CartOperations {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Favorites extends GetxService implements FavoritesService {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Recent extends GetxService implements RecentlyViewedService {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Recommendations implements GetRecommendationsUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late FakeMessaging messaging;
  late FakeDisplay display;
  late _Details details;
  late _Items items;
  setUp(() async {
    Get.testMode = true;
    Get.reset();
    await getIt.reset();
    SharedPreferences.setMockInitialValues({});
    final prefs = PrefsStorage(await SharedPreferences.getInstance());
    final session = SessionService(prefs, MemoryTokens());
    Get.put<SessionService>(session, permanent: true);
    Get.put<Languages>(Languages(prefs), permanent: true);
    Get.put<AppServices>(AppServices(prefs: prefs), permanent: true);
    Get.put<OrderService>(_OrderService(), permanent: true);
    Get.put<CartOperations>(_Cart(), permanent: true);
    Get.put<FavoritesService>(_Favorites(), permanent: true);
    Get.put<RecentlyViewedService>(_Recent(), permanent: true);
    Get.put<CartStore>(CartStore(), permanent: true);
    items = _Items();
    getIt.registerSingleton<GetItemDetailsUseCase>(items);
    getIt.registerSingleton<GetRecommendationsUseCase>(_Recommendations());
    messaging = FakeMessaging();
    display = FakeDisplay();
    details = _Details();
    getIt.registerSingleton<PrefsStorage>(prefs);
    getIt.registerSingleton<NotificationMessaging>(messaging);
    getIt.registerSingleton<LocalNotificationDisplay>(display);
    getIt.registerSingleton<NotificationTokenApi>(FakeTokenApi());
    getIt.registerSingleton<GetOrderDetailsUseCase>(details);
  });
  tearDown(() async {
    Get.reset();
    await getIt.reset();
    await messaging.close();
  });

  NotificationPayload order(int id) =>
      NotificationPayload.fromData({'action': 'open_order', 'order_id': '$id'});
  Future<void> pump(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();
  }

  testWidgets(
    'product taps use typed args, skip the current ID and allow a different ID',
    (tester) async {
      await tester.pumpWidget(
        const MediaQuery(
          data: MediaQueryData(size: Size(800, 600)),
          child: MyApp(),
        ),
      );
      await pump(tester);
      Get.offAll<void>(
        () => const Scaffold(body: Text('Home host')),
        routeName: RouteName.homeScreen,
      );
      await pump(tester);
      NotificationPayload product(int id) => NotificationPayload.fromData({
        'action': 'open_product',
        'product_id': '$id',
      });
      messaging.taps.add(product(42));
      await pump(tester);
      final firstArgs = Get.arguments as ItemsDetailsRouteArgs;
      final first = Get.find<ItemDetailsController>(
        tag: firstArgs.controllerTag,
      );
      expect(first.itemId, 42);
      expect(first.heroTag, 'notification-product-42');
      messaging.taps.add(product(42));
      await pump(tester);
      expect(items.ids, [42]);
      messaging.taps.add(product(43));
      await pump(tester);
      expect(items.ids, [42, 43]);
      final secondArgs = Get.arguments as ItemsDetailsRouteArgs;
      expect(secondArgs.controllerTag, isNot(firstArgs.controllerTag));
      Get.back<void>();
      await pump(tester);
      expect(Get.arguments, same(firstArgs));
      expect(first.isClosed, false);
      messaging.taps.add(NotificationPayload.fromData({'action': 'no_action'}));
      await pump(tester);
      expect(items.ids, [42, 43]);
      expect(tester.takeException(), isNull);
    },
  );

  for (final localLaunch in [true, false]) {
    testWidgets(
      '${localLaunch ? 'local' : 'remote'} cold tap waits for Home; newest pending wins and never replays',
      (tester) async {
        if (localLaunch) {
          display.launch = order(1);
        } else {
          messaging.launch = order(1);
        }
        await tester.pumpWidget(
          const MediaQuery(
            data: MediaQueryData(size: Size(800, 600)),
            child: MyApp(),
          ),
        );
        await pump(tester);
        expect(details.ids, isEmpty);
        expect(Get.currentRoute, RouteName.onboarding);
        messaging.taps.add(order(2));
        await pump(tester);
        expect(details.ids, isEmpty);
        Get.offAll<void>(
          () => const Scaffold(body: Text('Home host')),
          routeName: RouteName.homeScreen,
        );
        await pump(tester);
        await pump(tester);
        expect(details.ids, [2]);
        expect(Get.currentRoute, RouteName.orderDetails);
        final args = Get.arguments as OrderDetailsRouteArgs;
        final first = Get.find<OrderDetailsController>(tag: args.controllerTag);
        expect(first.orderId, 2);
        messaging.taps.add(order(2));
        await pump(tester);
        expect(details.ids, [2]);
        // Rebuild the root and visit an unrelated route; consumed tap stays consumed.
        Get.to<void>(
          () => const Scaffold(body: Text('Other')),
          routeName: '/other',
        );
        await pump(tester);
        expect(details.ids, [2]);
        Get.back<void>();
        await pump(tester);
        expect(first.isClosed, isFalse);
        await tester.pumpWidget(const SizedBox.shrink());
        messaging.taps.add(order(3));
        await tester.pump();
        expect(details.ids, [2]);
        expect(tester.takeException(), isNull);
      },
    );
  }
  testWidgets(
    'two real tagged Order pages keep distinct IDs and Back restores first',
    (tester) async {
      final page = createAppPages().firstWhere(
        (p) => p.name == RouteName.orderDetails,
      );
      await tester.pumpWidget(
        GetMaterialApp(
          initialRoute: '/host',
          getPages: [
            GetPage(
              name: '/host',
              page: () => const Scaffold(body: Text('host')),
            ),
            page,
          ],
        ),
      );
      await pump(tester);
      final firstArgs = OrderDetailsRouteArgs.fromOrdersList(10);
      Get.toNamed<void>(
        RouteName.orderDetails,
        arguments: firstArgs,
        preventDuplicates: false,
      );
      await pump(tester);
      final first = Get.find<OrderDetailsController>(
        tag: firstArgs.controllerTag,
      );
      final secondArgs = OrderDetailsRouteArgs.fromOrdersList(20);
      Get.toNamed<void>(
        RouteName.orderDetails,
        arguments: secondArgs,
        preventDuplicates: false,
      );
      await pump(tester);
      final second = Get.find<OrderDetailsController>(
        tag: secondArgs.controllerTag,
      );
      expect(first.orderId, 10);
      expect(second.orderId, 20);
      expect(details.ids, [10, 20]);
      expect(first.isClosed, false);
      expect(second.isClosed, false);
      expect(
        tester
            .widget<OrderDetailsPage>(find.byType(OrderDetailsPage))
            .routeArgs,
        same(secondArgs),
      );
      Get.back<void>();
      await pump(tester);
      expect(second.isClosed, true);
      expect(first.isClosed, false);
      expect(
        tester
            .widget<OrderDetailsPage>(find.byType(OrderDetailsPage))
            .routeArgs,
        same(firstArgs),
      );
      expect(Get.arguments, same(firstArgs));
      Get.back<void>();
      await pump(tester);
      expect(first.isClosed, true);
      expect(find.text('host'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
