import 'package:flutter_test/flutter_test.dart';
import 'package:my_project/features/cart/presentation/extensions/cart_upsert_input_extensions.dart';
import 'package:my_project/features/products/domain/entities/item_entity.dart';
import 'package:my_project/features/products/domain/entities/product_card_entity.dart';

void main() {
  group('ProductCardCartUpsertInput', () {
    test('uses representative variant id for variant cards', () {
      final input = _card(representativeVariantId: 9).toCartUpsertInput();

      expect(input.itemId, 1);
      expect(input.variantId, 9);
    });

    test('keeps variant id null for simple cards', () {
      final input = _card().toCartUpsertInput();

      expect(input.variantId, isNull);
    });

    test('calculates discount from original and display prices', () {
      final input = _card(
        displayPrice: 80,
        originalPrice: 100,
        hasDiscount: true,
        maxDiscountPct: 20,
      ).toCartUpsertInput();

      expect(input.price, 100);
      expect(input.discount, 20);
    });

    test('falls back to max discount percent when prices cannot derive it', () {
      final input = _card(
        displayPrice: 80,
        originalPrice: 0,
        hasDiscount: true,
        maxDiscountPct: 15,
      ).toCartUpsertInput();

      expect(input.price, 80);
      expect(input.discount, 15);
    });

    test(
      'uses display price without discount when discount is unavailable',
      () {
        final input = _card(
          displayPrice: 80,
          originalPrice: 100,
        ).toCartUpsertInput();

        expect(input.price, 80);
        expect(input.discount, 0);
      },
    );
  });

  group('ItemCartUpsertInput', () {
    test('keeps variant id null for simple items', () {
      final input = _item().toCartUpsertInput();

      expect(input.itemId, 1);
      expect(input.variantId, isNull);
      expect(input.stock, 5);
      expect(input.price, 100);
      expect(input.discount, 10);
      expect(input.image, 'item.jpg');
    });

    test('uses selected variant data when variant is provided', () {
      final variant = _variant(effectivePrice: 70, effectiveDiscount: 15);
      final input = _item(
        variants: [variant],
      ).toCartUpsertInput(variant: variant);

      expect(input.variantId, 9);
      expect(input.stock, 3);
      expect(input.price, 70);
      expect(input.discount, 15);
      expect(input.image, 'variant.jpg');
      expect(input.variantDescription, 'Variant');
      expect(input.variantSizeEn, 'Large');
      expect(input.variantColorEn, 'Red');
    });
  });
}

ProductCardEntity _card({
  int? representativeVariantId,
  double displayPrice = 10,
  double originalPrice = 10,
  bool hasDiscount = false,
  int maxDiscountPct = 0,
}) {
  return ProductCardEntity(
    itemId: 1,
    itemNameAr: 'عنصر',
    itemNameEn: 'Item',
    displayPrice: displayPrice,
    originalPrice: originalPrice,
    hasDiscount: hasDiscount,
    maxDiscountPct: maxDiscountPct,
    itemDisplayImage: 'https://example.com/item.jpg',
    availableColors: const [],
    availableSizes: const [],
    isFeatured: false,
    representativeVariantId: representativeVariantId,
    images: const ['https://example.com/item.jpg'],
    stockQuantity: 5,
    badges: const [],
  );
}

ItemEntity _item({List<VariantEntity> variants = const []}) {
  return ItemEntity(
    targetAudienceId: 1,
    itemId: 1,
    itemNameAr: 'Item',
    itemNameEn: 'Item',
    itemDescriptionAr: 'Description',
    itemDescriptionEn: 'Description',
    itemPrice: 100,
    itemCat: 1,
    itemActive: true,
    itemStock: 5,
    itemImages: const ['item.jpg'],
    variants: variants,
    itemDatetime: DateTime(2024),
    itemDiscount: 10,
  );
}

VariantEntity _variant({double? effectivePrice, double? effectiveDiscount}) {
  return VariantEntity(
    variantId: 9,
    variantPrice: 80,
    variantDiscount: 5,
    effectivePrice: effectivePrice,
    effectiveDiscount: effectiveDiscount,
    finalPrice: null,
    variantStock: 3,
    variantImages: const ['variant.jpg'],
    variantActive: true,
    variantDescriptionAr: 'Variant',
    variantDescriptionEn: 'Variant',
    variantColor: 'Red',
    variantColorEn: 'Red',
    colorHex: '#ff0000',
    colorDescriptionAr: '',
    colorDescriptionEn: '',
    variantSize: 'Large',
    variantSizeEn: 'Large',
  );
}
