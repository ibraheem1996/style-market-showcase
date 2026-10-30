import 'package:freezed_annotation/freezed_annotation.dart';

part 'admin_collection_entities.freezed.dart';

@freezed
abstract class AdminCollectionAudience with _$AdminCollectionAudience {
  const factory AdminCollectionAudience({
    required int id,
    required String nameAr,
    required String nameEn,
    required bool active,
  }) = _AdminCollectionAudience;
}

@freezed
abstract class AdminCollectionAudienceOption
    with _$AdminCollectionAudienceOption {
  const factory AdminCollectionAudienceOption({
    required int id,
    required String nameAr,
    required String nameEn,
    required bool active,
    required bool selectable,
  }) = _AdminCollectionAudienceOption;
}

@freezed
abstract class AdminCollectionLimits with _$AdminCollectionLimits {
  const factory AdminCollectionLimits({
    required int maxFileBytes,
    required List<String> allowedExtensions,
    required List<String> allowedMimeTypes,
  }) = _AdminCollectionLimits;
}

@freezed
abstract class AdminCollection with _$AdminCollection {
  const factory AdminCollection({
    required int id,
    required String nameAr,
    required String nameEn,
    required int targetAudienceId,
    required AdminCollectionAudience audience,
    required String image,
    required bool isActive,
    required int sortOrder,
    required int itemsCount,
  }) = _AdminCollection;
}

@freezed
abstract class AdminCollectionItem with _$AdminCollectionItem {
  const factory AdminCollectionItem({
    required int productId,
    required String arabicName,
    required String? englishName,
    required bool active,
    required int sortOrder,
  }) = _AdminCollectionItem;
}

@freezed
abstract class AdminCollectionListResult with _$AdminCollectionListResult {
  const factory AdminCollectionListResult({
    required List<AdminCollection> collections,
    required List<AdminCollectionAudienceOption> audienceOptions,
    required AdminCollectionLimits limits,
  }) = _AdminCollectionListResult;
}

@freezed
abstract class AdminCollectionMutationResult
    with _$AdminCollectionMutationResult {
  const factory AdminCollectionMutationResult({
    required AdminCollection collection,
    required List<AdminCollectionAudienceOption> audienceOptions,
    required AdminCollectionLimits? limits,
    required List<String> warnings,
  }) = _AdminCollectionMutationResult;
}

@freezed
abstract class AdminCollectionDetailResult with _$AdminCollectionDetailResult {
  const factory AdminCollectionDetailResult({
    required AdminCollection collection,
    required List<AdminCollectionAudienceOption> audienceOptions,
    required AdminCollectionLimits? limits,
    required List<String> warnings,
    required List<AdminCollectionItem> items,
  }) = _AdminCollectionDetailResult;
}

@freezed
abstract class AdminCollectionItemsResult with _$AdminCollectionItemsResult {
  const factory AdminCollectionItemsResult({
    required int collectionId,
    required List<AdminCollectionItem> items,
  }) = _AdminCollectionItemsResult;
}

@freezed
abstract class AdminCollectionDeleteResult with _$AdminCollectionDeleteResult {
  const factory AdminCollectionDeleteResult({
    required int deletedCollectionId,
    required List<String> warnings,
  }) = _AdminCollectionDeleteResult;
}

@freezed
abstract class AdminCollectionImageInput with _$AdminCollectionImageInput {
  const factory AdminCollectionImageInput({
    required String name,
    required List<int> bytes,
    required int size,
    required String? mimeType,
  }) = _AdminCollectionImageInput;
}

@freezed
abstract class AdminCollectionCreateInput with _$AdminCollectionCreateInput {
  const factory AdminCollectionCreateInput({
    required String nameAr,
    required String nameEn,
    required int targetAudienceId,
    required AdminCollectionImageInput image,
    required bool isActive,
    required int sortOrder,
  }) = _AdminCollectionCreateInput;
}

@freezed
abstract class AdminCollectionUpdateInput with _$AdminCollectionUpdateInput {
  const factory AdminCollectionUpdateInput({
    required int collectionId,
    required String nameAr,
    required String nameEn,
    required int targetAudienceId,
    required AdminCollectionImageInput? image,
    required bool isActive,
    required int sortOrder,
  }) = _AdminCollectionUpdateInput;
}

@freezed
abstract class AdminCollectionItemWriteInput
    with _$AdminCollectionItemWriteInput {
  const factory AdminCollectionItemWriteInput({
    required int productId,
    required int sortOrder,
  }) = _AdminCollectionItemWriteInput;
}

@freezed
abstract class AdminCollectionItemsReplaceInput
    with _$AdminCollectionItemsReplaceInput {
  const factory AdminCollectionItemsReplaceInput({
    required List<AdminCollectionItemWriteInput> items,
  }) = _AdminCollectionItemsReplaceInput;
}

class AdminCollectionFilters {
  const AdminCollectionFilters({this.active, this.audienceId, this.search});

  final bool? active;
  final int? audienceId;
  final String? search;

  Map<String, dynamic> toQuery() {
    final normalizedSearch = search?.trim();
    return {
      if (active != null) 'active': active,
      if (audienceId != null) 'audience_id': audienceId,
      if (normalizedSearch != null && normalizedSearch.isNotEmpty)
        'search': normalizedSearch,
    };
  }
}
