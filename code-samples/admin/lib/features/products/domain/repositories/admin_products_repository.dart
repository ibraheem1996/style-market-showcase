import '../../../../core/result/app_result.dart';
import '../entities/admin_product_edit_entities.dart';
import '../entities/admin_product_enums.dart';
import '../entities/admin_product_create_entities.dart';
import '../entities/admin_product_media_entities.dart';
import '../entities/admin_variant_edit_entities.dart';
import '../entities/admin_variant_create_entities.dart';
import '../entities/admin_product_entities.dart';
import '../entities/admin_product_filters.dart';
import '../entities/admin_product_lifecycle_entities.dart';

abstract interface class AdminProductsRepository {
  Future<AppResult<AdminProductsPageEntity>> getProducts({
    required int page,
    required int pageSize,
    required AdminProductFilters filters,
  });

  Future<AppResult<AdminProductDetailEntity>> getProductDetail(int productId);

  Future<AppResult<AdminProductDeletionImpactEntity>> getProductDeletionImpact(
    int productId,
  );

  Future<AppResult<AdminProductDeleteResultEntity>> deleteProduct(
    int productId,
  );

  Future<AppResult<AdminProductCreateOptionsEntity>> getProductCreateOptions();

  Future<AppResult<AdminProductCreateResultEntity>> createProduct(
    AdminProductCreateInputEntity input,
  );

  Future<AppResult<AdminProductMediaBootstrapEntity>> getProductMedia(
    int productId,
  );

  Future<AppResult<AdminProductMediaMutationResultEntity>>
  uploadProductMediaImages({
    required int productId,
    required AdminProductMediaScope scope,
    required int targetId,
    required List<AdminProductMediaUploadFileEntity> files,
  });

  Future<AppResult<AdminProductMediaMutationResultEntity>>
  deleteProductMediaImage({required int productId, required int imageId});

  Future<AppResult<AdminProductMediaMutationResultEntity>>
  reorderProductMediaTarget({
    required int productId,
    required AdminProductMediaScope scope,
    required int targetId,
    required List<int> imageIds,
  });

  Future<AppResult<AdminProductMediaMutationResultEntity>>
  setProductMediaPrimary({
    required int productId,
    required AdminProductMediaScope scope,
    required int targetId,
    required int? imageId,
  });

  Future<AppResult<AdminProductDetailsEditBootstrapEntity>>
  getProductDetailsEditBootstrap(int productId);

  Future<AppResult<AdminVariantCreateOptionsEntity>> getVariantCreateOptions(
    int productId,
  );

  Future<AppResult<AdminVariantCreateResultEntity>> createVariant({
    required int productId,
    required AdminVariantCreateInputEntity input,
  });

  Future<AppResult<AdminProductDetailEntity>> updateProductDetails({
    required int productId,
    required AdminProductDetailsPatchEntity patch,
  });

  Future<AppResult<AdminProductDetailEntity>> updateProductSizeGroup({
    required int productId,
    required int? sizeGroupId,
  });

  Future<AppResult<AdminVariantDetailsEditBootstrapEntity>>
  getVariantDetailsEditBootstrap(int variantId);

  Future<AppResult<AdminProductDetailEntity>> updateVariantDetails({
    required int variantId,
    required AdminVariantDetailsPatchEntity patch,
  });

  Future<AppResult<AdminProductVisibilityEntity>> updateProductVisibility({
    required int productId,
    bool? active,
    bool? featured,
  });

  Future<AppResult<AdminProductStockEntity>> updateProductStock({
    required int productId,
    required int stock,
  });

  Future<AppResult<AdminVariantStockEntity>> updateVariantStock({
    required int variantId,
    required int stock,
  });

  Future<AppResult<AdminVariantVisibilityEntity>> updateVariantVisibility({
    required int variantId,
    required bool active,
  });

  Future<AppResult<AdminVariantDeletionImpactEntity>> getVariantDeletionImpact(
    int variantId,
  );

  Future<AppResult<AdminVariantDeleteResultEntity>> deleteVariant(
    int variantId,
  );
}
