import '../logic/cart_line_identity.dart';

class CartLineViewData {
  const CartLineViewData({
    required this.identity,
    required this.cartId,
    required this.name,
    required this.imageUrl,
    required this.images,
    required this.itemDescription,
    required this.variantDescription,
    required this.variantAttributes,
    required this.hasVariant,
    required this.isSelected,
    required this.quantity,
    required this.maxQuantity,
    required this.price,
    required this.discount,
    required this.lineTotal,
    required this.lineSavings,
    required this.isLineMutating,
    required this.isSelectionMutating,
    required this.needsVariantSelection,
    required this.isUnavailable,
    required this.canTap,
    required this.canSelect,
    required this.canIncrease,
    required this.canDecrease,
    required this.canDelete,
    required this.canSelectVariant,
  });

  final CartLineIdentity identity;
  final int cartId;
  final String name;
  final String imageUrl;
  final List<String> images;
  final String itemDescription;
  final String variantDescription;
  final List<String> variantAttributes;
  final bool hasVariant;
  final bool isSelected;
  final int quantity;
  final int maxQuantity;
  final double price;
  final double discount;
  final double lineTotal;
  final double lineSavings;
  final bool isLineMutating;
  final bool isSelectionMutating;
  final bool needsVariantSelection;
  final bool isUnavailable;
  final bool canTap;
  final bool canSelect;
  final bool canIncrease;
  final bool canDecrease;
  final bool canDelete;
  final bool canSelectVariant;
}
