import 'package:freezed_annotation/freezed_annotation.dart';

import 'admin_product_enums.dart';
import 'admin_product_entities.dart';

part 'admin_product_media_entities.freezed.dart';

@freezed
abstract class AdminProductMediaBootstrapEntity
    with _$AdminProductMediaBootstrapEntity {
  const factory AdminProductMediaBootstrapEntity({
    required AdminProductMediaProductEntity product,
    required AdminProductMediaFallbackEntity fallback,
    required AdminProductMediaLimitsEntity limits,
    required AdminProductMediaBootstrapSummaryEntity summary,
    required AdminProductMediaBootstrapPreviewEntity preview,
    required List<AdminProductMediaTargetEntity> targets,
  }) = _AdminProductMediaBootstrapEntity;
}

@freezed
abstract class AdminProductMediaProductEntity
    with _$AdminProductMediaProductEntity {
  const factory AdminProductMediaProductEntity({
    required int id,
    required String arabicName,
    required String? englishName,
    required AdminProductSellMode sellMode,
    required bool active,
  }) = _AdminProductMediaProductEntity;
}

@freezed
abstract class AdminProductMediaFallbackEntity
    with _$AdminProductMediaFallbackEntity {
  const factory AdminProductMediaFallbackEntity({
    required List<AdminProductMediaScope> cardOrder,
    required List<AdminProductMediaScope> entityOrder,
  }) = _AdminProductMediaFallbackEntity;
}

@freezed
abstract class AdminProductMediaLimitsEntity
    with _$AdminProductMediaLimitsEntity {
  const factory AdminProductMediaLimitsEntity({
    required int maxFilesPerRequest,
    required int maxFileBytes,
    required List<String> allowedExtensions,
    required List<String> allowedMimeTypes,
  }) = _AdminProductMediaLimitsEntity;
}

@freezed
abstract class AdminProductMediaBootstrapSummaryEntity
    with _$AdminProductMediaBootstrapSummaryEntity {
  const factory AdminProductMediaBootstrapSummaryEntity({
    required int targetCount,
    required int ownedImageCount,
    required int itemImageCount,
    required int colorImageCount,
    required int sizeImageCount,
    required int variantImageCount,
  }) = _AdminProductMediaBootstrapSummaryEntity;
}

@freezed
abstract class AdminProductMediaBootstrapPreviewEntity
    with _$AdminProductMediaBootstrapPreviewEntity {
  const factory AdminProductMediaBootstrapPreviewEntity({
    required AdminProductImageSource source,
    required int? sourceId,
    required List<AdminProductMediaImageEntity> images,
  }) = _AdminProductMediaBootstrapPreviewEntity;
}

@freezed
abstract class AdminProductMediaTargetEntity
    with _$AdminProductMediaTargetEntity {
  const factory AdminProductMediaTargetEntity({
    required AdminProductMediaScope scope,
    required int targetId,
    required String targetKey,
    required String label,
    required AdminProductMediaTargetOwnerEntity owner,
    required List<AdminProductMediaImageEntity> ownedImages,
    required AdminProductMediaEffectiveImagesEntity effectiveImages,
  }) = _AdminProductMediaTargetEntity;
}

@freezed
abstract class AdminProductMediaTargetOwnerEntity
    with _$AdminProductMediaTargetOwnerEntity {
  const factory AdminProductMediaTargetOwnerEntity({
    required int? productId,
    required AdminProductColorSummaryEntity? color,
    required AdminProductSizeSummaryEntity? size,
    required int? variantId,
    required bool? active,
  }) = _AdminProductMediaTargetOwnerEntity;
}

@freezed
abstract class AdminProductMediaImageEntity
    with _$AdminProductMediaImageEntity {
  const factory AdminProductMediaImageEntity({
    required int imageId,
    required String url,
    required int sortOrder,
    required bool isPrimary,
    required DateTime? createdAt,
  }) = _AdminProductMediaImageEntity;
}

@freezed
abstract class AdminProductMediaEffectiveImagesEntity
    with _$AdminProductMediaEffectiveImagesEntity {
  const factory AdminProductMediaEffectiveImagesEntity({
    required AdminProductImageSource source,
    required int? sourceId,
    required bool inherited,
    required List<AdminProductMediaImageEntity> images,
  }) = _AdminProductMediaEffectiveImagesEntity;
}

@freezed
abstract class AdminProductMediaMutationResultEntity
    with _$AdminProductMediaMutationResultEntity {
  const factory AdminProductMediaMutationResultEntity({
    required AdminProductMediaOperation operation,
    required List<int>? createdImageIds,
    required int? deletedImageId,
    required bool? storageDeleted,
    required AdminProductMediaBootstrapEntity media,
  }) = _AdminProductMediaMutationResultEntity;
}

@freezed
abstract class AdminProductMediaUploadFileEntity
    with _$AdminProductMediaUploadFileEntity {
  const factory AdminProductMediaUploadFileEntity({
    required String name,
    required List<int> bytes,
    required int size,
    required String? mimeType,
  }) = _AdminProductMediaUploadFileEntity;
}
