import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/errors/failure.dart';
import '../../domain/entities/area_entity.dart';
import '../../domain/entities/city_entity.dart';

part 'address_form_state.freezed.dart';

@freezed
abstract class AddressFormState with _$AddressFormState {
  const factory AddressFormState({
    @Default(false) bool isLoadingCities,
    @Default(false) bool isLoadingAreas,
    @Default(false) bool isSubmitting,
    @Default(<CityEntity>[]) List<CityEntity> cities,
    @Default(<AreaEntity>[]) List<AreaEntity> areas,
    int? selectedCityId,
    int? selectedAreaId,
    Failure? loadCitiesFailure,
    Failure? loadAreasFailure,
    Failure? submitFailure,
  }) = _AddressFormState;
}
