import 'package:flutter/services.dart';

/// Stable Android display facts used to avoid density-driven misclassification.
class AndroidOrientationDisplayInfo {
  const AndroidOrientationDisplayInfo({
    required this.stableShortestSideDp,
    required this.isLargeScreenLayout,
  });

  /// The active display's shortest physical side normalized by stable density.
  final double stableShortestSideDp;

  /// Whether Android classifies the current display as large or xlarge.
  final bool isLargeScreenLayout;
}

/// Reads Android display facts that Flutter's current DPR does not preserve.
class AndroidOrientationDisplayInfoReader {
  const AndroidOrientationDisplayInfoReader();

  static const MethodChannel _channel = MethodChannel(
    'com.alhin.stylemarket/orientation_display_info',
  );

  /// Returns validated native facts, or `null` for an incomplete response.
  Future<AndroidOrientationDisplayInfo?> read() async {
    final result = await _channel.invokeMapMethod<String, Object?>(
      'getOrientationDisplayInfo',
    );
    final stableShortestSideDp = result?['stableShortestSideDp'];
    final isLargeScreenLayout = result?['isLargeScreenLayout'];

    if (stableShortestSideDp is! num ||
        stableShortestSideDp <= 0 ||
        isLargeScreenLayout is! bool) {
      return null;
    }

    return AndroidOrientationDisplayInfo(
      stableShortestSideDp: stableShortestSideDp.toDouble(),
      isLargeScreenLayout: isLargeScreenLayout,
    );
  }
}
