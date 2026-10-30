import '../../domain/entities/cart_item_entity.dart';

extension CartPricing on CartItemEntity {
  double get cartOriginalLineTotal {
    final quantity = cartQuantity.clamp(0, 1 << 30);
    final unitPrice = price.clamp(0.0, double.infinity);
    return unitPrice * quantity;
  }

  double get cartFinalLineTotal => lineTotal.clamp(0.0, double.infinity);

  double get cartLineSavings {
    final savings = cartOriginalLineTotal - cartFinalLineTotal;
    return savings > 0 ? savings : 0.0;
  }

  /// Backend-approved unit price derived from the final line total.
  ///
  /// Checkout must not divide by zero or submit the display/base price when the
  /// backend has already returned a discounted line total.
  double get cartFinalUnitPrice {
    if (cartQuantity <= 0) return 0.0;
    return cartFinalLineTotal / cartQuantity;
  }
}

double selectedCartSubtotal(Iterable<CartItemEntity> items) {
  return items
      .where((item) => item.isSelected)
      .fold(0.0, (sum, item) => sum + item.cartFinalLineTotal);
}

double selectedCartSavings(Iterable<CartItemEntity> items) {
  return items
      .where((item) => item.isSelected)
      .fold(0.0, (sum, item) => sum + item.cartLineSavings);
}
