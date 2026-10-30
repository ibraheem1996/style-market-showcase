import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_project/core/utils/responsive/android_orientation_display_info.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel(
    'com.alhin.stylemarket/orientation_display_info',
  );
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  tearDown(() {
    messenger.setMockMethodCallHandler(channel, null);
  });

  test('maps validated Android display facts', () async {
    messenger.setMockMethodCallHandler(channel, (call) async {
      expect(call.method, 'getOrientationDisplayInfo');
      return <String, Object?>{
        'stableShortestSideDp': 800.0,
        'isLargeScreenLayout': true,
      };
    });

    final info = await const AndroidOrientationDisplayInfoReader().read();

    expect(info?.stableShortestSideDp, 800);
    expect(info?.isLargeScreenLayout, isTrue);
  });

  test('rejects incomplete Android display facts', () async {
    messenger.setMockMethodCallHandler(channel, (_) async {
      return <String, Object?>{
        'stableShortestSideDp': 0,
        'isLargeScreenLayout': true,
      };
    });

    final info = await const AndroidOrientationDisplayInfoReader().read();

    expect(info, isNull);
  });
}
