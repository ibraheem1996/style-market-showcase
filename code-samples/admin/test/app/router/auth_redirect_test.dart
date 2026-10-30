import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:multi_product_store_admin_web/app/router/app_routes.dart';
import 'package:multi_product_store_admin_web/app/router/auth_redirect.dart';
import 'package:multi_product_store_admin_web/core/result/app_result.dart';
import 'package:multi_product_store_admin_web/features/auth/domain/entities/admin_entity.dart';
import 'package:multi_product_store_admin_web/features/auth/domain/usecases/clear_admin_session_use_case.dart';
import 'package:multi_product_store_admin_web/features/auth/domain/usecases/get_current_admin_use_case.dart';
import 'package:multi_product_store_admin_web/features/auth/domain/usecases/has_stored_admin_session_use_case.dart';
import 'package:multi_product_store_admin_web/features/auth/domain/usecases/logout_admin_use_case.dart';
import 'package:multi_product_store_admin_web/features/auth/domain/usecases/refresh_admin_session_use_case.dart';
import 'package:multi_product_store_admin_web/features/auth/presentation/cubit/admin_session_cubit.dart';

import '../../features/auth/auth_test_helpers.dart';

void main() {
  group('AuthRedirect', () {
    late FakeAdminAuthRepository repository;
    late AdminSessionCubit sessionCubit;
    late AuthRedirect redirect;

    setUp(() {
      repository = FakeAdminAuthRepository();
      sessionCubit = AdminSessionCubit(
        HasStoredAdminSessionUseCase(repository),
        GetCurrentAdminUseCase(repository),
        RefreshAdminSessionUseCase(repository),
        LogoutAdminUseCase(repository),
        ClearAdminSessionUseCase(repository),
      );
      redirect = AuthRedirect(sessionCubit);
    });

    tearDown(() async {
      await sessionCubit.close();
    });

    test('checking on dashboard redirects to auth checking', () async {
      final completer = Completer<AppResult<AdminEntity>>();
      repository.hasStoredSessionResult = true;
      repository.onGetCurrentAdmin = () => completer.future;
      final restore = sessionCubit.restoreSession();
      await Future<void>.delayed(Duration.zero);

      expect(
        redirect.redirectPath(AppRoutes.dashboard),
        AppRoutes.authChecking,
      );
      completer.complete(AppResult.success(testAdmin()));
      await restore;
    });

    test('authenticated on login redirects to dashboard', () {
      sessionCubit.acceptAuthenticatedSession(testAdmin());

      expect(redirect.redirectPath(AppRoutes.login), AppRoutes.dashboard);
    });

    test('unauthenticated on dashboard redirects to login', () async {
      repository.hasStoredSessionResult = false;
      await sessionCubit.restoreSession();

      expect(redirect.redirectPath(AppRoutes.dashboard), AppRoutes.login);
    });

    test('expired on dashboard redirects to login', () async {
      await sessionCubit.markSessionExpired();

      expect(redirect.redirectPath(AppRoutes.dashboard), AppRoutes.login);
    });

    test('forbidden on dashboard redirects to forbidden', () async {
      await sessionCubit.markForbidden();

      expect(redirect.redirectPath(AppRoutes.dashboard), AppRoutes.forbidden);
    });

    test('root redirects according to authenticated state', () {
      sessionCubit.acceptAuthenticatedSession(testAdmin());

      expect(redirect.redirectPath(AppRoutes.root), AppRoutes.dashboard);
    });
  });
}
