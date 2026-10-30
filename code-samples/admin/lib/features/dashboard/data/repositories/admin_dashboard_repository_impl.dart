import 'package:injectable/injectable.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/network_error_mapper.dart';
import '../../../../core/result/app_result.dart';
import '../../domain/entities/admin_dashboard_entities.dart';
import '../../domain/repositories/admin_dashboard_repository.dart';
import '../datasources/admin_dashboard_remote_data_source.dart';
import '../mappers/admin_dashboard_mapper.dart';

@LazySingleton(as: AdminDashboardRepository)
class AdminDashboardRepositoryImpl implements AdminDashboardRepository {
  const AdminDashboardRepositoryImpl(this._remoteDataSource, this._errorMapper);

  final AdminDashboardRemoteDataSource _remoteDataSource;
  final NetworkErrorMapper _errorMapper;

  @override
  Future<AppResult<AdminDashboardOverview>> getOverview(
    AdminDashboardFilter filter,
  ) async {
    try {
      final response = await _remoteDataSource.getOverview(filter.toQuery());
      return mapAdminDashboardResponse(
        response: response,
        mapper: (data) => data.toEntity(),
        errorMapper: _errorMapper,
      );
    } catch (error) {
      return AppResult.failure(_errorMapper.map(error));
    }
  }
}

AppResult<T> mapAdminDashboardResponse<T, M>({
  required ApiResponse<M> response,
  required T Function(M model) mapper,
  required NetworkErrorMapper errorMapper,
}) {
  if (!response.isSuccess || response.data == null) {
    return AppResult.failure(
      errorMapper.mapResponse(
        statusCode: null,
        data: {
          'status': response.status,
          'message': response.message,
          'error_code': response.errorCode,
        },
      ),
    );
  }

  try {
    return AppResult.success(mapper(response.data as M));
  } on FormatException catch (error) {
    return AppResult.failure(AppFailure.parsing(rawMessage: error.message));
  }
}
