import 'package:flutter/material.dart';

/// App colors that have no matching role in Material [ColorScheme].
class AppSemanticColors extends ThemeExtension<AppSemanticColors> {
  const AppSemanticColors({required this.warning});

  final Color warning;

  @override
  AppSemanticColors copyWith({Color? warning}) {
    return AppSemanticColors(warning: warning ?? this.warning);
  }

  @override
  AppSemanticColors lerp(AppSemanticColors? other, double t) {
    if (other == null) return this;
    return AppSemanticColors(warning: Color.lerp(warning, other.warning, t)!);
  }
}

extension AppThemeDataExtension on ThemeData {
  AppSemanticColors get semanticColors => extension<AppSemanticColors>()!;
}
