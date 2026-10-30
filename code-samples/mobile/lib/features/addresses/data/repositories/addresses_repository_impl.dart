// Package imports:
import 'package:dartz/dartz.dart';

// Project imports:
import '../../../../core/errors/api_result.dart';
import '../../../../core/errors/app_failure_key.dart';
import '../../../../core/errors/backend_error_code_resolver.dart';
import '../../../../core/base/base_repository.dart';
import '../../../../core/network/response_mapper.dart';
import '../../../../core/services/crashlytics_service.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/errors/failure_key.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/api_status.dart';
import 'package:my_project/features/auth/session/session_service.dart';
import '../../domain/entities/address_phone_verification_challenge_entity.dart';
import '../../domain/entities/address_entity.dart';
import '../../domain/entities/address_submit_result.dart';
import '../../domain/entities/area_entity.dart';
import '../../domain/entities/city_entity.dart';
import '../../domain/repositories/addresses_repository.dart';
import '../datasources/remote/addresses_remote_datasource.dart';
import '../mappers/address_mapper.dart';
import '../mappers/address_phone_verification_mapper.dart';
import '../mappers/address_submit_mapper.dart';
import '../mappers/address_verification_cancellation_mapper.dart';
import '../mappers/area_mapper.dart';
import '../mappers/city_mapper.dart';
import '../models/confirm_address_phone_verification_request.dart';
import '../models/create_address_request.dart';
import '../models/update_address_request.dart';
import '../../domain/entities/address_verification_cancellation_entity.dart';

