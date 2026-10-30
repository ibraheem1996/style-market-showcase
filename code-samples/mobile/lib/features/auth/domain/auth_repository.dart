// Project imports:
import '../../../../core/errors/api_result.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<ApiResult<UserEntity>> login(String email, String password);
  Future<ApiResult<UserEntity>> signInWithGoogle();
  Future<ApiResult<bool>> signup({
    required String username,
    required String email,
    required String password,
    required String phone,
  });
  Future<ApiResult<void>> sendEmailCode(String email);
  Future<ApiResult<void>> verifyEmail(String email, String code);
  Future<ApiResult<void>> forgetPassword(String email);
  Future<ApiResult<void>> verifyResetCode(String email, String code);
  Future<ApiResult<void>> updatePassword(
    String email,
    String code,
    String newPassword,
  );
  Future<ApiResult<void>> signOut();
}
