import 'package:freezed_annotation/freezed_annotation.dart';

import 'admin_product_entities.dart';
import 'admin_product_enums.dart';

part 'admin_product_lifecycle_entities.freezed.dart';

@freezed
abstract class AdminProductDeletionImpactEntity
    with _$AdminProductDeletionImpactEntity {
  const factory AdminProductDeletionImpactEntity({
    required int productId,
    required String arabicName,
    required String? englishName,
    required bool active,
    required AdminProductSellMode sellMode,
    required bool canDelete,
    required AdminProductDeletionBlockersEntity blockers,
    required AdminProductDeleteEffectsEntity deleteEffects,
  }) = _AdminProductDeletionImpactEntity;
}

@freezed
abstract class AdminProductDeletionBlockersEntity
    with _$AdminProductDeletionBlockersEntity {
  const factory AdminProductDeletionBlockersEntity({
    required bool active,
    required int orderItemCount,
    required int cartRowCount,
  }) = _AdminProductDeletionBlockersEntity;
}

@freezed
abstract class AdminProductDeleteEffectsEntity
    with _$AdminProductDeleteEffectsEntity {
  const factory AdminProductDeleteEffectsEntity({
    required int favoriteRowCount,
    required int variantCount,
    required int variantAttributeCount,
    required int mediaRowCount,
    required int mediaFileCount,
    required int collectionItemCount,
    required int itemAttributeMetaCount,
    required int recentlyViewedCount,
  }) = _AdminProductDeleteEffectsEntity;
}

@freezed
abstract class AdminVariantDeletionImpactEntity
    with _$AdminVariantDeletionImpactEntity {
  const factory AdminVariantDeletionImpactEntity({
    required int variantId,
    required int productId,
    required String productArabicName,
    required bool active,
    required bool canDelete,
    required AdminVariantDeletionBlockersEntity blockers,
    required AdminVariantDeleteEffectsEntity deleteEffects,
  }) = _AdminVariantDeletionImpactEntity;
}

@freezed
abstract class AdminVariantDeletionBlockersEntity
    with _$AdminVariantDeletionBlockersEntity {
  const factory AdminVariantDeletionBlockersEntity({
    required bool active,
    required int orderItemCount,
    required int cartRowCount,
    required bool isLastVariant,
  }) = _AdminVariantDeletionBlockersEntity;
}

@freezed
abstract class AdminVariantDeleteEffectsEntity
    with _$AdminVariantDeleteEffectsEntity {
  const factory AdminVariantDeleteEffectsEntity({
    required int favoriteRowCount,
    required int variantAttributeCount,
    required int variantMediaRowCount,
    required int orphanColorMediaRowCount,
    required int orphanSizeMediaRowCount,
    required int orphanItemAttributeMetaCount,
    required int mediaFileCount,
    required int remainingVariantCount,
  }) = _AdminVariantDeleteEffectsEntity;
}

@freezed
abstract class AdminDeletionStorageEntity with _$AdminDeletionStorageEntity {
  const factory AdminDeletionStorageEntity({
    required int deleted,
    required int retainedShared,
    required int failed,
  }) = _AdminDeletionStorageEntity;
}

@freezed
abstract class AdminProductDeleteResultEntity
    with _$AdminProductDeleteResultEntity {
  const factory AdminProductDeleteResultEntity({
    required int deletedProductId,
    required AdminProductDeleteEffectsEntity deleteEffects,
    required AdminDeletionStorageEntity storage,
  }) = _AdminProductDeleteResultEntity;
}

@freezed
abstract class AdminVariantDeleteResultEntity
    with _$AdminVariantDeleteResultEntity {
  const factory AdminVariantDeleteResultEntity({
    required int deletedVariantId,
    required int productId,
    required AdminVariantDeleteEffectsEntity deleteEffects,
    required AdminDeletionStorageEntity storage,
    required AdminProductDetailEntity product,
  }) = _AdminVariantDeleteResultEntity;
}
