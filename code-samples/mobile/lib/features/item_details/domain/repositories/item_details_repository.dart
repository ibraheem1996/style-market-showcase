// Project imports:
import '../../../../core/errors/api_result.dart';
import '../../../products/domain/entities/item_entity.dart';

abstract class ItemDetailsRepository {
  Future<ApiResult<ItemEntity>> getItemDetails(int itemId);
}
