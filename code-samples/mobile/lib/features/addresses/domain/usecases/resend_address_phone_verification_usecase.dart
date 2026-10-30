import '../../../../core/errors/api_result.dart';
import '../entities/address_phone_verification_challenge_entity.dart';
import '../repositories/addresses_repository.dart';

class ResendAddressPhoneVerificationUseCase {
  const ResendAddressPhoneVerificationUseCase(this.repository);

  final AddressesRepository repository;

  Future<ApiResult<AddressPhoneVerificationChallengeEntity>> call(
    ResendAddressPhoneVerificationParams params,
  ) {
    return repository.resendAddressPhoneVerification(
      verificationId: params.verificationId,
    );
  }
}

class ResendAddressPhoneVerificationParams {
  const ResendAddressPhoneVerificationParams({required this.verificationId});

  final String verificationId;
}
