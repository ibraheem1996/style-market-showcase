import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/config/api_config.dart';
import '../../../../core/network/api_response.dart';
import '../models/recommendations_response_model.dart';

part 'recommendations_remote_datasource.g.dart';

@RestApi()
abstract class RecommendationsRemoteDataSource {
  factory RecommendationsRemoteDataSource(Dio dio, {String baseUrl}) =
      _RecommendationsRemoteDataSource;

  @GET(ApiConfig.recommendations)
  Future<ApiResponse<RecommendationsResponseModel>> getRecommendations(
    @Query('context') String context,
    @Query('page') int page,
    @Query('limit') int limit,
    @Query('item_id') int? itemId,
    @Header('X-Audience-Id') int? audienceId,
  );
}
