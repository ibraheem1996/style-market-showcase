import 'dart:async';

import 'package:multi_product_store_admin_web/core/errors/app_failure.dart';
import 'package:multi_product_store_admin_web/core/result/app_result.dart';
import 'package:multi_product_store_admin_web/features/products/domain/entities/admin_product_enums.dart';
import 'package:multi_product_store_admin_web/features/products/domain/entities/admin_product_create_entities.dart';
import 'package:multi_product_store_admin_web/features/products/domain/entities/admin_product_edit_entities.dart';
import 'package:multi_product_store_admin_web/features/products/domain/entities/admin_product_entities.dart';
import 'package:multi_product_store_admin_web/features/products/domain/entities/admin_product_filters.dart';
import 'package:multi_product_store_admin_web/features/products/domain/entities/admin_product_media_entities.dart';
import 'package:multi_product_store_admin_web/features/products/domain/entities/admin_product_lifecycle_entities.dart';
import 'package:multi_product_store_admin_web/features/products/domain/entities/admin_products_pagination.dart';
import 'package:multi_product_store_admin_web/features/products/domain/entities/admin_variant_create_entities.dart';
import 'package:multi_product_store_admin_web/features/products/domain/entities/admin_variant_edit_entities.dart';
import 'package:multi_product_store_admin_web/features/products/domain/repositories/admin_products_repository.dart';

const testColorBlack = AdminProductColorSummaryEntity(
  id: 7,
  arabicName: 'أسود',
  englishName: 'Black',
  hex: '#000000',
);

const testColorPink = AdminProductColorSummaryEntity(
  id: 7,
  arabicName: 'وردي',
  englishName: 'Pink',
  hex: '#EE8AA8',
);

const testSizeM = AdminProductSizeSummaryEntity(
  id: 4,
  arabicName: 'M',
  englishName: 'M',
);

const testSizeL = AdminProductSizeSummaryEntity(
  id: 5,
  arabicName: 'L',
  englishName: 'L',
);

AdminProductsPageEntity testProductsPage({
  List<AdminProductSummaryEntity>? items,
  int page = 1,
  int totalItems = 1,
}) {
  return AdminProductsPageEntity(
    items: items ?? [testSimpleProductSummary()],
    pagination: AdminProductsPagination(
      page: page,
      pageSize: 20,
      totalItems: totalItems,
      totalPages: totalItems == 0 ? 0 : ((totalItems + 19) ~/ 20),
      hasNext: page * 20 < totalItems,
      hasPrevious: page > 1,
    ),
  );
}

AdminProductSummaryEntity testSimpleProductSummary({int id = 10}) {
  return AdminProductSummaryEntity(
    id: id,
    arabicName: 'منتج بسيط',
    englishName: 'Simple',
    category: const AdminProductNamedSummaryEntity(
      id: 2,
      arabicName: 'ملابس',
      englishName: 'Clothes',
    ),
    audience: const AdminProductNamedSummaryEntity(
      id: 1,
      arabicName: 'رجال',
      englishName: 'Men',
    ),
    sellMode: AdminProductSellMode.simple,
    active: true,
    featured: false,
    variantCount: 0,
    totalStock: 4,
    stockState: AdminProductStockState.lowStock,
    stockSource: AdminProductStockSource.itemStock,
    price: testPrice(finalPrice: 90),
    thumbnailImage: 'simple.jpg',
    resolvedImages: const ['simple.jpg'],
    createdAt: DateTime(2026, 6, 15),
    updatedAt: null,
  );
}

AdminProductDetailEntity testSimpleProductDetail({int id = 10}) {
  return AdminProductDetailEntity(
    id: id,
    arabicName: 'منتج بسيط',
    englishName: 'Simple',
    descriptionAr: 'وصف',
    descriptionEn: 'Description',
    category: const AdminProductNamedSummaryEntity(
      id: 2,
      arabicName: 'ملابس',
      englishName: 'Clothes',
    ),
    audience: const AdminProductNamedSummaryEntity(
      id: 1,
      arabicName: 'رجال',
      englishName: 'Men',
    ),
    sizeGroup: const AdminProductNamedSummaryEntity(
      id: 3,
      arabicName: 'مقاسات عامة',
      englishName: 'General Sizes',
    ),
    sellMode: AdminProductSellMode.simple,
    active: true,
    featured: false,
    simpleStock: const AdminProductSimpleStockEntity(
      stock: 4,
      stockState: AdminProductStockState.lowStock,
      stockSource: AdminProductStockSource.itemStock,
    ),
    inventorySummary: const AdminProductInventorySummaryEntity(
      stockSource: AdminProductStockSource.itemStock,
      stock: 4,
      stockState: AdminProductStockState.lowStock,
      variantCount: 0,
      activeVariantCount: 0,
      inactiveVariantCount: 0,
      totalStock: 4,
      lowestStock: 4,
    ),
    price: testPrice(finalPrice: 90),
    media: testMedia(itemImages: const ['simple.jpg']),
    variantView: null,
    orderLinked: false,
    createdAt: DateTime(2026, 6, 15),
    updatedAt: null,
  );
}

AdminProductDetailEntity testVariantProductDetail({int id = 11}) {
  final variant = testVariant(id: 101, orderLinked: true);
  return testSimpleProductDetail(id: id).copyWith(
    arabicName: 'منتج بخيارات',
    sellMode: AdminProductSellMode.variant,
    simpleStock: null,
    inventorySummary: const AdminProductInventorySummaryEntity(
      stockSource: AdminProductStockSource.variantStock,
      stock: null,
      stockState: AdminProductStockState.lowStock,
      variantCount: 1,
      activeVariantCount: 1,
      inactiveVariantCount: 0,
      totalStock: 2,
      lowestStock: 2,
    ),
    orderLinked: true,
    price: testPrice(minFinalPrice: 57, maxFinalPrice: 70),
    media: testMedia(
      itemImages: const ['item.jpg'],
      colorImages: const ['black.jpg'],
      color: testColorBlack,
      strategy: AdminProductImageStrategy.mixed,
    ),
    variantView: testVariantView(
      noteCode: AdminProductVariantNoteCode.variantsUseColorImages,
      imageStrategy: AdminProductImageStrategy.colorImages,
      groups: [
        testVariantGroup(
          color: testColorBlack,
          images: const ['black.jpg'],
          variants: [variant],
          inherited: false,
          source: AdminProductImageSource.color,
          sourceId: 7,
        ),
      ],
    ),
  );
}

