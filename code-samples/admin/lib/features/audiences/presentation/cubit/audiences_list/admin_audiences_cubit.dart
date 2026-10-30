import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/result/app_result.dart';
import '../../../domain/entities/admin_audience_entities.dart';
import '../../../domain/usecases/delete_admin_audience_use_case.dart';
import '../../../domain/usecases/get_admin_audience_deletion_impact_use_case.dart';
import '../../../domain/usecases/get_admin_audiences_use_case.dart';
import '../../../domain/usecases/update_admin_audience_visibility_use_case.dart';
import '../../logic/admin_audience_error_message_mapper.dart';
import 'admin_audiences_effect.dart';
import 'admin_audiences_state.dart';

@injectable
class AdminAudiencesCubit extends Cubit<AdminAudiencesState> {
  AdminAudiencesCubit(
    this._getAudiences,
    this._updateVisibility,
    this._getDeletionImpact,
    this._deleteAudience,
  ) : super(const AdminAudiencesState());

  final GetAdminAudiencesUseCase _getAudiences;
  final UpdateAdminAudienceVisibilityUseCase _updateVisibility;
  final GetAdminAudienceDeletionImpactUseCase _getDeletionImpact;
  final DeleteAdminAudienceUseCase _deleteAudience;

  Future<void> load() => _load(initial: true);

  Future<void> refresh() => _load(initial: false);

  Future<void> changeVisibility(AdminAudienceEntity audience) async {
    if (state.operation != null) return;
    emit(
      state.copyWith(
        operationAudienceId: audience.id,
        operation: AdminAudienceListOperation.visibility,
        effect: null,
      ),
    );
    final result = await _updateVisibility(
      audienceId: audience.id,
      active: !audience.active,
    );
    if (isClosed) return;
    switch (result) {
      case AppResultSuccess(:final data):
        emit(
          state.copyWith(
            audiences: _replaceAudience(state.audiences, data),
            operationAudienceId: null,
            operation: null,
            pendingDeletionImpact: null,
            effect: AdminAudiencesMessageEffect(
              data.active
                  ? 'تم تفعيل الفئة المستهدفة.'
                  : 'تم إيقاف الفئة المستهدفة.',
            ),
            effectId: state.effectId + 1,
          ),
        );
      case AppResultFailure(:final failure):
        _finishOperationWithMessage(adminAudienceFailureMessage(failure));
    }
  }

  /// Loads a fresh dependency snapshot before deletion can be confirmed.
  Future<void> requestDeletionImpact(int audienceId) async {
    if (state.operation != null) return;
    emit(
      state.copyWith(
        operationAudienceId: audienceId,
        operation: AdminAudienceListOperation.deletionImpact,
        pendingDeletionImpact: null,
        effect: null,
      ),
    );
    final result = await _getDeletionImpact(audienceId);
    if (isClosed) return;
    switch (result) {
      case AppResultSuccess(:final data):
        emit(
          state.copyWith(
            operationAudienceId: null,
            operation: null,
            pendingDeletionImpact: data,
            effect: AdminAudiencesDeletionImpactEffect(data),
            effectId: state.effectId + 1,
          ),
        );
      case AppResultFailure(:final failure):
        _finishOperationWithMessage(adminAudienceFailureMessage(failure));
    }
  }

  Future<void> deleteAudience(int audienceId) async {
    final impact = state.pendingDeletionImpact;
    if (state.operation != null ||
        impact == null ||
        impact.audienceId != audienceId ||
        !impact.canDelete) {
      return;
    }
    emit(
      state.copyWith(
        operationAudienceId: audienceId,
        operation: AdminAudienceListOperation.delete,
        effect: null,
      ),
    );
    final result = await _deleteAudience(audienceId);
    if (isClosed) return;
    switch (result) {
      case AppResultFailure(:final failure):
        _finishOperationWithMessage(adminAudienceFailureMessage(failure));
      case AppResultSuccess(data: _):
        final refreshResult = await _getAudiences();
        if (isClosed) return;
        switch (refreshResult) {
          case AppResultSuccess(:final data):
            emit(
              state.copyWith(
                audiences: data,
                operationAudienceId: null,
                operation: null,
                pendingDeletionImpact: null,
                effect: const AdminAudiencesMessageEffect(
                  'تم حذف الفئة المستهدفة.',
                ),
                effectId: state.effectId + 1,
              ),
            );
          case AppResultFailure():
            emit(
              state.copyWith(
                operationAudienceId: null,
                operation: null,
                pendingDeletionImpact: null,
                effect: const AdminAudiencesMessageEffect(
                  'تم حذف الفئة المستهدفة، لكن تعذر تحديث القائمة. اضغط تحديث للمحاولة مجددًا.',
                ),
                effectId: state.effectId + 1,
              ),
            );
        }
    }
  }

  Future<void> _load({required bool initial}) async {
    if (state.isLoading || state.isRefreshing || state.operation != null) {
      return;
    }
    emit(
      state.copyWith(
        isLoading: initial && state.audiences.isEmpty,
        isRefreshing: !initial || state.audiences.isNotEmpty,
        loadError: null,
        effect: null,
      ),
    );
    final result = await _getAudiences();
    if (isClosed) return;
    switch (result) {
      case AppResultSuccess(:final data):
        emit(
          state.copyWith(
            audiences: data,
            isLoading: false,
            isRefreshing: false,
            pendingDeletionImpact: null,
          ),
        );
      case AppResultFailure(:final failure):
        final message = adminAudienceFailureMessage(failure);
        final hasData = state.audiences.isNotEmpty;
        emit(
          state.copyWith(
            isLoading: false,
            isRefreshing: false,
            loadError: hasData ? null : message,
            effect: hasData ? AdminAudiencesMessageEffect(message) : null,
            effectId: hasData ? state.effectId + 1 : state.effectId,
          ),
        );
    }
  }

  List<AdminAudienceEntity> _replaceAudience(
    List<AdminAudienceEntity> audiences,
    AdminAudienceEntity replacement,
  ) => audiences
      .map((item) => item.id == replacement.id ? replacement : item)
      .toList(growable: false);

  void _finishOperationWithMessage(String message) {
    emit(
      state.copyWith(
        operationAudienceId: null,
        operation: null,
        pendingDeletionImpact: null,
        effect: AdminAudiencesMessageEffect(message),
        effectId: state.effectId + 1,
      ),
    );
  }
}
