import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_project/core/errors/api_result.dart';
import 'package:my_project/core/errors/failure.dart';
import 'package:my_project/core/errors/failure_key.dart';
import 'package:my_project/features/addresses/domain/entities/address_entity.dart';
import 'package:my_project/features/addresses/domain/entities/address_phone_verification_challenge_entity.dart';
import 'package:my_project/features/addresses/domain/entities/address_submit_result.dart';
import 'package:my_project/features/addresses/domain/entities/address_verification_cancellation_entity.dart';
import 'package:my_project/features/addresses/domain/entities/area_entity.dart';
import 'package:my_project/features/addresses/domain/entities/city_entity.dart';
import 'package:my_project/features/addresses/domain/repositories/addresses_repository.dart';
import 'package:my_project/features/addresses/domain/usecases/cancel_address_verification_usecase.dart';
import 'package:my_project/features/addresses/domain/usecases/confirm_address_phone_verification_usecase.dart';
import 'package:my_project/features/addresses/domain/usecases/resend_address_phone_verification_usecase.dart';
import 'package:my_project/features/addresses/presentation/controllers/address_verification_controller.dart';
import 'package:my_project/features/addresses/presentation/state/address_verification_state.dart';

void main() {
  late _FakeRepository repository;
  late AddressVerificationController controller;

  setUp(() {
    repository = _FakeRepository();
    controller = AddressVerificationController(
      challenge: _challenge(),
      confirmUseCase: ConfirmAddressPhoneVerificationUseCase(repository),
      resendUseCase: ResendAddressPhoneVerificationUseCase(repository),
      cancelUseCase: CancelAddressVerificationUseCase(repository),
    )..onStart();
  });

  tearDown(() => controller.onDelete());

  test('confirm success emits authoritative address result', () async {
    controller.onCodeChanged('123456');
    await controller.confirm();

    expect(repository.confirmCode, '123456');
    expect(controller.state.value.status, AddressVerificationStatus.verified);
    expect(controller.completion.value?.address, _address);
  });

  test(
    'invalid OTP remains retryable without remaining-attempt state',
    () async {
      repository.confirmResult = const Left(
        Failure.http(key: FailureKey.otpInvalid),
      );
      controller.onCodeChanged('000000');

      await controller.confirm();

      expect(controller.state.value.status, AddressVerificationStatus.active);
      expect(controller.state.value.actionFailure, isNotNull);
      expect(controller.state.value.code, isEmpty);
    },
  );

  test('resend limit becomes terminal', () async {
    repository.resendResult = const Left(
      Failure.http(key: FailureKey.otpResendLimitExceeded),
    );

    await controller.resend();

    expect(controller.state.value.status, AddressVerificationStatus.limited);
  });

  test('device deadline cannot block backend confirmation', () async {
    final expiredController = AddressVerificationController(
      challenge: _challenge().copyWith(
        expiresAt: DateTime.now().subtract(const Duration(seconds: 1)),
      ),
      confirmUseCase: ConfirmAddressPhoneVerificationUseCase(repository),
      resendUseCase: ResendAddressPhoneVerificationUseCase(repository),
      cancelUseCase: CancelAddressVerificationUseCase(repository),
    )..onStart();

    expect(
      expiredController.state.value.status,
      AddressVerificationStatus.active,
    );
    await expiredController.confirm('123456');
    expect(repository.confirmCode, '123456');
    expect(
      expiredController.state.value.status,
      AddressVerificationStatus.verified,
    );
    expiredController.onDelete();
  });

  test('backend expiry shows only the local terminal message', () async {
    repository.confirmResult = const Left(
      Failure.http(key: FailureKey.otpExpired, rawServerMessage: 'OTP expired'),
    );

    await controller.confirm('123456');

    expect(controller.state.value.status, AddressVerificationStatus.expired);
    expect(controller.state.value.actionFailure, isNull);
  });

  test('invalid session has no challenge or expiry timer', () {
    final invalidController = AddressVerificationController(
      challenge: null,
      confirmUseCase: ConfirmAddressPhoneVerificationUseCase(repository),
      resendUseCase: ResendAddressPhoneVerificationUseCase(repository),
      cancelUseCase: CancelAddressVerificationUseCase(repository),
    )..onStart();

    expect(invalidController.state.value.challenge, isNull);
    expect(
      invalidController.state.value.status,
      AddressVerificationStatus.invalid,
    );
    expect(invalidController.isTerminal, isTrue);
    invalidController.onDelete();
  });

  test('cancel failure keeps verification active', () async {
    repository.cancelResult = const Left(
      Failure.http(key: FailureKey.networkTimeout),
    );

    await controller.cancel();

    expect(controller.state.value.status, AddressVerificationStatus.active);
    expect(controller.completion.value, isNull);
  });

  test('cancel success emits a closed completion', () async {
    await controller.cancel();

    expect(controller.state.value.status, AddressVerificationStatus.cancelled);
    expect(controller.completion.value?.address, isNull);
    expect(controller.completion.value, isNotNull);
  });

  test(
    'cancel replay returns an already-applied authoritative address',
    () async {
      repository.cancelResult = Right(
        AddressVerificationCancellationEntity(
          status: 'verified',
          address: _address,
        ),
      );

      await controller.cancel();

      expect(controller.state.value.status, AddressVerificationStatus.verified);
      expect(controller.completion.value?.address, _address);
    },
  );

  test('late confirm result is ignored after route disposal', () async {
    final pending = repository.enqueueConfirm();
    controller.onCodeChanged('123456');

    final confirm = controller.confirm();
    controller.onDelete();
    pending.complete(Right(_address));
    await confirm;

    expect(controller.completion.value, isNull);
  });
}