AdminProductDetailEntity testVariantProductWithItemImagesOnly({int id = 12}) {
  final variants = [
    testVariant(id: 201, color: null, size: testSizeM),
    testVariant(id: 202, color: null, size: testSizeL, stock: 3),
  ];
  return testVariantProductDetail(id: id).copyWith(
    media: testMedia(itemImages: const ['item-a.jpg', 'item-b.jpg']),
    variantView: testVariantView(
      grouping: AdminProductVariantGrouping.size,
      noteCode: AdminProductVariantNoteCode.variantsUseItemImages,
      imageStrategy: AdminProductImageStrategy.itemImages,
      groups: [
        testVariantGroup(
          type: AdminProductVariantGroupType.size,
          color: null,
          size: testSizeM,
          images: const [],
          variants: [variants.first],
          source: AdminProductImageSource.item,
          inherited: true,
          sourceId: id,
        ),
        testVariantGroup(
          type: AdminProductVariantGroupType.size,
          color: null,
          size: testSizeL,
          images: const [],
          variants: [variants.last],
          source: AdminProductImageSource.item,
          inherited: true,
          sourceId: id,
        ),
      ],
    ),
  );
}

AdminProductDetailEntity testColorGroupedVariantProduct({int id = 13}) {
  final variants = [
    testVariant(id: 301, color: testColorPink, size: testSizeM, stock: 28),
    testVariant(id: 302, color: testColorPink, size: testSizeL, stock: 30),
  ];
  return testVariantProductDetail(id: id).copyWith(
    media: testMedia(
      colorImages: const ['pink-a.jpg', 'pink-b.jpg'],
      color: testColorPink,
      strategy: AdminProductImageStrategy.colorImages,
    ),
    variantView: testVariantView(
      noteCode: AdminProductVariantNoteCode.variantsUseColorImages,
      imageStrategy: AdminProductImageStrategy.colorImages,
      groups: [
        testVariantGroup(
          color: testColorPink,
          images: const ['pink-a.jpg', 'pink-b.jpg'],
          variants: variants,
          totalStock: 58,
          lowestStock: 28,
          variantCount: 2,
          source: AdminProductImageSource.color,
          inherited: false,
          sourceId: 7,
        ),
      ],
    ),
  );
}

AdminProductDetailEntity testVariantSpecificImageProduct({int id = 14}) {
  final product = testColorGroupedVariantProduct(id: id);
  final variant = testVariant(
    id: 302,
    color: testColorPink,
    size: testSizeL,
    variantImages: const ['variant-l-a.jpg', 'variant-l-b.jpg'],
    source: AdminProductImageSource.variant,
    inherited: false,
    sourceId: 302,
  );
  return product.copyWith(
    media: testMedia(
      colorImages: const ['pink-a.jpg'],
      color: testColorPink,
      variantImages: const ['variant-l-a.jpg', 'variant-l-b.jpg'],
      variantRefId: 302,
      strategy: AdminProductImageStrategy.mixed,
    ),
    variantView: testVariantView(
      noteCode: AdminProductVariantNoteCode.variantsHaveOwnImages,
      imageStrategy: AdminProductImageStrategy.variantImages,
      groups: [
        testVariantGroup(
          color: testColorPink,
          images: const [],
          variants: [variant],
          source: AdminProductImageSource.variant,
          inherited: false,
          sourceId: 302,
        ),
      ],
    ),
  );
}

AdminProductDetailEntity testSizeOnlyVariantProduct({int id = 15}) {
  final variants = [
    testVariant(id: 401, color: null, size: testSizeM),
    testVariant(id: 402, color: null, size: testSizeL),
  ];
  return testVariantProductDetail(id: id).copyWith(
    media: testMedia(
      sizeImages: const ['size-m.jpg'],
      size: testSizeM,
      strategy: AdminProductImageStrategy.sizeImages,
    ),
    variantView: testVariantView(
      grouping: AdminProductVariantGrouping.size,
      noteCode: AdminProductVariantNoteCode.variantsUseSizeImages,
      imageStrategy: AdminProductImageStrategy.sizeImages,
      groups: [
        testVariantGroup(
          type: AdminProductVariantGroupType.size,
          color: null,
          size: testSizeM,
          images: const ['size-m.jpg'],
          variants: [variants.first],
          source: AdminProductImageSource.size,
          inherited: false,
          sourceId: 4,
        ),
        testVariantGroup(
          type: AdminProductVariantGroupType.size,
          color: null,
          size: testSizeL,
          images: const [],
          variants: [variants.last],
          source: AdminProductImageSource.none,
          inherited: false,
        ),
      ],
    ),
  );
}

AdminProductPriceSummaryEntity testPrice({
  double? finalPrice,
  double? minFinalPrice,
  double? maxFinalPrice,
}) {
  return AdminProductPriceSummaryEntity(
    itemPrice: 100,
    itemDiscount: 10,
    minEffectivePrice: minFinalPrice,
    maxEffectivePrice: maxFinalPrice,
    minFinalPrice: minFinalPrice,
    maxFinalPrice: maxFinalPrice,
    effectivePrice: finalPrice,
    effectiveDiscount: 10,
    finalPrice: finalPrice,
  );
}

