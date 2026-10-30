import 'package:get/get.dart';
import 'package:my_project/core/errors/failure_i18n.dart';

import '../../../../binding_route_middleware/route.dart';
import '../../../../core/di/shared_di.dart';
import '../../../auth/session/session_service.dart';
import '../../../audience/presentation/manager/audience_manager.dart';

class AppInitController extends GetxController {
  final SessionService sessionService;
  final AudienceManager audienceManager;
  final bool returnAfterRestore;
  final void Function()? onSessionReady;

  AppInitController(
    this.sessionService,
    this.audienceManager, {
    required this.returnAfterRestore,
    this.onSessionReady,
  });

  final isLoading = false.obs;
  final failure = RxnString();

  Future<void> loadInitialData() async {
    isLoading.value = true;
    failure.value = null;

    final restored = await sessionService.restoreStoredSession();
    if (isClosed) return;

    if (!restored) {
      await SharedDiService.clearSessionAndUserState();
      if (isClosed) return;
    }

    final result = await audienceManager.initAudiences();
    if (isClosed) return;

    result.fold(
      (f) {
        failure.value = FailureI18n.keyOf(f).tr;
        isLoading.value = false;
      },
      (_) {
        isLoading.value = false;
        onSessionReady?.call();
        if (returnAfterRestore) {
          Get.back<void>();
        } else {
          Get.offAllNamed(RouteName.homeScreen);
        }
      },
    );
  }

  @override
  void onReady() {
    super.onReady();
    loadInitialData();
  }

  Future<void> retry() => loadInitialData();
}
