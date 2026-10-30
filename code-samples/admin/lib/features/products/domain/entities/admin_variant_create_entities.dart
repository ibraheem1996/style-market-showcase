import 'package:freezed_annotation/freezed_annotation.dart';

import 'admin_product_entities.dart';
import 'admin_product_enums.dart';

part 'admin_variant_create_entities.freezed.dart';

enum AdminVariantShape { colorOnly, sizeOnly, colorSize }

enum AdminVariantShapeLockReason {
  existingVariants,
  inconsistentExistingVariants,
}

enum AdminVariantShapeInconsistency {
  mixedShapes,
  unsupportedEmptyShape,
  sizeGroupMissing,
  sizeGroupMismatch,
  multipleSizeGroups,
  invalidVariantRelation,
}

@freezed
abstract class AdminVariantCreateOptionsEntity
    with _$AdminVariantCreateOptionsEntity {
  const factory AdminVariantCreateOptionsEntity({
    required int productId,
    required AdminVariantCreateProductContextEntity product,
    required AdminVariantShape? currentVariantShape,
    required List<AdminVariantShape> detectedVariantShapes,
    required bool shapeLocked,
    required AdminVariantShapeLockReason? shapeLockReason,
    required AdminVariantShapeInconsistency? shapeInconsistency,
    required int? inferredSizeGroupId,
    required AdminVariantAllowedShapesEntity allowedShapes,
    required List<AdminVariantCreateColorOptionEntity> colors,
    required List<AdminVariantCreateSizeOptionEntity> sizes,
    required List<AdminVariantExistingCombinationEntity> existingCombinations,
    required AdminVariantConversionImpactEntity conversionImpact,
  }) = _AdminVariantCreateOptionsEntity;
}

@freezed
abstract class AdminVariantCreateProductContextEntity
    with _$AdminVariantCreateProductContextEntity {
  const factory AdminVariantCreateProductContextEntity({
    required int id,
    required String arabicName,
    required String? englishName,
    required AdminProductSellMode sellMode,
    required String itemPrice,
    required String itemDiscount,
    required AdminProductNamedSummaryEntity? sizeGroup,
  }) = _AdminVariantCreateProductContextEntity;
}

@freezed
abstract class AdminVariantAllowedShapesEntity
    with _$AdminVariantAllowedShapesEntity {
  const factory AdminVariantAllowedShapesEntity({
    required bool colorSize,
    required bool colorOnly,
    required bool sizeOnly,
    required bool none,
  }) = _AdminVariantAllowedShapesEntity;
}

@freezed
abstract class AdminVariantCreateColorOptionEntity
    with _$AdminVariantCreateColorOptionEntity {
  const factory AdminVariantCreateColorOptionEntity({
    required int id,
    required String arabicName,
    required String? englishName,
    required String? hex,
    required int sortOrder,
    required bool selectable,
  }) = _AdminVariantCreateColorOptionEntity;
}

@freezed
abstract class AdminVariantCreateSizeOptionEntity
    with _$AdminVariantCreateSizeOptionEntity {
  const factory AdminVariantCreateSizeOptionEntity({
    required int id,
    required String arabicName,
    required String? englishName,
    required int sortOrder,
    required bool selectable,
  }) = _AdminVariantCreateSizeOptionEntity;
}

@freezed
abstract class AdminVariantExistingCombinationEntity
    with _$AdminVariantExistingCombinationEntity {
  const factory AdminVariantExistingCombinationEntity({
    required int variantId,
    required int? colorId,
    required int? sizeId,
    required String? variantKey,
    required String label,
    required AdminVariantShape? shape,
    required bool active,
  }) = _AdminVariantExistingCombinationEntity;
}

@freezed
abstract class AdminVariantConversionImpactEntity
    with _$AdminVariantConversionImpactEntity {
  const factory AdminVariantConversionImpactEntity({
    required bool willConvertSimpleProduct,
    required int simpleCartRowCount,
    required int simpleFavoriteRowCount,
  }) = _AdminVariantConversionImpactEntity;
}

@freezed
abstract class AdminVariantCreateInputEntity
    with _$AdminVariantCreateInputEntity {
  const factory AdminVariantCreateInputEntity({
    required int? colorId,
    required int? sizeId,
    required String? descriptionAr,
    required String? descriptionEn,
    required int stock,
    required bool active,
    required String? variantPrice,
    required String? variantDiscount,
  }) = _AdminVariantCreateInputEntity;
}

@freezed
abstract class AdminVariantCreateResultEntity
    with _$AdminVariantCreateResultEntity {
  const factory AdminVariantCreateResultEntity({
    required int createdVariantId,
    required AdminProductDetailEntity product,
  }) = _AdminVariantCreateResultEntity;
}
