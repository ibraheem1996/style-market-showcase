import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../../core/errors/backend_error_code.dart';
import '../../../../core/result/app_result.dart';
import '../../domain/entities/admin_entity.dart';
import '../../domain/usecases/clear_admin_session_use_case.dart';
import '../../domain/usecases/get_current_admin_use_case.dart';
import '../../domain/usecases/has_stored_admin_session_use_case.dart';
import '../../domain/usecases/logout_admin_use_case.dart';
import '../../domain/usecases/refresh_admin_session_use_case.dart';
import 'admin_session_state.dart';

@lazySingleton
class AdminSessionCubit extends Cubit<AdminSessionState> {
  AdminSessionCubit(
    this._hasStoredSession,
    this._getCurrentAdmin,
    this._refreshSession,
    this._logout,
    this._clearSession,
  ) : super(const AdminSessionState.unknown());

  final HasStoredAdminSessionUseCase _hasStoredSession;
  final GetCurrentAdminUseCase _getCurrentAdmin;
  final RefreshAdminSessionUseCase _refreshSession;
  final LogoutAdminUseCase _logout;
  final ClearAdminSessionUseCase _clearSession;

  Future<void> restoreSession() async {
    emit(const AdminSessionState.checking());
    //TODO remove after test
    await Future.delayed(const Duration(seconds: 2));

    final hasSession = await _hasStoredSession();
    if (!hasSession) {
      await _clearSession();
      emit(const AdminSessionState.unauthenticated());
      return;
    }

    final currentAdminResult = await _getCurrentAdmin();
    switch (currentAdminResult) {
      case AppResultSuccess(data: final AdminEntity data):
        emit(AdminSessionState.authenticated(admin: data));
      case AppResultFailure(failure: final failure):
        // Only an expired access token is recoverable during restore; other
        // auth failures invalidate the local session.
        await _handleRestoreFailure(failure);
    }
  }

  Future<void> markSessionExpired() async {
    await _clearSession();
    emit(
      const AdminSessionState.expired(
        message: 'انتهت الجلسة. يرجى تسجيل الدخول مرة أخرى.',
      ),
    );
  }

  Future<void> logout() async {
    await _logout();
    emit(const AdminSessionState.unauthenticated());
  }

  Future<void> markForbidden() async {
    await _clearSession();
    emit(
      const AdminSessionState.forbidden(
        message: 'لا توجد صلاحية كافية للوصول إلى لوحة الأدمن.',
      ),
    );
  }

  void acceptAuthenticatedSession(AdminEntity admin) {
    emit(AdminSessionState.authenticated(admin: admin));
  }

  Future<void> _handleRestoreFailure(AppFailure failure) async {
    if (_isForbidden(failure)) {
      await markForbidden();
      return;
    }

    if (failure.errorCode == BackendErrorCode.tokenExpired) {
      await _restoreWithRefresh();
      return;
    }

    await _clearSession();
    emit(AdminSessionState.expired(message: failure.message));
  }

  Future<void> _restoreWithRefresh() async {
    final refreshResult = await _refreshSession();

    switch (refreshResult) {
      case AppResultSuccess(:final data):
        emit(AdminSessionState.authenticated(admin: data.admin));
      case AppResultFailure(:final failure):
        if (_isForbidden(failure)) {
          await markForbidden();
          return;
        }
        await _clearSession();
        emit(AdminSessionState.expired(message: failure.message));
    }
  }

  bool _isForbidden(AppFailure failure) {
    return failure is ForbiddenFailure ||
        failure.errorCode == BackendErrorCode.adminForbidden;
  }
}
