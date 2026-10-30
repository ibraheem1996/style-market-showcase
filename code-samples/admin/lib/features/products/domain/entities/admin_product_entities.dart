import 'package:freezed_annotation/freezed_annotation.dart';

import 'admin_product_enums.dart';
import 'admin_products_pagination.dart';

part 'admin_product_entities.freezed.dart';

@freezed
abstract class AdminProductsPageEntity with _$AdminProductsPageEntity {
  const factory AdminProductsPageEntity({
    required List<AdminProductSummaryEntity> items,

    required AdminProductsPagination pagination,
  }) = _AdminProductsPageEntity;
}

@freezed
abstract class AdminProductSummaryEntity with _$AdminProductSummaryEntity {
  const factory AdminProductSummaryEntity({
    required int id,

    required String arabicName,

    required String? englishName,

    required AdminProductNamedSummaryEntity? category,

    required AdminProductNamedSummaryEntity? audience,

    required AdminProductSellMode sellMode,

    required bool active,

    required bool featured,

    required int variantCount,

    required int totalStock,

    required AdminProductStockState stockState,

    required AdminProductStockSource stockSource,

    required AdminProductPriceSummaryEntity price,

    required String? thumbnailImage,

    required List<String> resolvedImages,

    required DateTime? createdAt,

    required DateTime? updatedAt,
  }) = _AdminProductSummaryEntity;
}

@freezed
abstract class AdminProductDetailEntity with _$AdminProductDetailEntity {
  const factory AdminProductDetailEntity({
    required int id,

    required String arabicName,

    required String? englishName,

    required String? descriptionAr,

    required String? descriptionEn,

    required AdminProductNamedSummaryEntity? category,

    required AdminProductNamedSummaryEntity? audience,

    required AdminProductNamedSummaryEntity? sizeGroup,

    required AdminProductSellMode sellMode,

    required bool active,

    required bool featured,

    required AdminProductSimpleStockEntity? simpleStock,

    required AdminProductInventorySummaryEntity inventorySummary,

    required AdminProductPriceSummaryEntity price,

    required AdminProductMediaEntity media,

    required AdminProductVariantViewEntity? variantView,

    required bool orderLinked,

    required DateTime? createdAt,

    required DateTime? updatedAt,
  }) = _AdminProductDetailEntity;
}

@freezed
abstract class AdminProductVariantViewVariantEntity
    with _$AdminProductVariantViewVariantEntity {
  const factory AdminProductVariantViewVariantEntity({
    required int id,

    required bool active,

    required int stock,

    required AdminProductStockState stockState,

    required AdminProductStockSource stockSource,

    required AdminProductColorSummaryEntity? color,

    required AdminProductSizeSummaryEntity? size,

    required String? descriptionAr,

    required String? descriptionEn,

    required AdminProductPriceSummaryEntity price,

    required AdminProductImageOwnershipEntity imageOwnership,

    required List<AdminProductImageEntity> variantImages,

    required bool orderLinked,

    required DateTime? createdAt,
  }) = _AdminProductVariantViewVariantEntity;
}

@freezed
abstract class AdminProductNamedSummaryEntity
    with _$AdminProductNamedSummaryEntity {
  const factory AdminProductNamedSummaryEntity({
    required int? id,

    required String? arabicName,

    required String? englishName,
  }) = _AdminProductNamedSummaryEntity;
}

@freezed
abstract class AdminProductColorSummaryEntity
    with _$AdminProductColorSummaryEntity {
  const factory AdminProductColorSummaryEntity({
    required int? id,

    required String? arabicName,

    required String? englishName,

    required String? hex,
  }) = _AdminProductColorSummaryEntity;
}

@freezed
abstract class AdminProductSizeSummaryEntity
    with _$AdminProductSizeSummaryEntity {
  const factory AdminProductSizeSummaryEntity({
    required int? id,

    required String? arabicName,

    required String? englishName,
  }) = _AdminProductSizeSummaryEntity;
}

