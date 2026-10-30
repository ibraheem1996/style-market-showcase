import '../../../../core/errors/mapping_exception.dart';
import '../../domain/entities/recommendations_pagination_entity.dart';
import '../models/recommendations_pagination_model.dart';

extension RecommendationsPaginationModelMapper
    on RecommendationsPaginationModel {
  RecommendationsPaginationEntity toEntity() {
    final p = page;
    final l = limit;
    final more = hasMore;
    if (p == null || l == null || more == null) {
      throw const MappingException(
        'Recommendations pagination: page/limit/has_more required',
      );
    }
    return RecommendationsPaginationEntity(page: p, limit: l, hasMore: more);
  }
}
