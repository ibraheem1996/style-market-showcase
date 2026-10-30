import 'package:flutter/services.dart';

import 'android_orientation_display_info.dart';

/// The platform action selected by [AppOrientationPolicy].
enum AppOrientationDecision {
  portraitLocked,
  unrestricted,
  platformManaged;

  /// Orientations sent to Android, or `null` when native configuration owns it.
  List<DeviceOrientation>? get preferredOrientations {
    return switch (this) {
      AppOrientationDecision.portraitLocked => const [
        DeviceOrientation.portraitUp,
      ],
      AppOrientationDecision.unrestricted => const [],
      AppOrientationDecision.platformManaged => null,
    };
  }
}

/// Keeps confirmed compact Android displays in portrait without locking large
/// or ambiguously classified displays.
abstract final class AppOrientationPolicy {
  static const double unlockedShortestSide = 600;

  /// Returns a runtime decision for Android and defers other platforms to their
  /// native configuration.
  ///
  /// Android locks only when both current and stable display facts confirm a
  /// compact screen. Missing native facts deliberately fail open to avoid
  /// introducing letterboxing on a potentially large display.
  static AppOrientationDecision decisionFor({
    required TargetPlatform platform,
    required Size logicalDisplaySize,
    required AndroidOrientationDisplayInfo? androidDisplayInfo,
  }) {
    if (platform != TargetPlatform.android) {
      return AppOrientationDecision.platformManaged;
    }

    if (androidDisplayInfo == null) {
      return AppOrientationDecision.unrestricted;
    }

    final hasLargeCurrentDisplay =
        logicalDisplaySize.shortestSide >= unlockedShortestSide;
    final hasLargeStableDisplay =
        androidDisplayInfo.stableShortestSideDp >= unlockedShortestSide;

    if (hasLargeCurrentDisplay ||
        hasLargeStableDisplay ||
        androidDisplayInfo.isLargeScreenLayout) {
      return AppOrientationDecision.unrestricted;
    }

    return AppOrientationDecision.portraitLocked;
  }
}
