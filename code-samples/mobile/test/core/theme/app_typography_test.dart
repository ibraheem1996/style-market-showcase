import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_project/core/theme/app_typography.dart';

void main() {
  group('AppTypography', () {
    testWidgets('bundles the declared Tajawal and Playfair font assets', (
      tester,
    ) async {
      final manifest =
          jsonDecode(await rootBundle.loadString('FontManifest.json'))
              as List<dynamic>;
      final families = {
        for (final entry in manifest.cast<Map<String, dynamic>>())
          entry['family'] as String: entry['fonts'] as List<dynamic>,
      };

      expect(_declaredWeights(families['Tajawal']!), [
        200,
        300,
        400,
        500,
        700,
        800,
        900,
      ]);
      expect(_declaredWeights(families['Playfair']!), [
        400,
        500,
        600,
        700,
        800,
        900,
      ]);
      expect(_declaredAssets(families['Tajawal']!), [
        'assets/fonts/Tajawal/Tajawal-ExtraLight.ttf',
        'assets/fonts/Tajawal/Tajawal-Light.ttf',
        'assets/fonts/Tajawal/Tajawal-Regular.ttf',
        'assets/fonts/Tajawal/Tajawal-Medium.ttf',
        'assets/fonts/Tajawal/Tajawal-Bold.ttf',
        'assets/fonts/Tajawal/Tajawal-ExtraBold.ttf',
        'assets/fonts/Tajawal/Tajawal-Black.ttf',
      ]);
      expect(_declaredAssets(families['Playfair']!), [
        'assets/fonts/Playfair/PlayfairDisplay-Regular.ttf',
        'assets/fonts/Playfair/PlayfairDisplay-Medium.ttf',
        'assets/fonts/Playfair/PlayfairDisplay-SemiBold.ttf',
        'assets/fonts/Playfair/PlayfairDisplay-Bold.ttf',
        'assets/fonts/Playfair/PlayfairDisplay-ExtraBold.ttf',
        'assets/fonts/Playfair/PlayfairDisplay-Black.ttf',
      ]);
    });

    testWidgets('resolves exact sizes at each window class', (tester) async {
      for (final scenario in <(double, double, double)>[
        (599, 19, 17),
        (600, 20, 17),
        (840, 21, 18),
      ]) {
        final typography = await _pumpTypography(tester, width: scenario.$1);

        expect(typography.appBar.title.fontSize, scenario.$2);
        expect(typography.productCard.currentPrice.fontSize, scenario.$3);
      }
    });

    testWidgets('uses semantic colors from the active ColorScheme', (
      tester,
    ) async {
      for (final brightness in Brightness.values) {
        final colors = ColorScheme.fromSeed(
          seedColor: brightness == Brightness.light
              ? Colors.blue
              : Colors.orange,
          brightness: brightness,
        );
        final typography = await _pumpTypography(tester, colorScheme: colors);

        expect(
          typography.contentText.primary.color,
          colors.onSecondary.withValues(alpha: 0.8),
        );
        expect(
          typography.contentText.supporting.color,
          colors.onSurfaceVariant,
        );
        expect(typography.productCard.currentPrice.color, colors.primary);
        expect(typography.formField.errorMessage.color, colors.error);
        expect(typography.mediaOverlay.message.color, colors.onInverseSurface);
        expect(typography.tooltip.message.color, colors.onInverseSurface);
        expect(typography.snackbar.message.color, colors.onSurface);
        expect(typography.button.label.color, isNull);
        expect(typography.badge.label.color, isNull);
        expect(typography.status.label.color, isNull);
      }
    });

    testWidgets('selects declared locale fonts and available medium weights', (
      tester,
    ) async {
      final arabic = await _pumpTypography(tester, locale: const Locale('ar'));
      final english = await _pumpTypography(tester, locale: const Locale('en'));

      expect(arabic.productCard.name.fontFamily, 'Tajawal');
      expect(arabic.productCard.name.fontWeight, FontWeight.w500);
      expect(english.productCard.name.fontFamily, 'Playfair');
      expect(english.productCard.name.fontWeight, FontWeight.w600);
      expect(arabic.page.title.fontWeight, FontWeight.w700);
      expect(english.summary.finalValue.fontWeight, FontWeight.w900);
    });

    testWidgets('keeps base size while system scaling affects rendering', (
      tester,
    ) async {
      Future<(double, double)> renderAt(double scale) async {
        late double baseSize;
        late double renderedHeight;
        await tester.pumpWidget(
          _TypographyHost(
            width: 360,
            textScaler: TextScaler.linear(scale),
            child: Builder(
              builder: (context) {
                final style = context.appTypography.contentText.primary;
                baseSize = style.fontSize!;
                final painter = TextPainter(
                  text: TextSpan(text: 'Scaling sample', style: style),
                  textDirection: TextDirection.ltr,
                  textScaler: MediaQuery.textScalerOf(context),
                )..layout();
                renderedHeight = painter.height;
                return Text(
                  'Scaling sample',
                  key: const Key('text'),
                  style: style,
                );
              },
            ),
          ),
        );
        return (baseSize, renderedHeight);
      }

      final normal = await renderAt(1);
      final scaled = await renderAt(2);

      expect(normal.$1, 16);
      expect(scaled.$1, 16);
      expect(scaled.$2, greaterThan(normal.$2));
    });

    testWidgets('defines representative semantic style details', (
      tester,
    ) async {
      final typography = await _pumpTypography(tester);

      expect(typography.page.title.height, 1.30);
      expect(typography.page.title.letterSpacing, 0);
      expect(typography.page.subtitle.fontSize, 18);
      expect(
        typography.productCard.oldPrice.decoration,
        TextDecoration.lineThrough,
      );
      expect(
        typography.productCard.oldPrice.decorationColor,
        typography.productCard.oldPrice.color,
      );
      expect(typography.formField.errorMessage.fontSize, 12);
      expect(typography.appBar.subtitle.fontSize, 13);
      expect(typography.navigation.searchPrompt.fontSize, 14);
      expect(typography.filterChip.label.fontSize, 14);
      expect(typography.status.title.fontSize, 18);
      expect(typography.status.detail.fontSize, 13);
      expect(typography.snackbar.title.fontSize, 16);
      expect(typography.summary.finalValue.fontSize, 18);
    });
  });
}

