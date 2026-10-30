import 'package:freezed_annotation/freezed_annotation.dart';

import 'admin_audience_form_effect.dart';

part 'admin_audience_form_state.freezed.dart';

enum AdminAudienceFormMode { create, edit }

@freezed
abstract class AdminAudienceFormDraft with _$AdminAudienceFormDraft {
  const factory AdminAudienceFormDraft({
    @Default('') String arabicName,
    @Default('') String englishName,
    @Default('0') String sortOrder,
    @Default(true) bool active,
  }) = _AdminAudienceFormDraft;
}

@freezed
abstract class AdminAudienceFormState with _$AdminAudienceFormState {
  const factory AdminAudienceFormState({
    required AdminAudienceFormMode mode,
    int? audienceId,
    AdminAudienceFormDraft? draft,
    @Default(<String, String>{}) Map<String, String> fieldErrors,
    @Default(false) bool showValidationErrors,
    @Default(false) bool isLoading,
    @Default(false) bool isSubmitting,
    String? loadError,
    AdminAudienceFormEffect? effect,
    @Default(0) int effectId,
  }) = _AdminAudienceFormState;
}
