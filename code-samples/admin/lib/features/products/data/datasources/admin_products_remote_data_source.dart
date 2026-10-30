import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/network/api_response.dart';
import '../models/admin_product_media_request_models.dart';
import '../models/admin_product_media_response_models.dart';
import '../models/admin_product_lifecycle_response_models.dart';
import '../models/admin_product_request_models.dart';
import '../models/admin_product_response_models.dart';

part 'admin_products_remote_data_source.g.dart';

@RestApi()
@lazySingleton
abstract class AdminProductsRemoteDataSource {
  @factoryMethod
  factory AdminProductsRemoteDataSource(@Named('protectedDio') Dio dio) =
      _AdminProductsRemoteDataSource;

  @GET('/admin/products')
  Future<ApiResponse<AdminProductsListDataModel>> getProducts(
    @Queries() Map<String, dynamic> queries,
  );

  @GET('/admin/products/{productId}')
  Future<ApiResponse<AdminProductDetailModel>> getProductDetail(
    @Path('productId') int productId,
  );

  @GET('/admin/products/{productId}/deletion-impact')
  Future<ApiResponse<AdminProductDeletionImpactModel>> getProductDeletionImpact(
    @Path('productId') int productId,
  );

  @DELETE('/admin/products/{productId}')
  Future<ApiResponse<AdminProductDeleteResultModel>> deleteProduct(
    @Path('productId') int productId,
  );

  @GET('/admin/products/create/options')
  Future<ApiResponse<AdminProductCreateOptionsModel>> getProductCreateOptions();

  @POST('/admin/products')
  Future<ApiResponse<AdminProductCreateResultModel>> createProduct(
    @Body() AdminProductCreateRequestModel body,
  );

  @GET('/admin/products/{productId}/media')
  Future<ApiResponse<AdminProductMediaBootstrapModel>> getProductMedia(
    @Path('productId') int productId,
  );

  @MultiPart()
  @POST('/admin/products/{productId}/media/targets/{scope}/{targetId}/images')
  Future<ApiResponse<AdminProductMediaMutationDataModel>>
  uploadProductMediaImages(
    @Path('productId') int productId,
    @Path('scope') String scope,
    @Path('targetId') int targetId,
    @Part(name: 'files') List<MultipartFile> files,
  );

  @DELETE('/admin/products/{productId}/media/images/{imageId}')
  Future<ApiResponse<AdminProductMediaMutationDataModel>>
  deleteProductMediaImage(
    @Path('productId') int productId,
    @Path('imageId') int imageId,
  );

  @PATCH('/admin/products/{productId}/media/targets/{scope}/{targetId}/order')
  Future<ApiResponse<AdminProductMediaMutationDataModel>>
  reorderProductMediaTarget(
    @Path('productId') int productId,
    @Path('scope') String scope,
    @Path('targetId') int targetId,
    @Body() AdminProductMediaReorderRequestModel body,
  );

  @PATCH('/admin/products/{productId}/media/targets/{scope}/{targetId}/primary')
  Future<ApiResponse<AdminProductMediaMutationDataModel>>
  setProductMediaPrimary(
    @Path('productId') int productId,
    @Path('scope') String scope,
    @Path('targetId') int targetId,
    @Body() AdminProductMediaPrimaryRequestModel body,
  );

  @GET('/admin/products/{productId}/details/options')
  Future<ApiResponse<AdminProductDetailsEditBootstrapModel>>
  getProductDetailsEditBootstrap(@Path('productId') int productId);

  @GET('/admin/products/{productId}/variants/create/options')
  Future<ApiResponse<AdminVariantCreateOptionsModel>> getVariantCreateOptions(
    @Path('productId') int productId,
  );

  @POST('/admin/products/{productId}/variants')
  Future<ApiResponse<AdminVariantCreateResultModel>> createVariant(
    @Path('productId') int productId,
    @Body() Map<String, dynamic> body,
  );

  @PATCH('/admin/products/{productId}/details')
  Future<ApiResponse<AdminProductDetailModel>> updateProductDetails(
    @Path('productId') int productId,
    @Body() Map<String, dynamic> body,
  );

  @PATCH('/admin/products/{productId}/size-group')
  Future<ApiResponse<AdminProductDetailModel>> updateProductSizeGroup(
    @Path('productId') int productId,
    @Body() AdminProductSizeGroupUpdateRequestModel body,
  );

  @PATCH('/admin/products/{productId}/visibility')
  Future<ApiResponse<AdminProductVisibilityDataModel>> updateProductVisibility(
    @Path('productId') int productId,
    @Body() AdminProductVisibilityRequestModel body,
  );

  @PATCH('/admin/products/{productId}/stock')
  Future<ApiResponse<AdminProductStockDataModel>> updateProductStock(
    @Path('productId') int productId,
    @Body() AdminProductStockRequestModel body,
  );

  @PATCH('/admin/variants/{variantId}/stock')
  Future<ApiResponse<AdminVariantStockDataModel>> updateVariantStock(
    @Path('variantId') int variantId,
    @Body() AdminVariantStockRequestModel body,
  );

  @PATCH('/admin/variants/{variantId}/visibility')
  Future<ApiResponse<AdminVariantVisibilityDataModel>> updateVariantVisibility(
    @Path('variantId') int variantId,
    @Body() AdminVariantVisibilityRequestModel body,
  );

  @GET('/admin/variants/{variantId}/deletion-impact')
  Future<ApiResponse<AdminVariantDeletionImpactModel>> getVariantDeletionImpact(
    @Path('variantId') int variantId,
  );

  @DELETE('/admin/variants/{variantId}')
  Future<ApiResponse<AdminVariantDeleteResultModel>> deleteVariant(
    @Path('variantId') int variantId,
  );

  @GET('/admin/variants/{variantId}/details/options')
  Future<ApiResponse<AdminVariantDetailsEditBootstrapModel>>
  getVariantDetailsEditBootstrap(@Path('variantId') int variantId);

  @PATCH('/admin/variants/{variantId}/details')
  Future<ApiResponse<AdminProductDetailModel>> updateVariantDetails(
    @Path('variantId') int variantId,
    @Body() Map<String, dynamic> body,
  );
}
