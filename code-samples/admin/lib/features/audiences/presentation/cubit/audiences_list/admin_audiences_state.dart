import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../domain/entities/admin_audience_entities.dart';
import 'admin_audiences_effect.dart';

part 'admin_audiences_state.freezed.dart';

enum AdminAudienceListOperation { visibility, deletionImpact, delete }

@freezed
abstract class AdminAudiencesState with _$AdminAudiencesState {
  const factory AdminAudiencesState({
    @Default(<AdminAudienceEntity>[]) List<AdminAudienceEntity> audiences,
    @Default(false) bool isLoading,
    @Default(false) bool isRefreshing,
    int? operationAudienceId,
    AdminAudienceListOperation? operation,
    AdminAudienceDeletionImpact? pendingDeletionImpact,
    String? loadError,
    AdminAudiencesEffect? effect,
    @Default(0) int effectId,
  }) = _AdminAudiencesState;
}
