import 'package:freezed_annotation/freezed_annotation.dart';

part 'pagination_entity.freezed.dart';

@freezed
abstract class PaginationEntity with _$PaginationEntity {
  const factory PaginationEntity({
    @Default(1) int page,
    @Default(16) int limit,
    @Default(0) int total,
    @Default(false) bool hasMore,
  }) = _PaginationEntity;
}
