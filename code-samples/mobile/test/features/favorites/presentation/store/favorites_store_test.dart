import 'package:flutter_test/flutter_test.dart';
import 'package:my_project/features/favorites/domain/entities/favorite_entity.dart';
import 'package:my_project/features/favorites/presentation/store/favorites_store.dart';

void main() {
  group('FavoritesStore', () {
    test('keeps simple and variant favorite keys independent', () {
      final store = FavoritesStore();

      store.setFav(7, null, true);
      store.setFav(7, 11, true);

      expect(store.isFav(7, null), isTrue);
      expect(store.isFav(7, 11), isTrue);
      expect(store.isFav(7, 12), isFalse);

      store.toggleLocal(7, 11);

      expect(store.isFav(7, null), isTrue);
      expect(store.isFav(7, 11), isFalse);
    });

    test(
      'upsert replaces the exact identity and sorts ties by favorite id',
      () {
        final store = FavoritesStore();
        store.upsert(_favorite(favId: 1, itemId: 7));
        store.upsert(_favorite(favId: 3, itemId: 8));
        store.upsert(_favorite(favId: 2, itemId: 7));
        expect(store.favorites.map((favorite) => favorite.favId), [3, 2]);
        store.remove(7, null);
        expect(store.isFav(7, null), isFalse);
        expect(store.favorites.map((favorite) => favorite.favId), [3]);
      },
    );

    test('replaces entities and exact keys together', () {
      final store = FavoritesStore();

      store.setAllFavorites([
        _favorite(favId: 1, itemId: 3),
        _favorite(favId: 2, itemId: 3, variantId: 8),
      ]);

      expect(store.favorites, hasLength(2));
      expect(store.isFav(3, null), isTrue);
      expect(store.isFav(3, 8), isTrue);

      store.setAllFavorites([_favorite(favId: 3, itemId: 9)]);

      expect(store.favorites.single.itemId, 9);
      expect(store.isFav(3, null), isFalse);
      expect(store.isFav(3, 8), isFalse);
      expect(store.isFav(9, null), isTrue);
    });
  });
}

FavoriteEntity _favorite({
  required int favId,
  required int itemId,
  int? variantId,
}) {
  return FavoriteEntity(
    favId: favId,
    itemId: itemId,
    variantId: variantId,
    targetType: variantId == null
        ? FavoriteTargetType.item
        : FavoriteTargetType.variant,
    itemNameAr: 'منتج',
    itemNameEn: 'Product',
    displayImage: 'product.jpg',
    displayPrice: 10,
    originalPrice: 10,
    discount: 0,
    stockQuantity: 3,
    isAvailable: true,
    status: FavoriteStatus.ok,
    createdAt: DateTime.utc(2026, 1, 1),
  );
}
