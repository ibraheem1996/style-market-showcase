import '../../../../core/result/app_result.dart';
import '../entities/admin_entity.dart';
import '../entities/admin_session_entity.dart';

abstract interface class AdminAuthRepository {
  Future<AppResult<AdminSessionEntity>> signIn({
    required String email,
    required String password,
  });

  Future<AppResult<AdminEntity>> getCurrentAdmin();

  Future<AppResult<AdminSessionEntity>> refreshSession();

  Future<AppResult<void>> logout();

  Future<void> clearLocalSession();

  Future<bool> hasStoredSession();
}
