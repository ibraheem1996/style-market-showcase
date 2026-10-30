import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:my_project/core/utils/responsive/app_window_class.dart';

void main() {
  group('AppWindowClass', () {
    test('classifies breakpoint edges from application-window width', () {
      expect(AppWindowClass.fromWidth(599), AppWindowClass.compact);
      expect(AppWindowClass.fromWidth(600), AppWindowClass.medium);
      expect(AppWindowClass.fromWidth(839), AppWindowClass.medium);
      expect(AppWindowClass.fromWidth(840), AppWindowClass.expanded);
    });

    test('classifies a Size by width only', () {
      expect(
        AppWindowClass.fromSize(const Size(500, 1200)),
        AppWindowClass.compact,
      );
      expect(
        AppWindowClass.fromSize(const Size(900, 200)),
        AppWindowClass.expanded,
      );
    });
  });

  group('isShortWindow', () {
    test('uses the 480 logical-pixel height boundary', () {
      expect(isShortWindow(const Size(1200, 479)), isTrue);
      expect(isShortWindow(const Size(320, 480)), isFalse);
    });

    test('does not affect width classification', () {
      const window = Size(840, 479);

      expect(isShortWindow(window), isTrue);
      expect(AppWindowClass.fromSize(window), AppWindowClass.expanded);
    });
  });
}
