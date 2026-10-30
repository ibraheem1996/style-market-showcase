import 'package:flutter_test/flutter_test.dart';
import 'package:my_project/features/cart/domain/entities/cart_item_entity.dart';
import 'package:my_project/features/cart/presentation/logic/cart_line_rules.dart';
import 'package:my_project/features/cart/presentation/logic/cart_pricing.dart';

void main() {
  group('Cart pricing', () {
    test('selected subtotal sums final backend line totals', () {
      final rows = [
        _row(itemId: 1, cartQuantity: 2, price: 100, lineTotal: 160),
        _row(itemId: 2, cartQuantity: 1, price: 50, lineTotal: 45),
      ];

      expect(selectedCartSubtotal(rows), 205);
    });

    test('savings compare base price against final line total', () {
      final row = _row(cartQuantity: 2, price: 100, lineTotal: 160);

      expect(row.cartLineSavings, 40);
    });

    test('final unit price avoids unsafe division', () {
      expect(_row(cartQuantity: 2, lineTotal: 160).cartFinalUnitPrice, 80);
      expect(_row(cartQuantity: 0, lineTotal: 160).cartFinalUnitPrice, 0);
    });
  });

  group('Cart line rules', () {
    test(
      'blocks selected invalid rows but ignores unselected invalid rows',
      () {
        final rows = [
          _row(itemId: 1),
          _row(itemId: 2, isSelected: false, status: 'NEEDS_VARIANT'),
        ];

        expect(
          selectedCartCheckoutBlockReason(
            rows,
            hasPendingSelectedOperation: false,
          ),
          isNull,
        );

        expect(
          selectedCartCheckoutBlockReason([
            _row(status: 'NEEDS_VARIANT'),
          ], hasPendingSelectedOperation: false),
          CartCheckoutBlockReason.needsReview,
        );
      },
    );

    test('reports pending and over-stock checkout blockers', () {
      expect(
        selectedCartCheckoutBlockReason([
          _row(),
        ], hasPendingSelectedOperation: true),
        CartCheckoutBlockReason.pendingChanges,
      );

      expect(
        selectedCartCheckoutBlockReason([
          _row(cartQuantity: 3, stock: 2, lineTotal: 30),
        ], hasPendingSelectedOperation: false),
        CartCheckoutBlockReason.stockChanged,
      );
    });
  });
}

CartItemEntity _row({
  int itemId = 1,
  int cartQuantity = 1,
  double price = 10,
  double lineTotal = 10,
  int stock = 5,
  bool isSelected = true,
  bool isAvailable = true,
  String status = 'OK',
}) {
  return CartItemEntity.local(
    itemId: itemId,
    cartQuantity: cartQuantity,
    price: price,
    lineTotal: lineTotal,
    stock: stock,
    image: '',
    isSelected: isSelected,
    isAvailable: isAvailable,
    status: status,
  );
}
