import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../core/services/analytics_service.dart';
import '../core/services/crashlytics_service.dart';
import '../core/services/performance_service.dart';
import '../core/storage/token_storage.dart';
import 'notifications/notification_messaging.dart';
import 'notifications/notification_token_api.dart';
import 'notifications/local_notification_display.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../core/di/service_locator.dart';
import '../core/di/shared_di.dart';
import '../core/network/network_module.dart';
import '../features/addresses/presentation/bindings/addresses_bindings.dart';
import '../features/audience/presentation/bindings/audience_bindings.dart';
import '../features/auth/presentation/bindings/auth_bindings.dart';
import '../features/auth/session/session_service.dart';
import '../features/cart/presentation/bindings/cart_bindings.dart';
import '../features/favorites/presentation/bindings/favorites_bindings.dart';
import '../features/home/bindings/home_banner_bindings.dart';
import '../features/home/bindings/home_collections_bindings.dart';
import '../features/item_details/presentation/bindings/item_details_bindings.dart';
import '../features/listing/presentation/bindings/listing_binding.dart';
import '../features/orders/presentation/bindings/orders_bindings.dart';
import '../features/products/bindings/home_bindings.dart';
import '../features/recently_viewed/presentation/bindings/recently_viewed_binding.dart';
import '../features/recommendations/presentation/bindings/recommendations_bindings.dart';

/// Builds the existing application dependency graph in its established order.
Future<void> setupAppDependencies() async {
  await setupLocator();
  setupNetworkModule(
    currentSessionRevision: () => Get.find<SessionService>().sessionVersion,
  );

  AuthBindings.setup();
  ProductsBindings.setup();
  HomeBannerBindings.setup();
  HomeCollectionsBindings.setup();
  RecommendationsBindings.setup();
  ItemDetailsBindings.setup();
  CartBindings.setup();
  FavoritesBindings.setup();
  AddressesBindings.setup();
  AudienceBindings.setup();
  OrdersBindings.setup();
  ListingBinding.setup();
  RecentlyViewedBinding.setup();

  SharedDiService.setup();
  getIt.registerLazySingleton<NotificationMessaging>(
    () => NotificationMessaging(FirebaseMessaging.instance),
  );
  getIt.registerLazySingleton<LocalNotificationDisplay>(
    () => LocalNotificationDisplay(FlutterLocalNotificationsPlugin()),
  );
  getIt.registerLazySingleton<NotificationTokenRemoteApi>(
    () => NotificationTokenRemoteApi(getIt<Dio>()),
  );
  getIt.registerLazySingleton<NotificationTokenApi>(
    () => NotificationTokenApi(
      getIt<NotificationTokenRemoteApi>(),
      analytics: getIt<AnalyticsService>(),
      crash: getIt<CrashlyticsService>(),
      performance: getIt<PerformanceService>(),
    ),
  );
}

/// Discards only a failed startup attempt's in-memory registrations.
Future<void> resetAppDependenciesForRetry() async {
  // Dispose GetX owners before removing GetIt objects they may reference.
  await Get.deleteAll(force: true);
  Get.reset();
  await getIt.reset();
}
