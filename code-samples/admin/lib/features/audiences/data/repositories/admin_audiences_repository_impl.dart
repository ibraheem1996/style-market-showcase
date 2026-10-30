import 'package:injectable/injectable.dart';

import '../../../../core/network/api_response.dart';
import '../../../../core/network/network_error_mapper.dart';
import '../../../../core/result/app_result.dart';
import '../../domain/entities/admin_audience_entities.dart';
import '../../domain/repositories/admin_audiences_repository.dart';
import '../datasources/admin_audiences_remote_data_source.dart';
import '../mappers/admin_audience_mapper.dart';
import '../models/admin_audience_request_models.dart';
import '../models/admin_audience_response_models.dart';

@LazySingleton(as: AdminAudiencesRepository)
class AdminAudiencesRepositoryImpl implements AdminAudiencesRepository {
  const AdminAudiencesRepositoryImpl(this._remote, this._errorMapper);

  final AdminAudiencesRemoteDataSource _remote;
  final NetworkErrorMapper _errorMapper;

  @override
  Future<AppResult<List<AdminAudienceEntity>>> getAudiences() async {
    try {
      final response = await _remote.getAudiences();
      return mapAdminAudienceResponse(
        response: response,
        mapper: (data) => data.audiences
            .map((audience) => audience.toEntity())
            .toList(growable: false),
        errorMapper: _errorMapper,
      );
    } catch (error) {
      return AppResult.failure(_errorMapper.map(error));
    }
  }

  @override
  Future<AppResult<AdminAudienceEntity>> getAudience(int audienceId) =>
      _mutation(() => _remote.getAudience(audienceId));

  @override
  Future<AppResult<AdminAudienceEntity>> createAudience(
    AdminAudienceCreateInput input,
  ) => _mutation(
    () => _remote.createAudience(
      AdminAudienceCreateRequestModel(
        arabicName: input.arabicName,
        englishName: input.englishName,
        sortOrder: input.sortOrder,
        active: input.active,
      ),
    ),
  );

  @override
  Future<AppResult<AdminAudienceEntity>> updateAudience(
    AdminAudienceUpdateInput input,
  ) => _mutation(
    () => _remote.updateAudience(
      input.audienceId,
      AdminAudienceUpdateRequestModel(
        arabicName: input.arabicName,
        englishName: input.englishName,
        sortOrder: input.sortOrder,
      ),
    ),
  );

  @override
  Future<AppResult<AdminAudienceEntity>> updateVisibility({
    required int audienceId,
    required bool active,
  }) => _mutation(
    () => _remote.updateVisibility(
      audienceId,
      AdminAudienceVisibilityRequestModel(active: active),
    ),
  );

  @override
  Future<AppResult<AdminAudienceDeletionImpact>> getDeletionImpact(
    int audienceId,
  ) async {
    try {
      final response = await _remote.getDeletionImpact(audienceId);
      return mapAdminAudienceResponse(
        response: response,
        mapper: (data) => data.toEntity(),
        errorMapper: _errorMapper,
      );
    } catch (error) {
      return AppResult.failure(_errorMapper.map(error));
    }
  }

  @override
  Future<AppResult<int>> deleteAudience(int audienceId) async {
    try {
      final response = await _remote.deleteAudience(audienceId);
      return mapAdminAudienceResponse(
        response: response,
        mapper: (data) {
          if (data.deletedAudienceId <= 0) {
            throw const FormatException('Invalid deleted audience id.');
          }
          return data.deletedAudienceId;
        },
        errorMapper: _errorMapper,
      );
    } catch (error) {
      return AppResult.failure(_errorMapper.map(error));
    }
  }

  Future<AppResult<AdminAudienceEntity>> _mutation(
    Future<ApiResponse<AdminAudienceMutationDataModel>> Function() request,
  ) async {
    try {
      final response = await request();
      return mapAdminAudienceResponse(
        response: response,
        mapper: (data) => data.audience.toEntity(),
        errorMapper: _errorMapper,
      );
    } catch (error) {
      return AppResult.failure(_errorMapper.map(error));
    }
  }
}
