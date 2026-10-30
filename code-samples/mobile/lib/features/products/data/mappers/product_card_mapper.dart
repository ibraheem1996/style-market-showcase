import 'package:my_project/core/config/api_config.dart';
import 'package:my_project/core/errors/mapping_exception.dart';

import '../../domain/entities/product_badge_entity.dart';
import '../../domain/entities/product_card_entity.dart';
import '../model/product_card_model.dart';

extension ProductCardModelMapper on ProductCardModel {
  ProductCardEntity toEntity() {
    final iId = itemId ?? (throw MappingException("itemId is null"));

    String fallbackName(String? primary, String? fallback) {
      if (primary != null && primary.trim().isNotEmpty) {
        return primary;
      }

      if (fallback != null && fallback.trim().isNotEmpty) {
        return fallback;
      }

      throw MappingException("item name is null");
    }

    final dP = displayPrice ?? (throw MappingException("displayPrice is null"));

    final oP = originalPrice ?? dP;

    final displayImage =
        (itemDisplayImage != null &&
            itemDisplayImage!.isNotEmpty &&
            itemDisplayImage!.trim().length > 4)
        ? "${ApiConfig.images}/$itemDisplayImage"
        : ApiConfig.placeholder;

    final allImages = () {
      if (images != null) {
        final list = <String>[];
        for (final image in images!) {
          if (image.trim().isNotEmpty && image.length > 4) {
            list.add("${ApiConfig.images}/$image");
          }
        }
        return list;
      }
      return [ApiConfig.placeholder];
    }();

    return ProductCardEntity(
      itemId: iId,
      itemNameAr: fallbackName(itemNameAr, itemNameEn),
      itemNameEn: fallbackName(itemNameEn, itemNameAr),
      displayPrice: dP,
      originalPrice: oP,
      hasDiscount: hasDiscount ?? false,
      maxDiscountPct: maxDiscountPct ?? 0,
      itemDisplayImage: displayImage,
      availableColors: (availableColors ?? [])
          .map(
            (c) => ProductColorOption(
              valueId:
                  c.valueId ??
                  (throw MappingException("color valueId is null")),
              hex: c.hex ?? '',
              nameAr: c.nameAr ?? '',
              nameEn: c.nameEn ?? '',
            ),
          )
          .toList(),
      availableSizes: (availableSizes ?? [])
          .map(
            (s) => ProductSizeOption(
              sizeValueId:
                  s.sizeValueId ??
                  (throw MappingException("sizeValueId is null")),
              nameAr: s.nameAr ?? '',
              nameEn: s.nameEn ?? '',
            ),
          )
          .toList(),
      isFeatured: isFeatured ?? false,
      representativeVariantId: representativeVariantId,
      colorGroupId: colorGroupId,
      images: allImages,
      stockQuantity: stockQuantity,
      badges: (badges ?? [])
          .map(
            (b) => ProductBadgeEntity(
              type: b.type ?? '',
              labelAr: b.labelAr ?? '',
              labelEn: b.labelEn ?? '',
            ),
          )
          .toList(),
    );
  }
}
