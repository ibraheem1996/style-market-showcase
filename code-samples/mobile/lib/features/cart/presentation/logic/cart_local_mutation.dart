import '../../../../core/config/api_config.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../../domain/entities/cart_upsert_input.dart';
import '../store/cart_store.dart';
import 'cart_line_identity.dart';

class CartLineSnapshot {
  const CartLineSnapshot({
    required this.identity,
    required this.index,
    required this.item,
  });

  final CartLineIdentity identity;
  final int index;
  final CartItemEntity? item;
}

class CartSelectionSnapshot {
  const CartSelectionSnapshot({
    required this.cartId,
    required this.index,
    required this.isSelected,
  });

  final int cartId;
  final int index;
  final bool? isSelected;
}

class CartLocalMutation {
  const CartLocalMutation._();

  static CartLineSnapshot snapshotLine(
    List<CartItemEntity> items,
    CartLineIdentity identity,
  ) {
    final index = items.indexWhere((item) => identity.matches(item));
    return CartLineSnapshot(
      identity: identity,
      index: index,
      item: index == -1 ? null : items[index],
    );
  }

  static void restoreLine(CartStore store, CartLineSnapshot snapshot) {
    final currentIndex = store.indexOfLine(snapshot.identity);

    if (snapshot.item == null) {
      if (currentIndex != -1) {
        store.removeAt(currentIndex);
      }
      return;
    }

    if (currentIndex != -1) {
      store.removeAt(currentIndex);
    }

    store.insertAt(snapshot.index, snapshot.item!);
  }

  static CartSelectionSnapshot snapshotSelection(
    List<CartItemEntity> items,
    int cartId,
  ) {
    final index = items.indexWhere((item) => item.cartId == cartId);
    return CartSelectionSnapshot(
      cartId: cartId,
      index: index,
      isSelected: index == -1 ? null : items[index].isSelected,
    );
  }

  static void restoreSelection(
    CartStore store,
    CartSelectionSnapshot snapshot,
  ) {
    if (snapshot.isSelected == null) return;
    final index = store.indexOfCartId(snapshot.cartId);
    store.setSelectionAt(index, snapshot.isSelected!);
  }

  static void applyInputDelta(
    CartStore store, {
    required CartUpsertInput input,
    required int quantityDelta,
  }) {
    final identity = CartLineIdentity.fromInput(input);
    final currentIndex = store.indexOfLine(identity);
    if (currentIndex == -1 && quantityDelta <= 0) return;

    if (currentIndex == -1) {
      store.insertAt(
        store.length,
        _newOptimisticLine(input, quantityDelta, identity),
      );
      return;
    }

    final current = store.itemAt(currentIndex);
    final newQuantity = current.cartQuantity + quantityDelta;
    if (newQuantity <= 0) {
      store.removeAt(currentIndex);
      return;
    }

    final price = input.price.clamp(0.0, double.infinity);
    final discount = input.discount.clamp(0.0, 100.0);
    final unitAfterDiscount = price * (100.0 - discount) / 100.0;
    store.replaceAt(
      currentIndex,
      current.copyWith(
        cartQuantity: newQuantity,
        price: price,
        discount: discount,
        lineTotal: unitAfterDiscount * newQuantity,
      ),
    );
  }

  static void applyCartLineDelta(
    CartStore store, {
    required CartItemEntity item,
    required int quantityDelta,
  }) {
    final identity = CartLineIdentity.fromItem(item);
    final currentIndex = _indexForLine(store, identity, cartId: item.cartId);
    if (currentIndex == -1) return;
    final current = store.itemAt(currentIndex);

    if (quantityDelta == 0) {
      store.removeAt(currentIndex);
      return;
    }

    final newQuantity = current.cartQuantity + quantityDelta;
    if (newQuantity <= 0) {
      store.removeAt(currentIndex);
      return;
    }

    final price = current.price.clamp(0.0, double.infinity);
    final discount = current.discount.clamp(0.0, 100.0);
    final unitAfterDiscount = price * (100.0 - discount) / 100.0;
    store.replaceAt(
      currentIndex,
      current.copyWith(
        cartQuantity: newQuantity,
        lineTotal: unitAfterDiscount * newQuantity,
      ),
    );
  }

