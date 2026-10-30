import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/typography_calibration_showcase.dart';

void main() {
  testWidgets('visual calibration matrix renders every scenario', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1200, 2200);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(home: TypographyCalibrationShowcase()),
    );

    for (
      var index = 0;
      index < TypographyCalibrationShowcase.scenarios.length;
      index++
    ) {
      expect(find.byKey(Key('typography-calibration-$index')), findsOneWidget);
    }
    expect(find.byType(Text).evaluate().length, greaterThan(40));
    expect(tester.takeException(), isNull);
  });
}
