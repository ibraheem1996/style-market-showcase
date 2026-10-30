import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:my_project/app/app_di.dart';
import 'package:my_project/core/di/service_locator.dart';

void main() {
  setUp(() async {
    Get.testMode = true;
    Get.reset();
    await getIt.reset();
  });

  tearDown(() async {
    Get.reset();
    await getIt.reset();
  });

  test('retry cleanup removes partial GetX and GetIt registrations', () async {
    final getXDependency = Get.put(_GetXDependency(), permanent: true);
    getIt.registerSingleton(_GetItDependency());

    await resetAppDependenciesForRetry();

    expect(Get.isRegistered<_GetXDependency>(), isFalse);
    expect(getXDependency.wasClosed, isTrue);
    expect(getIt.isRegistered<_GetItDependency>(), isFalse);

    expect(() {
      Get.put(_GetXDependency(), permanent: true);
      getIt.registerSingleton(_GetItDependency());
    }, returnsNormally);
  });
}

class _GetXDependency extends GetxService {
  bool wasClosed = false;

  @override
  void onClose() {
    wasClosed = true;
    super.onClose();
  }
}

class _GetItDependency {}
