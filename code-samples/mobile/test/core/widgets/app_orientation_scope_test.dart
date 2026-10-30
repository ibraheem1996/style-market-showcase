import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_project/core/utils/responsive/android_orientation_display_info.dart';
import 'package:my_project/core/widgets/app_orientation_scope.dart';

void main() {
  const compactInfo = AndroidOrientationDisplayInfo(
    stableShortestSideDp: 430,
    isLargeScreenLayout: false,
  );
  const tabletInfo = AndroidOrientationDisplayInfo(
    stableShortestSideDp: 800,
    isLargeScreenLayout: true,
  );

  testWidgets('locks a confirmed compact Android display once', (tester) async {
    final requests = <List<DeviceOrientation>>[];

    await tester.pumpWidget(
      AppOrientationScope(
        platform: TargetPlatform.android,
        logicalDisplaySizeReader: (_) => const Size(430, 932),
        androidDisplayInfoLoader: () async => compactInfo,
        preferredOrientationsSetter: (orientations) async {
          requests.add(orientations);
        },
        child: const SizedBox.expand(),
      ),
    );
    await tester.pump();

    tester.view.physicalSize = const Size(500, 900);
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pump();

    expect(requests, [
      const [DeviceOrientation.portraitUp],
    ]);
  });

  testWidgets('keeps a normal tablet unrestricted', (tester) async {
    final requests = <List<DeviceOrientation>>[];

    await tester.pumpWidget(
      AppOrientationScope(
        platform: TargetPlatform.android,
        logicalDisplaySizeReader: (_) => const Size(800, 1280),
        androidDisplayInfoLoader: () async => tabletInfo,
        preferredOrientationsSetter: (orientations) async {
          requests.add(orientations);
        },
        child: const SizedBox.expand(),
      ),
    );
    await tester.pump();

    expect(requests, [const <DeviceOrientation>[]]);
  });

  testWidgets('stable facts keep a density-scaled tablet unrestricted', (
    tester,
  ) async {
    final requests = <List<DeviceOrientation>>[];

    await tester.pumpWidget(
      AppOrientationScope(
        platform: TargetPlatform.android,
        logicalDisplaySizeReader: (_) => const Size(533, 853),
        androidDisplayInfoLoader: () async => tabletInfo,
        preferredOrientationsSetter: (orientations) async {
          requests.add(orientations);
        },
        child: const SizedBox.expand(),
      ),
    );
    await tester.pump();

    expect(requests, [const <DeviceOrientation>[]]);
  });

  testWidgets('missing Android native facts fail open', (tester) async {
    final requests = <List<DeviceOrientation>>[];

    await tester.pumpWidget(
      AppOrientationScope(
        platform: TargetPlatform.android,
        logicalDisplaySizeReader: (_) => const Size(430, 932),
        androidDisplayInfoLoader: () async => null,
        preferredOrientationsSetter: (orientations) async {
          requests.add(orientations);
        },
        child: const SizedBox.expand(),
      ),
    );
    await tester.pump();

    expect(requests, [const <DeviceOrientation>[]]);
  });

  testWidgets('a native display-info failure fails open', (tester) async {
    final requests = <List<DeviceOrientation>>[];

    await tester.pumpWidget(
      AppOrientationScope(
        platform: TargetPlatform.android,
        logicalDisplaySizeReader: (_) => const Size(430, 932),
        androidDisplayInfoLoader: () async {
          throw PlatformException(code: 'display-unavailable');
        },
        preferredOrientationsSetter: (orientations) async {
          requests.add(orientations);
        },
        child: const SizedBox.expand(),
      ),
    );
    await tester.pump();

    expect(requests, [const <DeviceOrientation>[]]);
    expect(tester.takeException(), isNull);
  });

  testWidgets('releases portrait when a compact display becomes large', (
    tester,
  ) async {
    final requests = <List<DeviceOrientation>>[];
    var logicalDisplaySize = const Size(430, 932);
    var displayInfo = compactInfo;

    await tester.pumpWidget(
      AppOrientationScope(
        platform: TargetPlatform.android,
        logicalDisplaySizeReader: (_) => logicalDisplaySize,
        androidDisplayInfoLoader: () async => displayInfo,
        preferredOrientationsSetter: (orientations) async {
          requests.add(orientations);
        },
        child: const SizedBox.expand(),
      ),
    );
    await tester.pump();

    logicalDisplaySize = const Size(800, 1280);
    displayInfo = tabletInfo;
    tester.view.physicalSize = const Size(800, 1280);
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pump();

    expect(requests, [
      const [DeviceOrientation.portraitUp],
      const <DeviceOrientation>[],
    ]);
  });

  testWidgets('re-evaluates the policy when the app resumes', (tester) async {
    final requests = <List<DeviceOrientation>>[];
    var logicalDisplaySize = const Size(430, 932);
    var displayInfo = compactInfo;

    await tester.pumpWidget(
      AppOrientationScope(
        platform: TargetPlatform.android,
        logicalDisplaySizeReader: (_) => logicalDisplaySize,
        androidDisplayInfoLoader: () async => displayInfo,
        preferredOrientationsSetter: (orientations) async {
          requests.add(orientations);
        },
        child: const SizedBox.expand(),
      ),
    );
    await tester.pump();

    logicalDisplaySize = const Size(800, 1280);
    displayInfo = tabletInfo;
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();

    expect(requests, [
      const [DeviceOrientation.portraitUp],
      const <DeviceOrientation>[],
    ]);
  });

  testWidgets('drops stale classification before applying an orientation', (
    tester,
  ) async {
    final firstLoad = Completer<AndroidOrientationDisplayInfo?>();
    final secondLoad = Completer<AndroidOrientationDisplayInfo?>();
    final requests = <List<DeviceOrientation>>[];
    var loadCount = 0;
    var logicalDisplaySize = const Size(430, 932);

    await tester.pumpWidget(
      AppOrientationScope(
        platform: TargetPlatform.android,
        logicalDisplaySizeReader: (_) => logicalDisplaySize,
        androidDisplayInfoLoader: () {
          loadCount++;
          return loadCount == 1 ? firstLoad.future : secondLoad.future;
        },
        preferredOrientationsSetter: (orientations) async {
          requests.add(orientations);
        },
        child: const SizedBox.expand(),
      ),
    );
    expect(loadCount, 1);

    logicalDisplaySize = const Size(800, 1280);
    tester.view.physicalSize = const Size(800, 1280);
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pump();

    firstLoad.complete(compactInfo);
    await tester.pump();
    expect(loadCount, 2);
    expect(requests, isEmpty);

    secondLoad.complete(tabletInfo);
    await tester.pump();

    expect(requests, [const <DeviceOrientation>[]]);
  });

  testWidgets('serializes a newer decision behind an active setter', (
    tester,
  ) async {
    final firstSetter = Completer<void>();
    final requests = <List<DeviceOrientation>>[];
    var logicalDisplaySize = const Size(430, 932);
    var displayInfo = compactInfo;

    await tester.pumpWidget(
      AppOrientationScope(
        platform: TargetPlatform.android,
        logicalDisplaySizeReader: (_) => logicalDisplaySize,
        androidDisplayInfoLoader: () async => displayInfo,
        preferredOrientationsSetter: (orientations) {
          requests.add(orientations);
          return requests.length == 1 ? firstSetter.future : Future.value();
        },
        child: const SizedBox.expand(),
      ),
    );
    await tester.pump();
    expect(requests, [
      const [DeviceOrientation.portraitUp],
    ]);

    logicalDisplaySize = const Size(800, 1280);
    displayInfo = tabletInfo;
    tester.view.physicalSize = const Size(800, 1280);
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pump();
    expect(requests, hasLength(1));

    firstSetter.complete();
    await tester.pump();

    expect(requests, [
      const [DeviceOrientation.portraitUp],
      const <DeviceOrientation>[],
    ]);
  });

  testWidgets('a failed setter is retried on the next evaluation', (
    tester,
  ) async {
    var setterCalls = 0;

    await tester.pumpWidget(
      AppOrientationScope(
        platform: TargetPlatform.android,
        logicalDisplaySizeReader: (_) => const Size(430, 932),
        androidDisplayInfoLoader: () async => compactInfo,
        preferredOrientationsSetter: (_) async {
          setterCalls++;
          if (setterCalls == 1) throw StateError('platform failure');
        },
        child: const SizedBox.expand(),
      ),
    );
    await tester.pump();

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();

    expect(setterCalls, 2);
    expect(tester.takeException(), isNull);
  });

  testWidgets('late native results are ignored after disposal', (tester) async {
    final load = Completer<AndroidOrientationDisplayInfo?>();
    final requests = <List<DeviceOrientation>>[];

    await tester.pumpWidget(
      AppOrientationScope(
        platform: TargetPlatform.android,
        logicalDisplaySizeReader: (_) => const Size(430, 932),
        androidDisplayInfoLoader: () => load.future,
        preferredOrientationsSetter: (orientations) async {
          requests.add(orientations);
        },
        child: const SizedBox.expand(),
      ),
    );
    await tester.pumpWidget(const SizedBox.shrink());

    load.complete(compactInfo);
    await tester.pump();

    expect(requests, isEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets('iOS defers to Info.plist without runtime requests', (
    tester,
  ) async {
    var nativeLoads = 0;
    final requests = <List<DeviceOrientation>>[];

    await tester.pumpWidget(
      AppOrientationScope(
        platform: TargetPlatform.iOS,
        logicalDisplaySizeReader: (_) => const Size(390, 844),
        androidDisplayInfoLoader: () async {
          nativeLoads++;
          return compactInfo;
        },
        preferredOrientationsSetter: (orientations) async {
          requests.add(orientations);
        },
        child: const SizedBox.expand(),
      ),
    );
    await tester.pump();

    expect(nativeLoads, 0);
    expect(requests, isEmpty);
  });
}
