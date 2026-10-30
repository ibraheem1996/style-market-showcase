import '../../domain/entities/cart_item_entity.dart';
import 'cart_pricing.dart';

enum CartCheckoutBlockReason {
  empty,
  pendingChanges,
  needsReview,
  stockChanged,
}

extension CartLineRules on CartItemEntity {
  bool get needsVariantSelection => status == 'NEEDS_VARIANT';

  bool get isUnavailable => !isAvailable;

  bool canOpenDetails({required bool isLinePending}) {
    return isAvailable && !needsVariantSelection && !isLinePending;
  }

  bool canSelect({
    required bool isLinePending,
    required bool isSelectionPending,
  }) {
    return isAvailable &&
        !needsVariantSelection &&
        !isLinePending &&
        !isSelectionPending;
  }

  bool canEditQuantity({bool? isLinePending}) {
    return isAvailable && !needsVariantSelection && !(isLinePending ?? false);
  }

  // bool canDelete({required bool isLinePending}) => !isLinePending;`

  bool canIncrease({bool? isLinePending}) {
    final stockLimit = stock;
    if (!canEditQuantity()) return false;
    if (stockLimit == null || stockLimit < 0) return true;
    return cartQuantity < stockLimit;
  }

  bool canDecrease({bool? isLinePending}) {
    return canEditQuantity() && cartQuantity > 1;
  }

  bool get hasValidCheckoutQuantity => cartQuantity > 0;

  bool get exceedsAvailableStock {
    final stockLimit = stock;
    return stockLimit != null && stockLimit >= 0 && cartQuantity > stockLimit;
  }
}

CartCheckoutBlockReason? selectedCartCheckoutBlockReason(
  Iterable<CartItemEntity> items, {
  required bool hasPendingSelectedOperation,
}) {
  final selected = items.where((item) => item.isSelected).toList();
  if (selected.isEmpty || selectedCartSubtotal(selected) <= 0) {
    return CartCheckoutBlockReason.empty;
  }

  if (hasPendingSelectedOperation) {
    return CartCheckoutBlockReason.pendingChanges;
  }

  for (final item in selected) {
    if (item.needsVariantSelection ||
        item.isUnavailable ||
        !item.hasValidCheckoutQuantity) {
      return CartCheckoutBlockReason.needsReview;
    }

    if (item.exceedsAvailableStock) {
      return CartCheckoutBlockReason.stockChanged;
    }
  }

  return null;
}
