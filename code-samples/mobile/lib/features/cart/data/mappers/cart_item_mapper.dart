// Project imports:
import '../../../../core/errors/mapping_exception.dart';
import '../../../../core/network/api_response.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../models/cart_item_model.dart';

extension CartItemMapper on CartItemModel {
  CartItemEntity toEntity() {
    final idCart = cartId != null && cartId != 0
        ? cartId!
        : throw MappingException('Cart ID is null or 0  ');

    final idUser = userId != null && userId != 0
        ? userId!
        : throw MappingException('User ID is null or 0  ');

    final idItem = itemId != null && itemId != 0
        ? itemId!
        : throw MappingException('Item ID is null or 0');

    final quantity = cartQuantity != null && cartQuantity! > 0
        ? cartQuantity!
        : throw MappingException('Cart Quantity is null or <0');

    final added = (() {
      if (addedAt != null && addedAt!.isNotEmpty) {
        try {
          return DateTime.parse(addedAt!);
        } catch (e) {
          throw MappingException(
            'Added At is null or empty or invalid format  ',
          );
        }
      }
      return DateTime.now();
    })();

    final nameAr = _requiredLocalizedText(itemName, itemNameEn, 'item name');
    final nameEn = _requiredLocalizedText(itemNameEn, itemName, 'item name en');
    final finalUnitPrice = price != null && price! > -1
        ? price!
        : throw MappingException('Price is null or 0  ');
    final baseUnitPrice = basePrice != null && basePrice! > -1
        ? basePrice!
        : finalUnitPrice;
    final lineTotalPrice = lineTotal != null && lineTotal! > -1
        ? lineTotal!
        : throw MappingException('Line Total is null or 0  ');
    final needsVariant =
        (requiresVariantSelection ?? false) == true ||
        status == 'NEEDS_VARIANT';

    final bool isSelect = (() {
      if (isSelected != null) {
        if (isAvailable == 0) return false;
        if (isSelected == 1) return true;
        if (isSelected == 0) return false;
      }
      throw MappingException('Is Selected is null or not 1 or 0  ');
    })();
    return CartItemEntity(
      isSelected: isSelect,
      cartId: idCart,
      userId: idUser,
      itemId: idItem,
      variantId: variantId,
      cartQuantity: quantity,
      addedAt: added,
      itemName: nameAr,
      itemNameEn: nameEn,
      itemDescription: itemDescription ?? itemDescriptionEn ?? "",
      itemDescriptionEn: itemDescriptionEn ?? itemDescription ?? "",
      price: baseUnitPrice,
      discount: discount ?? 0,
      stock: stock ?? 0,
      image: displayImage ?? "",
      images: images ?? [],
      variantColor: variantColor ?? "",
      variantColorEn: variantColorEn,
      colorHex: colorHex,
      variantSize: variantSize ?? "",
      variantSizeEn: variantSizeEn,
      variantDescription: variantDescription ?? variantDescriptionEn ?? "",
      variantDescriptionEn: variantDescriptionEn ?? variantDescription ?? "",
      lineTotal: lineTotalPrice,
      isAvailable: isAvailable == 1,
      status: needsVariant ? 'NEEDS_VARIANT' : 'OK',
    );
  }
}

String _requiredLocalizedText(
  String? preferred,
  String? fallback,
  String fieldName,
) {
  final preferredValue = preferred?.trim();
  if (preferredValue != null && preferredValue.isNotEmpty) {
    return preferredValue;
  }
  final fallbackValue = fallback?.trim();
  if (fallbackValue != null && fallbackValue.isNotEmpty) {
    return fallbackValue;
  }
  throw MappingException('$fieldName is null or empty');
}

extension CartActionMapper on ApiResponse<dynamic> {
  CartAction toCartAction() {
    return switch (action) {
      "added" => CartAction.added,
      "updated" => CartAction.updated,
      "removed" => CartAction.removed,
      _ => throw MappingException('Invalid action: $action'),
    };
  }
}