AdminProductMediaEntity testMedia({
  List<String> itemImages = const [],
  List<String> colorImages = const [],
  AdminProductColorSummaryEntity color = testColorBlack,
  List<String> sizeImages = const [],
  AdminProductSizeSummaryEntity size = testSizeM,
  List<String> variantImages = const [],
  int variantRefId = 101,
  AdminProductImageStrategy? strategy,
}) {
  final preview = itemImages.isNotEmpty
      ? itemImages
      : colorImages.isNotEmpty
      ? colorImages
      : sizeImages.isNotEmpty
      ? sizeImages
      : variantImages;
  final previewSource = itemImages.isNotEmpty
      ? AdminProductImageSource.item
      : colorImages.isNotEmpty
      ? AdminProductImageSource.color
      : sizeImages.isNotEmpty
      ? AdminProductImageSource.size
      : variantImages.isNotEmpty
      ? AdminProductImageSource.variant
      : AdminProductImageSource.none;
  final resolvedStrategy =
      strategy ??
      _strategyForImages(
        itemImages: itemImages,
        colorImages: colorImages,
        sizeImages: sizeImages,
        variantImages: variantImages,
      );
  return AdminProductMediaEntity(
    thumbnail: preview.isEmpty
        ? null
        : AdminProductMediaThumbnailEntity(
            url: preview.first,
            source: previewSource,
            sourceId: previewSource == AdminProductImageSource.item
                ? 10
                : previewSource == AdminProductImageSource.color
                ? color.id
                : previewSource == AdminProductImageSource.size
                ? size.id
                : previewSource == AdminProductImageSource.variant
                ? variantRefId
                : null,
          ),
    preview: AdminProductMediaPreviewEntity(
      source: previewSource,
      sourceId: null,
      images: _images(preview),
    ),
    summary: AdminProductMediaSummaryEntity(
      strategy: resolvedStrategy,
      totalImageCount:
          itemImages.length +
          colorImages.length +
          sizeImages.length +
          variantImages.length,
      uniqueImageCount: {
        ...itemImages,
        ...colorImages,
        ...sizeImages,
        ...variantImages,
      }.length,
      itemImageCount: itemImages.length,
      colorGroupCount: colorImages.isEmpty ? 0 : 1,
      colorImageCount: colorImages.length,
      sizeGroupCount: sizeImages.isEmpty ? 0 : 1,
      sizeImageCount: sizeImages.length,
      variantGroupCount: variantImages.isEmpty ? 0 : 1,
      variantImageCount: variantImages.length,
    ),
    itemImages: AdminProductMediaItemImagesEntity(
      source: AdminProductImageSource.item,
      images: _images(itemImages),
    ),
    colorImageGroups: colorImages.isEmpty
        ? const []
        : [
            AdminProductMediaColorImageGroupEntity(
              source: AdminProductImageSource.color,
              color: color,
              images: _images(colorImages),
            ),
          ],
    sizeImageGroups: sizeImages.isEmpty
        ? const []
        : [
            AdminProductMediaSizeImageGroupEntity(
              source: AdminProductImageSource.size,
              size: size,
              images: _images(sizeImages),
            ),
          ],
    variantImageGroups: variantImages.isEmpty
        ? const []
        : [
            AdminProductMediaVariantImageGroupEntity(
              source: AdminProductImageSource.variant,
              variant: AdminProductMediaVariantRefEntity(
                id: variantRefId,
                label: 'خيار #$variantRefId',
                color: color,
                size: size,
              ),
              images: _images(variantImages),
            ),
          ],
  );
}

AdminProductVariantViewEntity testVariantView({
  AdminProductVariantGrouping grouping = AdminProductVariantGrouping.color,
  AdminProductImageStrategy imageStrategy =
      AdminProductImageStrategy.colorImages,
  AdminProductVariantNoteCode noteCode =
      AdminProductVariantNoteCode.variantsUseColorImages,
  required List<AdminProductVariantGroupEntity> groups,
}) {
  return AdminProductVariantViewEntity(
    grouping: grouping,
    imageStrategy: imageStrategy,
    noteCode: noteCode,
    groups: groups,
  );
}

AdminProductVariantGroupEntity testVariantGroup({
  AdminProductVariantGroupType type = AdminProductVariantGroupType.color,
  String? label,
  AdminProductColorSummaryEntity? color = testColorBlack,
  AdminProductSizeSummaryEntity? size,
  List<String> images = const [],
  List<AdminProductVariantViewVariantEntity> variants = const [],
  AdminProductImageSource source = AdminProductImageSource.color,
  bool inherited = false,
  int? sourceId,
  int variantCount = 1,
  int totalStock = 2,
  int lowestStock = 2,
}) {
  return AdminProductVariantGroupEntity(
    type: type,
    label: label,
    color: color,
    size: size,
    images: _images(images),
    imageOwnership: AdminProductImageOwnershipEntity(
      source: source,
      inherited: inherited,
      sourceId: sourceId,
    ),
    summary: AdminProductVariantGroupSummaryEntity(
      variantCount: variantCount,
      totalStock: totalStock,
      lowestStock: lowestStock,
      activeCount: variantCount,
      inactiveCount: 0,
      minFinalPrice: 57,
      maxFinalPrice: 57,
    ),
    variants: variants,
  );
}

AdminProductVariantViewVariantEntity testVariant({
  required int id,
  AdminProductColorSummaryEntity? color = testColorBlack,
  AdminProductSizeSummaryEntity? size,
  int stock = 2,
  List<String> variantImages = const [],
  AdminProductImageSource source = AdminProductImageSource.color,
  bool inherited = true,
  int? sourceId = 7,
  bool orderLinked = false,
}) {
  return AdminProductVariantViewVariantEntity(
    id: id,
    active: true,
    stock: stock,
    stockState: AdminProductStockState.lowStock,
    stockSource: AdminProductStockSource.variantStock,
    color: color,
    size: size,
    descriptionAr: null,
    descriptionEn: null,
    price: testPrice(finalPrice: 57),
    imageOwnership: AdminProductImageOwnershipEntity(
      source: source,
      inherited: inherited,
      sourceId: sourceId,
    ),
    variantImages: _images(variantImages),
    orderLinked: orderLinked,
    createdAt: DateTime(2026, 6, 15),
  );
}

List<AdminProductImageEntity> _images(List<String> urls) {
  return urls.map((url) => AdminProductImageEntity(url: url)).toList();
}