AddressPhoneVerificationChallengeEntity _challenge() {
  final now = DateTime.now();
  return AddressPhoneVerificationChallengeEntity(
    verificationId: 'verification-1',
    maskedPhone: '+96279***000',
    expiresAt: now.add(const Duration(minutes: 5)),
    resendAvailableAt: now.subtract(const Duration(seconds: 1)),
  );
}

final _address = AddressEntity(
  addressId: 1,
  userId: 2,
  cityId: 3,
  areaId: 4,
  streetOne: 'Main',
  streetTwo: '',
  phone: '+962790000000',
  cityAr: 'عمّان',
  cityEn: 'Amman',
  areaAr: 'الصويفية',
  areaEn: 'Sweifieh',
);

class _FakeRepository implements AddressesRepository {
  ApiResult<AddressEntity> confirmResult = Right(_address);
  ApiResult<AddressPhoneVerificationChallengeEntity> resendResult = Right(
    _challenge(),
  );
  ApiResult<AddressVerificationCancellationEntity> cancelResult = const Right(
    AddressVerificationCancellationEntity(status: 'cancelled'),
  );
  String? confirmCode;
  Completer<ApiResult<AddressEntity>>? _pendingConfirm;

  Completer<ApiResult<AddressEntity>> enqueueConfirm() {
    return _pendingConfirm = Completer<ApiResult<AddressEntity>>();
  }

  @override
  Future<ApiResult<AddressEntity>> confirmAddressPhoneVerification({
    required String verificationId,
    required String code,
  }) async {
    confirmCode = code;
    return _pendingConfirm?.future ?? confirmResult;
  }

  @override
  Future<ApiResult<AddressPhoneVerificationChallengeEntity>>
  resendAddressPhoneVerification({required String verificationId}) async =>
      resendResult;

  @override
  Future<ApiResult<AddressVerificationCancellationEntity>>
  cancelAddressVerification({required String verificationId}) async =>
      cancelResult;

  @override
  Future<ApiResult<AddressSubmitResult>> createAddress({
    required int areaId,
    required String streetOne,
    String? streetTwo,
    required String phone,
  }) => throw UnimplementedError();

  @override
  Future<ApiResult<void>> deleteAddress(int addressId) =>
      throw UnimplementedError();

  @override
  Future<ApiResult<List<AreaEntity>>> getAreas(int cityId) =>
      throw UnimplementedError();

  @override
  Future<ApiResult<List<CityEntity>>> getCities() => throw UnimplementedError();

  @override
  Future<ApiResult<List<AddressEntity>>> getUserAddresses() =>
      throw UnimplementedError();

  @override
  Future<ApiResult<AddressSubmitResult>> updateAddress({
    required int addressId,
    required int areaId,
    required String streetOne,
    String? streetTwo,
    required String phone,
  }) => throw UnimplementedError();
}
