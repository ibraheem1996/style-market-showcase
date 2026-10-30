import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:my_project/core/errors/api_result.dart';
import 'package:my_project/core/translations/app_translations.dart';
import 'package:my_project/features/addresses/domain/entities/address_entity.dart';
import 'package:my_project/features/addresses/domain/entities/address_phone_verification_challenge_entity.dart';
import 'package:my_project/features/addresses/domain/entities/address_submit_result.dart';
import 'package:my_project/features/addresses/domain/entities/address_verification_cancellation_entity.dart';
import 'package:my_project/features/addresses/domain/entities/area_entity.dart';
import 'package:my_project/features/addresses/domain/entities/city_entity.dart';
import 'package:my_project/features/addresses/domain/repositories/addresses_repository.dart';
import 'package:my_project/features/addresses/domain/usecases/create_address_usecase.dart';
import 'package:my_project/features/addresses/domain/usecases/get_areas_usecase.dart';
import 'package:my_project/features/addresses/domain/usecases/get_cities_usecase.dart';
import 'package:my_project/features/addresses/domain/usecases/update_address_usecase.dart';
import 'package:my_project/features/addresses/presentation/controllers/address_form_controller.dart';
import 'package:my_project/features/addresses/presentation/widgets/sheet/address_form_view.dart';

