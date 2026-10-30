// Project imports:
import '../../../../core/errors/api_result.dart';
import '../entities/address_submit_result.dart';
import '../repositories/addresses_repository.dart';

//! Use case for creating a new address
class CreateAddressUseCase {
  final AddressesRepository repository;

  CreateAddressUseCase(this.repository);

  Future<ApiResult<AddressSubmitResult>> call(
    CreateAddressParams params,
  ) async {
    return await repository.createAddress(
      areaId: params.areaId,
      streetOne: params.streetOne,
      streetTwo: params.streetTwo,
      phone: params.phone,
    );
  }
}

class CreateAddressParams {
  final int areaId;
  final String streetOne;
  final String? streetTwo;
  final String phone;

  CreateAddressParams({
    required this.areaId,
    required this.streetOne,
    required this.phone,
    this.streetTwo,
  });
}
