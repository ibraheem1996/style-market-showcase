import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/app_semantic_colors.dart';
import '../theme/app_typography.dart';
import '../utils/responsive/app_design_tokens.dart';
import '../utils/responsive/app_radius.dart';
import '../utils/responsive/app_responsive_value.dart';
import '../utils/responsive/app_text_scale_limits.dart';
import '../utils/responsive/responsive_content_profile.dart';

/// Semantic presentation tones supported by [AppSnackbar].
enum AppSnackbarTone { neutral, success, warning, error }

/// The App-owned entry point for transient message-only feedback.
abstract final class AppSnackbar {
  static final messengerKey = GlobalKey<ScaffoldMessengerState>();

  static Future<void> show(
    String message, {
    AppSnackbarTone tone = AppSnackbarTone.neutral,
    Duration duration = const Duration(seconds: 2),
  }) {
    final currentState = messengerKey.currentState;
    if (currentState == null) {
      return Future<void>.value();
    }

    currentState.clearSnackBars();

    currentState.showSnackBar(
      SnackBar(
        content: _AppSnackbarPresentation(message: message, tone: tone),
        duration: duration,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        padding: EdgeInsets.zero,
      ),
    );

    return Future<void>.value();
  }
}

class _AppSnackbarPresentation extends StatelessWidget {
  const _AppSnackbarPresentation({required this.message, required this.tone});

  final String message;
  final AppSnackbarTone tone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final warningColor = theme.semanticColors.warning;
    final presentation = _SnackbarPresentation.forTone(
      colors,
      tone,
      warningColor,
    );
    final horizontalInset = ResponsiveContentGutters.forWindowClass(
      context.windowClass,
    );

    final contentPadding = AppResponsiveValue.resolve(
      context,
      compact: AppSpacing.md,
      medium: AppSpacing.lg,
      expanded: AppSpacing.xl,
    );
    final iconGap = AppResponsiveValue.resolve(
      context,
      compact: AppSpacing.sm,
      medium: AppSpacing.md,
      expanded: AppSpacing.lg,
    );

    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: AppTextScaleLimits.snackbar,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalInset,
          // vertical: verticalInset,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: ResponsiveContentProfile.form.maxWidth,
            ),
            child: Material(
              color: presentation.background,
              elevation: 2,
              shadowColor: colors.shadow.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(AppRadius.md(context)),
              clipBehavior: Clip.antiAlias,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(color: presentation.borderColor),
                  borderRadius: BorderRadius.circular(AppRadius.md(context)),
                ),
                child: Padding(
                  padding: EdgeInsets.all(contentPadding),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        presentation.icon,
                        color: presentation.accent,
                        size: AppIconSizes.listLeading(context),
                      ),
                      SizedBox(width: iconGap),
                      Expanded(
                        child: Text(
                          message,
                          style: context.appTypography.snackbar.message
                              .copyWith(color: presentation.foreground),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SnackbarPresentation {
  const _SnackbarPresentation({
    required this.background,
    required this.foreground,
    required this.accent,
    required this.borderColor,
    required this.icon,
  });

  final Color background;
  final Color foreground;
  final Color accent;
  final Color borderColor;
  final IconData icon;

  factory _SnackbarPresentation.forTone(
    ColorScheme colors,
    AppSnackbarTone tone,
    Color warningColor,
  ) {
    return switch (tone) {
      AppSnackbarTone.neutral => _SnackbarPresentation(
        background: colors.surface,
        foreground: colors.onSurface,
        accent: colors.onSurfaceVariant,
        borderColor: colors.outlineVariant.withValues(alpha: 0.45),
        icon: Icons.info_outline,
      ),
      AppSnackbarTone.success => _SnackbarPresentation(
        background: colors.primary,
        foreground: colors.onPrimary,
        accent: colors.onPrimary.withValues(alpha: 0.70),
        borderColor: colors.onPrimaryContainer.withValues(alpha: 0.70),
        icon: Icons.check_circle_outline,
      ),
      AppSnackbarTone.warning => _SnackbarPresentation(
        background: colors.surface,
        foreground: colors.onSurface,
        accent: warningColor,
        borderColor: warningColor.withValues(alpha: 0.35),
        icon: Icons.warning_amber_outlined,
      ),
      AppSnackbarTone.error => _SnackbarPresentation(
        background: colors.surface,
        foreground: colors.error,
        accent: colors.error.withValues(alpha: 0.90),
        borderColor: colors.error.withValues(alpha: 0.35),
        icon: Icons.error_outline,
      ),
    };
  }
}
