import 'package:dartz/dartz.dart';

import '../../../../core/base/base_repository.dart';
import '../../../../core/errors/api_result.dart';

import '../../../../core/network/response_mapper.dart';
import '../../../../core/services/crashlytics_service.dart';
import '../../domain/entities/audience_entity.dart';
import '../../domain/repositories/audience_repository.dart';
import '../datasources/local/audience_local_datasource.dart';
import '../datasources/remote/audience_remote_datasource.dart';
import '../mappers/audience_mapper.dart';
import '../models/audience_model.dart';

class AudienceRepositoryImpl extends BaseRepository
    implements AudienceRepository {
  AudienceRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.crash,
    required super.analytics,
    required super.performance,
  }) : super(crash: crash);

  final AudienceRemoteDataSource remoteDataSource;
  final AudienceLocalDataSource localDataSource;
  final CrashlyticsService crash;

  @override
  Future<ApiResult<List<AudienceEntity>>> getAudiences() async {
    final result = await handleApiCall(() => remoteDataSource.getAudiences());
    return result.fold((l) => Left(l), (response) {
      return mapListResponse<AudienceModel, AudienceEntity>(
        r: response,
        mapper: (model) => model.toEntity(),
        logTag: "AudienceRepositoryImpl",
        crash: crash,
        requireAllItems: true,
      );
    });
  }

  @override
  int? getSelectedAudienceId() => localDataSource.getSelectedAudienceId();

  @override
  Future<bool> setSelectedAudienceId(int id) =>
      localDataSource.setSelectedAudienceId(id);
}
