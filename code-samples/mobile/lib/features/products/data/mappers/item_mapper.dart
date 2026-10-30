// Project imports:

import 'package:my_project/core/config/api_config.dart';

import '../../../../core/errors/mapping_exception.dart';
import '../../domain/entities/item_entity.dart';
import '../model/item_model.dart';

extension ItemMapper on ItemModel {
  ItemEntity toEntity() {
    final id = itemId != null && itemId != 0
        ? itemId!
        : throw MappingException("Item ID is null");

    final audienceId = targetAudienceId != null && targetAudienceId! > 0
        ? targetAudienceId!
        : throw MappingException("Item target audience is invalid");

    String fallbackName(String? primary, String? fallback) {
      if (primary != null && primary.trim().isNotEmpty) {
        return primary;
      }

      if (fallback != null && fallback.trim().isNotEmpty) {
        return fallback;
      }

      throw MappingException("item name is null");
    }

    final cat = itemCat != null && itemCat != 0
        ? itemCat!
        : throw MappingException("Item Category is null");

    final price = itemPrice != null && itemPrice! >= 0
        ? itemPrice!
        : throw MappingException("Item Price is invalid: $itemPrice");

    final bool active = switch (itemActive) {
      1 => true,
      0 => false,
      _ => false,
    };

    final DateTime? dateTime = itemDatetime != null
        ? DateTime.tryParse(itemDatetime ?? "")
        : null;

    List<String> images = [];

    for (final image in itemImages ?? <String>[]) {
      if (image.trim().isNotEmpty && image.length >= 4) {
        images.add("${ApiConfig.images}/$image");
      }
    }

    if (images.isEmpty) {
      images = [ApiConfig.placeholder];
    }

    return ItemEntity(
      itemId: id,
      targetAudienceId: audienceId,
      itemCat: cat,
      itemNameAr: fallbackName(itemName, itemNameEn),
      itemNameEn: fallbackName(itemNameEn, itemName),
      itemPrice: price,
      itemDescriptionAr: itemDescription ?? "",
      itemDescriptionEn: itemDescriptionEn ?? "",
      itemDiscount: itemDiscount,
      itemStock: itemStock ?? 0,
      itemActive: active,
      itemDatetime: dateTime,
      itemImages: images,
      variants:
          variants?.map((v) => v.toEntity()).toList() ?? <VariantEntity>[],
      favId: favId,
    );
  }
}

extension VariantMapper on VariantModel {
  VariantEntity toEntity() {
    final id = switch (variantId) {
      final value? when value > 0 => value,
      _ => throw MappingException("Variant ID is null"),
    };

    final bool active = switch (variantActive) {
      1 => true,
      0 => false,
      _ => false,
    };

    final hex = colorHex != null && colorHex!.isNotEmpty ? colorHex! : "";

    // variantPrice/variantDiscount may be null (admin didn't set them → backend resolved via effectivePrice/effectiveDiscount)
    // Validate raw price only when present
    if (variantPrice != null && variantPrice! < 0) {
      throw MappingException("Variant Price is invalid: $variantPrice");
    }

    List<String> images = [];
    for (final String image in variantImages ?? <String>[]) {
      if (image.trim().isNotEmpty && image.length >= 4) {
        images.add("${ApiConfig.images}/$image");
      }
    }
    if (images.isEmpty) {
      images = [ApiConfig.placeholder];
    }

    String fallbackSizeName(String? primary, String? fallback) {
      if (primary != null && primary.trim().isNotEmpty) {
        return primary;
      }

      if (fallback != null && fallback.trim().isNotEmpty) {
        return fallback;
      }

      return "";
    }

    return VariantEntity(
      variantDescriptionAr: variantDescription ?? "",
      variantDescriptionEn: variantDescriptionEn ?? "",
      variantId: id,
      colorGroupId: colorGroupId,
      variantPrice: variantPrice,
      variantDiscount: variantDiscount,
      effectivePrice: effectivePrice,
      effectiveDiscount: effectiveDiscount,
      finalPrice: finalPrice,
      variantColor: variantColor ?? "",
      variantColorEn: variantColorEn ?? "",
      colorHex: hex,
      colorDescriptionAr: colorDescriptionAr ?? "",
      colorDescriptionEn: colorDescriptionEn ?? "",
      variantSize: fallbackSizeName(variantSize, variantSizeEn),
      variantSizeEn: fallbackSizeName(variantSizeEn, variantSize),
      variantStock: variantStock ?? 0,
      variantImages: images,

      variantActive: active,
    );
  }
}
