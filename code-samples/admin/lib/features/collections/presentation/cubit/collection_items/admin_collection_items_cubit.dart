import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/result/app_result.dart';
import '../../../domain/entities/admin_collection_entities.dart';
import '../../../domain/usecases/get_admin_collection_use_case.dart';
import '../../../domain/usecases/replace_admin_collection_items_use_case.dart';
import '../../logic/admin_collection_error_message_mapper.dart';
import '../../logic/admin_collection_items_validator.dart';
import 'admin_collection_items_effect.dart';
import 'admin_collection_items_state.dart';

@injectable
class AdminCollectionItemsCubit extends Cubit<AdminCollectionItemsState> {
  AdminCollectionItemsCubit(this._getCollection, this._replaceItems)
    : super(const AdminCollectionItemsState());

  final GetAdminCollectionUseCase _getCollection;
  final ReplaceAdminCollectionItemsUseCase _replaceItems;

  Future<void> load(int collectionId) async {
    emit(const AdminCollectionItemsState(isLoading: true));
    final result = await _getCollection(collectionId);
    if (isClosed) return;
    switch (result) {
      case AppResultSuccess(:final data):
        emit(
          state.copyWith(
            items: data.items,
            drafts: data.items
                .map(AdminCollectionItemDraft.fromItem)
                .toList(growable: false),
            isLoading: false,
          ),
        );
      case AppResultFailure(:final failure):
        emit(
          state.copyWith(
            isLoading: false,
            loadError: adminCollectionFailureMessage(failure),
          ),
        );
    }
  }

  void addRow() {
    if (state.isSubmitting) return;
    emit(
      state.copyWith(
        drafts: [
          ...state.drafts,
          const AdminCollectionItemDraft(productId: '', sortOrder: '0'),
        ],
        rowErrors: const {},
      ),
    );
  }

  void removeRow(int index) {
    if (state.isSubmitting || index < 0 || index >= state.drafts.length) {
      return;
    }
    final drafts = [...state.drafts]..removeAt(index);
    emit(state.copyWith(drafts: drafts, rowErrors: const {}));
  }

  void productIdChanged(int index, String value) {
    _updateDraft(index, (draft) => draft.copyWith(productId: value));
  }

  void sortOrderChanged(int index, String value) {
    _updateDraft(index, (draft) => draft.copyWith(sortOrder: value));
  }

  void assignSequentialSortOrder() {
    if (state.isSubmitting) return;
    emit(
      state.copyWith(
        drafts: [
          for (var index = 0; index < state.drafts.length; index++)
            state.drafts[index].copyWith(sortOrder: '$index'),
        ],
        rowErrors: const {},
      ),
    );
  }

  Future<void> submit(int collectionId) async {
    if (state.isSubmitting) return;
    final validation = validateAdminCollectionItems(drafts: state.drafts);
    if (validation.errors.isNotEmpty) {
      emit(
        state.copyWith(
          rowErrors: validation.errors,
          showValidationErrors: true,
        ),
      );
      return;
    }

    emit(state.copyWith(isSubmitting: true, effect: null));
    final result = await _replaceItems(
      collectionId: collectionId,
      input: AdminCollectionItemsReplaceInput(items: validation.items),
    );
    if (isClosed) return;
    switch (result) {
      case AppResultSuccess(:final data):
        emit(
          state.copyWith(
            items: data.items,
            drafts: data.items
                .map(AdminCollectionItemDraft.fromItem)
                .toList(growable: false),
            rowErrors: const {},
            showValidationErrors: false,
            isSubmitting: false,
            effect: const AdminCollectionItemsMessageEffect(
              'تم تحديث منتجات المجموعة.',
            ),
            effectId: state.effectId + 1,
          ),
        );
      case AppResultFailure(:final failure):
        emit(
          state.copyWith(
            isSubmitting: false,
            effect: AdminCollectionItemsMessageEffect(
              adminCollectionFailureMessage(failure),
            ),
            effectId: state.effectId + 1,
          ),
        );
    }
  }

  void _updateDraft(
    int index,
    AdminCollectionItemDraft Function(AdminCollectionItemDraft draft) update,
  ) {
    if (state.isSubmitting || index < 0 || index >= state.drafts.length) {
      return;
    }
    final drafts = [...state.drafts];
    drafts[index] = update(drafts[index]);
    final validation = state.showValidationErrors
        ? validateAdminCollectionItems(drafts: drafts)
        : null;
    emit(
      state.copyWith(
        drafts: drafts,
        rowErrors: validation?.errors ?? state.rowErrors,
      ),
    );
  }
}
