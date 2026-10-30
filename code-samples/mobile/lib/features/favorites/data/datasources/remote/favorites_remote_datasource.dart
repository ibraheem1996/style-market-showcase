// Package imports:
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

// Project imports:
import '../../../../../core/config/api_config.dart';
import '../../../../../core/network/api_response.dart';
import '../../models/favorite_model.dart';
import '../../models/toggle_favorite_request.dart';

part 'favorites_remote_datasource.g.dart';

//! Remote data source for favorites feature
@RestApi()
abstract class FavoritesRemoteDataSource {
  factory FavoritesRemoteDataSource(Dio dio, {String? baseUrl}) =
      _FavoritesRemoteDataSource;

  //! Get user's favorites
  @GET(ApiConfig.favorites)
  Future<ApiResponse<List<FavoriteModel>>> getFavorites();

  @POST(ApiConfig.addRemoveFavorite)
  Future<ApiResponse<dynamic>> toggleFavorite(
    @Body() ToggleFavoriteRequest request,
  );

  @DELETE(ApiConfig.clearFavorites)
  Future<ApiResponse<void>> clearFavorites();
}
