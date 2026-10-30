import 'package:flutter_test/flutter_test.dart';
import 'package:my_project/features/cart/domain/entities/cart_item_entity.dart';
import 'package:my_project/features/cart/presentation/logic/cart_line_identity.dart';
import 'package:my_project/features/cart/presentation/store/cart_store.dart';

void main() {
  group('CartStore', () {
    late CartStore store;

    setUp(() {
      store = CartStore();
    });

    test('matches null variant id with local simple item variant id null', () {
      store.replaceItems([
        CartItemEntity.local(itemId: 1, cartQuantity: 2, image: 'simple.jpg'),
      ]);

      expect(store.getCartQuantity(1, null), 2);
      expect(store.findLine(1, null)?.cartQuantity, 2);
      expect(store.findLine(1, 9), isNull);
      expect(store.getCartQuantity(1, 9), 0);
    });

    test('keeps simple and variant cart lines separate', () {
      store.replaceItems([
        CartItemEntity.local(itemId: 1, cartQuantity: 1, image: 'simple.jpg'),
        CartItemEntity.local(
          itemId: 1,
          variantId: 7,
          cartQuantity: 3,
          image: 'variant.jpg',
        ),
      ]);

      expect(store.getCartQuantity(1, null), 1);
      expect(store.getCartQuantity(1, 7), 3);
    });

    test('atomic replaceAt updates only the requested index', () {
      store.replaceItems([
        CartItemEntity.local(
          cartId: 10,
          itemId: 1,
          cartQuantity: 1,
          image: 'old.jpg',
        ),
      ]);

      store.replaceAt(
        0,
        CartItemEntity.local(
          cartId: 10,
          itemId: 1,
          cartQuantity: 2,
          image: 'server.jpg',
        ),
      );

      expect(store.items, hasLength(1));
      expect(store.items.single.cartQuantity, 2);
      expect(store.items.single.image, 'server.jpg');
    });

    test('atomic removeAt removes only the requested index', () {
      store.replaceItems([
        CartItemEntity.local(itemId: 1, image: 'simple.jpg'),
        CartItemEntity.local(itemId: 1, variantId: 7, image: 'variant.jpg'),
      ]);

      store.removeAt(
        store.indexOfLine(const CartLineIdentity(itemId: 1, variantId: null)),
      );

      expect(store.items, hasLength(1));
      expect(store.items.single.variantId, 7);
    });

    test('setSelection updates only the matching cart row', () {
      store.replaceItems([
        CartItemEntity.local(cartId: 1, itemId: 1, image: 'one.jpg'),
        CartItemEntity.local(cartId: 2, itemId: 2, image: 'two.jpg'),
      ]);

      store.setSelectionAt(store.indexOfCartId(1), false);

      expect(store.items.first.isSelected, isFalse);
      expect(store.items.last.isSelected, isTrue);
    });

    test('clearLocal removes cart rows only', () {
      store.replaceItems([CartItemEntity.local(itemId: 1, image: 'one.jpg')]);

      store.clearLocal();

      expect(store.items, isEmpty);
    });
  });
}