@freezed
abstract class AdminProductPriceSummaryEntity
    with _$AdminProductPriceSummaryEntity {
  const factory AdminProductPriceSummaryEntity({
    required double itemPrice,

    required double itemDiscount,

    required double? minEffectivePrice,

    required double? maxEffectivePrice,

    required double? minFinalPrice,

    required double? maxFinalPrice,

    required double? effectivePrice,

    required double? effectiveDiscount,

    required double? finalPrice,
  }) = _AdminProductPriceSummaryEntity;
}

@freezed
abstract class AdminProductSimpleStockEntity
    with _$AdminProductSimpleStockEntity {
  const factory AdminProductSimpleStockEntity({
    required int stock,

    required AdminProductStockState stockState,

    required AdminProductStockSource stockSource,
  }) = _AdminProductSimpleStockEntity;
}

@freezed
abstract class AdminProductInventorySummaryEntity
    with _$AdminProductInventorySummaryEntity {
  const factory AdminProductInventorySummaryEntity({
    required AdminProductStockSource stockSource,

    required int? stock,

    required AdminProductStockState stockState,

    required int variantCount,

    required int activeVariantCount,

    required int inactiveVariantCount,

    required int totalStock,

    required int lowestStock,
  }) = _AdminProductInventorySummaryEntity;
}

@freezed
abstract class AdminProductMediaEntity with _$AdminProductMediaEntity {
  const factory AdminProductMediaEntity({
    required AdminProductMediaThumbnailEntity? thumbnail,

    required AdminProductMediaPreviewEntity preview,

    required AdminProductMediaSummaryEntity summary,

    required AdminProductMediaItemImagesEntity itemImages,

    required List<AdminProductMediaColorImageGroupEntity> colorImageGroups,

    required List<AdminProductMediaSizeImageGroupEntity> sizeImageGroups,

    required List<AdminProductMediaVariantImageGroupEntity> variantImageGroups,
  }) = _AdminProductMediaEntity;
}

@freezed
abstract class AdminProductMediaThumbnailEntity
    with _$AdminProductMediaThumbnailEntity {
  const factory AdminProductMediaThumbnailEntity({
    required String url,

    required AdminProductImageSource source,

    required int? sourceId,
  }) = _AdminProductMediaThumbnailEntity;
}

@freezed
abstract class AdminProductMediaPreviewEntity
    with _$AdminProductMediaPreviewEntity {
  const factory AdminProductMediaPreviewEntity({
    required AdminProductImageSource source,

    required int? sourceId,

    required List<AdminProductImageEntity> images,
  }) = _AdminProductMediaPreviewEntity;
}

@freezed
abstract class AdminProductMediaSummaryEntity
    with _$AdminProductMediaSummaryEntity {
  const factory AdminProductMediaSummaryEntity({
    required AdminProductImageStrategy strategy,

    required int totalImageCount,

    required int uniqueImageCount,

    required int itemImageCount,

    required int colorGroupCount,

    required int colorImageCount,

    required int sizeGroupCount,

    required int sizeImageCount,

    required int variantGroupCount,

    required int variantImageCount,
  }) = _AdminProductMediaSummaryEntity;
}

@freezed
abstract class AdminProductMediaItemImagesEntity
    with _$AdminProductMediaItemImagesEntity {
  const factory AdminProductMediaItemImagesEntity({
    required AdminProductImageSource source,

    required List<AdminProductImageEntity> images,
  }) = _AdminProductMediaItemImagesEntity;
}

@freezed
abstract class AdminProductImageEntity with _$AdminProductImageEntity {
  const factory AdminProductImageEntity({required String url}) =
      _AdminProductImageEntity;
}

@freezed
abstract class AdminProductMediaColorImageGroupEntity
    with _$AdminProductMediaColorImageGroupEntity {
  const factory AdminProductMediaColorImageGroupEntity({
    required AdminProductImageSource source,

    required AdminProductColorSummaryEntity color,

    required List<AdminProductImageEntity> images,
  }) = _AdminProductMediaColorImageGroupEntity;
}

@freezed
abstract class AdminProductMediaSizeImageGroupEntity
    with _$AdminProductMediaSizeImageGroupEntity {
  const factory AdminProductMediaSizeImageGroupEntity({
    required AdminProductImageSource source,

    required AdminProductSizeSummaryEntity size,

    required List<AdminProductImageEntity> images,
  }) = _AdminProductMediaSizeImageGroupEntity;
}

