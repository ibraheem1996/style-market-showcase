import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';

import '../../core/network/dio_factory.dart';
import '../../core/result/app_result.dart';
import '../../core/storage/token_storage.dart';
import '../../core/storage/token_storage_factory.dart';
import '../../features/auth/domain/usecases/refresh_admin_session_use_case.dart';
import '../../features/auth/presentation/cubit/admin_session_cubit.dart';
import '../router/app_router.dart';
import '../router/auth_redirect.dart';
import '../router/router_refresh_notifier.dart';

@module
abstract class RegisterModule {
  @lazySingleton
  TokenStorage tokenStorage() => createTokenStorage();

  @Named('authDio')
  @lazySingleton
  Dio authDio(DioFactory factory) {
    return factory.createAuthDio();
  }

  @Named('protectedDio')
  @lazySingleton
  Dio protectedDio(
    DioFactory factory,
    RefreshAdminSessionUseCase refreshSession,
    AdminSessionCubit sessionCubit,
  ) {
    return factory.createProtectedDio(
      refreshSession: () async {
        final result = await refreshSession();
        return result is AppResultSuccess;
      },
      onSessionExpired: sessionCubit.markSessionExpired,
      onForbidden: sessionCubit.markForbidden,
    );
  }

  ///any body need Dio with interceptor with token use @Named('protectedDio') instead of @Named('dio')
  @lazySingleton
  Dio dio(@Named('protectedDio') Dio dio) {
    return dio;
  }

  @lazySingleton
  GoRouter router(
    AuthRedirect authRedirect,
    RouterRefreshNotifier refreshNotifier,
  ) {
    return createAppRouter(
      authRedirect: authRedirect,
      refreshNotifier: refreshNotifier,
    );
  }
}
