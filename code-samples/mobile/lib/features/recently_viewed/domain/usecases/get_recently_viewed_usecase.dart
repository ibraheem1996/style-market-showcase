import 'package:my_project/core/errors/api_result.dart';
import 'package:my_project/features/products/domain/entities/product_card_entity.dart';
import '../repositories/recently_viewed_repository.dart';

class GetRecentlyViewedUseCase {
  final RecentlyViewedRepository repository;

  GetRecentlyViewedUseCase(this.repository);

  Future<ApiResult<List<ProductCardEntity>>> call() {
    return repository.getRecentlyViewed();
  }
}
