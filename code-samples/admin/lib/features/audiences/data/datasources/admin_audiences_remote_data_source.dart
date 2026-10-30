import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/network/api_response.dart';
import '../models/admin_audience_request_models.dart';
import '../models/admin_audience_response_models.dart';

part 'admin_audiences_remote_data_source.g.dart';

@RestApi()
@lazySingleton
abstract class AdminAudiencesRemoteDataSource {
  @factoryMethod
  factory AdminAudiencesRemoteDataSource(@Named('protectedDio') Dio dio) =
      _AdminAudiencesRemoteDataSource;

  @GET('/admin/audiences')
  Future<ApiResponse<AdminAudiencesListDataModel>> getAudiences();

  @GET('/admin/audiences/{audienceId}')
  Future<ApiResponse<AdminAudienceMutationDataModel>> getAudience(
    @Path('audienceId') int audienceId,
  );

  @POST('/admin/audiences')
  Future<ApiResponse<AdminAudienceMutationDataModel>> createAudience(
    @Body() AdminAudienceCreateRequestModel body,
  );

  @PUT('/admin/audiences/{audienceId}')
  Future<ApiResponse<AdminAudienceMutationDataModel>> updateAudience(
    @Path('audienceId') int audienceId,
    @Body() AdminAudienceUpdateRequestModel body,
  );

  @PATCH('/admin/audiences/{audienceId}/visibility')
  Future<ApiResponse<AdminAudienceMutationDataModel>> updateVisibility(
    @Path('audienceId') int audienceId,
    @Body() AdminAudienceVisibilityRequestModel body,
  );

  @GET('/admin/audiences/{audienceId}/deletion-impact')
  Future<ApiResponse<AdminAudienceDeletionImpactDataModel>> getDeletionImpact(
    @Path('audienceId') int audienceId,
  );

  @DELETE('/admin/audiences/{audienceId}')
  Future<ApiResponse<AdminAudienceDeleteDataModel>> deleteAudience(
    @Path('audienceId') int audienceId,
  );
}
