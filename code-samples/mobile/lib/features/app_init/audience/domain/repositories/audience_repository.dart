import '../../../../core/errors/api_result.dart';
import '../entities/audience_entity.dart';

abstract class AudienceRepository {
  Future<ApiResult<List<AudienceEntity>>> getAudiences();
  int? getSelectedAudienceId();
  Future<bool> setSelectedAudienceId(int id);
}
