import 'package:freezed_annotation/freezed_annotation.dart';

part 'admin_order_effect.freezed.dart';

@freezed
abstract class AdminOrderEffect with _$AdminOrderEffect {
  const factory AdminOrderEffect.success(String message) =
      AdminOrderSuccessEffect;
  const factory AdminOrderEffect.failure(String message) =
      AdminOrderFailureEffect;
}
