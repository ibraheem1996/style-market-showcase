import 'package:flutter_test/flutter_test.dart';
import 'package:my_project/core/config/api_config.dart';
import 'package:my_project/features/cart/domain/entities/cart_item_entity.dart';
import 'package:my_project/features/cart/domain/entities/cart_upsert_input.dart';
import 'package:my_project/features/cart/presentation/logic/cart_line_identity.dart';
import 'package:my_project/features/cart/presentation/logic/cart_local_mutation.dart';
import 'package:my_project/features/cart/presentation/store/cart_store.dart';

void main() {
  group('CartLocalMutation', () {
    late CartStore store;

    setUp(() {
      store = CartStore();
    });

    test('optimistic input increments quantity and discounted line total', () {
      const input = CartUpsertInput(
        itemId: 2,
        itemName: 'Item',
        itemDescription: 'Description',
        image: 'item.jpg',
        price: 100,
        discount: 20,
        stock: 5,
      );

      CartLocalMutation.applyInputDelta(store, input: input, quantityDelta: 1);
      CartLocalMutation.applyInputDelta(store, input: input, quantityDelta: 1);

      expect(store.items.single.cartQuantity, 2);
      expect(store.items.single.variantId, isNull);
      expect(store.items.single.lineTotal, 160);
    });

    test('optimistic input keeps absolute image urls unchanged', () {
      const imageUrl = 'https://example.com/item.jpg';
      CartLocalMutation.applyInputDelta(
        store,
        input: const CartUpsertInput(
          itemId: 6,
          itemName: 'Item',
          itemDescription: '',
          image: imageUrl,
          price: 10,
          discount: 0,
        ),
        quantityDelta: 1,
      );

      expect(store.items.single.image, imageUrl);
    });

    test('optimistic input uses placeholder once when images are empty', () {
      CartLocalMutation.applyInputDelta(
        store,
        input: const CartUpsertInput(
          itemId: 7,
          itemName: 'Item',
          itemDescription: '',
          image: '',
          images: [],
          price: 10,
          discount: 0,
        ),
        quantityDelta: 1,
      );

      expect(store.items.single.image, ApiConfig.placeholder);
    });

    test('restoreLine restores only the targeted cart line and order', () {
      store.replaceItems([
        CartItemEntity.local(
          itemId: 1,
          cartQuantity: 1,
          image: 'one.jpg',
          lineTotal: 10,
        ),
        CartItemEntity.local(
          itemId: 2,
          cartQuantity: 1,
          image: 'two.jpg',
          lineTotal: 20,
        ),
      ]);
      final snapshot = CartLocalMutation.snapshotLine(
        store.items,
        const CartLineIdentity(itemId: 1, variantId: null),
      );

      store.replaceAt(0, store.itemAt(0).copyWith(cartQuantity: 3));
      store.replaceAt(1, store.itemAt(1).copyWith(cartQuantity: 4));
      CartLocalMutation.restoreLine(store, snapshot);

      expect(store.getCartQuantity(1, null), 1);
      expect(store.getCartQuantity(2, null), 4);
      expect(store.items.map((item) => item.itemId), [1, 2]);
    });

    test('selection snapshot restores only the targeted row', () {
      store.replaceItems([
        CartItemEntity.local(cartId: 1, itemId: 1, image: '', isSelected: true),
        CartItemEntity.local(cartId: 2, itemId: 2, image: '', isSelected: true),
      ]);
      final snapshot = CartLocalMutation.snapshotSelection(store.items, 1);

      store.setSelectionAt(store.indexOfCartId(1), false);
      CartLocalMutation.restoreSelection(store, snapshot);

      expect(store.items.first.isSelected, isTrue);
      expect(store.items.last.isSelected, isTrue);
    });
  });
}
