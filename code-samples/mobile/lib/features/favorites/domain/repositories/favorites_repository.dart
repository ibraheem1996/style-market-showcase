// Project imports:
import '../../../../core/errors/api_result.dart';
import '../entities/favorite_entity.dart';
import '../entities/favorites_toggle_result.dart';

//! Repository interface for favorites feature
abstract class FavoritesRepository {
  //! Get user's favorite items
  Future<ApiResult<List<FavoriteEntity>>> getFavorites();

  Future<ApiResult<FavoritesToggleResult>> toggleFavorite({
    required int itemId,
    int? variantId,
  });

  Future<ApiResult<void>> clearFavorites();
}