AdminProductDetailsEditBootstrapEntity testEditBootstrap({
  int productId = 10,
  int? currentSizeGroupId = 3,
  bool canUpdateSizeGroup = true,
  int variantCount = 0,
  int sizeVariantCount = 0,
  bool allowedNull = true,
}) {
  return AdminProductDetailsEditBootstrapEntity(
    productId: productId,
    current: const AdminProductEditableDetailsEntity(
      arabicName: 'منتج بسيط',
      englishName: 'Simple',
      descriptionAr: 'وصف',
      descriptionEn: 'Description',
      categoryId: 2,
      audienceId: 1,
      itemPrice: '100.00',
      itemDiscount: '10.00',
      sellMode: AdminProductSellMode.simple,
    ),
    categories: const [
      AdminProductCategoryOptionEntity(
        id: 1,
        arabicName: 'الملابس',
        englishName: 'Clothes',
        parentId: null,
        sortOrder: 1,
        active: true,
        selectable: true,
      ),
      AdminProductCategoryOptionEntity(
        id: 2,
        arabicName: 'قمصان',
        englishName: 'Shirts',
        parentId: 1,
        sortOrder: 1,
        active: true,
        selectable: true,
      ),
    ],
    audiences: const [
      AdminProductAudienceOptionEntity(
        id: 1,
        arabicName: 'رجال',
        englishName: 'Men',
        sortOrder: 1,
        active: true,
        selectable: true,
      ),
      AdminProductAudienceOptionEntity(
        id: 2,
        arabicName: 'نساء',
        englishName: 'Women',
        sortOrder: 2,
        active: true,
        selectable: true,
      ),
    ],
    sizeGroupCorrection: AdminProductSizeGroupCorrectionEntity(
      currentSizeGroupId: currentSizeGroupId,
      canUpdate: canUpdateSizeGroup,
      lockedReason: canUpdateSizeGroup
          ? null
          : 'Product has size-bearing variants',
      variantCount: variantCount,
      sizeVariantCount: sizeVariantCount,
      allowedNull: allowedNull,
      sizeGroups: const [
        AdminProductEditSizeGroupOptionEntity(
          id: 3,
          arabicName: 'مقاسات عامة',
          englishName: 'General Sizes',
          values: [
            AdminProductEditSizeValueOptionEntity(
              id: 4,
              arabicName: 'M',
              englishName: 'M',
              sortOrder: 1,
            ),
            AdminProductEditSizeValueOptionEntity(
              id: 5,
              arabicName: 'L',
              englishName: 'L',
              sortOrder: 2,
            ),
          ],
        ),
        AdminProductEditSizeGroupOptionEntity(
          id: 6,
          arabicName: 'مقاسات أحذية',
          englishName: 'Shoe Sizes',
          values: [],
        ),
      ],
    ),
  );
}

AdminProductCreateOptionsEntity testProductCreateOptions({
  bool active = false,
  bool featured = true,
}) {
  return AdminProductCreateOptionsEntity(
    defaults: AdminProductCreateDefaultsEntity(
      active: active,
      featured: featured,
      itemDiscount: '0.00',
      simpleStock: 0,
    ),
    limits: const AdminProductCreateLimitsEntity(
      arabicNameMaxLength: 150,
      englishNameMaxLength: 255,
      priceMin: '0.00',
      priceMax: '99999999.99',
      discountMin: '0.00',
      discountMax: '100.00',
    ),
    categories: testEditBootstrap().categories,
    audiences: testEditBootstrap().audiences,
    sizeGroups: const [
      AdminProductCreateSizeGroupOptionEntity(
        id: 3,
        arabicName: 'مقاسات عامة',
        englishName: 'General Sizes',
        values: [
          AdminProductCreateSizeValueOptionEntity(
            id: 4,
            arabicName: 'M',
            englishName: 'M',
            sortOrder: 1,
          ),
          AdminProductCreateSizeValueOptionEntity(
            id: 5,
            arabicName: 'L',
            englishName: 'L',
            sortOrder: 2,
          ),
        ],
      ),
    ],
  );
}

AdminProductCreateResultEntity testProductCreateResult({
  int createdProductId = 77,
  AdminProductDetailEntity? product,
}) {
  return AdminProductCreateResultEntity(
    createdProductId: createdProductId,
    product: product ?? testSimpleProductDetail(id: createdProductId),
  );
}

AdminVariantDetailsEditBootstrapEntity testVariantEditBootstrap({
  int variantId = 101,
  int productId = 10,
}) {
  return AdminVariantDetailsEditBootstrapEntity(
    variantId: variantId,
    product: AdminVariantProductContextEntity(
      id: productId,
      arabicName: 'منتج مع خيارات',
      englishName: 'Variable Product',
      itemPrice: '150.00',
      itemDiscount: '20.00',
    ),
    current: const AdminVariantEditableDetailsEntity(
      descriptionAr: 'وصف الخيار',
      descriptionEn: 'Variant Description',
      variantPrice: '140.00',
      variantDiscount: '15.00',
      effectivePrice: '140.00',
      effectiveDiscount: '15.00',
      finalPrice: '125.00',
      priceIsInherited: false,
      discountIsInherited: false,
    ),
    readonly: const AdminVariantReadonlyContextEntity(
      color: testColorBlack,
      size: testSizeM,
      stock: 45,
      active: true,
      stockSource: 'variant_stock',
      orderLinked: false,
      createdAt: null,
    ),
  );
}

