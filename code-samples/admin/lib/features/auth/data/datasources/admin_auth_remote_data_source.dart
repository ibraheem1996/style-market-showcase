import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/network/api_response.dart';
import '../models/admin_auth_request_models.dart';
import '../models/admin_auth_response_models.dart';

part 'admin_auth_remote_data_source.g.dart';

@RestApi()
@lazySingleton
abstract class AdminAuthRemoteDataSource {
  @factoryMethod
  factory AdminAuthRemoteDataSource(@Named('authDio') Dio dio) =
      _AdminAuthRemoteDataSource;

  @POST('/admin/auth/signin')
  Future<ApiResponse<AdminAuthSessionDataModel>> signIn(
    @Body() AdminSignInRequestModel body,
  );

  @GET('/admin/auth/me')
  Future<ApiResponse<AdminMeDataModel>> me(
    @Header('Authorization') String authorization,
  );

  @POST('/admin/auth/refresh')
  Future<ApiResponse<AdminAuthSessionDataModel>> refresh(
    @Body() AdminRefreshTokenRequestModel body,
  );

  @POST('/admin/auth/logout')
  Future<ApiResponse<void>> logout(@Body() AdminLogoutRequestModel body);
}
