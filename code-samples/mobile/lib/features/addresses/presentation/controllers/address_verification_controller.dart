import 'dart:async';

import 'package:get/get.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/errors/failure_key.dart';
import '../../../../core/translations/locale_keys.dart';
import '../../domain/entities/address_entity.dart';
import '../../domain/entities/address_phone_verification_challenge_entity.dart';
import '../../domain/usecases/cancel_address_verification_usecase.dart';
import '../../domain/usecases/confirm_address_phone_verification_usecase.dart';
import '../../domain/usecases/resend_address_phone_verification_usecase.dart';
import '../state/address_verification_state.dart';

/// Requests closing Verification and optionally carries its saved address.
class AddressVerificationCompletion {
  const AddressVerificationCompletion.closed() : address = null;
  const AddressVerificationCompletion.verified(this.address);

  final AddressEntity? address;
}

/// Owns one temporary address-phone challenge until it reaches a terminal state.
class AddressVerificationController extends GetxController {
  AddressVerificationController({
    required AddressPhoneVerificationChallengeEntity? challenge,
    required ConfirmAddressPhoneVerificationUseCase confirmUseCase,
    required ResendAddressPhoneVerificationUseCase resendUseCase,
    required CancelAddressVerificationUseCase cancelUseCase,
  }) : _confirmUseCase = confirmUseCase,
       _resendUseCase = resendUseCase,
       _cancelUseCase = cancelUseCase,
       state = AddressVerificationState(
         challenge: challenge,
         status: challenge == null
             ? AddressVerificationStatus.invalid
             : AddressVerificationStatus.active,
         messageKey: challenge == null
             ? LocaleKeys.phoneVerificationInvalidSession
             : null,
       ).obs;

  final ConfirmAddressPhoneVerificationUseCase _confirmUseCase;
  final ResendAddressPhoneVerificationUseCase _resendUseCase;
  final CancelAddressVerificationUseCase _cancelUseCase;

  final Rx<AddressVerificationState> state;
  final Rxn<AddressVerificationCompletion> completion =
      Rxn<AddressVerificationCompletion>();
  Timer? _timer;

  bool get isTerminal => switch (state.value.status) {
    AddressVerificationStatus.verified ||
    AddressVerificationStatus.cancelled ||
    AddressVerificationStatus.expired ||
    AddressVerificationStatus.limited ||
    AddressVerificationStatus.invalid => true,
    _ => false,
  };

  bool get isBusy => switch (state.value.status) {
    AddressVerificationStatus.confirming ||
    AddressVerificationStatus.resending ||
    AddressVerificationStatus.cancelling => true,
    _ => false,
  };

