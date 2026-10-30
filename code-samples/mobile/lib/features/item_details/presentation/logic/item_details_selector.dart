import 'package:get/get.dart';

import '../../../../core/config/api_config.dart';
import '../../../../core/media/image_url_normalizer.dart';
import '../../../products/domain/entities/item_entity.dart';

/// Selects the route-requested variant when available, otherwise the first
/// in-stock active variant. If all active variants are out of stock, the first
/// active variant remains selected so the page can show the unavailable state.
VariantEntity? defaultVariant(ItemEntity item, int? variantId) {
  final variants = item.variants;
  if (variantId != null) {
    final requested = variants.firstWhereOrNull(
      (variant) => variant.variantId == variantId,
    );
    if (requested != null) return requested;
  }
  return variants.firstWhereOrNull((variant) => variant.variantStock > 0) ??
      variants.firstOrNull;
}

List<String> resolveImages({required ItemEntity item, VariantEntity? variant}) {
  final variantImages = _usableImages(variant?.variantImages ?? const []);
  if (variantImages.isNotEmpty) {
    return variantImages.map(normalizeProductImageUrl).toList();
  }

  final itemImages = _usableImages(item.itemImages);
  if (itemImages.isNotEmpty) {
    return itemImages.map(normalizeProductImageUrl).toList();
  }

  return [ApiConfig.placeholder];
}

double resolvePrice({required ItemEntity item, VariantEntity? variant}) {
  return resolvePriceData(item: item, variant: variant).displayPrice;
}

ItemDetailsPriceData resolvePriceData({
  required ItemEntity item,
  VariantEntity? variant,
}) {
  if (variant != null) {
    final originalPrice =
        variant.effectivePrice ?? variant.variantPrice ?? item.itemPrice;
    final discount =
        variant.effectiveDiscount ??
        variant.variantDiscount ??
        item.itemDiscount ??
        0.0;
    final finalPrice =
        variant.finalPrice ?? _priceAfterDiscount(originalPrice, discount);
    return ItemDetailsPriceData(
      originalPrice: originalPrice,
      discountPercent: discount,
      finalPrice: finalPrice,
    );
  }
  final discount = item.itemDiscount ?? 0.0;
  return ItemDetailsPriceData(
    originalPrice: item.itemPrice,
    discountPercent: discount,
    finalPrice: _priceAfterDiscount(item.itemPrice, discount),
  );
}

double resolveDiscount({required ItemEntity item, VariantEntity? variant}) {
  return resolvePriceData(item: item, variant: variant).discountPercent;
}

int resolveAvailableStock({
  required ItemEntity item,
  VariantEntity? variant,
  required int cartQuantity,
}) {
  final effectiveStock = item.variants.isNotEmpty
      ? (variant?.variantStock ?? 0)
      : item.itemStock;
  return (effectiveStock - cartQuantity).clamp(0, 1 << 30);
}

int clampItemDetailsQuantity(int quantity, int availableStock) {
  if (availableStock <= 0) return 0;
  return quantity.clamp(1, availableStock.clamp(1, 50));
}

List<ItemDetailsDescriptionSection> resolveDescriptionSections({
  required String itemDescription,
  required String variantDescription,
}) {
  final itemText = itemDescription.trim();
  final variantText = variantDescription.trim();

  return [
    if (itemText.isNotEmpty)
      ItemDetailsDescriptionSection(
        type: ItemDetailsDescriptionType.product,
        text: itemText,
      ),
    if (variantText.isNotEmpty && !_sameDescription(itemText, variantText))
      ItemDetailsDescriptionSection(
        type: ItemDetailsDescriptionType.selectedVariant,
        text: variantText,
      ),
  ];
}

List<VariantEntity> uniqueColors(List<VariantEntity> variants) {
  final seen = <String>{};
  final out = <VariantEntity>[];

  for (final v in variants) {
    final key = v.colorHex;

    if (key.isEmpty) continue;
    if (seen.contains(key)) continue;

    seen.add(key);
    out.add(v);
  }

  return out;
}

bool variantsHaveColors(List<VariantEntity> variants) {
  return variants.any((variant) => variant.colorHex.trim().isNotEmpty);
}

bool variantsHaveSizes(List<VariantEntity> variants) {
  return variants.any((variant) => variant.variantSize.trim().isNotEmpty);
}

bool isColorAvailable(List<VariantEntity> variants, String colorCode) {
  final normalized = colorCode.trim().toLowerCase();
  return variants.any(
    (variant) =>
        variant.colorHex.trim().toLowerCase() == normalized &&
        variant.variantStock > 0,
  );
}

VariantEntity? variantForColor(List<VariantEntity> variants, String colorCode) {
  final normalized = colorCode.trim().toLowerCase();
  if (normalized.isEmpty) return null;
  final matches = variants
      .where((variant) => variant.colorHex.trim().toLowerCase() == normalized)
      .toList();
  return matches.firstWhereOrNull((variant) => variant.variantStock > 0) ??
      matches.firstOrNull;
}

VariantEntity? variantForSize(
  List<VariantEntity> variants, {
  required String colorCode,
  required String sizeLabel,
}) {
  final normalizedColor = colorCode.trim().toLowerCase();
  final normalizedSize = sizeLabel.trim().toLowerCase();
  if (normalizedSize.isEmpty) return null;
  final matches = variants.where((variant) {
    final variantColor = variant.colorHex.trim().toLowerCase();
    final variantSize = variant.variantSize.trim().toLowerCase();
    return variantSize == normalizedSize &&
        (normalizedColor.isEmpty || variantColor == normalizedColor);
  }).toList();
  return matches.firstWhereOrNull((variant) => variant.variantStock > 0) ??
      matches.firstOrNull;
}

List<VariantEntity> sizesForColor(
  List<VariantEntity> variants,
  String colorCode,
) {
  final key = (colorCode.trim().toLowerCase());
  return variants
      .where(
        (variant) =>
            variant.variantSize.trim().isNotEmpty &&
            (key.isEmpty || variant.colorHex.trim().toLowerCase() == key),
      )
      .toList();
}

List<String> _usableImages(List<String> images) {
  return images.where(isUsableProductImageUrl).toList();
}

double _priceAfterDiscount(double price, double discount) {
  final normalizedPrice = price.clamp(0.0, double.infinity);
  final normalizedDiscount = discount.clamp(0.0, 100.0);
  return normalizedPrice * (100.0 - normalizedDiscount) / 100.0;
}

bool _sameDescription(String left, String right) {
  if (left.trim().isEmpty || right.trim().isEmpty) return false;
  return _normalizeDescription(left) == _normalizeDescription(right);
}

String _normalizeDescription(String value) {
  return value.trim().replaceAll(RegExp(r'\s+'), ' ').toLowerCase();
}

class ItemDetailsPriceData {
  const ItemDetailsPriceData({
    required this.originalPrice,
    required this.discountPercent,
    required this.finalPrice,
  });

  final double originalPrice;
  final double discountPercent;
  final double finalPrice;

  bool get hasDiscount =>
      discountPercent > 0 && originalPrice > 0 && finalPrice < originalPrice;

  double get displayPrice => hasDiscount ? finalPrice : originalPrice;
}

enum ItemDetailsDescriptionType { product, selectedVariant }

class ItemDetailsDescriptionSection {
  const ItemDetailsDescriptionSection({required this.type, required this.text});

  final ItemDetailsDescriptionType type;
  final String text;
}
