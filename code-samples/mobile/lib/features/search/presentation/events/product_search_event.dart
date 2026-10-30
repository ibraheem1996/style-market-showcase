import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/errors/failure.dart';
import '../../../cart/domain/entities/cart_item_entity.dart';

part 'product_search_event.freezed.dart';

@freezed
sealed class ProductSearchEvent with _$ProductSearchEvent {
  const factory ProductSearchEvent.interactionFailure(Failure failure) =
      _InteractionFailure;
  const factory ProductSearchEvent.cartSuccess(CartAction action) =
      _CartSuccess;
  const factory ProductSearchEvent.cartUnavailable() = _CartUnavailable;
}
