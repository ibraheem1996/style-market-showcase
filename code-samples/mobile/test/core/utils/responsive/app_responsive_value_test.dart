import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_project/core/utils/responsive/app_responsive_value.dart';
import 'package:my_project/core/utils/responsive/app_window_class.dart';

void main() {
  group('AppResponsiveValue', () {
    testWidgets('selects the supplied value at each window-class boundary', (
      tester,
    ) async {
      expect(await _valueAt(tester, const Size(599, 800)), 0.6);
      expect(await _valueAt(tester, const Size(600, 800)), 0.5);
      expect(await _valueAt(tester, const Size(839, 800)), 0.5);
      expect(await _valueAt(tester, const Size(840, 800)), 0.4);
    });

    testWidgets('identifies window classes and helper predicates correctly', (
      tester,
    ) async {
      // Compact (< 600)
      await _pumpContext(tester, const Size(500, 800), (context) {
        expect(AppResponsiveValue.isCompact(context), isTrue);
        expect(AppResponsiveValue.isMedium(context), isFalse);
        expect(AppResponsiveValue.isExpanded(context), isFalse);
        expect(AppResponsiveValue.isAtLeastMedium(context), isFalse);

        expect(context.windowClass, AppWindowClass.compact);
        expect(context.isCompact, isTrue);
        expect(context.isMedium, isFalse);
        expect(context.isExpanded, isFalse);
        expect(context.isAtLeastMedium, isFalse);
      });

      // Medium (600 - 839)
      await _pumpContext(tester, const Size(700, 800), (context) {
        expect(AppResponsiveValue.isCompact(context), isFalse);
        expect(AppResponsiveValue.isMedium(context), isTrue);
        expect(AppResponsiveValue.isExpanded(context), isFalse);
        expect(AppResponsiveValue.isAtLeastMedium(context), isTrue);

        expect(context.windowClass, AppWindowClass.medium);
        expect(context.isCompact, isFalse);
        expect(context.isMedium, isTrue);
        expect(context.isExpanded, isFalse);
        expect(context.isAtLeastMedium, isTrue);
      });

      // Expanded (>= 840)
      await _pumpContext(tester, const Size(900, 800), (context) {
        expect(AppResponsiveValue.isCompact(context), isFalse);
        expect(AppResponsiveValue.isMedium(context), isFalse);
        expect(AppResponsiveValue.isExpanded(context), isTrue);
        expect(AppResponsiveValue.isAtLeastMedium(context), isTrue);

        expect(context.windowClass, AppWindowClass.expanded);
        expect(context.isCompact, isFalse);
        expect(context.isMedium, isFalse);
        expect(context.isExpanded, isTrue);
        expect(context.isAtLeastMedium, isTrue);
      });
    });
  });

  group('AppTextScaleValue', () {
    testWidgets('identifies text scale helpers correctly', (tester) async {
      // Normal scale (1.0)
      await _pumpTextScaleContext(tester, 1.0, (context) {
        expect(AppTextScaleValue.scaleFactor(context), 1.0);
        expect(AppTextScaleValue.isNormal(context), isTrue);
        expect(AppTextScaleValue.isLarge(context), isFalse);
        expect(AppTextScaleValue.isLargeOnly(context), isFalse);
        expect(AppTextScaleValue.isExtraLarge(context), isFalse);

        expect(context.isNormalText, isTrue);
        expect(context.isLargeText, isFalse);
        expect(context.isLargeTextOnly, isFalse);
        expect(context.isExtraLargeText, isFalse);
      });

      // Large scale (1.6)
      await _pumpTextScaleContext(tester, 1.6, (context) {
        expect(AppTextScaleValue.scaleFactor(context), closeTo(1.6, 0.001));
        expect(AppTextScaleValue.isNormal(context), isFalse);
        expect(AppTextScaleValue.isLarge(context), isTrue);
        expect(AppTextScaleValue.isLargeOnly(context), isTrue);
        expect(AppTextScaleValue.isExtraLarge(context), isFalse);

        expect(context.isNormalText, isFalse);
        expect(context.isLargeText, isTrue);
        expect(context.isLargeTextOnly, isTrue);
        expect(context.isExtraLargeText, isFalse);
      });

      // Extra large scale (2.2)
      await _pumpTextScaleContext(tester, 2.2, (context) {
        expect(AppTextScaleValue.scaleFactor(context), closeTo(2.2, 0.001));
        expect(AppTextScaleValue.isNormal(context), isFalse);
        expect(AppTextScaleValue.isLarge(context), isTrue);
        expect(AppTextScaleValue.isLargeOnly(context), isFalse);
        expect(AppTextScaleValue.isExtraLarge(context), isTrue);

        expect(context.isNormalText, isFalse);
        expect(context.isLargeText, isTrue);
        expect(context.isLargeTextOnly, isFalse);
        expect(context.isExtraLargeText, isTrue);
      });
    });
  });
}

Future<double> _valueAt(WidgetTester tester, Size size) async {
  late double value;
  await _pumpContext(tester, size, (context) {
    value = AppResponsiveValue.resolve(
      context,
      compact: 0.6,
      medium: 0.5,
      expanded: 0.4,
    );
  });
  return value;
}

Future<void> _pumpContext(
  WidgetTester tester,
  Size size,
  void Function(BuildContext context) callback,
) async {
  await tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(size: size),
      child: Builder(
        builder: (context) {
          callback(context);
          return const SizedBox.shrink();
        },
      ),
    ),
  );
}

Future<void> _pumpTextScaleContext(
  WidgetTester tester,
  double textScaleFactor,
  void Function(BuildContext context) callback,
) async {
  await tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(
        textScaler: TextScaler.linear(textScaleFactor),
      ),
      child: Builder(
        builder: (context) {
          callback(context);
          return const SizedBox.shrink();
        },
      ),
    ),
  );
}
