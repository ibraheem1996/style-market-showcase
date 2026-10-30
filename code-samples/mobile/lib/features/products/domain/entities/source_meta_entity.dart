import 'package:freezed_annotation/freezed_annotation.dart';

part 'source_meta_entity.freezed.dart';

@freezed
abstract class SourceMetaEntity with _$SourceMetaEntity {
  const factory SourceMetaEntity({
    @Default('') String nameAr,
    @Default('') String nameEn,
    @Default('') String sourceType,
    @Default('') String sourceId,
  }) = _SourceMetaEntity;
}
