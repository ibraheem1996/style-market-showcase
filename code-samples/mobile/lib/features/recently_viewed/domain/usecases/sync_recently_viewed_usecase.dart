import 'package:my_project/core/errors/api_result.dart';
import '../repositories/recently_viewed_repository.dart';

class SyncRecentlyViewedUseCase {
  final RecentlyViewedRepository repository;

  SyncRecentlyViewedUseCase(this.repository);

  Future<ApiResult<void>> call() {
    return repository.syncGuestKeysIfAny();
  }
}
