import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/errors/api_result.dart';
import '../../../../core/translations/locale_keys.dart';
import '../../domain/entities/address_entity.dart';
import '../../domain/entities/address_submit_result.dart';
import '../../domain/usecases/create_address_usecase.dart';
import '../../domain/usecases/get_areas_usecase.dart';
import '../../domain/usecases/get_cities_usecase.dart';
import '../../domain/usecases/update_address_usecase.dart';
import '../events/address_event.dart';
import '../state/address_form_state.dart';

/// Owns one temporary Create/Edit form and its region lookups.
class AddressFormController extends GetxController {
  AddressFormController({
    required GetCitiesUseCase getCitiesUseCase,
    required GetAreasUseCase getAreasUseCase,
    required CreateAddressUseCase createAddressUseCase,
    required UpdateAddressUseCase updateAddressUseCase,
  }) : _getCitiesUseCase = getCitiesUseCase,
       _getAreasUseCase = getAreasUseCase,
       _createAddressUseCase = createAddressUseCase,
       _updateAddressUseCase = updateAddressUseCase;

  final GetCitiesUseCase _getCitiesUseCase;
  final GetAreasUseCase _getAreasUseCase;
  final CreateAddressUseCase _createAddressUseCase;
  final UpdateAddressUseCase _updateAddressUseCase;

  final formKey = GlobalKey<FormState>();
  late final TextEditingController streetOne;
  late final TextEditingController streetTwo;
  late final TextEditingController phone;

  final state = const AddressFormState().obs;
  final Rxn<AddressEvent> event = Rxn<AddressEvent>();
  final Rxn<AddressSubmitResult> submissionResult = Rxn<AddressSubmitResult>();

  int _areasGeneration = 0;
  bool _isPreparingForm = false;
  Future<void>? _citiesLoadFuture;

  void clearEvent() => event.value = null;
  void clearSubmissionResult() => submissionResult.value = null;

  @override
  void onInit() {
    super.onInit();
    streetOne = TextEditingController();
    streetTwo = TextEditingController();
    phone = TextEditingController();
    loadCities();
  }

  Future<void> loadCities() {
    final activeLoad = _citiesLoadFuture;
    if (activeLoad != null) return activeLoad;
    final load = _loadCities();
    _citiesLoadFuture = load;
    load.whenComplete(() {
      if (identical(_citiesLoadFuture, load)) {
        _citiesLoadFuture = null;
      }
    });
    return load;
  }

  Future<void> _loadCities() async {
    state.value = state.value.copyWith(
      isLoadingCities: true,
      loadCitiesFailure: null,
    );

    final result = await _getCitiesUseCase();
    if (isClosed) return;
    result.fold(
      (failure) => state.value = state.value.copyWith(
        isLoadingCities: false,
        cities: const [],
        loadCitiesFailure: failure,
      ),
      (cities) => state.value = state.value.copyWith(
        isLoadingCities: false,
        cities: List.unmodifiable(cities),
        loadCitiesFailure: null,
      ),
    );
  }

  Future<bool> prepareCreateForm() async {
    if (state.value.isSubmitting || _isPreparingForm) return false;
    _isPreparingForm = true;
    try {
      _areasGeneration++;
      streetOne.clear();
      streetTwo.clear();
      phone.clear();
      state.value = state.value.copyWith(
        areas: const [],
        selectedCityId: null,
        selectedAreaId: null,
        isLoadingAreas: false,
        loadAreasFailure: null,
        submitFailure: null,
      );
      return _ensureCitiesReady();
    } finally {
      _isPreparingForm = false;
    }
  }

  Future<bool> prepareEditForm(AddressEntity address) async {
    if (state.value.isSubmitting || _isPreparingForm) return false;
    _isPreparingForm = true;
    try {
      streetOne.text = address.streetOne;
      streetTwo.text = address.streetTwo;
      phone.text = address.phone;
      state.value = state.value.copyWith(
        selectedCityId: address.cityId,
        selectedAreaId: address.areaId,
        submitFailure: null,
      );
      if (!await _ensureCitiesReady()) return false;
      final result = await loadAreasForCity(
        address.cityId,
        keepSelection: true,
      );
      return result.isRight();
    } finally {
      _isPreparingForm = false;
    }
  }

  Future<bool> _ensureCitiesReady() async {
    if (state.value.cities.isNotEmpty) return true;
    await loadCities();
    return state.value.cities.isNotEmpty &&
        state.value.loadCitiesFailure == null;
  }

  void onAreaChanged(int? areaId) {
    state.value = state.value.copyWith(selectedAreaId: areaId);
  }

  Future<ApiResult<void>> loadAreasForCity(
    int? cityId, {
    bool keepSelection = false,
  }) async {
    final requestGeneration = ++_areasGeneration;
    state.value = state.value.copyWith(
      isLoadingAreas: true,
      loadAreasFailure: null,
      selectedCityId: cityId,
      selectedAreaId: keepSelection ? state.value.selectedAreaId : null,
      areas: const [],
    );

    if (cityId == null) {
      state.value = state.value.copyWith(isLoadingAreas: false);
      return const Right(null);
    }

    final result = await _getAreasUseCase(GetAreasParams(cityId: cityId));
    // A slower response for an old city cannot replace the current areas.
    if (isClosed ||
        requestGeneration != _areasGeneration ||
        state.value.selectedCityId != cityId) {
      return result;
    }
    result.fold(
      (failure) => state.value = state.value.copyWith(
        isLoadingAreas: false,
        areas: const [],
        loadAreasFailure: failure,
      ),
      (areas) => state.value = state.value.copyWith(
        isLoadingAreas: false,
        areas: List.unmodifiable(areas),
        loadAreasFailure: null,
      ),
    );
    return result;
  }

  Future<void> submit(AddressEntity? address) async {
    if (state.value.isSubmitting ||
        !(formKey.currentState?.validate() ?? false)) {
      return;
    }
    final areaId = state.value.selectedAreaId;
    if (areaId == null) {
      event.value = const AddressEvent.message(
        LocaleKeys.addressesSelectAreaFirst,
      );
      return;
    }

    state.value = state.value.copyWith(isSubmitting: true, submitFailure: null);
    final ApiResult<AddressSubmitResult> result = address == null
        ? await _createAddressUseCase(
            CreateAddressParams(
              areaId: areaId,
              streetOne: streetOne.text.trim(),
              streetTwo: _optional(streetTwo.text),
              phone: phone.text.trim(),
            ),
          )
        : await _updateAddressUseCase(
            UpdateAddressParams(
              addressId: address.addressId,
              areaId: areaId,
              streetOne: streetOne.text.trim(),
              streetTwo: _optional(streetTwo.text),
              phone: phone.text.trim(),
            ),
          );
    if (isClosed) return;

    state.value = state.value.copyWith(isSubmitting: false);
    result.fold((failure) {
      state.value = state.value.copyWith(submitFailure: failure);
      event.value = AddressEvent.failure(failure);
    }, (submitResult) => submissionResult.value = submitResult);
  }

  String? _optional(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  @override
  void onClose() {
    _areasGeneration++;
    streetOne.dispose();
    streetTwo.dispose();
    phone.dispose();
    super.onClose();
  }
}