List<int> _declaredWeights(List<dynamic> fonts) {
  return fonts
      .cast<Map<String, dynamic>>()
      .map((font) => font['weight'] as int)
      .toList();
}

List<String> _declaredAssets(List<dynamic> fonts) {
  return fonts
      .cast<Map<String, dynamic>>()
      .map((font) => font['asset'] as String)
      .toList();
}

Future<AppTypography> _pumpTypography(
  WidgetTester tester, {
  double width = 360,
  Locale locale = const Locale('en'),
  ColorScheme? colorScheme,
}) async {
  late AppTypography typography;
  await tester.pumpWidget(
    _TypographyHost(
      width: width,
      locale: locale,
      colorScheme: colorScheme,
      child: Builder(
        builder: (context) {
          typography = context.appTypography;
          return const SizedBox.shrink();
        },
      ),
    ),
  );
  return typography;
}

class _TypographyHost extends StatelessWidget {
  const _TypographyHost({
    required this.width,
    required this.child,
    this.locale = const Locale('en'),
    this.colorScheme,
    this.textScaler = TextScaler.noScaling,
  });

  final double width;
  final Widget child;
  final Locale locale;
  final ColorScheme? colorScheme;
  final TextScaler textScaler;

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQueryData(size: Size(width, 800), textScaler: textScaler),
      child: Localizations(
        locale: locale,
        delegates: const [DefaultWidgetsLocalizations.delegate],
        child: Directionality(
          textDirection: locale.languageCode == 'ar'
              ? TextDirection.rtl
              : TextDirection.ltr,
          child: Theme(
            data: ThemeData(colorScheme: colorScheme),
            child: Material(child: child),
          ),
        ),
      ),
    );
  }
}
