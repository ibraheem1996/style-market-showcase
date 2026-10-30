import 'package:dartz/dartz.dart';

import '../../../../core/base/base_repository.dart';
import '../../../../core/errors/api_result.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/errors/failure_key.dart';
import '../../../../core/errors/backend_error_code_resolver.dart';
import '../../../../core/network/api_status.dart';
import '../../../../core/network/response_mapper.dart';
import '../../../../core/services/crashlytics_service.dart';
import '../../../../core/services/logger_service.dart';
import '../../domain/entities/product_catalog_filter_entity.dart';
import '../../domain/entities/product_catalog_response_entity.dart';
import '../../domain/entities/product_catalog_source.dart';
import '../../domain/entities/product_search_response_entity.dart';
import '../../domain/repositories/product_catalog_repository.dart';
import '../datasources/product_catalog_remote_datasource.dart';
import '../mappers/product_card_mapper.dart';
import '../mappers/product_catalog_response_mapper.dart';

class ProductCatalogRepositoryImpl extends BaseRepository
    implements ProductCatalogRepository {
  final ProductCatalogRemoteDataSource remoteDataSource;
  final CrashlyticsService crash;

  ProductCatalogRepositoryImpl({
    required this.remoteDataSource,
    required this.crash,
  }) : super(crash: crash);

  @override
  Future<ApiResult<ProductCatalogResponseEntity>> getCatalog({
    required int audienceId,
    required ProductCatalogSource source,
    required String searchQuery,
    required int page,
    required int limit,
    required String sort,
    required ProductCatalogFilterSelection filterState,
  }) async {
    final colorIds = filterState.selectedColorIds.join(',');
    final sizeIds = filterState.selectedSizeIds.join(',');

    final apiResult = await handleApiCall(
      () => remoteDataSource.getCatalog(
        source.sourceType.name,
        source.sourceId,
        searchQuery.trim(),
        page,
        limit,
        sort,
        colorIds,
        sizeIds,
        filterState.minPrice,
        filterState.maxPrice,
      ),
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
        final data = r.data!;
        final rawItems = data.items;

        if (rawItems == null ||
            data.pagination == null ||
            data.sourceMeta == null) {
          LoggerService.error(
            'ProductCatalogRepo.getCatalog: items or pagination or sourceMeta is null',
            null,
            null,
          );
          return const Left(Failure.http(key: FailureKey.missingServerData));
        }

        if (rawItems.isEmpty) {
          return Right(
            ProductCatalogResponseEntity(
              items: const [],
              pagination: data.pagination!.toEntity(),
              sourceMeta: data.sourceMeta!.toEntity(),
            ),
          );
        }

        final mappedItems = mapListSafely(
          models: rawItems,
          mapper: (item) => item.toEntity(),
          logTag: 'ProductCatalogRepo.getCatalog',
          crash: crash,
          requireAllItems: false,
        );
        return mappedItems.fold(
          (failure) => Left(failure),
          (validItems) => Right(
            ProductCatalogResponseEntity(
              items: validItems,
              pagination: data.pagination!.toEntity(),
              sourceMeta: data.sourceMeta!.toEntity(),
            ),
          ),
        );
      } catch (e, s) {
        LoggerService.error(
          'ProductCatalogRepo.getCatalog: response mapping failed',
          e,
          s,
        );

        crash.logError(
          e,
          s,
          reason: 'ProductCatalogRepo.getCatalog response mapping',
        );

        return const Left(Failure.http(key: FailureKey.invalidData));
      }
    });
  }

  @override
  Future<ApiResult<ProductSearchResponseEntity>> searchProducts({
    required int audienceId,
    required String query,
    required int page,
    required int limit,
  }) async {
    final apiResult = await handleApiCall(
      () => remoteDataSource.searchProducts(audienceId, query, page, limit),
    );

    return apiResult.fold((failure) => Left(failure), (response) {
      if (!parseApiStatus(response.status).isSuccess) {
        return Left(
          Failure.http(
            key:
                BackendErrorCodeResolver.httpFailureKeyOf(response.errorCode) ??
                FailureKey.serverGeneric,
            errorCode: response.errorCode,
            rawServerMessage: response.message,
          ),
        );
      }
      if (response.data?.items == null || response.data?.pagination == null) {
        return const Left(Failure.http(key: FailureKey.missingServerData));
      }

      try {
        final data = response.data!;
        final rawItems = data.items!;
        final mappedItems = mapListSafely(
          models: rawItems,
          mapper: (item) => item.toEntity(),
          logTag: 'ProductCatalogRepo.searchProducts',
          crash: crash,
          requireAllItems: false,
        );
        return mappedItems.fold(
          (failure) => Left(failure),
          (validItems) => Right(
            ProductSearchResponseEntity(
              items: validItems,
              pagination: data.pagination!.toEntity(),
            ),
          ),
        );
      } catch (error, stackTrace) {
        LoggerService.error(
          'ProductCatalogRepo.searchProducts: response mapping failed',
          error,
          stackTrace,
        );
        crash.logError(
          error,
          stackTrace,
          reason: 'ProductCatalogRepo.searchProducts response mapping',
        );
        return const Left(Failure.http(key: FailureKey.invalidData));
      }
    });
  }
}
