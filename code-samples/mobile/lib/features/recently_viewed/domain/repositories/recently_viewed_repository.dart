import 'package:my_project/core/errors/api_result.dart';
import 'package:my_project/features/products/domain/entities/product_card_entity.dart';

abstract class RecentlyViewedRepository {
  Future<ApiResult<void>> recordView({required int itemId, int? colorGroupId});
  Future<ApiResult<List<ProductCardEntity>>> getRecentlyViewed();
  Future<ApiResult<void>> syncGuestKeysIfAny();
  Future<void> clearLocalKeys();
  Future<ApiResult<void>> clearRecentlyViewed();
}
