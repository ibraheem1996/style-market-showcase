import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_project/core/theme/dark_theme.dart';
import 'package:my_project/core/theme/light_theme.dart';
import 'package:my_project/core/utils/responsive/app_design_tokens.dart';

void main() {
  const scenarios = [
    (size: Size(599, 800), appBar: 24.0, standard: 20.0),
    (size: Size(600, 800), appBar: 26.0, standard: 23.0),
    (size: Size(840, 800), appBar: 28.0, standard: 26.0),
  ];

  for (final scenario in scenarios) {
    testWidgets(
      'light and dark themes source icon roles at ${scenario.size.width}',
      (tester) async {
        late ThemeData light;
        late ThemeData dark;
        late double semanticAppBarSize;
        late double semanticStandardSize;
        late Widget lightBackIcon;
        late Widget darkBackIcon;

        await tester.pumpWidget(
          MediaQuery(
            data: MediaQueryData(size: scenario.size),
            child: Builder(
              builder: (context) {
                semanticAppBarSize = AppIconSizes.appBarAction(context);
                semanticStandardSize = AppIconSizes.standardAction(context);
                light = lightTheme(context);
                dark = darkTheme(context);
                lightBackIcon = light.actionIconTheme!.backButtonIconBuilder!(
                  context,
                );
                darkBackIcon = dark.actionIconTheme!.backButtonIconBuilder!(
                  context,
                );
                return const SizedBox.shrink();
              },
            ),
          ),
        );

        expect(semanticAppBarSize, scenario.appBar);
        expect(semanticStandardSize, scenario.standard);
        _expectThemeUsesSemanticIconSizes(
          light,
          appBarSize: semanticAppBarSize,
          standardSize: semanticStandardSize,
          backIcon: lightBackIcon,
        );
        _expectThemeUsesSemanticIconSizes(
          dark,
          appBarSize: semanticAppBarSize,
          standardSize: semanticStandardSize,
          backIcon: darkBackIcon,
        );
      },
    );
  }
}

void _expectThemeUsesSemanticIconSizes(
  ThemeData theme, {
  required double appBarSize,
  required double standardSize,
  required Widget backIcon,
}) {
  expect(theme.appBarTheme.iconTheme?.size, appBarSize);
  expect(theme.appBarTheme.actionsIconTheme?.size, appBarSize);
  expect(
    theme.iconButtonTheme.style?.iconSize?.resolve(<WidgetState>{}),
    standardSize,
  );

  expect(backIcon, isA<Icon>());
  expect((backIcon as Icon).size, appBarSize);
}
