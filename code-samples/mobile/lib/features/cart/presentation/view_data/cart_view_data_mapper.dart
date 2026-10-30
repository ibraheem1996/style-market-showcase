import 'package:get/get.dart';

import '../../../../core/translations/locale_keys.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../logic/cart_line_identity.dart';
import '../logic/cart_line_rules.dart';
import '../logic/cart_pricing.dart';
import 'cart_checkout_bar_view_data.dart';
import 'cart_line_view_data.dart';

class CartViewDataMapper {
  const CartViewDataMapper._();

  static CartLineViewData line({
    required CartItemEntity item,
    required bool isArabic,
    required bool isLineMutating,
    required bool isSelectionMutating,
  }) {
    final maxQuantity = (item.stock ?? 1).clamp(1, 1 << 30);
    final displayColor = _localizedAttribute(
      isArabic: isArabic,
      arabic: item.variantColor,
      english: item.variantColorEn,
    );
    final displaySize = _localizedAttribute(
      isArabic: isArabic,
      arabic: item.variantSize,
      english: item.variantSizeEn,
    );
    final displayName = _localizedAttribute(
      isArabic: isArabic,
      arabic: item.itemName,
      english: item.itemNameEn,
    );
    final itemDescription = _localizedAttribute(
      isArabic: isArabic,
      arabic: item.itemDescription,
      english: item.itemDescriptionEn,
    );
    final variantDescription = _localizedAttribute(
      isArabic: isArabic,
      arabic: item.variantDescription,
      english: item.variantDescriptionEn,
    );
    final variantAttributes = <String>[
      if (displayColor.isNotEmpty) displayColor,
      if (displaySize.isNotEmpty) displaySize,
    ];

    return CartLineViewData(
      identity: CartLineIdentity.fromItem(item),
      cartId: item.cartId,
      name: displayName,
      imageUrl: item.image,
      images: item.images,
      itemDescription: itemDescription,
      variantDescription: variantDescription,
      variantAttributes: List.unmodifiable(variantAttributes),
      hasVariant: item.variantId != null,
      isSelected: item.isSelected,
      quantity: item.cartQuantity,
      maxQuantity: maxQuantity,
      price: item.price,
      discount: item.discount,
      lineTotal: item.cartFinalLineTotal,
      lineSavings: item.cartLineSavings,
      isLineMutating: isLineMutating,
      isSelectionMutating: isSelectionMutating,
      needsVariantSelection: item.needsVariantSelection,
      isUnavailable: item.isUnavailable,
      canTap: item.canOpenDetails(isLinePending: isLineMutating),
      canSelect: item.canSelect(
        isLinePending: isLineMutating,
        isSelectionPending: isSelectionMutating,
      ),
      canIncrease: item.canIncrease(isLinePending: isLineMutating),
      canDecrease: item.canDecrease(isLinePending: isLineMutating),
      canDelete: !isLineMutating,
      canSelectVariant: item.needsVariantSelection && !isLineMutating,
    );
  }

  static String _localizedAttribute({
    required bool isArabic,
    required String arabic,
    required String? english,
  }) {
    final preferred = (isArabic ? arabic : english ?? '').trim();
    if (preferred.isNotEmpty) return preferred;
    return (isArabic ? english ?? '' : arabic).trim();
  }

  static CartCheckoutBarViewData checkoutBar({
    required Iterable<CartItemEntity> items,
    required bool hasPendingCheckoutOperation,
    required bool shouldShowBlockedMessage,
  }) {
    final selected = items.where((item) => item.isSelected).toList();
    final blockReason = selectedCartCheckoutBlockReason(
      items,
      hasPendingSelectedOperation: hasPendingCheckoutOperation,
    );

    return CartCheckoutBarViewData(
      isVisible: selected.isNotEmpty,
      subTotal: selectedCartSubtotal(selected),
      selectedCount: selected.length,
      totalSavings: selectedCartSavings(selected),
      canCheckout: blockReason == null,
      shouldShowBlockedMessage: shouldShowBlockedMessage,
      blockReason: blockReason,
      blockedMessage: _messageForBlockReason(blockReason),
    );
  }

  static String? _messageForBlockReason(CartCheckoutBlockReason? reason) {
    return switch (reason) {
      CartCheckoutBlockReason.needsReview =>
        LocaleKeys.cartCheckoutBlockedNeedsVariant.tr,
      CartCheckoutBlockReason.pendingChanges =>
        LocaleKeys.cartPendingChanges.tr,
      CartCheckoutBlockReason.stockChanged => LocaleKeys.cartStockChanged.tr,
      CartCheckoutBlockReason.empty || null => null,
    };
  }
}
