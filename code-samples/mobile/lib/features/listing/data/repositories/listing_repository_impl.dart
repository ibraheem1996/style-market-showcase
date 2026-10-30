import 'package:dartz/dartz.dart';
import 'package:my_project/core/services/logger_service.dart';

import '../../../../core/base/base_repository.dart';
import '../../../../core/errors/api_result.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/errors/failure_key.dart';
import '../../../../core/errors/backend_error_code_resolver.dart';
import '../../../../core/network/api_status.dart';
import '../../../../core/network/response_mapper.dart';
import '../../../../core/services/crashlytics_service.dart';
import '../../../products/data/mappers/category_mapper.dart';
import '../../../products/data/model/category_model.dart';
import '../../../products/domain/entities/product_catalog_source.dart';
import '../../../products/domain/entities/category_entity.dart';
import '../../domain/entities/filter_options_entity.dart';
import '../../domain/entities/sort_options_entity.dart';
import '../../domain/repositories/listing_repository.dart';
import '../datasources/listing_remote_datasource.dart';
import '../mappers/filter_options_mapper.dart';

class ListingRepositoryImpl extends BaseRepository
    implements ListingRepository {
  final ListingRemoteDataSource remoteDataSource;
  final CrashlyticsService crash;

  ListingRepositoryImpl({
    required this.remoteDataSource,
    required this.crash,
  }) : super(crash: crash);

  @override
  Future<ApiResult<(FilterOptionsEntity, SortOptionsEntity)>>
  getListingControls({
    required int audienceId,
    required ProductCatalogSource source,
  }) async {
    final apiResult = await handleApiCall(
      () =>
          remoteDataSource.getFilters(source.sourceType.name, source.sourceId),
    );

    return apiResult.fold((l) => Left(l), (r) {
      if (!parseApiStatus(r.status).isSuccess) {
        return Left(
          Failure.http(
            key:
                BackendErrorCodeResolver.httpFailureKeyOf(r.errorCode) ??
                FailureKey.serverGeneric,
            errorCode: r.errorCode,
            rawServerMessage: r.message,
          ),
        );
      }
      if (r.data == null) {
        return const Left(Failure.http(key: FailureKey.missingServerData));
      }
      try {
        final filterOptions = r.data!.toFilterOptionsEntity();
        final sortOptions = r.data!.toSortOptionsEntity();
        return Right((filterOptions, sortOptions));
      } catch (e, s) {
        LoggerService.error(
          'ListingRepo.getListingControls: mapping failed',
          e,
          s,
        );
        crash.logError(e, s, reason: 'ListingRepo.getListingControls mapping');
        return const Left(Failure.http(key: FailureKey.invalidData));
      }
    });
  }

  @override
  Future<ApiResult<List<CategoryEntity>>> getSubcategories({
    required int categoryId,
    required int audienceId,
  }) async {
    final apiResult = await handleApiCall(
      () => remoteDataSource.getSubcategories(categoryId),
    );

    return apiResult.fold((l) => Left(l), (r) {
      return mapListResponse<Object?, CategoryEntity>(
        r: r,
        mapper: (raw) =>
            CategoryModel.fromJson(raw as Map<String, dynamic>).toEntity(),
        logTag: 'ListingRepo.getSubcategories',
        crash: crash,
        requireAllItems: false,
      );

      // }
    });
  }
}
