import 'package:freezed_annotation/freezed_annotation.dart';

part 'admin_category_entities.freezed.dart';

/// A category node exactly as owned and ordered by the Backend tree.
@freezed
abstract class AdminCategoryEntity with _$AdminCategoryEntity {
  const factory AdminCategoryEntity({
    required int id,
    required String arabicName,
    required String englishName,
    required String? image,
    required int? parentId,
    required int sortOrder,
    required bool active,
    required int directProductCount,
    required int directChildrenCount,
    required bool canDelete,
    required List<AdminCategoryEntity> children,
  }) = _AdminCategoryEntity;
}

@freezed
abstract class AdminCategoryImageInput with _$AdminCategoryImageInput {
  const factory AdminCategoryImageInput({
    required String name,
    required List<int> bytes,
    required int size,
    required String? mimeType,
  }) = _AdminCategoryImageInput;
}

@freezed
abstract class AdminCategoryCreateInput with _$AdminCategoryCreateInput {
  const factory AdminCategoryCreateInput({
    required String arabicName,
    required String englishName,
    required int? parentId,
    required int sortOrder,
    required AdminCategoryImageInput image,
  }) = _AdminCategoryCreateInput;
}

@freezed
abstract class AdminCategoryUpdateInput with _$AdminCategoryUpdateInput {
  const factory AdminCategoryUpdateInput({
    required int categoryId,
    required String arabicName,
    required String englishName,
    required int? parentId,
    required int sortOrder,
    required AdminCategoryImageInput? image,
  }) = _AdminCategoryUpdateInput;
}

@freezed
abstract class AdminCategoryMutationResult with _$AdminCategoryMutationResult {
  const factory AdminCategoryMutationResult({
    required AdminCategoryEntity category,
    required List<String> warnings,
  }) = _AdminCategoryMutationResult;
}

@freezed
abstract class AdminCategoryDeletionImpact with _$AdminCategoryDeletionImpact {
  const factory AdminCategoryDeletionImpact({
    required int categoryId,
    required bool active,
    required int directProductCount,
    required int directChildrenCount,
    required bool canDelete,
    required List<String> blockers,
  }) = _AdminCategoryDeletionImpact;
}

@freezed
abstract class AdminCategoryDeleteResult with _$AdminCategoryDeleteResult {
  const factory AdminCategoryDeleteResult({
    required int deletedCategoryId,
    required List<String> warnings,
  }) = _AdminCategoryDeleteResult;
}
