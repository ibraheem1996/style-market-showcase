import 'package:get/get.dart';

import '../../domain/entities/favorite_entity.dart';

class FavoritesStore extends GetxService {
  final RxSet<String> _keys = <String>{}.obs;
  final RxList<FavoriteEntity> _favorites = <FavoriteEntity>[].obs;

  List<FavoriteEntity> get favorites =>
      List<FavoriteEntity>.unmodifiable(_favorites);

  String _getKey(int itemId, int? variantId) =>
      "${itemId}_${variantId ?? 'null'}";

  bool isFav(int itemId, int? variantId) {
    return _keys.contains(_getKey(itemId, variantId));
  }

  void setAllFavorites(List<FavoriteEntity> newFavorites) {
    _favorites.assignAll(newFavorites);
    _keys
      ..clear()
      ..addAll(newFavorites.map((e) => _getKey(e.itemId, e.variantId)));
  }

  void clearAll() {
    _favorites.clear();
    _keys.clear();
  }

  void toggleLocal(int itemId, int? variantId) {
    final key = _getKey(itemId, variantId);
    if (!_keys.add(key)) {
      _keys.remove(key);
    }
  }

  void setFav(int itemId, int? variantId, bool value) {
    final key = _getKey(itemId, variantId);
    if (value) {
      _keys.add(key);
    } else {
      _keys.remove(key);
    }
  }

  void upsert(FavoriteEntity favorite) {
    _favorites.removeWhere(
      (item) =>
          item.itemId == favorite.itemId &&
          item.variantId == favorite.variantId,
    );
    _favorites.add(favorite);
    _favorites.sort((a, b) {
      final byDate = b.createdAt.compareTo(a.createdAt);
      return byDate != 0 ? byDate : b.favId.compareTo(a.favId);
    });
    setFav(favorite.itemId, favorite.variantId, true);
  }

  void remove(int itemId, int? variantId) {
    _favorites.removeWhere(
      (item) => item.itemId == itemId && item.variantId == variantId,
    );
    setFav(itemId, variantId, false);
  }
}
