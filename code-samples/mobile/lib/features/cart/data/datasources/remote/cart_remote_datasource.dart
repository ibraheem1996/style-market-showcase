// Package imports:
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

// Project imports:
import '../../../../../core/config/api_config.dart';
import '../../../../../core/network/api_response.dart';
import '../../models/cart_item_model.dart';
import '../../models/toggle_cart_request.dart';
import '../../models/toggle_selection_request.dart';

part 'cart_remote_datasource.g.dart';

//! Remote data source for cart operations
@RestApi()
abstract class CartRemoteDataSource {
  factory CartRemoteDataSource(Dio dio, {String baseUrl}) =
      _CartRemoteDataSource;

  //! Get user's cart items
  @GET(ApiConfig.cart)
  Future<ApiResponse<List<CartItemModel>>> getCart();

  //! Add, update, or remove item from cart
  @POST(ApiConfig.toggleCart)
  Future<ApiResponse<CartItemModel?>> toggleCart(
    @Body() ToggleCartRequest request,
  );

  //! Toggle cart item selection
  @POST('/cart/toggle-selection')
  Future<ApiResponse<void>> toggleSelection(
    @Body() ToggleSelectionRequest request,
  );

  //! Clear all items from user's cart
  @DELETE(ApiConfig.clearCart)
  Future<ApiResponse<void>> clearCart();
}
