import '../../../../core/services/logger_service.dart';
import 'product_card_model.dart';

/// Keeps valid card DTOs when one JSON item has an invalid shape.
List<ProductCardModel>? parseProductCardList(List<dynamic>? values) {
  if (values == null) return null;
  final items = <ProductCardModel>[];
  var failures = 0;
  for (var index = 0; index < values.length; index++) {
    try {
      items.add(
        ProductCardModel.fromJson(values[index] as Map<String, dynamic>),
      );
    } catch (error, stackTrace) {
      if (failures < 3) {
        LoggerService.error(
          'Product card DTO at index $index',
          error,
          stackTrace,
        );
      }
      failures++;
    }
  }
  if (values.isNotEmpty && items.isEmpty) {
    throw const FormatException('All product cards failed to decode');
  }
  return items;
}
