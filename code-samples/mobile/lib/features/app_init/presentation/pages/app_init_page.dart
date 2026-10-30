import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_typography.dart';
import '../../../../core/translations/locale_keys.dart';

import '../controllers/app_init_controller.dart';

class AppInitPage extends GetView<AppInitController> {
  const AppInitPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(automaticallyImplyLeading: false),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }

          if (controller.failure.value != null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: SizedBox(
                      width: Get.width * 0.8,
                      child: Text(
                        controller.failure.value ?? "",
                        textAlign: TextAlign.center,
                        style: context.appTypography.stateMessage.message,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 4,
                      shadowColor: context.theme.colorScheme.secondary
                          .withValues(alpha: 0.8),
                    ),
                    onPressed: controller.retry,
                    child: Text(
                      LocaleKeys.errorAppTryAgain.tr,
                      style: context.appTypography.button.label,
                    ),
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        }),
      ),
    );
  }
}
