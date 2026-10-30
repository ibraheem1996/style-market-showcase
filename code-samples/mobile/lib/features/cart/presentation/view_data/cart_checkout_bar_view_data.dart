import '../logic/cart_line_rules.dart';

class CartCheckoutBarViewData {
  const CartCheckoutBarViewData({
    required this.isVisible,
    required this.subTotal,
    required this.selectedCount,
    required this.totalSavings,
    required this.canCheckout,
    required this.shouldShowBlockedMessage,
    this.blockReason,
    this.blockedMessage,
  });

  final bool isVisible;
  final double subTotal;
  final int selectedCount;
  final double totalSavings;
  final bool canCheckout;
  final bool shouldShowBlockedMessage;
  final CartCheckoutBlockReason? blockReason;
  final String? blockedMessage;

  bool get canPressCheckout {
    return isVisible && blockReason != CartCheckoutBlockReason.pendingChanges;
  }

  String? get visibleBlockedMessage {
    if (!shouldShowBlockedMessage) return null;
    if (blockReason == CartCheckoutBlockReason.pendingChanges) return null;
    return blockedMessage;
  }
}