//! Repository implementation for addresses feature
class AddressesRepositoryImpl extends BaseRepository
    implements AddressesRepository {
  final AddressesRemoteDataSource remoteDataSource;
  final SessionService sessionService;
  final CrashlyticsService crash;

  AddressesRepositoryImpl({
    required this.remoteDataSource,
    required this.sessionService,
    required this.crash,
    required super.analytics,
    required super.performance,
  }) : super(crash: crash);

  @override
  Future<ApiResult<List<AddressEntity>>> getUserAddresses() async {
    if (sessionService.userId == null) {
      return Left(Failure.app(key: AppFailureKey.loginRequired));
    }
    final result = await handleApiCall(remoteDataSource.getUserAddresses);
    return result.fold((failure) => Left(failure), (response) {
      if (!parseApiStatus(response.status).isSuccess) {
        return Left(
          Failure.http(
            key:
                BackendErrorCodeResolver.httpFailureKeyOf(response.errorCode) ??
                FailureKey.serverGeneric,
            rawServerMessage: response.message,
            errorCode: response.errorCode,
          ),
        );
      }

      final data = response.data;
      if (data == null) {
        return const Left(Failure.http(key: FailureKey.missingServerData));
      }
      return mapListSafely(
        models: data,
        mapper: (model) => model.toEntity(),
        requireAllItems: false,
        logTag: 'AddressesRepository.getUserAddresses',
        crash: crash,
      );
    });
  }

  @override
  Future<ApiResult<List<CityEntity>>> getCities() async {
    final result = await handleApiCall(remoteDataSource.getCities);
    return result.fold((failure) => Left(failure), (response) {
      if (!parseApiStatus(response.status).isSuccess) {
        return Left(
          Failure.http(
            key:
                BackendErrorCodeResolver.httpFailureKeyOf(response.errorCode) ??
                FailureKey.serverGeneric,
            rawServerMessage: response.message,
            errorCode: response.errorCode,
          ),
        );
      }

      final data = response.data;
      if (data == null) {
        return const Left(Failure.http(key: FailureKey.missingServerData));
      }
      return mapListSafely(
        models: data,
        mapper: (model) => model.toEntity(),
        requireAllItems: false,
        logTag: 'AddressesRepository.getCities',
        crash: crash,
      );
    });
  }

  @override
  Future<ApiResult<List<AreaEntity>>> getAreas(int cityId) async {
    final result = await handleApiCall(() => remoteDataSource.getAreas(cityId));
    return result.fold((failure) => Left(failure), (response) {
      if (!parseApiStatus(response.status).isSuccess) {
        return Left(
          Failure.http(
            key:
                BackendErrorCodeResolver.httpFailureKeyOf(response.errorCode) ??
                FailureKey.serverGeneric,
            rawServerMessage: response.message,
            errorCode: response.errorCode,
          ),
        );
      }

      final data = response.data;
      if (data == null) {
        return const Left(Failure.http(key: FailureKey.missingServerData));
      }
      return mapListSafely(
        models: data,
        mapper: (model) => model.toEntity(),
        requireAllItems: false,
        logTag: 'AddressesRepository.getAreas',
        crash: crash,
      );
    });
  }

  @override
  Future<ApiResult<AddressSubmitResult>> createAddress({
    required int areaId,
    required String streetOne,
    String? streetTwo,
    required String phone,
  }) async {
    if (sessionService.userId == null) {
      return Left(Failure.app(key: AppFailureKey.loginRequired));
    }
    final request = CreateAddressRequest(
      areaId: areaId,
      streetOne: streetOne,
      streetTwo: streetTwo,
      phone: phone,
    );
    return handleApiCall(
      () async => (await remoteDataSource.createAddress(request)).toEntity(),
    );
  }

  @override
  Future<ApiResult<AddressSubmitResult>> updateAddress({
    required int addressId,
    required int areaId,
    required String streetOne,
    String? streetTwo,
    required String phone,
  }) async {
    if (sessionService.userId == null) {
      return Left(Failure.app(key: AppFailureKey.loginRequired));
    }
    final result = await handleApiCall(() async {
      final request = UpdateAddressRequest(
        areaId: areaId,
        streetOne: streetOne,
        streetTwo: streetTwo,
        phone: phone,
      );
      return (await remoteDataSource.updateAddress(
        addressId,
        request,
      )).toEntity();
    });
    return result;
  }

  @override
  Future<ApiResult<void>> deleteAddress(int addressId) async {
    if (sessionService.userId == null) {
      return Left(Failure.app(key: AppFailureKey.loginRequired));
    }

    final result = await handleApiCall(
      () => remoteDataSource.deleteAddress(addressId),
    );
    return result.fold((failure) => Left(failure), (response) {
      if (!parseApiStatus(response.status).isSuccess ||
          response.errorCode != null) {
        return Left(_failureFromResponse(response));
      }
      return const Right(null);
    });
  }

  @override
  Future<ApiResult<AddressEntity>> confirmAddressPhoneVerification({
    required String verificationId,
    required String code,
  }) async {
    if (sessionService.userId == null) {
      return Left(Failure.app(key: AppFailureKey.loginRequired));
    }

    final result = await handleApiCall(
      () => remoteDataSource.confirmAddressPhoneVerification(
        ConfirmAddressPhoneVerificationRequest(
          verificationId: verificationId,
          code: code,
        ),
      ),
    );
    return result.fold((failure) => Left(failure), (response) {
      if (!parseApiStatus(response.status).isSuccess ||
          response.errorCode != null) {
        return Left(_failureFromResponse(response));
      }
      if (response.data == null) {
        return const Left(Failure.http(key: FailureKey.missingServerData));
      }

      try {
        return Right(response.data!.toEntity());
      } catch (error, stackTrace) {
        crash.logError(
          error,
          stackTrace,
          reason:
              'AddressesRepository.confirmAddressPhoneVerification invalid data',
        );
        return const Left(Failure.http(key: FailureKey.invalidData));
      }
    });
  }

  @override
  Future<ApiResult<AddressPhoneVerificationChallengeEntity>>
  resendAddressPhoneVerification({required String verificationId}) async {
    if (sessionService.userId == null) {
      return Left(Failure.app(key: AppFailureKey.loginRequired));
    }

    final result = await handleApiCall(
      () => remoteDataSource.resendAddressPhoneVerification(verificationId),
    );
    return result.fold((failure) => Left(failure), (response) {
      if (!parseApiStatus(response.status).isSuccess ||
          response.errorCode != 'PHONE_VERIFICATION_REQUIRED') {
        return Left(_failureFromResponse(response));
      }
      if (response.data == null) {
        return const Left(Failure.http(key: FailureKey.missingServerData));
      }

      try {
        return Right(response.data!.toEntity());
      } catch (error, stackTrace) {
        crash.logError(
          error,
          stackTrace,
          reason:
              'AddressesRepository.resendAddressPhoneVerification invalid data',
        );
        return const Left(Failure.http(key: FailureKey.invalidData));
      }
    });
  }

  @override
  Future<ApiResult<AddressVerificationCancellationEntity>>
  cancelAddressVerification({required String verificationId}) async {
    if (sessionService.userId == null) {
      return Left(Failure.app(key: AppFailureKey.loginRequired));
    }

    final result = await handleApiCall(
      () => remoteDataSource.cancelAddressVerification(verificationId),
    );
    return result.fold((failure) => Left(failure), (response) {
      if (!parseApiStatus(response.status).isSuccess ||
          response.errorCode != null) {
        return Left(_failureFromResponse(response));
      }
      if (response.data == null) {
        return const Left(Failure.http(key: FailureKey.missingServerData));
      }
      try {
        return Right(response.data!.toEntity());
      } catch (error, stackTrace) {
        crash.logError(
          error,
          stackTrace,
          reason: 'AddressesRepository.cancelAddressVerification invalid data',
        );
        return const Left(Failure.http(key: FailureKey.invalidData));
      }
    });
  }

  Failure _failureFromResponse<T>(ApiResponse<T> response) {
    final errorCode = response.errorCode;
    return Failure.http(
      key:
          BackendErrorCodeResolver.httpFailureKeyOf(errorCode) ??
          FailureKey.serverGeneric,
      rawServerMessage: response.message,
      errorCode: errorCode,
    );
  }
}
