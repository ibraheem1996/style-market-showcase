import 'package:dio/dio.dart';
import 'package:my_project/core/config/api_config.dart';
import 'package:my_project/core/network/api_response.dart';
import 'package:my_project/features/products/data/model/product_catalog_response_model.dart';
import 'package:retrofit/retrofit.dart';

import '../models/record_view_request.dart';
import '../models/cards_by_keys_request_model.dart';
import '../models/sync_keys_request_model.dart';

part 'recently_viewed_remote_datasource.g.dart';

@RestApi()
abstract class RecentlyViewedRemoteDataSource {
  factory RecentlyViewedRemoteDataSource(Dio dio, {String baseUrl}) =
      _RecentlyViewedRemoteDataSource;

  @GET(ApiConfig.recentlyViewed)
  Future<ApiResponse<ProductCatalogResponseModel>> getRecentlyViewed();

  @POST(ApiConfig.recentlyViewed)
  Future<ApiResponse<void>> recordView(@Body() RecordViewRequest body);

  @POST(ApiConfig.recentlyViewedSync)
  Future<ApiResponse<void>> syncKeys(@Body() SyncKeysRequest body);

  @POST(ApiConfig.cardsByKeys)
  Future<ApiResponse<ProductCatalogResponseModel>> getCardsByKeys(
    @Body() CardsByKeysRequestModel body,
  );

  @DELETE(ApiConfig.recentlyViewed)
  Future<ApiResponse<void>> clearRecentlyViewed();
}
