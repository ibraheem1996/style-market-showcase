import 'package:flutter/material.dart';

@immutable
class AppDataVisualizationTheme
    extends ThemeExtension<AppDataVisualizationTheme> {
  final Color seriesPrimary;
  final Color seriesSecondary;
  final Color seriesTertiary;
  final Color seriesSuccess;
  final Color seriesWarning;
  final Color seriesDanger;
  final Color cardHighlight;

  const AppDataVisualizationTheme({
    required this.seriesPrimary,
    required this.seriesSecondary,
    required this.seriesTertiary,
    required this.seriesSuccess,
    required this.seriesWarning,
    required this.seriesDanger,
    required this.cardHighlight,
  });

  @override
  AppDataVisualizationTheme copyWith({
    Color? seriesPrimary,
    Color? seriesSecondary,
    Color? seriesTertiary,
    Color? seriesSuccess,
    Color? seriesWarning,
    Color? seriesDanger,
    Color? cardHighlight,
  }) {
    return AppDataVisualizationTheme(
      seriesPrimary: seriesPrimary ?? this.seriesPrimary,
      seriesSecondary: seriesSecondary ?? this.seriesSecondary,
      seriesTertiary: seriesTertiary ?? this.seriesTertiary,
      seriesSuccess: seriesSuccess ?? this.seriesSuccess,
      seriesWarning: seriesWarning ?? this.seriesWarning,
      seriesDanger: seriesDanger ?? this.seriesDanger,
      cardHighlight: cardHighlight ?? this.cardHighlight,
    );
  }

  @override
  AppDataVisualizationTheme lerp(
    ThemeExtension<AppDataVisualizationTheme>? other,
    double t,
  ) {
    if (other is! AppDataVisualizationTheme) {
      return this;
    }
    return AppDataVisualizationTheme(
      seriesPrimary: Color.lerp(seriesPrimary, other.seriesPrimary, t)!,
      seriesSecondary: Color.lerp(seriesSecondary, other.seriesSecondary, t)!,
      seriesTertiary: Color.lerp(seriesTertiary, other.seriesTertiary, t)!,
      seriesSuccess: Color.lerp(seriesSuccess, other.seriesSuccess, t)!,
      seriesWarning: Color.lerp(seriesWarning, other.seriesWarning, t)!,
      seriesDanger: Color.lerp(seriesDanger, other.seriesDanger, t)!,
      cardHighlight: Color.lerp(cardHighlight, other.cardHighlight, t)!,
    );
  }
}

extension AppDataVisualizationThemeExtension on ThemeData {
  AppDataVisualizationTheme get dataVisTheme =>
      extension<AppDataVisualizationTheme>()!;
}
