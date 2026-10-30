import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/admin_entity.dart';

part 'admin_session_state.freezed.dart';

@freezed
sealed class AdminSessionState with _$AdminSessionState {
  const factory AdminSessionState.unknown() = AdminSessionUnknown;
  const factory AdminSessionState.checking() = AdminSessionChecking;
  const factory AdminSessionState.unauthenticated() =
      AdminSessionUnauthenticated;
  const factory AdminSessionState.authenticated({required AdminEntity admin}) =
      AdminSessionAuthenticated;
  const factory AdminSessionState.forbidden({String? message}) =
      AdminSessionForbidden;
  const factory AdminSessionState.expired({String? message}) =
      AdminSessionExpired;
}
