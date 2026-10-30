import 'package:flutter_test/flutter_test.dart';
import 'package:my_project/core/config/api_config.dart';
import 'package:my_project/features/cart/presentation/extensions/cart_upsert_input_extensions.dart';
import 'package:my_project/features/item_details/presentation/logic/item_details_selector.dart';
import 'package:my_project/features/products/domain/entities/item_entity.dart';

void main() {
  group('homogeneous variant selection', () {
    test('color_only selects the exact variant by color', () {
      final variants = [
        _variant(id: 1, color: '#111111'),
        _variant(id: 2, color: '#FFFFFF'),
      ];

      expect(variantsHaveColors(variants), isTrue);
      expect(variantsHaveSizes(variants), isFalse);
      expect(variantForColor(variants, '#ffffff')?.variantId, 2);
      expect(uniqueColors(variants).map((item) => item.variantId), [1, 2]);
    });

    test('size_only exposes sizes and selects the exact variant by size', () {
      final variants = [_variant(id: 3, size: 'M'), _variant(id: 4, size: 'L')];

      expect(variantsHaveColors(variants), isFalse);
      expect(variantsHaveSizes(variants), isTrue);
      expect(sizesForColor(variants, '').map((item) => item.variantId), [3, 4]);
      expect(
        variantForSize(variants, colorCode: '', sizeLabel: 'l')?.variantId,
        4,
      );
    });

    test('color_size filters sizes by color and selects the exact pair', () {
      final variants = [
        _variant(id: 5, color: '#111111', size: 'M'),
        _variant(id: 6, color: '#111111', size: 'L'),
        _variant(id: 7, color: '#FFFFFF', size: 'M'),
      ];

      expect(variantsHaveColors(variants), isTrue);
      expect(variantsHaveSizes(variants), isTrue);
      expect(sizesForColor(variants, '#111111').map((item) => item.variantId), [
        5,
        6,
      ]);
      final selected = variantForSize(
        variants,
        colorCode: '#111111',
        sizeLabel: 'L',
      );
      expect(selected?.variantId, 6);
      expect(_item(variants).toCartUpsertInput(variant: selected).variantId, 6);
    });
  });

  group('item-details presentation selection', () {
    test('route variant wins over first in-stock default variant', () {
      final item = _item([
        _variant(id: 1, stock: 5),
        _variant(id: 2, stock: 0),
      ]);

      expect(defaultVariant(item, 2)?.variantId, 2);
      expect(defaultVariant(item, null)?.variantId, 1);
    });

    test('missing route variant falls back to first in-stock variant', () {
      final item = _item([
        _variant(id: 1, stock: 0),
        _variant(id: 2, stock: 4),
      ]);

      expect(defaultVariant(item, 999)?.variantId, 2);
    });

    test('color availability considers every size in the color group', () {
      final variants = [
        _variant(id: 1, color: '#111111', size: 'S', stock: 0),
        _variant(id: 2, color: '#111111', size: 'M', stock: 3),
      ];

      expect(isColorAvailable(variants, '#111111'), isTrue);
      expect(isColorAvailable(variants, '#ffffff'), isFalse);
    });

    test('variant placeholder does not block item image fallback', () {
      final item = _item(
        [
          _variant(id: 1, images: [ApiConfig.placeholder]),
        ],
        images: ['item.jpg'],
      );

      expect(resolveImages(item: item, variant: item.variants.first), [
        '${ApiConfig.images}/item.jpg',
      ]);
    });

    test(
      'uses placeholder only when no usable item or variant image exists',
      () {
        final item = _item([
          _variant(id: 1, images: [ApiConfig.placeholder]),
        ]);

        expect(resolveImages(item: item, variant: item.variants.first), [
          ApiConfig.placeholder,
        ]);
      },
    );

    test('keeps absolute image URL unchanged and normalizes relative URL', () {
      const absolute = 'https://cdn.example.com/p.jpg';
      final item = _item([], images: [absolute, 'local.jpg']);

      expect(resolveImages(item: item), [
        absolute,
        '${ApiConfig.images}/local.jpg',
      ]);
    });

    test('description sections suppress duplicate variant details', () {
      final sections = resolveDescriptionSections(
        itemDescription: '  Cotton   Shirt ',
        variantDescription: 'cotton shirt',
      );

      expect(sections, hasLength(1));
      expect(sections.single.type, ItemDetailsDescriptionType.product);
    });

    test('description sections keep distinct product and variant details', () {
      final sections = resolveDescriptionSections(
        itemDescription: 'Cotton shirt',
        variantDescription: 'Blue variant with pearl buttons',
      );

      expect(sections.map((section) => section.type), [
        ItemDetailsDescriptionType.product,
        ItemDetailsDescriptionType.selectedVariant,
      ]);
    });

    test(
      'available stock subtracts current cart quantity and clamps quantity',
      () {
        final item = _item([_variant(id: 1, stock: 4)]);

        final stock = resolveAvailableStock(
          item: item,
          variant: item.variants.first,
          cartQuantity: 3,
        );

        expect(stock, 1);
        expect(clampItemDetailsQuantity(5, stock), 1);
        expect(clampItemDetailsQuantity(1, 0), 0);
      },
    );

    test('price data shows final price when discount exists', () {
      final item = _item([
        _variant(id: 1, effectivePrice: 20, effectiveDiscount: 25),
      ]);

      final price = resolvePriceData(item: item, variant: item.variants.first);

      expect(price.originalPrice, 20);
      expect(price.finalPrice, 15);
      expect(price.hasDiscount, isTrue);
    });
  });
}

ItemEntity _item(
  List<VariantEntity> variants, {
  List<String> images = const [],
}) {
  return ItemEntity(
    targetAudienceId: 1,
    itemId: 10,
    itemNameAr: 'منتج',
    itemNameEn: 'Product',
    itemDescriptionAr: '',
    itemDescriptionEn: '',
    itemPrice: 10,
    itemCat: 1,
    itemActive: true,
    itemStock: 0,
    itemImages: images,
    variants: variants,
  );
}

VariantEntity _variant({
  required int id,
  String color = '',
  String size = '',
  int stock = 5,
  List<String> images = const [],
  double? effectivePrice,
  double? effectiveDiscount,
}) {
  return VariantEntity(
    variantId: id,
    variantStock: stock,
    variantImages: images,
    variantActive: true,
    effectivePrice: effectivePrice,
    effectiveDiscount: effectiveDiscount,
    variantDescriptionAr: '',
    variantDescriptionEn: '',
    variantColor: color,
    variantColorEn: color,
    colorHex: color,
    colorDescriptionAr: '',
    colorDescriptionEn: '',
    variantSize: size,
    variantSizeEn: size,
  );
}
