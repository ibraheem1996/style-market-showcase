import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/result/app_result.dart';
import '../../../domain/entities/admin_audience_entities.dart';
import '../../../domain/usecases/create_admin_audience_use_case.dart';
import '../../../domain/usecases/get_admin_audience_use_case.dart';
import '../../../domain/usecases/update_admin_audience_use_case.dart';
import '../../logic/admin_audience_error_message_mapper.dart';
import '../../logic/admin_audience_form_validator.dart';
import 'admin_audience_form_effect.dart';
import 'admin_audience_form_state.dart';

@injectable
class AdminAudienceFormCubit extends Cubit<AdminAudienceFormState> {
  AdminAudienceFormCubit(
    this._getAudience,
    this._createAudience,
    this._updateAudience,
  ) : super(const AdminAudienceFormState(mode: AdminAudienceFormMode.create));

  final GetAdminAudienceUseCase _getAudience;
  final CreateAdminAudienceUseCase _createAudience;
  final UpdateAdminAudienceUseCase _updateAudience;

  void loadCreate() {
    emit(
      const AdminAudienceFormState(
        mode: AdminAudienceFormMode.create,
        draft: AdminAudienceFormDraft(),
      ),
    );
  }

  Future<void> loadEdit(int audienceId) async {
    emit(
      AdminAudienceFormState(
        mode: AdminAudienceFormMode.edit,
        audienceId: audienceId,
        isLoading: true,
      ),
    );
    final result = await _getAudience(audienceId);
    if (isClosed) return;
    switch (result) {
      case AppResultSuccess(:final data):
        emit(
          state.copyWith(
            draft: AdminAudienceFormDraft(
              arabicName: data.arabicName,
              englishName: data.englishName,
              sortOrder: '${data.sortOrder}',
              active: data.active,
            ),
            isLoading: false,
          ),
        );
      case AppResultFailure(:final failure):
        emit(
          state.copyWith(
            isLoading: false,
            loadError: adminAudienceFailureMessage(failure),
          ),
        );
    }
  }

  void arabicNameChanged(String value) =>
      _updateDraft((draft) => draft.copyWith(arabicName: value));

  void englishNameChanged(String value) =>
      _updateDraft((draft) => draft.copyWith(englishName: value));

  void sortOrderChanged(String value) =>
      _updateDraft((draft) => draft.copyWith(sortOrder: value));

  void activeChanged(bool value) {
    if (state.mode == AdminAudienceFormMode.create) {
      _updateDraft((draft) => draft.copyWith(active: value));
    }
  }

  Future<void> submit() async {
    final draft = state.draft;
    if (draft == null || state.isSubmitting) return;

    final validation = validateAdminAudienceForm(draft);
    if (validation.errors.isNotEmpty) {
      emit(
        state.copyWith(
          fieldErrors: validation.errors,
          showValidationErrors: true,
        ),
      );
      return;
    }

    emit(state.copyWith(isSubmitting: true, effect: null));
    final result = switch (state.mode) {
      AdminAudienceFormMode.create => _createAudience(
        AdminAudienceCreateInput(
          arabicName: validation.arabicName,
          englishName: validation.englishName,
          sortOrder: validation.sortOrder!,
          active: draft.active,
        ),
      ),
      AdminAudienceFormMode.edit => _updateAudience(
        AdminAudienceUpdateInput(
          audienceId: state.audienceId!,
          arabicName: validation.arabicName,
          englishName: validation.englishName,
          sortOrder: validation.sortOrder!,
        ),
      ),
    };
    final completed = await result;
    if (isClosed) return;
    switch (completed) {
      case AppResultSuccess():
        emit(
          state.copyWith(
            isSubmitting: false,
            fieldErrors: const {},
            showValidationErrors: false,
            effect: AdminAudienceFormSuccessEffect(
              state.mode == AdminAudienceFormMode.create
                  ? AdminAudienceSavedAction.created
                  : AdminAudienceSavedAction.updated,
            ),
            effectId: state.effectId + 1,
          ),
        );
      case AppResultFailure(:final failure):
        emit(
          state.copyWith(
            isSubmitting: false,
            effect: AdminAudienceFormFailureEffect(
              adminAudienceFailureMessage(failure),
            ),
            effectId: state.effectId + 1,
          ),
        );
    }
  }

  void _updateDraft(
    AdminAudienceFormDraft Function(AdminAudienceFormDraft draft) update,
  ) {
    final draft = state.draft;
    if (draft == null || state.isSubmitting) return;
    final updated = update(draft);
    final validation = state.showValidationErrors
        ? validateAdminAudienceForm(updated)
        : null;
    emit(
      state.copyWith(
        draft: updated,
        fieldErrors: validation?.errors ?? state.fieldErrors,
      ),
    );
  }
}