AdminVariantCreateOptionsEntity testVariantCreateOptions({
  int productId = 10,
  bool willConvertSimpleProduct = true,
  AdminVariantShape? currentVariantShape,
  bool shapeLocked = false,
  AdminVariantShapeLockReason? shapeLockReason,
  AdminVariantShapeInconsistency? shapeInconsistency,
  AdminVariantAllowedShapesEntity allowedShapes =
      const AdminVariantAllowedShapesEntity(
        colorSize: true,
        colorOnly: true,
        sizeOnly: true,
        none: false,
      ),
}) {
  return AdminVariantCreateOptionsEntity(
    productId: productId,
    product: AdminVariantCreateProductContextEntity(
      id: productId,
      arabicName: 'منتج بسيط',
      englishName: 'Simple',
      sellMode: AdminProductSellMode.simple,
      itemPrice: '100.00',
      itemDiscount: '10.00',
      sizeGroup: const AdminProductNamedSummaryEntity(
        id: 3,
        arabicName: 'مقاسات عامة',
        englishName: 'General Sizes',
      ),
    ),
    currentVariantShape: currentVariantShape,
    detectedVariantShapes: currentVariantShape == null
        ? const []
        : [currentVariantShape],
    shapeLocked: shapeLocked,
    shapeLockReason: shapeLockReason,
    shapeInconsistency: shapeInconsistency,
    inferredSizeGroupId: null,
    allowedShapes: allowedShapes,
    colors: const [
      AdminVariantCreateColorOptionEntity(
        id: 7,
        arabicName: 'أسود',
        englishName: 'Black',
        hex: '#000000',
        sortOrder: 1,
        selectable: true,
      ),
      AdminVariantCreateColorOptionEntity(
        id: 8,
        arabicName: 'أبيض',
        englishName: 'White',
        hex: '#FFFFFF',
        sortOrder: 2,
        selectable: true,
      ),
    ],
    sizes: const [
      AdminVariantCreateSizeOptionEntity(
        id: 4,
        arabicName: 'M',
        englishName: 'M',
        sortOrder: 1,
        selectable: true,
      ),
      AdminVariantCreateSizeOptionEntity(
        id: 5,
        arabicName: 'L',
        englishName: 'L',
        sortOrder: 2,
        selectable: true,
      ),
    ],
    existingCombinations: const [
      AdminVariantExistingCombinationEntity(
        variantId: 101,
        colorId: 7,
        sizeId: 4,
        variantKey: 'c7-s4',
        label: 'أسود / M',
        shape: AdminVariantShape.colorSize,
        active: true,
      ),
    ],
    conversionImpact: AdminVariantConversionImpactEntity(
      willConvertSimpleProduct: willConvertSimpleProduct,
      simpleCartRowCount: 2,
      simpleFavoriteRowCount: 1,
    ),
  );
}

AdminVariantCreateResultEntity testVariantCreateResult({
  int createdVariantId = 501,
  AdminProductDetailEntity? product,
}) {
  return AdminVariantCreateResultEntity(
    createdVariantId: createdVariantId,
    product: product ?? testVariantProductDetail(id: 10),
  );
}

AdminProductMediaBootstrapEntity testProductMediaBootstrap({
  int productId = 10,
  List<AdminProductMediaTargetEntity>? targets,
}) {
  final resolvedTargets =
      targets ??
      [
        testProductMediaTarget(
          scope: AdminProductMediaScope.item,
          targetId: productId,
          targetKey: 'item:$productId',
          label: 'صور المنتج العامة',
          ownedImages: [
            testProductMediaImage(imageId: 501, url: 'item-a.jpg'),
            testProductMediaImage(imageId: 502, url: 'item-b.jpg'),
          ],
        ),
        testProductMediaTarget(
          scope: AdminProductMediaScope.color,
          targetId: 7,
          targetKey: 'color:7',
          label: 'أسود',
          owner: const AdminProductMediaTargetOwnerEntity(
            productId: null,
            color: testColorBlack,
            size: null,
            variantId: null,
            active: null,
          ),
          ownedImages: const [],
          effectiveImages: const AdminProductMediaEffectiveImagesEntity(
            source: AdminProductImageSource.item,
            sourceId: 10,
            inherited: true,
            images: [
              AdminProductMediaImageEntity(
                imageId: 501,
                url: 'item-a.jpg',
                sortOrder: 0,
                isPrimary: false,
                createdAt: null,
              ),
            ],
          ),
        ),
      ];
  return AdminProductMediaBootstrapEntity(
    product: AdminProductMediaProductEntity(
      id: productId,
      arabicName: 'منتج بسيط',
      englishName: 'Simple',
      sellMode: AdminProductSellMode.simple,
      active: true,
    ),
    fallback: const AdminProductMediaFallbackEntity(
      cardOrder: [AdminProductMediaScope.color, AdminProductMediaScope.item],
      entityOrder: [
        AdminProductMediaScope.variant,
        AdminProductMediaScope.color,
        AdminProductMediaScope.size,
        AdminProductMediaScope.item,
      ],
    ),
    limits: const AdminProductMediaLimitsEntity(
      maxFilesPerRequest: 10,
      maxFileBytes: 5242880,
      allowedExtensions: ['.jpg', '.jpeg', '.png', '.webp', '.avif'],
      allowedMimeTypes: ['image/jpeg', 'image/png', 'image/webp', 'image/avif'],
    ),
    summary: AdminProductMediaBootstrapSummaryEntity(
      targetCount: resolvedTargets.length,
      ownedImageCount: resolvedTargets.fold<int>(
        0,
        (sum, target) => sum + target.ownedImages.length,
      ),
      itemImageCount: resolvedTargets
          .where((target) => target.scope == AdminProductMediaScope.item)
          .fold<int>(0, (sum, target) => sum + target.ownedImages.length),
      colorImageCount: resolvedTargets
          .where((target) => target.scope == AdminProductMediaScope.color)
          .fold<int>(0, (sum, target) => sum + target.ownedImages.length),
      sizeImageCount: 0,
      variantImageCount: 0,
    ),
    preview: AdminProductMediaBootstrapPreviewEntity(
      source: AdminProductImageSource.item,
      sourceId: productId,
      images: resolvedTargets.first.ownedImages,
    ),
    targets: resolvedTargets,
  );
}

AdminProductMediaTargetEntity testProductMediaTarget({
  AdminProductMediaScope scope = AdminProductMediaScope.item,
  int targetId = 10,
  String targetKey = 'item:10',
  String label = 'صور المنتج العامة',
  AdminProductMediaTargetOwnerEntity? owner,
  List<AdminProductMediaImageEntity> ownedImages = const [],
  AdminProductMediaEffectiveImagesEntity? effectiveImages,
}) {
  return AdminProductMediaTargetEntity(
    scope: scope,
    targetId: targetId,
    targetKey: targetKey,
    label: label,
    owner:
        owner ??
        const AdminProductMediaTargetOwnerEntity(
          productId: 10,
          color: null,
          size: null,
          variantId: null,
          active: true,
        ),
    ownedImages: ownedImages,
    effectiveImages:
        effectiveImages ??
        AdminProductMediaEffectiveImagesEntity(
          source: scope == AdminProductMediaScope.item
              ? AdminProductImageSource.item
              : AdminProductImageSource.none,
          sourceId: scope == AdminProductMediaScope.item ? targetId : null,
          inherited: false,
          images: ownedImages,
        ),
  );
}

