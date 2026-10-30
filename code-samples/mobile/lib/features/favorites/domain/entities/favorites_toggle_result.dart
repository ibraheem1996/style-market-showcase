import '../../../favorites/domain/entities/favorite_entity.dart';

class FavoritesToggleResult {
  final FavoriteEntity? favorite;
  final FavoritesToggleAction action;

  FavoritesToggleResult({required this.favorite, required this.action});
}

enum FavoritesToggleAction { added, removed }
