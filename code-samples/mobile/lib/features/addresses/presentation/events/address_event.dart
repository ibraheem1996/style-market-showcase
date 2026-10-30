import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/errors/failure.dart';
import '../../domain/entities/address_entity.dart';

part 'address_event.freezed.dart';

@freezed
abstract class AddressEvent with _$AddressEvent {
  const factory AddressEvent.failure(Failure failure) = _Failure;

  const factory AddressEvent.message(String localeKey) = _Message;

  const factory AddressEvent.closeSheet(AddressEntity address) = _CloseSheet;
}
