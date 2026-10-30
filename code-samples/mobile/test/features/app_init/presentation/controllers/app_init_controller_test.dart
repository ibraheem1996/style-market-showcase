import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/mockito.dart';
import 'package:my_project/binding_route_middleware/route.dart';
import 'package:my_project/core/constants/app_pref_key.dart';
import 'package:my_project/core/di/service_locator.dart';
import 'package:my_project/core/errors/failure.dart';
import 'package:my_project/core/errors/failure_key.dart';
import 'package:my_project/core/storage/prefs_storage.dart';
import 'package:my_project/core/storage/token_storage.dart';
import 'package:my_project/features/app_init/presentation/controllers/app_init_controller.dart';
import 'package:my_project/features/app_init/presentation/pages/app_init_page.dart';
import 'package:my_project/features/audience/presentation/manager/audience_manager.dart';
import 'package:my_project/features/auth/session/session_service.dart';
import 'package:my_project/features/recently_viewed/data/datasources/recently_viewed_local_datasource.dart';
import 'package:my_project/features/recently_viewed/data/models/cards_by_keys_request_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MockAudienceManager extends Mock implements AudienceManager {
  int initCalls = 0;
  bool fail = false;

  @override
  Future<Either<Failure, void>> initAudiences() async {
    initCalls++;
    return fail
        ? left(const Failure.http(key: FailureKey.networkTimeout))
        : right(null);
  }
}

class _MemoryTokenStorage extends TokenStorage {
  _MemoryTokenStorage({this.accessToken, this.refreshToken})
    : super(const FlutterSecureStorage());

  String? accessToken;
  String? refreshToken;
  int clearCalls = 0;

  @override
  Future<String?> get readAccessToken async => accessToken;

  @override
  Future<String?> get readRefreshToken async => refreshToken;

  @override
  Future<void> clearTokens() async {
    clearCalls++;
    accessToken = null;
    refreshToken = null;
  }
}

class _PendingAudienceManager extends Mock implements AudienceManager {
  final result = Completer<Either<Failure, void>>();

  @override
  Future<Either<Failure, void>> initAudiences() => result.future;
}

class _RetainedHomeController extends GetxController {}

