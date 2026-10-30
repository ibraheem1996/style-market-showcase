import 'package:flutter/material.dart';
import '../../core/responsive/app_responsive.dart';
import '../../core/responsive/app_text_sizes.dart';
import 'app_palette.dart';

abstract final class AppTextStyles {
  static TextStyle title(BuildContext context) {
    final screen = AppResponsive.of(context);
    final colors = Theme.of(context).semanticColors;
    return TextStyle(
      fontSize: AppTextSizes.title(screen),
      fontWeight: FontWeight.w700,
      color: colors.textPrimary,
    );
  }

  static TextStyle sectionTitle(BuildContext context) {
    final screen = AppResponsive.of(context);
    final colors = Theme.of(context).semanticColors;
    return TextStyle(
      fontSize: AppTextSizes.sectionTitle(screen),
      fontWeight: FontWeight.w700,
      color: colors.textPrimary,
    );
  }

  static TextStyle body(BuildContext context) {
    final screen = AppResponsive.of(context);
    final colors = Theme.of(context).semanticColors;
    return TextStyle(
      fontSize: AppTextSizes.body(screen),
      height: 1.6,
      color: colors.textPrimary,
    );
  }

  static TextStyle label(BuildContext context) {
    final screen = AppResponsive.of(context);
    final colors = Theme.of(context).semanticColors;
    return TextStyle(
      fontSize: AppTextSizes.label(screen),
      fontWeight: FontWeight.w600,
      color: colors.textSecondary,
    );
  }

  static TextStyle button(BuildContext context) {
    final screen = AppResponsive.of(context);
    final colors = Theme.of(context).semanticColors;
    return TextStyle(
      fontSize: AppTextSizes.button(screen),
      fontWeight: FontWeight.w700,
      color: colors.textPrimary,
    );
  }

  static TextStyle table(BuildContext context) {
    final screen = AppResponsive.of(context);
    final colors = Theme.of(context).semanticColors;
    return TextStyle(
      fontSize: AppTextSizes.table(screen),
      fontWeight: FontWeight.w700,
      color: colors.textSecondary,
    );
  }

  static TextStyle tooltip(BuildContext context) {
    final screen = AppResponsive.of(context);
    final colors = Theme.of(context).colorScheme;
    return TextStyle(
      fontSize: AppTextSizes.tooltip(screen),
      fontWeight: FontWeight.w600,
      color: colors.onError,
    );
  }
}
