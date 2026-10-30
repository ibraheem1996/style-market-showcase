import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/errors/failure.dart';
import '../../domain/entities/address_phone_verification_challenge_entity.dart';

part 'address_verification_state.freezed.dart';

enum AddressVerificationStatus {
  active,
  confirming,
  resending,
  cancelling,
  verified,
  cancelled,
  expired,
  limited,
  invalid,
}

@freezed
abstract class AddressVerificationState with _$AddressVerificationState {
  const factory AddressVerificationState({
    AddressPhoneVerificationChallengeEntity? challenge,
    @Default(AddressVerificationStatus.active) AddressVerificationStatus status,
    @Default('') String code,
    @Default(0) int resendSecondsLeft,
    @Default(0) int otpInputVersion,
    Failure? actionFailure,
    String? messageKey,
  }) = _AddressVerificationState;
}
