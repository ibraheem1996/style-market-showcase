import 'package:freezed_annotation/freezed_annotation.dart';

part 'state.freezed.dart';

@freezed
abstract class CheckoutState with _$CheckoutState {
  const factory CheckoutState({
    @Default(false) bool isRefreshingCart,
    @Default(false) bool isPlacingOrder,
    @Default(false) bool isPreviewingOrder,
    @Default(0) int currentStepIndex,
    @Default(PaymentMethod.none) PaymentMethod selectedPaymentMethod,
    @Default(0.0) double previewSubtotal,
    @Default(0.0) double deliveryFee,
    @Default(0.0) double previewTotal,
  }) = _CheckoutState;
}

enum PaymentMethod { none, cash, visa }
