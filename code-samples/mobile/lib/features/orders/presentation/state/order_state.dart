import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:my_project/features/orders/domain/entities/order_details_entity.dart';

import '../../../../core/errors/failure.dart';

part 'order_state.freezed.dart';

@freezed
class OrderState with _$OrderState {
  const factory OrderState.initial() = _Initial;
  const factory OrderState.loading() = _Loading;
  const factory OrderState.error(Failure failure) = _Error;
  const factory OrderState.success(OrderDetailsEntity order) = _Success;
}
