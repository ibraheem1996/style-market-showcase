import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/errors/failure.dart';
import '../../../addresses/domain/entities/address_entity.dart';

part 'check_out_event.freezed.dart';

@freezed
abstract class CheckoutEvent with _$CheckoutEvent {
  const factory CheckoutEvent.errorMessage(String message) = _ErrorMessage;
  const factory CheckoutEvent.failure(Failure failure) = _Failure;
  const factory CheckoutEvent.addressPhoneVerificationRequired(
    Failure failure,
    AddressEntity address,
  ) = _AddressPhoneVerificationRequired;
  const factory CheckoutEvent.successMessage(String message) = _SuccessMessage;
  const factory CheckoutEvent.successOrder(String message, int orderId) =
      _SuccessOrder;
}
