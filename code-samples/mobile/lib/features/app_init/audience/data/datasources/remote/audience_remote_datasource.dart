import 'package:dio/dio.dart';
import 'package:my_project/core/network/api_response.dart';

import '../../../../../core/config/api_config.dart';
import '../../models/audience_model.dart';
import 'package:retrofit/retrofit.dart';

part 'audience_remote_datasource.g.dart';

@RestApi()
abstract class AudienceRemoteDataSource {
  factory AudienceRemoteDataSource(Dio dio, {String? baseUrl}) =
      _AudienceRemoteDataSource;

  @GET(ApiConfig.getAudiences)
  Future<ApiResponse<List<AudienceModel>>> getAudiences();
}