  static void applyServerResult(
    CartStore store, {
    required CartLineIdentity identity,
    required CartAction action,
    CartItemEntity? item,
  }) {
    if (action == CartAction.removed) {
      final index = _indexForLine(store, identity, cartId: item?.cartId);
      if (index != -1) {
        store.removeAt(index);
      }
      return;
    }
    if (item != null) {
      _upsertServerLine(store, identity: identity, item: item);
    }
  }

  static void removePurchasedLocal(
    CartStore store,
    List<CartItemEntity> purchasedItems,
  ) {
    for (final item in purchasedItems) {
      final index = _indexForLine(
        store,
        CartLineIdentity.fromItem(item),
        cartId: item.cartId,
      );
      if (index != -1) {
        store.removeAt(index);
      }
    }
  }

  static CartItemEntity _newOptimisticLine(
    CartUpsertInput input,
    int quantityDelta,
    CartLineIdentity identity,
  ) {
    final price = input.price.clamp(0.0, double.infinity);
    final discount = input.discount.clamp(0.0, 100.0);
    final unitAfterDiscount = price * (100.0 - discount) / 100.0;

    return CartItemEntity.local(
      itemId: input.itemId,
      variantId: identity.variantId,
      stock: input.stock ?? 0,
      price: price,
      discount: discount,
      itemName: input.itemName,
      itemNameEn: input.itemNameEn,
      itemDescription: input.itemDescription,
      itemDescriptionEn: input.itemDescriptionEn,
      image: _resolveInputImage(input),
      images: input.images,
      variantDescription: input.variantDescription,
      variantDescriptionEn: input.variantDescriptionEn,
      variantSize: input.variantSize,
      variantSizeEn: input.variantSizeEn,
      variantColor: input.variantColor,
      variantColorEn: input.variantColorEn,
      colorHex: input.colorHex,
      isAvailable: input.isAvailable,
      cartQuantity: quantityDelta,
      lineTotal: unitAfterDiscount * quantityDelta,
    );
  }
}

int _indexForLine(CartStore store, CartLineIdentity identity, {int? cartId}) {
  final cartIndex = cartId == null ? -1 : store.indexOfCartId(cartId);
  if (cartIndex != -1) return cartIndex;
  return store.indexOfLine(identity);
}

void _upsertServerLine(
  CartStore store, {
  required CartLineIdentity identity,
  required CartItemEntity item,
}) {
  final cartIndex = store.indexOfCartId(item.cartId);
  if (cartIndex != -1) {
    store.replaceAt(cartIndex, item);
    return;
  }

  final optimisticIndex = store.indexOfLine(identity);
  if (optimisticIndex != -1) {
    store.replaceAt(optimisticIndex, item);
    return;
  }

  final serverIdentityIndex = store.indexOfLine(
    CartLineIdentity.fromItem(item),
  );
  if (serverIdentityIndex != -1) {
    store.replaceAt(serverIdentityIndex, item);
    return;
  }

  store.insertAt(store.length, item);
}

String _resolveInputImage(CartUpsertInput input) {
  final directImage = _normalizedImageUrl(input.image);
  if (directImage.isNotEmpty) return directImage;

  for (final image in input.images) {
    final normalized = _normalizedImageUrl(image);
    if (normalized.isNotEmpty) return normalized;
  }

  return ApiConfig.placeholder;
}

String _normalizedImageUrl(String image) {
  final value = image.trim();
  if (value.isEmpty) return '';

  if (value.startsWith('http://') || value.startsWith('https://')) {
    return value;
  }

  final path = value.replaceFirst(RegExp(r'^/+'), '');
  return '${ApiConfig.images}/$path';
}
