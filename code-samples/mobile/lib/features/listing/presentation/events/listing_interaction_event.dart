import '../../../../core/errors/failure.dart';
import '../../../cart/domain/entities/cart_item_entity.dart';

/// Describes a one-time Listing interaction result that the page presents.
sealed class ListingInteractionEvent {
  const ListingInteractionEvent();
}

final class ListingInteractionFailure extends ListingInteractionEvent {
  const ListingInteractionFailure(this.failure);

  final Failure failure;
}

final class ListingFavoriteSuccess extends ListingInteractionEvent {
  const ListingFavoriteSuccess({required this.added});

  final bool added;
}

final class ListingCartSuccess extends ListingInteractionEvent {
  const ListingCartSuccess(this.action);

  final CartAction action;
}

final class ListingCartUnavailable extends ListingInteractionEvent {
  const ListingCartUnavailable();
}
