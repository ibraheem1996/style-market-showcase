import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:my_project/binding_route_middleware/middleware.dart';
import 'package:my_project/binding_route_middleware/route.dart';
import 'package:my_project/core/constants/app_pref_key.dart';
import 'package:my_project/core/di/service_locator.dart';
import 'package:my_project/core/navigation/app_init_route_args.dart';
import 'package:my_project/core/storage/prefs_storage.dart';
import 'package:my_project/core/storage/token_storage.dart';
import 'package:my_project/features/auth/session/session_service.dart';
import 'package:my_project/features/auth/presentation/navigation/login_route_args.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    Get.testMode = true;
    await getIt.reset();
  });

  tearDown(() async {
    Get.reset();
    await getIt.reset();
  });

  test('stored session candidate enters AppInit from cold start', () async {
    await _registerSession({
      AppStorageKey.isLogin: true,
      AppStorageKey.userId: 7,
      AppStorageKey.userName: 'User',
      AppStorageKey.userEmail: 'user@example.com',
    });

    final redirect = OnboardingMiddleware().redirect(RouteName.onboarding);

    expect(redirect?.name, RouteName.appInit);
  });

  test(
    'guest stays on onboarding regardless of orphaned legacy flags',
    () async {
      await _registerSession({'isChooseLanguage': true, 'isShowBording': true});

      final onboardingRedirect = OnboardingMiddleware().redirect(
        RouteName.onboarding,
      );

      expect(onboardingRedirect, isNull);
    },
  );

  testWidgets(
    'stored-session Login redirect preserves flow completion arguments',
    (tester) async {
      await _registerSession({
        AppStorageKey.isLogin: true,
        AppStorageKey.userId: 7,
        AppStorageKey.userName: 'User',
        AppStorageKey.userEmail: 'user@example.com',
      });
      await tester.pumpWidget(_middlewareTestApp());
      await tester.pumpAndSettle();

      Get.toNamed(RouteName.loginFlow, arguments: const LoginRouteArgs.flow());
      await tester.pumpAndSettle();

      expect(find.text('return-after-restore'), findsOneWidget);
    },
  );

  testWidgets('stored-session root Login redirect stays root', (tester) async {
    await _registerSession({
      AppStorageKey.isLogin: true,
      AppStorageKey.userId: 7,
      AppStorageKey.userName: 'User',
      AppStorageKey.userEmail: 'user@example.com',
    });
    await tester.pumpWidget(_middlewareTestApp());
    await tester.pumpAndSettle();

    Get.offAllNamed(RouteName.login, arguments: const LoginRouteArgs());
    await tester.pumpAndSettle();

    expect(find.text('root-completion'), findsOneWidget);
  });
}

Widget _middlewareTestApp() {
  return GetMaterialApp(
    initialRoute: '/host',
    getPages: [
      GetPage(
        name: '/host',
        page: () => const Scaffold(body: Text('host')),
      ),
      GetPage(
        name: RouteName.login,
        page: () => const Scaffold(body: Text('login')),
        middlewares: [LoginMiddleware()],
      ),
      GetPage(
        name: RouteName.appInit,
        page: () => Scaffold(
          body: Text(
            Get.arguments is AppInitRouteArgs
                ? 'return-after-restore'
                : 'root-completion',
          ),
        ),
      ),
    ],
  );
}

Future<void> _registerSession(Map<String, Object> values) async {
  SharedPreferences.setMockInitialValues(values);
  final prefs = PrefsStorage(await SharedPreferences.getInstance());
  getIt.registerSingleton<PrefsStorage>(prefs);
  Get.put<SessionService>(
    SessionService(prefs, TokenStorage(const FlutterSecureStorage())),
  );
}