@freezed
abstract class AdminProductMediaVariantImageGroupEntity
    with _$AdminProductMediaVariantImageGroupEntity {
  const factory AdminProductMediaVariantImageGroupEntity({
    required AdminProductImageSource source,

    required AdminProductMediaVariantRefEntity variant,

    required List<AdminProductImageEntity> images,
  }) = _AdminProductMediaVariantImageGroupEntity;
}

@freezed
abstract class AdminProductMediaVariantRefEntity
    with _$AdminProductMediaVariantRefEntity {
  const factory AdminProductMediaVariantRefEntity({
    required int id,

    required String label,

    required AdminProductColorSummaryEntity? color,

    required AdminProductSizeSummaryEntity? size,
  }) = _AdminProductMediaVariantRefEntity;
}

@freezed
abstract class AdminProductVariantViewEntity
    with _$AdminProductVariantViewEntity {
  const factory AdminProductVariantViewEntity({
    required AdminProductVariantGrouping grouping,

    required AdminProductImageStrategy imageStrategy,

    required AdminProductVariantNoteCode noteCode,

    required List<AdminProductVariantGroupEntity> groups,
  }) = _AdminProductVariantViewEntity;
}

@freezed
abstract class AdminProductVariantGroupEntity
    with _$AdminProductVariantGroupEntity {
  const factory AdminProductVariantGroupEntity({
    required AdminProductVariantGroupType type,

    required String? label,

    required AdminProductColorSummaryEntity? color,

    required AdminProductSizeSummaryEntity? size,

    required List<AdminProductImageEntity> images,

    required AdminProductImageOwnershipEntity imageOwnership,

    required AdminProductVariantGroupSummaryEntity summary,

    required List<AdminProductVariantViewVariantEntity> variants,
  }) = _AdminProductVariantGroupEntity;
}

@freezed
abstract class AdminProductImageOwnershipEntity
    with _$AdminProductImageOwnershipEntity {
  const factory AdminProductImageOwnershipEntity({
    required AdminProductImageSource source,

    required bool inherited,

    required int? sourceId,
  }) = _AdminProductImageOwnershipEntity;
}

@freezed
abstract class AdminProductVariantGroupSummaryEntity
    with _$AdminProductVariantGroupSummaryEntity {
  const factory AdminProductVariantGroupSummaryEntity({
    required int variantCount,

    required int totalStock,

    required int lowestStock,

    required int activeCount,

    required int inactiveCount,

    required double? minFinalPrice,

    required double? maxFinalPrice,
  }) = _AdminProductVariantGroupSummaryEntity;
}

@freezed
abstract class AdminProductVisibilityEntity
    with _$AdminProductVisibilityEntity {
  const factory AdminProductVisibilityEntity({
    required int productId,

    required bool active,

    required bool featured,

    required AdminProductDetailEntity product,
  }) = _AdminProductVisibilityEntity;
}

@freezed
abstract class AdminProductStockEntity with _$AdminProductStockEntity {
  const factory AdminProductStockEntity({
    required int productId,

    required AdminProductSellMode sellMode,

    required int stock,

    required AdminProductStockState stockState,

    required AdminProductStockSource stockSource,
  }) = _AdminProductStockEntity;
}

@freezed
abstract class AdminVariantStockEntity with _$AdminVariantStockEntity {
  const factory AdminVariantStockEntity({
    required int variantId,

    required int productId,

    required int stock,

    required AdminProductStockState stockState,

    required AdminProductStockSource stockSource,
  }) = _AdminVariantStockEntity;
}

@freezed
abstract class AdminVariantVisibilityEntity
    with _$AdminVariantVisibilityEntity {
  const factory AdminVariantVisibilityEntity({
    required int variantId,

    required int productId,

    required bool active,

    required AdminProductDetailEntity product,
  }) = _AdminVariantVisibilityEntity;
}

@freezed
abstract class AdminVariantUpdateEntity with _$AdminVariantUpdateEntity {
  const factory AdminVariantUpdateEntity({
    required int variantId,

    required int productId,

    required bool active,
  }) = _AdminVariantUpdateEntity;
}