void main() {
  setUp(() async {
    Get.testMode = true;
    await getIt.reset();
  });

  tearDown(() async {
    Get.reset();
    await getIt.reset();
  });

  testWidgets(
    'signals readiness once after audiences, before successful navigation',
    (tester) async {
      final harness = await _createHarness(
        prefsValues: {
          AppStorageKey.isLogin: true,
          AppStorageKey.userId: 7,
          AppStorageKey.userName: 'User',
          AppStorageKey.userEmail: 'user@example.com',
        },
        accessToken: 'access',
        refreshToken: 'refresh',
      );
      await Get.delete<AppInitController>(force: true);
      var signals = 0;
      Get.put(
        AppInitController(
          harness.session,
          harness.audience,
          returnAfterRestore: false,
          onSessionReady: () {
            signals++;
            expect(harness.session.isAuthenticated, isTrue);
            expect(harness.audience.initCalls, 1);
          },
        ),
      );
      await _pumpAppInit(tester);
      expect(signals, 1);
      expect(find.text('Home test page'), findsOneWidget);
    },
  );

  testWidgets('audience failure emits no readiness until a successful retry', (
    tester,
  ) async {
    final harness = await _createHarness(
      prefsValues: {
        AppStorageKey.isLogin: true,
        AppStorageKey.userId: 7,
        AppStorageKey.userName: 'User',
        AppStorageKey.userEmail: 'user@example.com',
      },
      accessToken: 'access',
      refreshToken: 'refresh',
    );
    await Get.delete<AppInitController>(force: true);
    harness.audience.fail = true;
    var signals = 0;
    final controller = Get.put(
      AppInitController(
        harness.session,
        harness.audience,
        returnAfterRestore: false,
        onSessionReady: () => signals++,
      ),
    );
    await _pumpAppInit(tester);
    expect(signals, 0);
    expect(controller.failure.value, isNotNull);
    harness.audience.fail = false;
    await controller.retry();
    await tester.pumpAndSettle();
    expect(signals, 1);
    expect(find.text('Home test page'), findsOneWidget);
  });

  testWidgets('restores a stored session before Audience and enters Home', (
    tester,
  ) async {
    final harness = await _createHarness(
      prefsValues: {
        AppStorageKey.isLogin: true,
        AppStorageKey.userId: 7,
        AppStorageKey.userName: 'User',
        AppStorageKey.userEmail: 'user@example.com',
      },
      accessToken: 'access',
      refreshToken: 'refresh',
    );

    await _pumpAppInit(tester);

    expect(find.text('Home test page'), findsOneWidget);
    expect(harness.session.isAuthenticated, isTrue);
    expect(harness.session.userId, 7);
    expect(harness.audience.initCalls, 1);
    expect(harness.tokens.clearCalls, 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'invalid session becomes guest without clearing Recently Viewed keys',
    (tester) async {
      final harness = await _createHarness(
        prefsValues: {
          AppStorageKey.isLogin: true,
          AppStorageKey.userId: 7,
          AppStorageKey.userName: 'User',
          AppStorageKey.userEmail: 'user@example.com',
        },
      );
      final recentlyViewed = RecentlyViewedLocalDataSourceImpl(harness.prefs);
      await recentlyViewed.addKey(
        const RecentlyViewedKeyModel(itemId: 11, colorGroupId: 4),
      );

      await _pumpAppInit(tester);

      expect(find.text('Home test page'), findsOneWidget);
      expect(harness.session.isAuthenticated, isFalse);
      expect(harness.tokens.clearCalls, 1);
      final preservedKeys = await recentlyViewed.getKeys();
      expect(preservedKeys, hasLength(1));
      expect(preservedKeys.single.itemId, 11);
      expect(preservedKeys.single.colorGroupId, 4);
      expect(harness.audience.initCalls, 1);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'retained completion restores Session and returns to the same Home owner',
    (tester) async {
      SharedPreferences.setMockInitialValues({
        AppStorageKey.isLogin: true,
        AppStorageKey.userId: 7,
        AppStorageKey.userName: 'User',
        AppStorageKey.userEmail: 'user@example.com',
      });
      final prefs = PrefsStorage(await SharedPreferences.getInstance());
      final tokens = _MemoryTokenStorage(
        accessToken: 'access',
        refreshToken: 'refresh',
      );
      final session = SessionService(prefs, tokens);
      final audience = _MockAudienceManager();
      var homeOwnerStarts = 0;

      getIt.registerSingleton<PrefsStorage>(prefs);
      getIt.registerSingleton<TokenStorage>(tokens);
      Get.put<SessionService>(session, permanent: true);

      await tester.pumpWidget(
        GetMaterialApp(
          initialRoute: RouteName.homeScreen,
          getPages: [
            GetPage(
              name: RouteName.homeScreen,
              page: () => const Scaffold(body: Text('Retained Home')),
              binding: BindingsBuilder(() {
                homeOwnerStarts++;
                Get.put(_RetainedHomeController());
              }),
            ),
            GetPage(
              name: RouteName.appInit,
              page: () => const Scaffold(body: Text('AppInit test page')),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();
      final retainedOwner = Get.find<_RetainedHomeController>();

      Get.toNamed(RouteName.appInit);
      await tester.pumpAndSettle();
      final controller = AppInitController(
        session,
        audience,
        returnAfterRestore: true,
      );
      await controller.loadInitialData();
      await tester.pumpAndSettle();

      expect(find.text('Retained Home'), findsOneWidget);
      expect(session.isAuthenticated, isTrue);
      expect(audience.initCalls, 1);
      expect(homeOwnerStarts, 1);
      expect(Get.find<_RetainedHomeController>(), same(retainedOwner));
      expect(retainedOwner.isClosed, isFalse);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('AppInit cannot be popped before retained completion finishes', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      AppStorageKey.isLogin: true,
      AppStorageKey.userId: 7,
      AppStorageKey.userName: 'User',
      AppStorageKey.userEmail: 'user@example.com',
    });
    final prefs = PrefsStorage(await SharedPreferences.getInstance());
    final tokens = _MemoryTokenStorage(
      accessToken: 'access',
      refreshToken: 'refresh',
    );
    final session = SessionService(prefs, tokens);
    final audience = _PendingAudienceManager();

    await tester.pumpWidget(
      GetMaterialApp(
        home: const Scaffold(body: Text('retained route')),
        getPages: [
          GetPage(
            name: RouteName.appInit,
            page: () => const AppInitPage(),
            binding: BindingsBuilder(() {
              Get.put(
                AppInitController(session, audience, returnAfterRestore: true),
              );
            }),
          ),
        ],
      ),
    );

    Get.toNamed(RouteName.appInit);
    await tester.pump();
    await tester.pump();
    await tester.binding.handlePopRoute();
    await tester.pump();

    expect(find.byType(AppInitPage), findsOneWidget);

    audience.result.complete(right(null));
    await tester.pumpAndSettle();

    expect(find.text('retained route'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Future<_Harness> _createHarness({
  required Map<String, Object> prefsValues,
  String? accessToken,
  String? refreshToken,
}) async {
  SharedPreferences.setMockInitialValues(prefsValues);
  final prefs = PrefsStorage(await SharedPreferences.getInstance());
  final tokens = _MemoryTokenStorage(
    accessToken: accessToken,
    refreshToken: refreshToken,
  );
  final session = SessionService(prefs, tokens);
  final audience = _MockAudienceManager();

  getIt.registerSingleton<PrefsStorage>(prefs);
  getIt.registerSingleton<TokenStorage>(tokens);
  Get.put<SessionService>(session, permanent: true);
  Get.put<AppInitController>(
    AppInitController(session, audience, returnAfterRestore: false),
  );

  return _Harness(
    prefs: prefs,
    tokens: tokens,
    session: session,
    audience: audience,
  );
}

Future<void> _pumpAppInit(WidgetTester tester) async {
  await tester.pumpWidget(
    GetMaterialApp(
      home: const AppInitPage(),
      getPages: [
        GetPage(
          name: RouteName.homeScreen,
          page: () => const Scaffold(body: Text('Home test page')),
        ),
      ],
    ),
  );
  await tester.pumpAndSettle();
}

class _Harness {
  const _Harness({
    required this.prefs,
    required this.tokens,
    required this.session,
    required this.audience,
  });

  final PrefsStorage prefs;
  final _MemoryTokenStorage tokens;
  final SessionService session;
  final _MockAudienceManager audience;
}
