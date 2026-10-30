import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:multi_product_store_admin_web/core/responsive/app_breakpoints.dart';
import 'package:multi_product_store_admin_web/core/responsive/app_screen_info.dart';

void main() {
  group('AppBreakpoints', () {
    test('classifies compact width', () {
      expect(AppBreakpoints.classify(729), AppScreenClass.compact);
    });

    test('classifies medium width', () {
      expect(AppBreakpoints.classify(730), AppScreenClass.medium);
      expect(AppBreakpoints.classify(1023), AppScreenClass.medium);
    });

    test('classifies expanded width', () {
      expect(AppBreakpoints.classify(1024), AppScreenClass.expanded);
      expect(AppBreakpoints.classify(1439), AppScreenClass.expanded);
    });

    test('classifies wide width', () {
      expect(AppBreakpoints.classify(1440), AppScreenClass.wide);
    });
  });

  group('AppScreenInfo', () {
    test('resolves flags and orientation from size', () {
      final compact = AppScreenInfo.fromSize(const Size(375, 812));
      final wide = AppScreenInfo.fromSize(const Size(1440, 900));

      expect(compact.isCompact, isTrue);
      expect(compact.isDesktop, isFalse);
      expect(compact.orientation, Orientation.portrait);

      expect(wide.isWide, isTrue);
      expect(wide.isDesktop, isTrue);
      expect(wide.orientation, Orientation.landscape);
    });
  });
}
