import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/errors/failure.dart';

part 'item_details_event.freezed.dart';

@freezed
class ItemDetailsEvent with _$ItemDetailsEvent {
  const factory ItemDetailsEvent.errToggleFav(Failure failure) =
      ItemDetailsErrToggleFav;
  const factory ItemDetailsEvent.toggleFavSuccess(String action) =
      ItemDetailsToggleFavSuccess;
  const factory ItemDetailsEvent.errAddToCart(Failure failure) =
      ItemDetailsErrAddToCart;
  const factory ItemDetailsEvent.addToCartSuccess(String action) =
      ItemDetailsAddToCartSuccess;
  const factory ItemDetailsEvent.errUpdateCart(String msgError) =
      ItemDetailsUpdateCart;
}
