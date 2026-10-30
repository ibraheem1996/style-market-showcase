import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';

import '../../features/auth/presentation/cubit/admin_session_cubit.dart';
import '../../features/auth/presentation/cubit/admin_session_state.dart';
import 'app_routes.dart';

@lazySingleton
class AuthRedirect {
  const AuthRedirect(this._sessionCubit);

  final AdminSessionCubit _sessionCubit;

  String? redirect(GoRouterState routerState) {
    return redirectPath(routerState.uri.path);
  }

  String? redirectPath(String location) {
    final state = _sessionCubit.state;
    final isLogin = location == AppRoutes.login;
    final isForbidden = location == AppRoutes.forbidden;
    final isChecking = location == AppRoutes.authChecking;

    if (location == AppRoutes.root) {
      if (state is AdminSessionAuthenticated) {
        return AppRoutes.dashboard;
      }
      if (state is AdminSessionUnauthenticated ||
          state is AdminSessionExpired) {
        return AppRoutes.login;
      }
      if (state is AdminSessionForbidden) {
        return AppRoutes.forbidden;
      }
      return AppRoutes.authChecking;
    }

    if (state is AdminSessionUnknown || state is AdminSessionChecking) {
      return isChecking ? null : AppRoutes.authChecking;
    }

    if (state is AdminSessionAuthenticated) {
      return isLogin || isChecking ? AppRoutes.dashboard : null;
    }

    if (state is AdminSessionUnauthenticated || state is AdminSessionExpired) {
      return isLogin ? null : AppRoutes.login;
    }

    if (state is AdminSessionForbidden) {
      return isForbidden ? null : AppRoutes.forbidden;
    }

    return null;
  }
}
