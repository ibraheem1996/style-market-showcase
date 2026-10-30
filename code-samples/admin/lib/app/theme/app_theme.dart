import 'package:flutter/material.dart';

import '../../core/responsive/app_radius.dart';
import '../../core/responsive/app_spacing.dart';
import '../../shared/design_system/app_data_visualization_theme.dart';
import '../../shared/design_system/app_palette.dart';

abstract final class AppTheme {
  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppDarkPalette.primary,
      brightness: Brightness.dark,
      primary: AppDarkPalette.primary,
      surface: AppDarkPalette.surface,
      error: AppDarkPalette.danger,
    );

    return ThemeData.dark().copyWith(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppDarkPalette.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppDarkPalette.surface,
        foregroundColor: AppDarkPalette.textPrimary,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppDarkPalette.surfaceVariant,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppDarkPalette.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppDarkPalette.border),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppDarkPalette.border),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppDarkPalette.primary,
          foregroundColor: AppDarkPalette.background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppDarkPalette.textPrimary,
          side: const BorderSide(color: AppDarkPalette.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppDarkPalette.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          side: const BorderSide(color: AppDarkPalette.border),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppDarkPalette.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppDarkPalette.border,
        thickness: 1,
      ),
      extensions: [
        const AppSemanticColors(
          border: AppDarkPalette.border,
          surfaceVariant: AppDarkPalette.surfaceVariant,
          textPrimary: AppDarkPalette.textPrimary,
          textSecondary: AppDarkPalette.textSecondary,
          success: AppDarkPalette.success,
          warning: AppDarkPalette.warning,
        ),
        const AppDataVisualizationTheme(
          seriesPrimary: AppDarkPalette.primary,
          seriesSecondary: Color(0xFF62D0E8),
          seriesTertiary: Color(0xFF8F6AF6),
          seriesSuccess: AppDarkPalette.success,
          seriesWarning: AppDarkPalette.warning,
          seriesDanger: AppDarkPalette.danger,
          cardHighlight: Color(0xFF1E2540),
        ),
      ],
    );
  }
}
