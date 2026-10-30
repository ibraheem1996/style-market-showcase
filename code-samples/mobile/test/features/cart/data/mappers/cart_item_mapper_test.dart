import 'package:flutter_test/flutter_test.dart';

import 'package:my_project/features/cart/data/mappers/cart_item_mapper.dart';
import 'package:my_project/features/cart/data/models/cart_item_model.dart';
import 'package:my_project/features/cart/presentation/logic/cart_pricing.dart';

void main() {
  test('maps prices and keeps both backend languages', () {
    final entity = CartItemModel(
      cartId: 1,
      userId: 2,
      itemId: 3,
      variantId: null,
      cartQuantity: 2,
      addedAt: DateTime(2026).toIso8601String(),
      itemName: 'منتج',
      itemNameEn: 'Item',
      itemDescription: 'وصف',
      itemDescriptionEn: 'Description',
      price: 80,
      basePrice: 100,
      discount: 20,
      stock: 5,
      displayImage: 'item.jpg',
      images: const ['item.jpg'],
      lineTotal: 160,
      isAvailable: 1,
      isSelected: 1,
      status: 'OK',
    ).toEntity();

    expect(entity.price, 100);
    expect(entity.lineTotal, 160);
    expect(entity.cartFinalUnitPrice, 80);
    expect(entity.variantId, isNull);
    expect(entity.itemName, 'منتج');
    expect(entity.itemNameEn, 'Item');
    expect(entity.itemDescription, 'وصف');
    expect(entity.itemDescriptionEn, 'Description');
  });

  test('normalizes explicit requires_variant_selection into NEEDS_VARIANT', () {
    final entity = CartItemModel(
      cartId: 1,
      userId: 2,
      itemId: 3,
      variantId: null,
      cartQuantity: 1,
      addedAt: DateTime(2026).toIso8601String(),
      itemName: 'منتج',
      itemNameEn: 'Item',
      price: 80,
      basePrice: 100,
      discount: 20,
      stock: 5,
      displayImage: 'item.jpg',
      images: const ['item.jpg'],
      lineTotal: 80,
      isAvailable: 1,
      isSelected: 1,
      status: 'OK',
      requiresVariantSelection: true,
    ).toEntity();

    expect(entity.status, 'NEEDS_VARIANT');
  });
}
