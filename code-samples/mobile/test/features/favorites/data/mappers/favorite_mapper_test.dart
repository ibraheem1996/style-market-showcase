import 'package:flutter_test/flutter_test.dart';
import 'package:my_project/core/errors/mapping_exception.dart';
import 'package:my_project/features/favorites/data/mappers/favorite_mapper.dart';
import 'package:my_project/features/favorites/data/models/favorite_model.dart';
import 'package:my_project/features/favorites/domain/entities/favorite_entity.dart';
import 'package:my_project/features/favorites/presentation/extension/fav_entity_extnsion.dart';

void main() {
  group('FavoriteModelMapper', () {
    test('maps the new variant favorite response shape', () {
      final entity = _favoriteModel().toEntity();

      expect(entity.favId, 10);
      expect(entity.itemId, 1);
      expect(entity.variantId, 9);
      expect(entity.targetType, FavoriteTargetType.variant);
      expect(entity.displayPrice, 90);
      expect(entity.originalPrice, 100);
      expect(entity.itemDescriptionEn, 'Soft cotton shirt');
      expect(entity.status, FavoriteStatus.ok);
      expect(entity.selectedAttributes.single.attributeTypeId, isNull);
      expect(entity.selectedAttributes.single.valueNameEn, 'Red');
      expect(entity.priceAlert?.type, 'price_drop');
    });

    test('maps unavailable statuses explicitly', () {
      expect(
        _favoriteModel(status: 'ITEM_INACTIVE').toEntity().status,
        FavoriteStatus.itemInactive,
      );
      expect(
        _favoriteModel(status: 'VARIANT_INACTIVE').toEntity().status,
        FavoriteStatus.variantInactive,
      );
      expect(
        _favoriteModel(status: 'OUT_OF_STOCK').toEntity().status,
        FavoriteStatus.outOfStock,
      );
      expect(
        _favoriteModel(status: 'INVALID_VARIANT').toEntity().status,
        FavoriteStatus.invalidVariant,
      );
    });

    test('rejects unknown status and missing timestamp', () {
      expect(
        () => _favoriteModel(status: 'UNKNOWN').toEntity(),
        throwsA(isA<MappingException>()),
      );
      expect(
        () => _favoriteModel(createdAt: null).toEntity(),
        throwsA(isA<MappingException>()),
      );
    });
  });

  group('FavoriteEntity to CartUpsertInput', () {
    test(
      'uses original price and derived discount for discounted favorites',
      () {
        final input = _favoriteModel().toEntity().toCartUpsertInput();

        expect(input.itemId, 1);
        expect(input.variantId, 9);
        expect(input.price, 100);
        expect(input.discount, 10);
      },
    );

    test('does not discount twice when original and display prices match', () {
      final input = _favoriteModel(
        displayPrice: 90,
        originalPrice: 90,
        discount: 10,
      ).toEntity().toCartUpsertInput();

      expect(input.price, 90);
      expect(input.discount, 0);
    });
  });
}

FavoriteModel _favoriteModel({
  String status = 'OK',
  double displayPrice = 90,
  double originalPrice = 100,
  double discount = 10,
  String? createdAt = '2026-05-21T10:00:00Z',
}) {
  return FavoriteModel(
    favId: 10,
    itemId: 1,
    variantId: 9,
    targetType: 'variant',
    itemNameAr: 'قميص',
    itemNameEn: 'Shirt',
    itemDescriptionAr: 'قميص قطني ناعم',
    itemDescriptionEn: 'Soft cotton shirt',
    displayImage: 'shirt.jpg',
    images: const ['shirt.jpg', 'shirt-2.jpg'],
    displayPrice: displayPrice,
    originalPrice: originalPrice,
    discount: discount,
    stockQuantity: 4,
    isAvailable: true,
    status: status,
    selectedAttributes: const [
      SelectedAttributeModel(
        attributeTypeId: null,
        attributeTypeKey: 'color',
        attributeTypeNameAr: 'اللون',
        attributeTypeNameEn: 'Color',
        valueId: 3,
        valueNameAr: 'أحمر',
        valueNameEn: 'Red',
        valueHex: '#ff0000',
      ),
    ],
    priceAlert: const PriceAlertModel(
      type: 'price_drop',
      oldPrice: 100,
      newPrice: 90,
      amount: 10,
      percent: 10,
    ),
    createdAt: createdAt,
  );
}
