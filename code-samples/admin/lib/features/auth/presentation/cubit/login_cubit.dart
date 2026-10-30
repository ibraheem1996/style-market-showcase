import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../../core/errors/backend_error_code.dart';
import '../../../../core/result/app_result.dart';
import '../../domain/usecases/sign_in_admin_use_case.dart';
import 'login_state.dart';

@injectable
class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this._signIn) : super(const LoginState());

  final SignInAdminUseCase _signIn;

  void emailChanged(String value) {
    emit(
      state.copyWith(
        email: value,
        emailError: null,
        errorMessage: null,
        session: null,
      ),
    );
  }

  void passwordChanged(String value) {
    emit(
      state.copyWith(
        password: value,
        passwordError: null,
        errorMessage: null,
        session: null,
      ),
    );
  }

  Future<void> submit() async {
    if (state.isSubmitting) {
      return;
    }

    final emailError = _validateEmail(state.email);
    final passwordError = _validatePassword(state.password);
    if (emailError != null || passwordError != null) {
      emit(
        state.copyWith(
          emailError: emailError,
          passwordError: passwordError,
          errorMessage: null,
          session: null,
        ),
      );
      return;
    }

    emit(state.copyWith(isSubmitting: true, errorMessage: null, session: null));

    final result = await _signIn(
      email: state.email.trim(),
      password: state.password,
    );

    switch (result) {
      case AppResultSuccess(:final data):
        emit(state.copyWith(isSubmitting: false, session: data));
      case AppResultFailure(:final failure):
        emit(
          state.copyWith(
            isSubmitting: false,
            errorMessage: _messageForFailure(failure),
          ),
        );
    }
  }

  String? _validateEmail(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return 'البريد الإلكتروني مطلوب.';
    }

    return null;
  }

  String? _validatePassword(String value) {
    if (value.isEmpty) {
      return 'كلمة المرور مطلوبة.';
    }

    if (value.length < 4) {
      return 'كلمة المرور يجب أن تكون 4 أحرف على الأقل.';
    }

    return null;
  }

  String _messageForFailure(AppFailure failure) {
    if (failure.errorCode == BackendErrorCode.adminInvalidCredentials ||
        failure.errorCode == BackendErrorCode.invalidCredentials) {
      return 'بيانات الدخول غير صحيحة.';
    }

    if (failure.errorCode == BackendErrorCode.adminForbidden ||
        failure is ForbiddenFailure) {
      return 'هذا الحساب لا يملك صلاحية الأدمن.';
    }

    if (failure is ValidationFailure ||
        failure.errorCode == BackendErrorCode.validationError) {
      return 'يرجى مراجعة البريد الإلكتروني وكلمة المرور.';
    }

    return failure.message;
  }
}
