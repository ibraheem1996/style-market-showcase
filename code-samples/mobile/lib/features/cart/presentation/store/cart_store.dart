import 'package:get/get.dart';

import '../../domain/entities/cart_item_entity.dart';
import '../logic/cart_line_identity.dart';

class CartStore extends GetxService {
  final RxList<CartItemEntity> _items = <CartItemEntity>[].obs;

  List<CartItemEntity> get items {
    return List<CartItemEntity>.unmodifiable(_items);
  }

  int get length => _items.length;

  CartItemEntity itemAt(int index) => _items[index];

  List<CartItemEntity> get selectedItems {
    return _items.where((item) => item.isSelected).toList(growable: false);
  }

  CartItemEntity? find(CartLineIdentity identity) {
    return _items.firstWhereOrNull(identity.matches);
  }

  CartItemEntity? findLine(int itemId, int? variantId) {
    return find(CartLineIdentity(itemId: itemId, variantId: variantId));
  }

  int getCartQuantity(int? itemId, int? variantId) {
    if (itemId == null) return 0;
    return findLine(itemId, variantId)?.cartQuantity ?? 0;
  }

  int indexOfCartId(int cartId) {
    if (cartId == 0) return -1;
    return _items.indexWhere((item) => item.cartId == cartId);
  }

  int indexOfLine(CartLineIdentity identity) {
    return _items.indexWhere(identity.matches);
  }

  void replaceItems(List<CartItemEntity> newItems) {
    _items.assignAll(newItems);
  }

  void replaceAt(int index, CartItemEntity item) {
    if (index < 0 || index >= _items.length) return;
    _items[index] = item;
  }

  void insertAt(int index, CartItemEntity item) {
    final boundedIndex = index.clamp(0, _items.length).toInt();
    _items.insert(boundedIndex, item);
  }

  void removeAt(int index) {
    if (index < 0 || index >= _items.length) return;
    _items.removeAt(index);
  }

  void setSelectionAt(int index, bool isSelected) {
    if (index < 0 || index >= _items.length) return;
    _items[index] = _items[index].copyWith(isSelected: isSelected);
  }

  void clearLocal() {
    _items.clear();
  }
}
