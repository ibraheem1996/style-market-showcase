import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../theme/app_typography.dart';
import '../utils/responsive/app_design_tokens.dart';
import '../utils/responsive/app_radius.dart';
import '../utils/responsive/app_responsive_value.dart';
import '../utils/responsive/app_text_scale_limits.dart';
import '../utils/responsive/responsive_content_profile.dart';

/// The App-owned entry point for decision dialogs and important alerts.
abstract final class AppDialog {
  /// Shows a two-action decision dialog and resolves to whether it was confirmed.
  static Future<bool> confirm(
    String message, {
    required String confirmLabel,
    required String cancelLabel,
    bool dismissible = false,
  }) async {
    final result = await _show<bool>(
      message: message,
      dismissible: dismissible,
      actionLabel: confirmLabel,
      cancelLabel: cancelLabel,
      onAction: () => Get.back(result: true),
      onCancel: () => Get.back(result: false),
    );

    return result ?? false;
  }

  /// Shows an acknowledgement dialog and completes after its action closes it.
  static Future<void> alert(
    String message, {
    required String actionLabel,
    bool dismissible = false,
  }) async {
    await _show<void>(
      message: message,
      dismissible: dismissible,
      actionLabel: actionLabel,
      onAction: Get.back,
    );
  }

  static Future<T?> _show<T>({
    required String message,
    required bool dismissible,
    required String actionLabel,
    required VoidCallback onAction,
    String? cancelLabel,
    VoidCallback? onCancel,
  }) {
    return Get.dialog<T>(
      _AppDialogPresentation(
        message: message,
        actionLabel: actionLabel,
        cancelLabel: cancelLabel,
        onAction: onAction,
        onCancel: onCancel,
      ),
      barrierColor: Colors.black54,
      barrierDismissible: dismissible,
      useSafeArea: true,
    );
  }
}

class _AppDialogPresentation extends StatelessWidget {
  const _AppDialogPresentation({
    required this.message,
    required this.actionLabel,
    required this.onAction,
    this.cancelLabel,
    this.onCancel,
  });

  final String message;
  final String actionLabel;
  final VoidCallback onAction;
  final String? cancelLabel;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    final typography = context.appTypography;
    final mediaQuery = MediaQuery.of(context);
    final horizontalInset = ResponsiveContentGutters.forWindowClass(
      context.windowClass,
    );
    final verticalInset = AppResponsiveValue.resolve(
      context,
      compact: AppSpacing.md,
      medium: AppSpacing.lg,
      expanded: AppSpacing.xl,
    );
    final contentPadding = AppResponsiveValue.resolve(
      context,
      compact: AppSpacing.md,
      medium: AppSpacing.lg,
      expanded: AppSpacing.xl,
    );
    final actionSpacing = AppResponsiveValue.resolve(
      context,
      compact: 40.0,
      medium: 50.0,
      expanded: 60.0,
    );

    final verticalSpacing = AppResponsiveValue.resolve(
      context,
      compact: 10.0,
      medium: 13.0,
      expanded: 15.0,
    );
    final availableWidth = math.max(
      0.0,
      mediaQuery.size.width - (horizontalInset * 2),
    );
    final availableHeight = math.max(
      0.0,
      mediaQuery.size.height - (verticalInset * 2),
    );
    final dialogWidth = math.min(
      ResponsiveContentProfile.form.maxWidth,
      availableWidth,
    );

    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: AppTextScaleLimits.dialog,
      child: Dialog(
        insetPadding: EdgeInsets.symmetric(
          horizontal: horizontalInset,
          vertical: verticalInset,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md(context)),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: dialogWidth,
            maxWidth: dialogWidth,
            maxHeight: availableHeight,
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(contentPadding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: typography.dialog.message,
                ),
                SizedBox(height: verticalSpacing),
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: actionSpacing,
                  children: [
                    if (cancelLabel != null && onCancel != null)
                      TextButton(
                        onPressed: onCancel,
                        child: Text(
                          cancelLabel!,
                          style: typography.textAction.secondary,
                        ),
                      ),
                    FilledButton(
                      onPressed: onAction,
                      child: Text(actionLabel, style: typography.button.label),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