AdminProductMediaImageEntity testProductMediaImage({
  required int imageId,
  required String url,
  int sortOrder = 0,
  bool isPrimary = false,
}) {
  return AdminProductMediaImageEntity(
    imageId: imageId,
    url: url,
    sortOrder: sortOrder,
    isPrimary: isPrimary,
    createdAt: null,
  );
}

AdminProductMediaMutationResultEntity testProductMediaMutationResult({
  AdminProductMediaOperation operation = AdminProductMediaOperation.upload,
  AdminProductMediaBootstrapEntity? media,
  List<int>? createdImageIds,
  int? deletedImageId,
  bool? storageDeleted,
}) {
  return AdminProductMediaMutationResultEntity(
    operation: operation,
    createdImageIds: createdImageIds,
    deletedImageId: deletedImageId,
    storageDeleted: storageDeleted,
    media: media ?? testProductMediaBootstrap(),
  );
}

AdminProductImageStrategy _strategyForImages({
  required List<String> itemImages,
  required List<String> colorImages,
  required List<String> sizeImages,
  required List<String> variantImages,
}) {
  final activeScopes = [
    if (itemImages.isNotEmpty) AdminProductImageStrategy.itemImages,
    if (colorImages.isNotEmpty) AdminProductImageStrategy.colorImages,
    if (sizeImages.isNotEmpty) AdminProductImageStrategy.sizeImages,
    if (variantImages.isNotEmpty) AdminProductImageStrategy.variantImages,
  ];
  if (activeScopes.isEmpty) return AdminProductImageStrategy.none;
  if (activeScopes.length == 1) return activeScopes.single;
  return AdminProductImageStrategy.mixed;
}

AdminProductDeletionImpactEntity testProductDeletionImpact({
  bool active = false,
  int orderItemCount = 0,
  int cartRowCount = 0,
}) {
  return AdminProductDeletionImpactEntity(
    productId: 10,
    arabicName: 'منتج بسيط',
    englishName: 'Simple',
    active: active,
    sellMode: AdminProductSellMode.simple,
    canDelete: !active && orderItemCount == 0 && cartRowCount == 0,
    blockers: AdminProductDeletionBlockersEntity(
      active: active,
      orderItemCount: orderItemCount,
      cartRowCount: cartRowCount,
    ),
    deleteEffects: const AdminProductDeleteEffectsEntity(
      favoriteRowCount: 2,
      variantCount: 0,
      variantAttributeCount: 0,
      mediaRowCount: 1,
      mediaFileCount: 1,
      collectionItemCount: 0,
      itemAttributeMetaCount: 0,
      recentlyViewedCount: 3,
    ),
  );
}

AdminVariantDeletionImpactEntity testVariantDeletionImpact({
  bool active = false,
  int orderItemCount = 0,
  int cartRowCount = 0,
  bool isLastVariant = false,
}) {
  return AdminVariantDeletionImpactEntity(
    variantId: 101,
    productId: 11,
    productArabicName: 'منتج بخيارات',
    active: active,
    canDelete:
        !active && orderItemCount == 0 && cartRowCount == 0 && !isLastVariant,
    blockers: AdminVariantDeletionBlockersEntity(
      active: active,
      orderItemCount: orderItemCount,
      cartRowCount: cartRowCount,
      isLastVariant: isLastVariant,
    ),
    deleteEffects: const AdminVariantDeleteEffectsEntity(
      favoriteRowCount: 1,
      variantAttributeCount: 2,
      variantMediaRowCount: 1,
      orphanColorMediaRowCount: 0,
      orphanSizeMediaRowCount: 0,
      orphanItemAttributeMetaCount: 0,
      mediaFileCount: 1,
      remainingVariantCount: 1,
    ),
  );
}

AdminProductDeleteResultEntity testProductDeleteResult() {
  return AdminProductDeleteResultEntity(
    deletedProductId: 10,
    deleteEffects: testProductDeletionImpact().deleteEffects,
    storage: const AdminDeletionStorageEntity(
      deleted: 1,
      retainedShared: 0,
      failed: 0,
    ),
  );
}

AdminVariantDeleteResultEntity testVariantDeleteResult() {
  return AdminVariantDeleteResultEntity(
    deletedVariantId: 101,
    productId: 11,
    deleteEffects: testVariantDeletionImpact().deleteEffects,
    storage: const AdminDeletionStorageEntity(
      deleted: 1,
      retainedShared: 0,
      failed: 0,
    ),
    product: testVariantProductDetail(),
  );
}

