import 'package:get/get.dart';

import '../../../../core/localization/languages.dart';
import '../../../cart/domain/entities/cart_upsert_input.dart';
import '../../domain/entities/favorite_entity.dart';

extension FavoriteEntityPresentationExtension on FavoriteEntity {
  bool get _isArabic {
    if (Get.isRegistered<Languages>()) {
      return Get.find<Languages>().isArabic;
    }
    return Get.locale?.languageCode == 'ar';
  }

  String get displayName => _isArabic ? itemNameAr : itemNameEn;

  String get displayDescription =>
      _isArabic ? itemDescriptionAr : itemDescriptionEn;

  String get cartAttributesDescription {
    return selectedAttributes
        .map((attribute) => attribute.displayValue)
        .where((value) => value.trim().isNotEmpty)
        .join(' / ');
  }

  CartUpsertInput toCartUpsertInput() {
    final priceData = _cartPriceData();

    return CartUpsertInput(
      itemId: itemId,
      variantId: targetType == FavoriteTargetType.variant ? variantId : null,
      itemName: itemNameAr,
      itemNameEn: itemNameEn,
      itemDescription: itemDescriptionAr,
      itemDescriptionEn: itemDescriptionEn,
      image: displayImage,
      images: images,
      price: priceData.price,
      discount: priceData.discount,
      stock: stockQuantity,
      variantDescription: selectedAttributes
          .map((attribute) => attribute.valueNameAr)
          .where((value) => value.trim().isNotEmpty)
          .join(' / '),
      variantDescriptionEn: selectedAttributes
          .map((attribute) => attribute.valueNameEn)
          .where((value) => value.trim().isNotEmpty)
          .join(' / '),
      isAvailable: isAvailable,
    );
  }

  _FavoriteCartPriceData _cartPriceData() {
    if (originalPrice > displayPrice && originalPrice > 0) {
      final derivedDiscount = ((originalPrice - displayPrice) / originalPrice)
          .clamp(0.0, 1.0);
      return _FavoriteCartPriceData(
        price: originalPrice,
        discount: derivedDiscount * 100,
      );
    }

    return _FavoriteCartPriceData(price: displayPrice, discount: 0);
  }
}

extension SelectedAttributePresentationExtension on SelectedAttributeEntity {
  bool get _isArabic {
    if (Get.isRegistered<Languages>()) {
      return Get.find<Languages>().isArabic;
    }
    return Get.locale?.languageCode == 'ar';
  }

  String get displayType =>
      _isArabic ? attributeTypeNameAr : attributeTypeNameEn;

  String get displayValue => _isArabic ? valueNameAr : valueNameEn;
}

class _FavoriteCartPriceData {
  const _FavoriteCartPriceData({required this.price, required this.discount});

  final double price;
  final double discount;
}