  @override
  void onInit() {
    super.onInit();
    _tick();
    if (state.value.challenge != null) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    }
  }

  void clearCompletion() => completion.value = null;

  void onCodeChanged(String code) {
    if (isTerminal) return;
    state.value = state.value.copyWith(code: code.trim(), actionFailure: null);
  }

  Future<void> confirm([String? code]) async {
    if (isBusy || isTerminal) return;
    final input = (code ?? state.value.code).trim();
    if (input.isEmpty) {
      state.value = state.value.copyWith(
        messageKey: LocaleKeys.validationRequired,
      );
      return;
    }

    state.value = state.value.copyWith(
      status: AddressVerificationStatus.confirming,
      actionFailure: null,
      messageKey: null,
    );
    final result = await _confirmUseCase(
      ConfirmAddressPhoneVerificationParams(
        verificationId: state.value.challenge!.verificationId,
        code: input,
      ),
    );
    if (isClosed) return;

    result.fold(_handleActionFailure, (address) {
      _timer?.cancel();
      state.value = state.value.copyWith(
        status: AddressVerificationStatus.verified,
        actionFailure: null,
      );
      completion.value = AddressVerificationCompletion.verified(address);
    });
  }

  Future<void> resend() async {
    if (isBusy || isTerminal || state.value.resendSecondsLeft > 0) {
      return;
    }

    state.value = state.value.copyWith(
      status: AddressVerificationStatus.resending,
      actionFailure: null,
      messageKey: null,
      code: '',
      otpInputVersion: state.value.otpInputVersion + 1,
    );
    final result = await _resendUseCase(
      ResendAddressPhoneVerificationParams(
        verificationId: state.value.challenge!.verificationId,
      ),
    );
    if (isClosed) return;

    result.fold(_handleActionFailure, (challenge) {
      state.value = state.value.copyWith(
        status: AddressVerificationStatus.active,
        challenge: challenge,
        actionFailure: null,
        messageKey: LocaleKeys.phoneVerificationResendSuccess,
      );
      _tick();
    });
  }

  /// Cancels only after an explicit UI confirmation.
  Future<void> cancel() async {
    if (isBusy || isTerminal) return;
    state.value = state.value.copyWith(
      status: AddressVerificationStatus.cancelling,
      actionFailure: null,
      messageKey: null,
    );
    final result = await _cancelUseCase(state.value.challenge!.verificationId);
    if (isClosed) return;

    result.fold(
      (failure) => state.value = state.value.copyWith(
        status: AddressVerificationStatus.active,
        actionFailure: failure,
      ),
      (cancellation) {
        _timer?.cancel();
        final saved = cancellation.address;
        if (saved != null) {
          state.value = state.value.copyWith(
            status: AddressVerificationStatus.verified,
          );
          completion.value = AddressVerificationCompletion.verified(saved);
          return;
        }
        if (cancellation.status == 'expired') {
          state.value = state.value.copyWith(
            status: AddressVerificationStatus.expired,
          );
          completion.value = const AddressVerificationCompletion.closed();
          return;
        }
        if (cancellation.status == 'failed') {
          state.value = state.value.copyWith(
            status: AddressVerificationStatus.limited,
          );
          completion.value = const AddressVerificationCompletion.closed();
          return;
        }
        state.value = state.value.copyWith(
          status: AddressVerificationStatus.cancelled,
        );
        completion.value = const AddressVerificationCompletion.closed();
      },
    );
  }

  void acknowledgeTerminal() {
    switch (state.value.status) {
      case AddressVerificationStatus.expired ||
          AddressVerificationStatus.limited ||
          AddressVerificationStatus.invalid:
        completion.value = const AddressVerificationCompletion.closed();

      case _:
        break;
    }
  }

  void _handleActionFailure(Failure failure) {
    final key = failure.maybeWhen(
      http: (key, _, __, ___, ____) => key,
      orElse: () => null,
    );
    if (key == FailureKey.otpExpired) {
      _expire();
      return;
    }
    if (key == FailureKey.otpAttemptsExceeded ||
        key == FailureKey.otpResendLimitExceeded ||
        key == FailureKey.otpRateLimited ||
        key == FailureKey.phoneAlreadyInUse) {
      _timer?.cancel();
      state.value = state.value.copyWith(
        status: AddressVerificationStatus.limited,
        actionFailure: failure,
      );
      return;
    }
    state.value = state.value.copyWith(
      status: AddressVerificationStatus.active,
      actionFailure: failure,
      code: '',
      otpInputVersion: state.value.otpInputVersion + 1,
    );
  }

  void _tick() {
    if (isClosed || isTerminal) return;
    // The backend decides expiry; the device clock drives the resend countdown.
    final resendAvailableAt = state.value.challenge!.resendAvailableAt;
    final difference = resendAvailableAt != null
        ? resendAvailableAt.difference(DateTime.now()).inSeconds
        : 0;
    final seconds = difference > 0 ? difference : 0;
    if (seconds != state.value.resendSecondsLeft) {
      state.value = state.value.copyWith(resendSecondsLeft: seconds);
    }
  }

  void _expire() {
    _timer?.cancel();
    state.value = state.value.copyWith(
      status: AddressVerificationStatus.expired,
      actionFailure: null,
    );
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
