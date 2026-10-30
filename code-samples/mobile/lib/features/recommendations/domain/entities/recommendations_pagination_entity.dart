import 'package:freezed_annotation/freezed_annotation.dart';

part 'recommendations_pagination_entity.freezed.dart';

@freezed
abstract class RecommendationsPaginationEntity
    with _$RecommendationsPaginationEntity {
  const factory RecommendationsPaginationEntity({
    required int page,
    required int limit,
    required bool hasMore,
  }) = _RecommendationsPaginationEntity;
}
