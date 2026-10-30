import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/network/api_response.dart';
import '../models/admin_dashboard_response_models.dart';

part 'admin_dashboard_remote_data_source.g.dart';

@RestApi()
@lazySingleton
abstract class AdminDashboardRemoteDataSource {
  @factoryMethod
  factory AdminDashboardRemoteDataSource(@Named('protectedDio') Dio dio) =
      _AdminDashboardRemoteDataSource;

  @GET('/admin/dashboard/overview')
  Future<ApiResponse<AdminDashboardOverviewDataDto>> getOverview(
    @Queries() Map<String, dynamic> query,
  );
}
