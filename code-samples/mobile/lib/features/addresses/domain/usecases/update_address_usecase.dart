// Project imports:
import '../../../../core/errors/api_result.dart';
import '../entities/address_submit_result.dart';
import '../repositories/addresses_repository.dart';

//! Use case for updating an existing address
class UpdateAddressUseCase {
  final AddressesRepository repository;

  UpdateAddressUseCase(this.repository);

  Future<ApiResult<AddressSubmitResult>> call(
    UpdateAddressParams params,
  ) async {
    return await repository.updateAddress(
      addressId: params.addressId,
      areaId: params.areaId,
      streetOne: params.streetOne,
      streetTwo: params.streetTwo,
      phone: params.phone,
    );
  }
}

class UpdateAddressParams {
  final int addressId;
  final int areaId;
  final String streetOne;
  final String? streetTwo;
  final String phone;

  UpdateAddressParams({
    required this.addressId,
    required this.areaId,
    required this.streetOne,
    required this.phone,
    this.streetTwo,
  });
}
