import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/config/api_config.dart';
import '../../../../core/network/api_response.dart';
import '../model/product_catalog_response_model.dart';
import '../model/product_search_response_model.dart';

part 'product_catalog_remote_datasource.g.dart';

@RestApi()
abstract class ProductCatalogRemoteDataSource {
  factory ProductCatalogRemoteDataSource(Dio dio, {String baseUrl}) =
      _ProductCatalogRemoteDataSource;

  @GET(ApiConfig.listing)
  Future<ApiResponse<ProductCatalogResponseModel>> getCatalog(
    @Query('source_type') String sourceType,
    @Query('source_id') String sourceId,
    @Query('search') String search,
    @Query('page') int page,
    @Query('limit') int limit,
    @Query('sort') String sort,
    @Query('color_ids') String colorIds,
    @Query('size_ids') String sizeIds,
    @Query('min_price') double? minPrice,
    @Query('max_price') double? maxPrice,
  );

  @GET(ApiConfig.productSearch)
  Future<ApiResponse<ProductSearchResponseModel>> searchProducts(
    @Header('X-Audience-Id') int audienceId,
    @Query('q') String query,
    @Query('page') int page,
    @Query('limit') int limit,
  );
}
