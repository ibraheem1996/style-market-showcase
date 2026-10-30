import '../../../../core/errors/api_result.dart';
import '../entities/recommendation_context.dart';
import '../entities/recommendations_response_entity.dart';

abstract class RecommendationsRepository {
  Future<ApiResult<RecommendationsResponseEntity>> getRecommendations({
    required RecommendationContext context,
    required int page,
    required int limit,
    int? itemId,
    int? audienceId,
  });
}
