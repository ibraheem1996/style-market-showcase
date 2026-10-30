import '../../../../core/errors/api_result.dart';
import '../entities/address_entity.dart';
import '../repositories/addresses_repository.dart';

class ConfirmAddressPhoneVerificationUseCase {
  const ConfirmAddressPhoneVerificationUseCase(this.repository);

  final AddressesRepository repository;

  Future<ApiResult<AddressEntity>> call(
    ConfirmAddressPhoneVerificationParams params,
  ) {
    return repository.confirmAddressPhoneVerification(
      verificationId: params.verificationId,
      code: params.code,
    );
  }
}

class ConfirmAddressPhoneVerificationParams {
  const ConfirmAddressPhoneVerificationParams({
    required this.verificationId,
    required this.code,
  });

  final String verificationId;
  final String code;
}
