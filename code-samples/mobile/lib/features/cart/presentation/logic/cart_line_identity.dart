import '../../domain/entities/cart_item_entity.dart';
import '../../domain/entities/cart_upsert_input.dart';

/// Stable client-side identity for one cart line.
class CartLineIdentity {
  const CartLineIdentity({required this.itemId, required this.variantId});
  final int itemId;
  final int? variantId;

  factory CartLineIdentity.fromItem(CartItemEntity item) {
    return CartLineIdentity(itemId: item.itemId, variantId: item.variantId);
  }

  factory CartLineIdentity.fromInput(CartUpsertInput input) {
    return CartLineIdentity(itemId: input.itemId, variantId: input.variantId);
  }

  String get operationKey => '$itemId:${variantId?.toString() ?? 'simple'}';

  bool matches(CartItemEntity item) {
    return item.itemId == itemId && (item.variantId == variantId);
  }

  @override
  bool operator ==(Object other) {
    return other is CartLineIdentity &&
        other.itemId == itemId &&
        other.variantId == variantId;
  }

  @override
  int get hashCode => Object.hash(itemId, variantId);

  @override
  String toString() => operationKey;
}
