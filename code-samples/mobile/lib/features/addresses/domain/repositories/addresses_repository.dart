// Project imports:
import '../../../../core/errors/api_result.dart';
import '../entities/address_phone_verification_challenge_entity.dart';
import '../entities/address_entity.dart';
import '../entities/address_submit_result.dart';
import '../entities/address_verification_cancellation_entity.dart';
import '../entities/area_entity.dart';
import '../entities/city_entity.dart';

//! Abstract repository for managing addresses
abstract class AddressesRepository {
  //! Get all addresses for a user
  Future<ApiResult<List<AddressEntity>>> getUserAddresses();

  //! Get all available cities
  Future<ApiResult<List<CityEntity>>> getCities();

  //! Get areas for a specific city
  Future<ApiResult<List<AreaEntity>>> getAreas(int cityId);

  //! Create a new address
  Future<ApiResult<AddressSubmitResult>> createAddress({
    required int areaId,
    required String streetOne,
    String? streetTwo,
    required String phone,
  });

  //! Update an existing address
  Future<ApiResult<AddressSubmitResult>> updateAddress({
    required int addressId,
    required int areaId,
    required String streetOne,
    String? streetTwo,
    required String phone,
  });

  //! Delete an address owned by the authenticated user
  Future<ApiResult<void>> deleteAddress(int addressId);

  Future<ApiResult<AddressEntity>> confirmAddressPhoneVerification({
    required String verificationId,
    required String code,
  });

  Future<ApiResult<AddressPhoneVerificationChallengeEntity>>
  resendAddressPhoneVerification({required String verificationId});

  /// Cancels an Address-purpose verification owned by the bearer user.
  Future<ApiResult<AddressVerificationCancellationEntity>>
  cancelAddressVerification({required String verificationId});
}
