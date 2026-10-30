import '../../../../core/errors/mapping_exception.dart';
import '../../../../core/media/image_url_normalizer.dart';
import '../../domain/entities/favorite_entity.dart';
import '../models/favorite_model.dart';

extension FavoriteModelMapper on FavoriteModel {
  FavoriteEntity toEntity() {
    final fId = favId != null && favId != 0
        ? favId!
        : throw MappingException('favorite id is null or 0');

    final iId = itemId != null && itemId != 0
        ? itemId!
        : throw MappingException('item id is null or 0');

    final resolvedTargetType = switch (targetType) {
      'item' => FavoriteTargetType.item,
      'variant' => FavoriteTargetType.variant,
      _ => throw MappingException('invalid target type $targetType'),
    };

    final varId = switch (variantId) {
      null => null,
      0 || < 0 => throw MappingException('variant id is invalid $variantId'),
      _ => variantId,
    };

    if (resolvedTargetType == FavoriteTargetType.variant && varId == null) {
      throw MappingException('variant favorite is missing variant id');
    }

    final nameAr = _fallbackText(itemNameAr, itemNameEn, 'item name');
    final nameEn = _fallbackText(itemNameEn, itemNameAr, 'item name en');
    final price = displayPrice != null && displayPrice! >= 0
        ? displayPrice!
        : throw MappingException('display price is null or invalid');
    final original = originalPrice != null && originalPrice! >= 0
        ? originalPrice!
        : price;
    final discountValue = discount != null && discount! >= 0
        ? discount!
        : _discountPercent(original: original, display: price);

    final createdValue = createdAt?.trim() ?? '';
    if (createdValue.isEmpty) {
      throw const MappingException('created at is null or empty');
    }
    final created = DateTime.tryParse(createdValue);
    if (created == null) {
      throw MappingException('created at is invalid: $createdValue');
    }

    return FavoriteEntity(
      favId: fId,
      itemId: iId,
      variantId: varId,
      targetType: resolvedTargetType,
      itemNameAr: nameAr,
      itemNameEn: nameEn,
      itemDescriptionAr: itemDescriptionAr?.trim() ?? '',
      itemDescriptionEn: itemDescriptionEn?.trim() ?? '',
      displayImage: _imageUrl(displayImage),
      images: _imageUrls(images),
      displayPrice: price,
      originalPrice: original,
      discount: discountValue,
      stockQuantity: stockQuantity ?? 0,
      isAvailable: _boolFlag(isAvailable),
      status: _statusFrom(status),
      selectedAttributes: (selectedAttributes ?? [])
          .map((attribute) => attribute.toEntity())
          .toList(),
      priceAlert: priceAlert?.toEntity(),
      createdAt: created,
    );
  }
}

extension SelectedAttributeModelMapper on SelectedAttributeModel {
  SelectedAttributeEntity toEntity() {
    return SelectedAttributeEntity(
      attributeTypeId: attributeTypeId,
      attributeTypeKey: attributeTypeKey ?? '',
      attributeTypeNameAr: attributeTypeNameAr ?? '',
      attributeTypeNameEn: attributeTypeNameEn ?? attributeTypeNameAr ?? '',
      valueId: valueId,
      valueNameAr: valueNameAr ?? '',
      valueNameEn: valueNameEn ?? valueNameAr ?? '',
      valueHex: valueHex,
    );
  }
}

extension PriceAlertModelMapper on PriceAlertModel {
  PriceAlertEntity toEntity() {
    return PriceAlertEntity(
      type: type ?? '',
      oldPrice: oldPrice,
      newPrice: newPrice,
      amount: amount,
      percent: percent,
    );
  }
}

String _fallbackText(String? primary, String? fallback, String fieldName) {
  if (primary != null && primary.trim().isNotEmpty) return primary.trim();
  if (fallback != null && fallback.trim().isNotEmpty) return fallback.trim();
  throw MappingException('$fieldName is null or empty');
}

String _imageUrl(String? value) {
  return normalizeProductImageUrl(value ?? '');
}

List<String> _imageUrls(List<String>? values) {
  final out = <String>[];
  for (final value in values ?? const <String>[]) {
    if (value.trim().isNotEmpty) {
      out.add(normalizeProductImageUrl(value));
    }
  }
  return out;
}

double _discountPercent({required double original, required double display}) {
  if (original <= 0 || display >= original) return 0;
  return ((original - display) / original) * 100;
}

bool _boolFlag(Object? value) {
  return switch (value) {
    true => true,
    false => false,
    1 => true,
    0 => false,
    '1' => true,
    '0' => false,
    'true' => true,
    'false' => false,
    null => false,
    _ => false,
  };
}

FavoriteStatus _statusFrom(String? value) {
  return switch (value) {
    'OK' => FavoriteStatus.ok,
    'ITEM_INACTIVE' => FavoriteStatus.itemInactive,
    'VARIANT_INACTIVE' => FavoriteStatus.variantInactive,
    'OUT_OF_STOCK' => FavoriteStatus.outOfStock,
    'INVALID_VARIANT' => FavoriteStatus.invalidVariant,
    _ => throw MappingException('invalid favorite status $value'),
  };
}
