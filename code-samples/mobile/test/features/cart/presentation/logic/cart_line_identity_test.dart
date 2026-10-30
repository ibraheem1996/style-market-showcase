import 'package:flutter_test/flutter_test.dart';
import 'package:my_project/features/cart/domain/entities/cart_item_entity.dart';
import 'package:my_project/features/cart/presentation/logic/cart_line_identity.dart';

void main() {
  group('CartLineIdentity', () {
    test('keeps null variant id as the simple line key', () {
      const fromNull = CartLineIdentity(itemId: 1, variantId: null);

      expect(fromNull.variantId, isNull);
      expect(fromNull.operationKey, '1:simple');
    });

    test('keeps concrete variants separate', () {
      const red = CartLineIdentity(itemId: 1, variantId: 7);
      const blue = CartLineIdentity(itemId: 1, variantId: 8);

      expect(red, isNot(blue));
      expect(red.variantId, 7);
    });

    test('matches cart rows by line identity', () {
      const identity = CartLineIdentity(itemId: 1, variantId: null);
      final row = CartItemEntity.local(itemId: 1, image: '');

      expect(identity.matches(row), isTrue);
    });
  });
}