class FakeAdminProductsRepository implements AdminProductsRepository {
  AppResult<AdminProductsPageEntity> productsResult = AppResult.success(
    testProductsPage(),
  );
  AppResult<AdminProductDetailEntity> detailResult = AppResult.success(
    testSimpleProductDetail(),
  );
  AppResult<AdminProductMediaBootstrapEntity> mediaResult = AppResult.success(
    testProductMediaBootstrap(),
  );
  AppResult<AdminProductMediaMutationResultEntity> mediaMutationResult =
      AppResult.success(testProductMediaMutationResult());
  AppResult<AdminProductDetailsEditBootstrapEntity> editBootstrapResult =
      AppResult.success(testEditBootstrap());
  AppResult<AdminProductCreateOptionsEntity> createOptionsResult =
      AppResult.success(testProductCreateOptions());
  AppResult<AdminProductCreateResultEntity> createProductResult =
      AppResult.success(testProductCreateResult());
  AppResult<AdminProductDetailEntity> updateDetailsResult = AppResult.success(
    testSimpleProductDetail(),
  );
  AppResult<AdminProductDetailEntity> updateSizeGroupResult = AppResult.success(
    testSimpleProductDetail(),
  );
  AppResult<AdminVariantDetailsEditBootstrapEntity> variantEditBootstrapResult =
      AppResult.success(testVariantEditBootstrap());
  AppResult<AdminProductDetailEntity> updateVariantDetailsResult =
      AppResult.success(testSimpleProductDetail());
  AppResult<AdminVariantCreateOptionsEntity> variantCreateOptionsResult =
      AppResult.success(testVariantCreateOptions());
  AppResult<AdminVariantCreateResultEntity> createVariantResult =
      AppResult.success(testVariantCreateResult());
  AppResult<AdminProductDeletionImpactEntity> productImpactResult =
      AppResult.success(testProductDeletionImpact());
  AppResult<AdminVariantDeletionImpactEntity> variantImpactResult =
      AppResult.success(testVariantDeletionImpact());
  AppResult<AdminProductDeleteResultEntity> deleteProductResult =
      AppResult.success(testProductDeleteResult());
  AppResult<AdminVariantDeleteResultEntity> deleteVariantResult =
      AppResult.success(testVariantDeleteResult());
  Completer<AppResult<AdminProductCreateResultEntity>>? createProductCompleter;
  Completer<AppResult<AdminVariantCreateResultEntity>>? createVariantCompleter;
  Completer<AppResult<AdminProductDetailEntity>>? updateSizeGroupCompleter;
  Completer<AppResult<AdminProductDeleteResultEntity>>? deleteProductCompleter;
  Completer<AppResult<AdminVariantDeleteResultEntity>>? deleteVariantCompleter;
  Completer<AppResult<AdminProductMediaMutationResultEntity>>?
  mediaMutationCompleter;
  AppResult<dynamic> mutationResult = const AppResult.success(null);
  Completer<AppResult<dynamic>>? mutationCompleter;
  int getProductsCalls = 0;
  int getDetailCalls = 0;
  int getMediaCalls = 0;
  int uploadMediaCalls = 0;
  int deleteMediaCalls = 0;
  int reorderMediaCalls = 0;
  int primaryMediaCalls = 0;
  int getEditBootstrapCalls = 0;
  int getCreateOptionsCalls = 0;
  int createProductCalls = 0;
  int updateDetailsCalls = 0;
  int updateSizeGroupCalls = 0;
  int getVariantEditBootstrapCalls = 0;
  int updateVariantDetailsCalls = 0;
  int getVariantCreateOptionsCalls = 0;
  int createVariantCalls = 0;
  int productVisibilityCalls = 0;
  int productStockCalls = 0;
  int variantStockCalls = 0;
  int variantVisibilityCalls = 0;
  int productImpactCalls = 0;
  int variantImpactCalls = 0;
  int deleteProductCalls = 0;
  int deleteVariantCalls = 0;
  int? lastPage;
  AdminProductFilters? lastFilters;
  int? lastStock;
  bool? lastActive;
  bool? lastFeatured;
  AdminProductDetailsPatchEntity? lastPatch;
  int? lastSizeGroupId;
  AdminProductCreateInputEntity? lastProductCreateInput;
  int? lastVariantId;
  AdminVariantDetailsPatchEntity? lastVariantPatch;
  AdminVariantCreateInputEntity? lastVariantCreateInput;
  AdminProductMediaScope? lastMediaScope;
  int? lastMediaTargetId;
  int? lastMediaImageId;
  List<int>? lastMediaImageIds;
  List<AdminProductMediaUploadFileEntity>? lastMediaUploadFiles;

  @override
  Future<AppResult<AdminProductsPageEntity>> getProducts({
    required int page,
    required int pageSize,
    required AdminProductFilters filters,
  }) async {
    getProductsCalls++;
    lastPage = page;
    lastFilters = filters;
    return productsResult;
  }

  @override
  Future<AppResult<AdminProductDetailEntity>> getProductDetail(
    int productId,
  ) async {
    getDetailCalls++;
    return detailResult;
  }

  @override
  Future<AppResult<AdminProductDeletionImpactEntity>> getProductDeletionImpact(
    int productId,
  ) async {
    productImpactCalls++;
    return productImpactResult;
  }

  @override
  Future<AppResult<AdminProductDeleteResultEntity>> deleteProduct(
    int productId,
  ) async {
    deleteProductCalls++;
    final completer = deleteProductCompleter;
    if (completer != null) return completer.future;
    return deleteProductResult;
  }

  @override
  Future<AppResult<AdminVariantDeletionImpactEntity>> getVariantDeletionImpact(
    int variantId,
  ) async {
    variantImpactCalls++;
    return variantImpactResult;
  }

  @override
  Future<AppResult<AdminVariantDeleteResultEntity>> deleteVariant(
    int variantId,
  ) async {
    deleteVariantCalls++;
    final completer = deleteVariantCompleter;
    if (completer != null) return completer.future;
    return deleteVariantResult;
  }

  @override
  Future<AppResult<AdminProductMediaBootstrapEntity>> getProductMedia(
    int productId,
  ) async {
    getMediaCalls++;
    return mediaResult;
  }

  @override
  Future<AppResult<AdminProductMediaMutationResultEntity>>
  uploadProductMediaImages({
    required int productId,
    required AdminProductMediaScope scope,
    required int targetId,
    required List<AdminProductMediaUploadFileEntity> files,
  }) async {
    uploadMediaCalls++;
    lastMediaScope = scope;
    lastMediaTargetId = targetId;
    lastMediaUploadFiles = files;
    return _completeMediaMutation();
  }

  @override
  Future<AppResult<AdminProductMediaMutationResultEntity>>
  deleteProductMediaImage({
    required int productId,
    required int imageId,
  }) async {
    deleteMediaCalls++;
    lastMediaImageId = imageId;
    return _completeMediaMutation();
  }

  @override
  Future<AppResult<AdminProductMediaMutationResultEntity>>
  reorderProductMediaTarget({
    required int productId,
    required AdminProductMediaScope scope,
    required int targetId,
    required List<int> imageIds,
  }) async {
    reorderMediaCalls++;
    lastMediaScope = scope;
    lastMediaTargetId = targetId;
    lastMediaImageIds = imageIds;
    return _completeMediaMutation();
  }

