import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../domain/entities/admin_collection_entities.dart';
import '../../logic/admin_collection_items_validator.dart';
import 'admin_collection_items_effect.dart';

part 'admin_collection_items_state.freezed.dart';

@freezed
abstract class AdminCollectionItemsState with _$AdminCollectionItemsState {
  const factory AdminCollectionItemsState({
    @Default(<AdminCollectionItem>[]) List<AdminCollectionItem> items,

    @Default(<AdminCollectionItemDraft>[])
    List<AdminCollectionItemDraft> drafts,

    @Default(<int, Map<String, String>>{})
    Map<int, Map<String, String>> rowErrors,

    @Default(false) bool showValidationErrors,

    @Default(false) bool isLoading,

    @Default(false) bool isSubmitting,

    String? loadError,

    AdminCollectionItemsEffect? effect,

    @Default(0) int effectId,
  }) = _AdminCollectionItemsState;
}
