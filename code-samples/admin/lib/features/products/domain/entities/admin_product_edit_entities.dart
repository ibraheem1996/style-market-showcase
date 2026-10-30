import 'package:freezed_annotation/freezed_annotation.dart';

import 'admin_product_enums.dart';

part 'admin_product_edit_entities.freezed.dart';

@freezed
abstract class AdminProductDetailsEditBootstrapEntity
    with _$AdminProductDetailsEditBootstrapEntity {
  const factory AdminProductDetailsEditBootstrapEntity({
    required int productId,
    required AdminProductEditableDetailsEntity current,
    required List<AdminProductCategoryOptionEntity> categories,
    required List<AdminProductAudienceOptionEntity> audiences,
    required AdminProductSizeGroupCorrectionEntity sizeGroupCorrection,
  }) = _AdminProductDetailsEditBootstrapEntity;
}

@freezed
abstract class AdminProductSizeGroupCorrectionEntity
    with _$AdminProductSizeGroupCorrectionEntity {
  const factory AdminProductSizeGroupCorrectionEntity({
    required int? currentSizeGroupId,
    required bool canUpdate,
    required String? lockedReason,
    required int variantCount,
    required int sizeVariantCount,
    required bool allowedNull,
    required List<AdminProductEditSizeGroupOptionEntity> sizeGroups,
  }) = _AdminProductSizeGroupCorrectionEntity;
}

@freezed
abstract class AdminProductEditSizeGroupOptionEntity
    with _$AdminProductEditSizeGroupOptionEntity {
  const factory AdminProductEditSizeGroupOptionEntity({
    required int id,
    required String arabicName,
    required String? englishName,
    required List<AdminProductEditSizeValueOptionEntity> values,
  }) = _AdminProductEditSizeGroupOptionEntity;
}

@freezed
abstract class AdminProductEditSizeValueOptionEntity
    with _$AdminProductEditSizeValueOptionEntity {
  const factory AdminProductEditSizeValueOptionEntity({
    required int id,
    required String arabicName,
    required String? englishName,
    required int sortOrder,
  }) = _AdminProductEditSizeValueOptionEntity;
}

@freezed
abstract class AdminProductEditableDetailsEntity
    with _$AdminProductEditableDetailsEntity {
  const factory AdminProductEditableDetailsEntity({
    required String arabicName,
    required String? englishName,
    required String? descriptionAr,
    required String? descriptionEn,
    required int? categoryId,
    required int? audienceId,
    required String itemPrice,
    required String itemDiscount,
    required AdminProductSellMode sellMode,
  }) = _AdminProductEditableDetailsEntity;
}

@freezed
abstract class AdminProductCategoryOptionEntity
    with _$AdminProductCategoryOptionEntity {
  const factory AdminProductCategoryOptionEntity({
    required int id,
    required String arabicName,
    required String? englishName,
    required int? parentId,
    required int sortOrder,
    required bool active,
    required bool selectable,
  }) = _AdminProductCategoryOptionEntity;
}

@freezed
abstract class AdminProductAudienceOptionEntity
    with _$AdminProductAudienceOptionEntity {
  const factory AdminProductAudienceOptionEntity({
    required int id,
    required String arabicName,
    required String? englishName,
    required int sortOrder,
    required bool active,
    required bool selectable,
  }) = _AdminProductAudienceOptionEntity;
}

@freezed
abstract class AdminProductDetailsPatchEntity
    with _$AdminProductDetailsPatchEntity {
  const factory AdminProductDetailsPatchEntity({
    String? arabicName,
    String? englishName,
    bool? clearEnglishName,
    String? descriptionAr,
    bool? clearDescriptionAr,
    String? descriptionEn,
    bool? clearDescriptionEn,
    int? categoryId,
    int? audienceId,
    String? itemPrice,
    String? itemDiscount,
    bool? clearItemDiscount,
  }) = _AdminProductDetailsPatchEntity;
}
