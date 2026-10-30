import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:my_project/features/products/domain/entities/item_entity.dart';

import '../../../../core/errors/failure.dart';
part 'item_details_state.freezed.dart';

@freezed
abstract class ItemDetailsState with _$ItemDetailsState {
  const factory ItemDetailsState.initial() = _Initial;
  const factory ItemDetailsState.loading() = _Loading;
  const factory ItemDetailsState.loaded(ItemEntity item) = _Loaded;
  const factory ItemDetailsState.error(Failure failure) = _Error;
}
