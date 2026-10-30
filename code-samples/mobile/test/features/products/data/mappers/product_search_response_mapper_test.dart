import 'package:flutter_test/flutter_test.dart';
import 'package:my_project/features/products/data/mappers/product_search_response_mapper.dart';
import 'package:my_project/features/products/data/model/product_search_response_model.dart';
import 'package:my_project/features/products/data/model/product_catalog_response_model.dart';
import 'package:my_project/features/recommendations/data/models/recommendations_response_model.dart';

void main() {
  test('search DTO keeps decodable cards and rejects all malformed cards', () {
    final body = {
      'items': [<String, dynamic>{}, 42],
      'pagination': {'page': 1},
    };
    expect(ProductSearchResponseModel.fromJson(body).items, hasLength(1));
    expect(
      () => ProductSearchResponseModel.fromJson({
        'items': [42],
      }),
      throwsA(isA<FormatException>()),
    );
  });

  test(
    'malformed catalog and recommendation cards fail during DTO decoding',
    () {
      expect(
        () => ProductCatalogResponseModel.fromJson({
          'items': [42],
        }),
        throwsA(isA<FormatException>()),
      );
      expect(
        () => RecommendationsResponseModel.fromJson({
          'items': [42],
        }),
        throwsA(isA<FormatException>()),
      );
      expect(
        ProductCatalogResponseModel.fromJson({
          'items': [<String, dynamic>{}, 42],
        }).items,
        hasLength(1),
      );
      expect(
        RecommendationsResponseModel.fromJson({
          'items': [<String, dynamic>{}, 42],
        }).items,
        hasLength(1),
      );
    },
  );
  test(
    'maps source-free search cards and pagination without source metadata',
    () {
      final model = ProductSearchResponseModel.fromJson({
        'items': [
          {
            'item_id': 9,
            'item_name_ar': 'قميص',
            'item_name_en': 'Shirt',
            'display_price': 12.5,
            'original_price': 15.0,
            'has_discount': true,
            'max_discount_pct': 17,
            'item_display_image': 'shirt.jpg',
            'images': ['shirt.jpg'],
            'representative_variant_id': 91,
            'color_group_id': 4,
            'stock_quantity': 3,
            'available_colors': <Map<String, dynamic>>[],
            'available_sizes': <Map<String, dynamic>>[],
            'is_featured': false,
            'badges': <Map<String, dynamic>>[],
          },
        ],
        'pagination': {'page': 2, 'limit': 16, 'total': 20, 'has_more': true},
      });

      final entity = model.toEntity();

      expect(entity.items.single.itemId, 9);
      expect(entity.items.single.representativeVariantId, 91);
      expect(entity.items.single.colorGroupId, 4);
      expect(entity.pagination.page, 2);
      expect(entity.pagination.hasMore, isTrue);
    },
  );
}
