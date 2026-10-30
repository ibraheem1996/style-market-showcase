import 'package:freezed_annotation/freezed_annotation.dart';

import 'admin_product_edit_entities.dart';
import 'admin_product_entities.dart';

part 'admin_product_create_entities.freezed.dart';

@freezed
abstract class AdminProductCreateOptionsEntity
    with _$AdminProductCreateOptionsEntity {
  const factory AdminProductCreateOptionsEntity({
    required AdminProductCreateDefaultsEntity defaults,
    required AdminProductCreateLimitsEntity limits,
    required List<AdminProductCategoryOptionEntity> categories,
    required List<AdminProductAudienceOptionEntity> audiences,
    required List<AdminProductCreateSizeGroupOptionEntity> sizeGroups,
  }) = _AdminProductCreateOptionsEntity;
}

@freezed
abstract class AdminProductCreateDefaultsEntity
    with _$AdminProductCreateDefaultsEntity {
  const factory AdminProductCreateDefaultsEntity({
    required bool active,
    required bool featured,
    required String itemDiscount,
    required int simpleStock,
  }) = _AdminProductCreateDefaultsEntity;
}

@freezed
abstract class AdminProductCreateLimitsEntity
    with _$AdminProductCreateLimitsEntity {
  const factory AdminProductCreateLimitsEntity({
    required int arabicNameMaxLength,
    required int englishNameMaxLength,
    required String priceMin,
    required String priceMax,
    required String discountMin,
    required String discountMax,
  }) = _AdminProductCreateLimitsEntity;
}

@freezed
abstract class AdminProductCreateSizeGroupOptionEntity
    with _$AdminProductCreateSizeGroupOptionEntity {
  const factory AdminProductCreateSizeGroupOptionEntity({
    required int id,
    required String arabicName,
    required String? englishName,
    required List<AdminProductCreateSizeValueOptionEntity> values,
  }) = _AdminProductCreateSizeGroupOptionEntity;
}

@freezed
abstract class AdminProductCreateSizeValueOptionEntity
    with _$AdminProductCreateSizeValueOptionEntity {
  const factory AdminProductCreateSizeValueOptionEntity({
    required int id,
    required String arabicName,
    required String? englishName,
    required int sortOrder,
  }) = _AdminProductCreateSizeValueOptionEntity;
}

@freezed
abstract class AdminProductCreateInputEntity
    with _$AdminProductCreateInputEntity {
  const factory AdminProductCreateInputEntity({
    required String arabicName,
    required String englishName,
    required String? descriptionAr,
    required String? descriptionEn,
    required int categoryId,
    required int audienceId,
    required int? sizeGroupId,
    required String itemPrice,
    required String itemDiscount,
    required bool active,
    required bool featured,
    required int simpleStock,
  }) = _AdminProductCreateInputEntity;
}

@freezed
abstract class AdminProductCreateResultEntity
    with _$AdminProductCreateResultEntity {
  const factory AdminProductCreateResultEntity({
    required int createdProductId,
    required AdminProductDetailEntity product,
  }) = _AdminProductCreateResultEntity;
}
