import '../../../../core/errors/api_result.dart';
import '../../../../features/products/domain/entities/category_entity.dart';
import '../../../../features/products/domain/entities/product_catalog_source.dart';
import '../entities/filter_options_entity.dart';
import '../entities/sort_options_entity.dart';

abstract class ListingRepository {
  // Returns filter options and sort options together — both come from one API
  // endpoint, so a single call provides data for both.
  Future<ApiResult<(FilterOptionsEntity, SortOptionsEntity)>>
  getListingControls({
    required int audienceId,
    required ProductCatalogSource source,
  });

  Future<ApiResult<List<CategoryEntity>>> getSubcategories({
    required int categoryId,
    required int audienceId,
  });
}
