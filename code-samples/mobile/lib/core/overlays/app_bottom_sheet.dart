import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../utils/responsive/app_radius.dart';
import '../utils/responsive/app_text_scale_limits.dart';
import '../utils/responsive/responsive_content_profile.dart';

/// The App-owned route/frame defaults for modal bottom sheets.
abstract final class AppBottomSheet {
  /// Shows [child] with the app's shared route, surface, and scaling defaults.
  static Future<T?> show<T>(
    Widget child, {
    bool isScrollControlled = true,
    bool isDismissible = true,
    bool enableDrag = true,
  }) {
    return Get.bottomSheet<T>(
      _AppBottomSheetPresentation(child: child),
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      clipBehavior: Clip.antiAlias,
      enableDrag: enableDrag,
      ignoreSafeArea: true,
      isDismissible: isDismissible,
      isScrollControlled: isScrollControlled,
    );
  }
}

class _AppBottomSheetPresentation extends StatelessWidget {
  const _AppBottomSheetPresentation({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: AppTextScaleLimits.bottomSheet,
      child: Align(
        alignment: Alignment.bottomCenter,
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: ResponsiveContentProfile.standard.maxWidth,
          ),
          child: Material(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppRadius.md(context)),
            ),
            clipBehavior: Clip.antiAlias,
            child: SafeArea(top: false, child: child),
          ),
        ),
      ),
    );
  }
}
