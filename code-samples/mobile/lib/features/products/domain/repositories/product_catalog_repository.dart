import '../../../../core/errors/api_result.dart';
import '../entities/product_catalog_filter_entity.dart';
import '../entities/product_catalog_response_entity.dart';
import '../entities/product_catalog_source.dart';
import '../entities/product_search_response_entity.dart';

abstract class ProductCatalogRepository {
  Future<ApiResult<ProductCatalogResponseEntity>> getCatalog({
    required int audienceId,
    required ProductCatalogSource source,
    required String searchQuery,
    required int page,
    required int limit,
    required String sort,
    required ProductCatalogFilterSelection filterState,
  });

  Future<ApiResult<ProductSearchResponseEntity>> searchProducts({
    required int audienceId,
    required String query,
    required int page,
    required int limit,
  });
}