  @override
  Future<AppResult<AdminProductMediaMutationResultEntity>>
  setProductMediaPrimary({
    required int productId,
    required AdminProductMediaScope scope,
    required int targetId,
    required int? imageId,
  }) async {
    primaryMediaCalls++;
    lastMediaScope = scope;
    lastMediaTargetId = targetId;
    lastMediaImageId = imageId;
    return _completeMediaMutation();
  }

  @override
  Future<AppResult<AdminProductDetailsEditBootstrapEntity>>
  getProductDetailsEditBootstrap(int productId) async {
    getEditBootstrapCalls++;
    return editBootstrapResult;
  }

  @override
  Future<AppResult<AdminProductCreateOptionsEntity>>
  getProductCreateOptions() async {
    getCreateOptionsCalls++;
    return createOptionsResult;
  }

  @override
  Future<AppResult<AdminProductCreateResultEntity>> createProduct(
    AdminProductCreateInputEntity input,
  ) async {
    createProductCalls++;
    lastProductCreateInput = input;
    final completer = createProductCompleter;
    if (completer != null) {
      return completer.future;
    }
    return createProductResult;
  }

  @override
  Future<AppResult<AdminVariantCreateOptionsEntity>> getVariantCreateOptions(
    int productId,
  ) async {
    getVariantCreateOptionsCalls++;
    return variantCreateOptionsResult;
  }

  @override
  Future<AppResult<AdminVariantCreateResultEntity>> createVariant({
    required int productId,
    required AdminVariantCreateInputEntity input,
  }) async {
    createVariantCalls++;
    lastVariantCreateInput = input;
    final completer = createVariantCompleter;
    if (completer != null) {
      return completer.future;
    }
    return createVariantResult;
  }

  @override
  Future<AppResult<AdminProductDetailEntity>> updateProductDetails({
    required int productId,
    required AdminProductDetailsPatchEntity patch,
  }) async {
    updateDetailsCalls++;
    lastPatch = patch;
    return updateDetailsResult;
  }

  @override
  Future<AppResult<AdminProductDetailEntity>> updateProductSizeGroup({
    required int productId,
    required int? sizeGroupId,
  }) async {
    updateSizeGroupCalls++;
    lastSizeGroupId = sizeGroupId;
    final completer = updateSizeGroupCompleter;
    if (completer != null) return completer.future;
    return updateSizeGroupResult;
  }

  @override
  Future<AppResult<AdminVariantDetailsEditBootstrapEntity>>
  getVariantDetailsEditBootstrap(int variantId) async {
    getVariantEditBootstrapCalls++;
    lastVariantId = variantId;
    return variantEditBootstrapResult;
  }

  @override
  Future<AppResult<AdminProductDetailEntity>> updateVariantDetails({
    required int variantId,
    required AdminVariantDetailsPatchEntity patch,
  }) async {
    updateVariantDetailsCalls++;
    lastVariantId = variantId;
    lastVariantPatch = patch;
    return updateVariantDetailsResult;
  }

  @override
  Future<AppResult<AdminProductVisibilityEntity>> updateProductVisibility({
    required int productId,
    bool? active,
    bool? featured,
  }) async {
    productVisibilityCalls++;
    lastActive = active;
    lastFeatured = featured;
    final result = await _completeMutation();
    return result is AppResultSuccess
        ? AppResult.success(
            AdminProductVisibilityEntity(
              productId: productId,
              active: active ?? true,
              featured: featured ?? false,
              product: testSimpleProductDetail(
                id: productId,
              ).copyWith(active: active ?? true, featured: featured ?? false),
            ),
          )
        : AppResult.failure((result as AppResultFailure).failure);
  }

  @override
  Future<AppResult<AdminProductStockEntity>> updateProductStock({
    required int productId,
    required int stock,
  }) async {
    productStockCalls++;
    lastStock = stock;
    final result = await _completeMutation();
    return result is AppResultSuccess
        ? AppResult.success(
            AdminProductStockEntity(
              productId: productId,
              sellMode: AdminProductSellMode.simple,
              stock: stock,
              stockState: AdminProductStockState.inStock,
              stockSource: AdminProductStockSource.itemStock,
            ),
          )
        : AppResult.failure((result as AppResultFailure).failure);
  }

  @override
  Future<AppResult<AdminVariantStockEntity>> updateVariantStock({
    required int variantId,
    required int stock,
  }) async {
    variantStockCalls++;
    lastStock = stock;
    final result = await _completeMutation();
    return result is AppResultSuccess
        ? AppResult.success(
            AdminVariantStockEntity(
              variantId: variantId,
              productId: 11,
              stock: stock,
              stockState: AdminProductStockState.inStock,
              stockSource: AdminProductStockSource.variantStock,
            ),
          )
        : AppResult.failure((result as AppResultFailure).failure);
  }

  @override
  Future<AppResult<AdminVariantVisibilityEntity>> updateVariantVisibility({
    required int variantId,
    required bool active,
  }) async {
    variantVisibilityCalls++;
    lastActive = active;
    final result = await _completeMutation();
    return result is AppResultSuccess
        ? AppResult.success(
            AdminVariantVisibilityEntity(
              variantId: variantId,
              productId: 11,
              active: active,
              product: testVariantProductDetail().copyWith(active: true),
            ),
          )
        : AppResult.failure((result as AppResultFailure).failure);
  }

  Future<AppResult<dynamic>> _completeMutation() {
    final completer = mutationCompleter;
    if (completer != null) {
      return completer.future;
    }
    return Future.value(mutationResult);
  }

  Future<AppResult<AdminProductMediaMutationResultEntity>>
  _completeMediaMutation() {
    final completer = mediaMutationCompleter;
    if (completer != null) {
      return completer.future;
    }
    return Future.value(mediaMutationResult);
  }
}

AppResult<T> productFailure<T>(AppFailure failure) =>
    AppResult.failure(failure);
