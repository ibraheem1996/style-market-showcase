import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/admin_session_entity.dart';

part 'login_state.freezed.dart';

@freezed
abstract class LoginState with _$LoginState {
  const factory LoginState({
    @Default('') String email,
    @Default('') String password,
    String? emailError,
    String? passwordError,
    String? errorMessage,
    @Default(false) bool isSubmitting,
    AdminSessionEntity? session,
  }) = _LoginState;
}
