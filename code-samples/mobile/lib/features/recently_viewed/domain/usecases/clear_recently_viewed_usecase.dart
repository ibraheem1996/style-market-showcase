import 'package:my_project/core/errors/api_result.dart';
import '../repositories/recently_viewed_repository.dart';

class ClearRecentlyViewedUseCase {
  final RecentlyViewedRepository repository;

  ClearRecentlyViewedUseCase(this.repository);

  Future<ApiResult<void>> call() {
    return repository.clearRecentlyViewed();
  }
}