void main() {
  late _FakeRepository repository;
  late AddressFormController controller;

  setUp(() async {
    repository = _FakeRepository();
    controller = AddressFormController(
      getCitiesUseCase: GetCitiesUseCase(repository),
      getAreasUseCase: GetAreasUseCase(repository),
      createAddressUseCase: CreateAddressUseCase(repository),
      updateAddressUseCase: UpdateAddressUseCase(repository),
    )..onStart();
  });

  tearDown(() => controller.onDelete());

  test(
    'prepare coalesces the cities load started by controller lifecycle',
    () async {
      expect(await controller.prepareCreateForm(), isTrue);
      expect(controller.state.value.cities, isNotEmpty);
    },
  );

  testWidgets('saved create returns its domain result without shared writes', (
    tester,
  ) async {
    await _pumpForm(tester, controller);
    controller.onAreaChanged(4);
    controller.streetOne.text = 'Main';
    controller.phone.text = '+962790000000';

    await controller.submit(null);

    expect(repository.createCalls, 1);
    expect(controller.submissionResult.value, isA<AddressSubmitSaved>());
  });

  testWidgets('verification-required result retains challenge metadata', (
    tester,
  ) async {
    repository.createResult = Right(
      AddressSubmitResult.verificationRequired(_challenge()),
    );
    await _pumpForm(tester, controller);
    controller.onAreaChanged(4);
    controller.streetOne.text = 'Main';
    controller.phone.text = '+962790000000';

    await controller.submit(null);

    final result =
        controller.submissionResult.value! as AddressSubmitVerificationRequired;
    expect(result.challenge.verificationId, 'verification-1');
    expect(controller.state.value.isSubmitting, isFalse);
  });

  testWidgets('duplicate submit is ignored while request is pending', (
    tester,
  ) async {
    final pending = repository.enqueueCreate();
    await _pumpForm(tester, controller);
    controller.onAreaChanged(4);
    controller.streetOne.text = 'Main';
    controller.phone.text = '+962790000000';

    final first = controller.submit(null);
    final second = controller.submit(null);
    expect(repository.createCalls, 1);
    pending.complete(Right(AddressSubmitResult.saved(_address())));
    await Future.wait([first, second]);
  });

  testWidgets('late submit result is ignored after sheet disposal', (
    tester,
  ) async {
    final pending = repository.enqueueCreate();
    await _pumpForm(tester, controller);
    controller.onAreaChanged(4);
    controller.streetOne.text = 'Main';
    controller.phone.text = '+962790000000';

    final submit = controller.submit(null);
    controller.onDelete();
    pending.complete(Right(AddressSubmitResult.saved(_address())));
    await submit;

    expect(controller.submissionResult.value, isNull);
  });

  testWidgets('form view reports submission without owning the controller', (
    tester,
  ) async {
    await controller.prepareCreateForm();
    AddressSubmitResult? receivedResult;
    await tester.pumpWidget(
      GetMaterialApp(
        home: Scaffold(
          body: AddressFormView(
            controller: controller,
            onSubmitted: (result) => receivedResult = result,
          ),
        ),
      ),
    );

    controller.submissionResult.value =
        AddressSubmitResult.verificationRequired(_challenge());
    await tester.pump();

    expect(receivedResult, isA<AddressSubmitVerificationRequired>());
    expect(controller.isClosed, isFalse);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const GetMaterialApp(home: SizedBox()));
    await tester.pump();

    expect(controller.isClosed, isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets('form content remains scrollable across target windows', (
    tester,
  ) async {
    await controller.prepareCreateForm();
    addTearDown(() => tester.binding.setSurfaceSize(null));
    const fixtures = [
      (size: Size(320, 640), locale: Locale('ar')),
      (size: Size(900, 700), locale: Locale('en')),
    ];

    for (final fixture in fixtures) {
      await tester.binding.setSurfaceSize(fixture.size);
      await tester.pumpWidget(
        GetMaterialApp(
          translations: AppTranslations(),
          locale: fixture.locale,
          home: Scaffold(
            body: AddressFormView(
              controller: controller,
              onSubmitted: (_) {},
              onBack: () {},
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(SingleChildScrollView), findsOneWidget);
      final scrollView = tester.widget<SingleChildScrollView>(
        find.byType(SingleChildScrollView),
      );
      expect(scrollView.padding, isNull);
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });

  test('stale area response cannot replace current city areas', () async {
    final first = repository.enqueueAreas();
    final second = repository.enqueueAreas();
    final firstRequest = controller.loadAreasForCity(3);
    final secondRequest = controller.loadAreasForCity(5);

    second.complete(
      const Right([
        AreaEntity(areaId: 8, cityId: 5, nameAr: 'خلدا', nameEn: 'Khalda'),
      ]),
    );
    await secondRequest;
    first.complete(
      const Right([
        AreaEntity(
          areaId: 4,
          cityId: 3,
          nameAr: 'الصويفية',
          nameEn: 'Sweifieh',
        ),
      ]),
    );
    await firstRequest;

    expect(controller.state.value.selectedCityId, 5);
    expect(controller.state.value.areas.single.areaId, 8);
  });
}

Future<void> _pumpForm(WidgetTester tester, AddressFormController controller) {
  return tester.pumpWidget(
    MaterialApp(
      home: Form(key: controller.formKey, child: const SizedBox()),
    ),
  );
}

AddressEntity _address() => AddressEntity(
  addressId: 1,
  userId: 2,
  cityId: 3,
  areaId: 4,
  streetOne: 'Main',
  streetTwo: '',
  phone: '+962790000000',
  cityAr: 'عمّان',
  cityEn: 'Amman',
  areaAr: 'الصويفية',
  areaEn: 'Sweifieh',
);

AddressPhoneVerificationChallengeEntity _challenge() {
  final now = DateTime.now();
  return AddressPhoneVerificationChallengeEntity(
    verificationId: 'verification-1',
    maskedPhone: '+96279***000',
    expiresAt: now.add(const Duration(minutes: 5)),
    resendAvailableAt: now.add(const Duration(seconds: 30)),
  );
}

class _FakeRepository implements AddressesRepository {
  final List<Completer<ApiResult<List<AreaEntity>>>> _areas = [];
  Completer<ApiResult<AddressSubmitResult>>? _pendingCreate;
  int createCalls = 0;
  ApiResult<AddressSubmitResult> createResult = Right(
    AddressSubmitResult.saved(_address()),
  );

  Completer<ApiResult<List<AreaEntity>>> enqueueAreas() {
    final completer = Completer<ApiResult<List<AreaEntity>>>();
    _areas.add(completer);
    return completer;
  }

  Completer<ApiResult<AddressSubmitResult>> enqueueCreate() {
    return _pendingCreate = Completer<ApiResult<AddressSubmitResult>>();
  }

  @override
  Future<ApiResult<AddressSubmitResult>> createAddress({
    required int areaId,
    required String streetOne,
    String? streetTwo,
    required String phone,
  }) {
    createCalls++;
    return _pendingCreate?.future ?? Future.value(createResult);
  }

  @override
  Future<ApiResult<List<CityEntity>>> getCities() async =>
      const Right([CityEntity(cityId: 3, nameAr: 'عمّان', nameEn: 'Amman')]);

  @override
  Future<ApiResult<List<AreaEntity>>> getAreas(int cityId) {
    if (_areas.isNotEmpty) return _areas.removeAt(0).future;
    return Future.value(
      Right([
        AreaEntity(areaId: 4, cityId: cityId, nameAr: 'منطقة', nameEn: 'Area'),
      ]),
    );
  }

  @override
  Future<ApiResult<AddressSubmitResult>> updateAddress({
    required int addressId,
    required int areaId,
    required String streetOne,
    String? streetTwo,
    required String phone,
  }) async => Right(AddressSubmitResult.saved(_address()));

  @override
  Future<ApiResult<AddressVerificationCancellationEntity>>
  cancelAddressVerification({required String verificationId}) async =>
      const Right(AddressVerificationCancellationEntity(status: 'cancelled'));

  @override
  Future<ApiResult<AddressEntity>> confirmAddressPhoneVerification({
    required String verificationId,
    required String code,
  }) => throw UnimplementedError();

  @override
  Future<ApiResult<void>> deleteAddress(int addressId) =>
      throw UnimplementedError();

  @override
  Future<ApiResult<List<AddressEntity>>> getUserAddresses() =>
      throw UnimplementedError();

  @override
  Future<ApiResult<AddressPhoneVerificationChallengeEntity>>
  resendAddressPhoneVerification({required String verificationId}) =>
      throw UnimplementedError();
}
