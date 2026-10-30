import '../../../products/domain/entities/item_entity.dart';
import '../../../products/domain/entities/product_card_entity.dart';
import '../../domain/entities/cart_upsert_input.dart';

extension ProductCardCartUpsertInput on ProductCardEntity {
  /// Converts a backend-resolved product card into optimistic cart line data.
  CartUpsertInput toCartUpsertInput() {
    final priceData = _resolvePriceData();

    return CartUpsertInput(
      itemId: itemId,
      variantId: representativeVariantId,
      itemName: itemNameAr,
      itemNameEn: itemNameEn,
      itemDescription: '',
      itemDescriptionEn: '',
      image: itemDisplayImage,
      images: images,
      price: priceData.price,
      discount: priceData.discount,
      stock: stockQuantity,
      isAvailable: (stockQuantity ?? 1) > 0,
    );
  }

  _CartPriceData _resolvePriceData() {
    if (hasDiscount && originalPrice > 0 && originalPrice > displayPrice) {
      final discount = ((originalPrice - displayPrice) / originalPrice) * 100;
      return _CartPriceData(price: originalPrice, discount: discount);
    }

    if (hasDiscount && maxDiscountPct > 0 && maxDiscountPct <= 100) {
      return _CartPriceData(
        price: originalPrice > 0 ? originalPrice : displayPrice,
        discount: maxDiscountPct.toDouble(),
      );
    }

    return _CartPriceData(price: displayPrice, discount: 0);
  }
}

extension ItemCartUpsertInput on ItemEntity {
  /// Converts item-details data into the shared optimistic cart input.
  CartUpsertInput toCartUpsertInput({VariantEntity? variant}) {
    final priceData = _resolvePriceDataa(variant: variant);
    final images = _resolveImages(variant: variant);
    final descriptionAr = _descriptionFor(variant, isArabic: true);
    final descriptionEn = _descriptionFor(variant, isArabic: false);

    return CartUpsertInput(
      itemId: itemId,
      variantId: variant?.variantId,
      itemName: itemNameAr,
      itemNameEn: itemNameEn,
      itemDescription: descriptionAr,
      itemDescriptionEn: descriptionEn,
      image: images.firstOrNull ?? '',
      images: images,
      price: priceData.price,
      discount: priceData.discount,
      stock: variant?.variantStock ?? itemStock,
      variantDescription: variant == null ? '' : descriptionAr,
      variantDescriptionEn: variant == null ? '' : descriptionEn,
      variantSize: variant?.variantSize ?? '',
      variantSizeEn: variant?.variantSizeEn,
      variantColor: variant?.variantColor ?? '',
      variantColorEn: variant?.variantColorEn,
      colorHex: variant?.colorHex,
      isAvailable: true,
    );
  }

  String _descriptionFor(VariantEntity? variant, {required bool isArabic}) {
    if (variant != null) {
      return isArabic
          ? variant.variantDescriptionAr
          : variant.variantDescriptionEn;
    }
    return isArabic ? itemDescriptionAr : itemDescriptionEn;
  }

  List<String> _resolveImages({VariantEntity? variant}) {
    if (variant != null && variant.variantImages.isNotEmpty) {
      return List<String>.from(variant.variantImages);
    }
    if (itemImages.isNotEmpty) {
      return List<String>.from(itemImages);
    }
    return const [];
  }

  _CartPriceData _resolvePriceDataa({VariantEntity? variant}) {
    if (variant != null) {
      return _CartPriceData(
        price: variant.effectivePrice ?? variant.variantPrice ?? itemPrice,
        discount:
            variant.effectiveDiscount ??
            variant.variantDiscount ??
            itemDiscount ??
            0,
      );
    }

    return _CartPriceData(price: itemPrice, discount: itemDiscount ?? 0);
  }
}

class _CartPriceData {
  const _CartPriceData({required this.price, required this.discount});

  final double price;
  final double discount;
}
