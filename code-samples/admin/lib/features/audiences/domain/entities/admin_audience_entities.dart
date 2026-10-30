import 'package:freezed_annotation/freezed_annotation.dart';

part 'admin_audience_entities.freezed.dart';

/// Target-audience data returned by the protected Admin contract.
@freezed
abstract class AdminAudienceEntity with _$AdminAudienceEntity {
  const factory AdminAudienceEntity({
    required int id,
    required String arabicName,
    required String englishName,
    required int sortOrder,
    required bool active,
    required int productCount,
    required int collectionCount,
    required int bannerCount,
    required bool canDelete,
  }) = _AdminAudienceEntity;
}

@freezed
abstract class AdminAudienceDeletionImpact with _$AdminAudienceDeletionImpact {
  const factory AdminAudienceDeletionImpact({
    required int audienceId,
    required bool active,
    required int productCount,
    required int collectionCount,
    required int bannerCount,
    required bool canDelete,
    required List<String> blockers,
  }) = _AdminAudienceDeletionImpact;
}

@freezed
abstract class AdminAudienceCreateInput with _$AdminAudienceCreateInput {
  const factory AdminAudienceCreateInput({
    required String arabicName,
    required String englishName,
    required int sortOrder,
    required bool active,
  }) = _AdminAudienceCreateInput;
}

@freezed
abstract class AdminAudienceUpdateInput with _$AdminAudienceUpdateInput {
  const factory AdminAudienceUpdateInput({
    required int audienceId,
    required String arabicName,
    required String englishName,
    required int sortOrder,
  }) = _AdminAudienceUpdateInput;
}
