import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_project/core/utils/responsive/android_orientation_display_info.dart';
import 'package:my_project/core/utils/responsive/app_orientation_policy.dart';

void main() {
  const compactInfo = AndroidOrientationDisplayInfo(
    stableShortestSideDp: 430,
    isLargeScreenLayout: false,
  );
  const stableTabletInfo = AndroidOrientationDisplayInfo(
    stableShortestSideDp: 800,
    isLargeScreenLayout: true,
  );

  group('AppOrientationPolicy', () {
    test('locks a confirmed compact Android display to portrait', () {
      expect(
        AppOrientationPolicy.decisionFor(
          platform: TargetPlatform.android,
          logicalDisplaySize: const Size(430, 932),
          androidDisplayInfo: compactInfo,
        ),
        AppOrientationDecision.portraitLocked,
      );
    });

    test('uses the 599 and 600 shortest-side boundary', () {
      const belowBoundaryInfo = AndroidOrientationDisplayInfo(
        stableShortestSideDp: 599,
        isLargeScreenLayout: false,
      );
      const atBoundaryInfo = AndroidOrientationDisplayInfo(
        stableShortestSideDp: 600,
        isLargeScreenLayout: false,
      );

      expect(
        AppOrientationPolicy.decisionFor(
          platform: TargetPlatform.android,
          logicalDisplaySize: const Size(599, 900),
          androidDisplayInfo: belowBoundaryInfo,
        ),
        AppOrientationDecision.portraitLocked,
      );
      expect(
        AppOrientationPolicy.decisionFor(
          platform: TargetPlatform.android,
          logicalDisplaySize: const Size(600, 960),
          androidDisplayInfo: belowBoundaryInfo,
        ),
        AppOrientationDecision.unrestricted,
      );
      expect(
        AppOrientationPolicy.decisionFor(
          platform: TargetPlatform.android,
          logicalDisplaySize: const Size(533, 853),
          androidDisplayInfo: atBoundaryInfo,
        ),
        AppOrientationDecision.unrestricted,
      );
    });

    test('unlocks a normal tablet', () {
      expect(
        AppOrientationPolicy.decisionFor(
          platform: TargetPlatform.android,
          logicalDisplaySize: const Size(800, 1280),
          androidDisplayInfo: stableTabletInfo,
        ),
        AppOrientationDecision.unrestricted,
      );
    });

    test('stable display facts keep a density-scaled tablet unlocked', () {
      expect(
        AppOrientationPolicy.decisionFor(
          platform: TargetPlatform.android,
          logicalDisplaySize: const Size(533, 853),
          androidDisplayInfo: stableTabletInfo,
        ),
        AppOrientationDecision.unrestricted,
      );
    });

    test(
      'large Android layout classification unlocks a borderline display',
      () {
        const largeLayoutInfo = AndroidOrientationDisplayInfo(
          stableShortestSideDp: 533,
          isLargeScreenLayout: true,
        );

        expect(
          AppOrientationPolicy.decisionFor(
            platform: TargetPlatform.android,
            logicalDisplaySize: const Size(533, 853),
            androidDisplayInfo: largeLayoutInfo,
          ),
          AppOrientationDecision.unrestricted,
        );
      },
    );

    test('missing Android native facts fail open', () {
      expect(
        AppOrientationPolicy.decisionFor(
          platform: TargetPlatform.android,
          logicalDisplaySize: const Size(430, 932),
          androidDisplayInfo: null,
        ),
        AppOrientationDecision.unrestricted,
      );
    });

    test('non-Android platforms defer to native configuration', () {
      for (final platform in <TargetPlatform>[
        TargetPlatform.iOS,
        TargetPlatform.macOS,
        TargetPlatform.windows,
        TargetPlatform.linux,
        TargetPlatform.fuchsia,
      ]) {
        expect(
          AppOrientationPolicy.decisionFor(
            platform: platform,
            logicalDisplaySize: const Size(390, 844),
            androidDisplayInfo: null,
          ),
          AppOrientationDecision.platformManaged,
        );
      }
    });
  });
}
