import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:my_project/core/errors/failure.dart';
import 'package:my_project/core/errors/failure_key.dart';
import 'package:my_project/core/network/api_response.dart';
import 'package:my_project/core/services/analytics_service.dart';
import 'package:my_project/core/services/crashlytics_service.dart';
import 'package:my_project/core/services/performance_service.dart';
import 'package:my_project/features/products/data/datasources/product_catalog_remote_datasource.dart';
import 'package:my_project/features/products/data/model/product_catalog_response_model.dart';
import 'package:my_project/features/products/data/model/product_search_response_model.dart';
import 'package:my_project/features/products/data/model/source_meta_model.dart';
import 'package:my_project/features/products/data/repositories/product_catalog_repository_impl.dart';
import 'package:my_project/features/products/domain/entities/product_catalog_filter_entity.dart';
import 'package:my_project/features/products/domain/entities/product_catalog_source.dart';

void main() {
  test(
    'catalog requires pagination even when source metadata exists',
    () async {
      final repository = ProductCatalogRepositoryImpl(
        remoteDataSource: _FakeRemote(
          ApiResponse(
            status: 'success',
            data: ProductCatalogResponseModel(
              items: [],
              sourceMeta: SourceMetaModel(),
            ),
          ),
        ),
        analytics: _MockAnalytics(),
        crash: _MockCrashlytics(),
        performance: _MockPerformance(),
      );

      final result = await repository.getCatalog(
        audienceId: 1,
        source: const ProductCatalogSource(
          sourceType: ProductCatalogSourceType.category,
          sourceId: '2',
          titleAr: 'فئة',
          titleEn: 'Category',
        ),
        searchQuery: '',
        page: 1,
        limit: 16,
        sort: '',
        filterState: ProductCatalogFilterSelection.empty(),
      );

      expect(
        result.fold((failure) => failure, (_) => null),
        const Failure.http(key: FailureKey.missingServerData),
      );
    },
  );
}

class _FakeRemote implements ProductCatalogRemoteDataSource {
  _FakeRemote(this.catalogResponse);

  final ApiResponse<ProductCatalogResponseModel> catalogResponse;

  @override
  Future<ApiResponse<ProductCatalogResponseModel>> getCatalog(
    String sourceType,
    String sourceId,
    String search,
    int page,
    int limit,
    String sort,
    String colorIds,
    String sizeIds,
    double? minPrice,
    double? maxPrice,
  ) async => catalogResponse;

  @override
  Future<ApiResponse<ProductSearchResponseModel>> searchProducts(
    int audienceId,
    String query,
    int page,
    int limit,
  ) => throw UnimplementedError();
}

class _MockAnalytics extends Mock implements AnalyticsService {}

class _MockCrashlytics extends Mock implements CrashlyticsService {}

class _MockPerformance extends Mock implements PerformanceService {}
