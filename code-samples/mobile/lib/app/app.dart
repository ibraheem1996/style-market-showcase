import 'dart:async';

// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../binding_route_middleware/route.dart';
import '../core/di/service_locator.dart';
import '../core/navigation/items_details_route_args.dart';
import '../core/navigation/order_details_route_args.dart';
import '../core/storage/prefs_storage.dart';
import '../features/auth/session/session_service.dart';
import 'notifications/app_notifications.dart';
import 'notifications/local_notification_display.dart';
import 'notifications/notification_messaging.dart';
import 'notifications/notification_payload.dart';
import 'notifications/notification_token_api.dart';
import '../core/localization/languages.dart';
import '../core/overlays/app_snackbar.dart';
import '../core/services/app_services.dart';
import '../core/services/logger_service.dart';
import '../core/theme/dark_theme.dart';
import '../core/theme/light_theme.dart';
import '../core/translations/app_translations.dart';
import '../core/utils/responsive/app_responsive_value.dart';
import '../core/widgets/app_orientation_scope.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  late final AppNotifications _notifications;
  late final List<GetPage<dynamic>> _pages;
  NotificationPayload? _pendingTap;
  bool _homeReached = false;

  @override
  void initState() {
    super.initState();
    _notifications = AppNotifications(
      messaging: getIt<NotificationMessaging>(),
      display: getIt<LocalNotificationDisplay>(),
      tokenApi: getIt<NotificationTokenApi>(),
      session: Get.find<SessionService>(),
      prefs: getIt<PrefsStorage>(),
      onTap: _receiveTap,
    );
    _pages = createAppPages(
      onSessionReady: _notifications.sessionReady,
      beforeLogout: _notifications.beforeLogout,
    );
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(_notifications.start());
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _notifications.resume();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _notifications.dispose();
    super.dispose();
  }

  void _receiveTap(NotificationPayload payload) {
    if (!mounted) return;
    _pendingTap = payload;
    _scheduleTap();
  }

  void _routingChanged(Routing? routing) {
    if (routing?.current == RouteName.homeScreen ||
        routing?.current == RouteName.home) {
      _homeReached = true;
    }
    _scheduleTap();
  }

  void _scheduleTap() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_homeReached || _pendingTap == null) return;
      final route = Get.currentRoute.split('?').first;
      if ({
        RouteName.onboarding,
        RouteName.appInit,
        RouteName.login,
        RouteName.signUp,
        RouteName.forgetPassword,
        RouteName.verifyCodeRestPassword,
        RouteName.setNewPassword,
        RouteName.verifyCodeChekEmail,
      }.contains(route)) {
        return;
      }
      final payload = _pendingTap!;
      _pendingTap = null;
      _openNotification(payload);
    });
    WidgetsBinding.instance.ensureVisualUpdate();
  }

  void _openNotification(NotificationPayload payload) {
    switch (payload.action) {
      case NotificationAction.noAction:
        return;
      case NotificationAction.openProduct:
        final args = Get.arguments;
        if (Get.currentRoute == RouteName.itemDetails &&
            args is ItemsDetailsRouteArgs &&
            args.itemId == payload.targetId) {
          return;
        }
        Get.toNamed<void>(
          RouteName.itemDetails,
          arguments: ItemsDetailsRouteArgs(
            itemId: payload.targetId!,
            heroTag: 'notification-product-${payload.targetId}',
          ),
          preventDuplicates: false,
        );
      case NotificationAction.openOrder:
        final args = Get.arguments;
        if (Get.currentRoute == RouteName.orderDetails &&
            args is OrderDetailsRouteArgs &&
            args.orderId == payload.targetId) {
          return;
        }
        Get.toNamed<void>(
          RouteName.orderDetails,
          arguments: OrderDetailsRouteArgs.fromOrdersList(payload.targetId!),
          preventDuplicates: false,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Kept intentionally while comparing text scaling across emulator targets.
    final size = MediaQuery.sizeOf(context);
    final scaler = context.textScale;
    final windowClass = context.windowClass;

    LoggerService.info(
      'DEVICE | '
      'size=$size | '
      'windowClass=$windowClass | '
      'scaledBody 1 = ${scaler.scale(1)}',
    );
    LoggerService.info('Platform: ${defaultTargetPlatform.name}');

    final Languages languages = Get.find();

    return AppOrientationScope(
      child: Obx(() {
        final AppServices services = Get.find();
        return GetMaterialApp(
          scaffoldMessengerKey: AppSnackbar.messengerKey,
          translations: AppTranslations(),
          locale: languages.language,
          fallbackLocale: const Locale('ar'),
          debugShowCheckedModeBanner: false,
          theme: lightTheme(context),
          darkTheme: darkTheme(context),
          themeMode: services.themeMode,
          getPages: _pages,
          routingCallback: _routingChanged,
          builder: (context, child) {
            return child ?? const SizedBox.shrink();
          },
        );
      }),
    );
  }
}
