import 'package:my_project/core/errors/api_result.dart';
import '../repositories/recently_viewed_repository.dart';

class RecordRecentlyViewedUseCase {
  final RecentlyViewedRepository repository;

  RecordRecentlyViewedUseCase(this.repository);

  Future<ApiResult<void>> call({required int itemId, int? colorGroupId}) {
    return repository.recordView(itemId: itemId, colorGroupId: colorGroupId);
  }
}
