import 'package:flutter/material.dart';

abstract final class AppDarkPalette {
  static const background = Color(0xFF0B1020);
  static const surface = Color(0xFF151C2B);
  static const surfaceVariant = Color(0xFF20293A);
  static const border = Color(0xFF2B3548);
  static const primary = Color(0xFF7C5CFF);
  static const success = Color(0xFF4FC978);
  static const warning = Color(0xFFE5A742);
  static const danger = Color(0xFFEF5B73);
  static const textPrimary = Color(0xFFF5F7FB);
  static const textSecondary = Color(0xFFAAB4C7);
}

@immutable
class AppSemanticColors extends ThemeExtension<AppSemanticColors> {
  final Color border;
  final Color surfaceVariant;
  final Color textPrimary;
  final Color textSecondary;
  final Color success;
  final Color warning;

  const AppSemanticColors({
    required this.border,
    required this.surfaceVariant,
    required this.textPrimary,
    required this.textSecondary,
    required this.success,
    required this.warning,
  });

  @override
  AppSemanticColors copyWith({
    Color? border,
    Color? surfaceVariant,
    Color? textPrimary,
    Color? textSecondary,
    Color? success,
    Color? warning,
  }) {
    return AppSemanticColors(
      border: border ?? this.border,
      surfaceVariant: surfaceVariant ?? this.surfaceVariant,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      success: success ?? this.success,
      warning: warning ?? this.warning,
    );
  }

  @override
  AppSemanticColors lerp(ThemeExtension<AppSemanticColors>? other, double t) {
    if (other is! AppSemanticColors) {
      return this;
    }
    return AppSemanticColors(
      border: Color.lerp(border, other.border, t)!,
      surfaceVariant: Color.lerp(surfaceVariant, other.surfaceVariant, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
    );
  }
}

extension AppSemanticColorsExtension on ThemeData {
  AppSemanticColors get semanticColors => extension<AppSemanticColors>()!;
}
