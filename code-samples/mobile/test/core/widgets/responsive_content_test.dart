import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_project/core/utils/responsive/responsive_content_profile.dart';
import 'package:my_project/core/widgets/responsive_content.dart';

void main() {
  const childKey = Key('responsive-child');

  testWidgets('form uses full compact width with compact gutters', (
    tester,
  ) async {
    await _pumpContent(
      tester,
      size: const Size(360, 690),
      content: const ResponsiveContent.form(child: _TestChild(key: childKey)),
    );

    expect(tester.getSize(find.byKey(childKey)).width, 336);
    expect(tester.getTopLeft(find.byKey(childKey)).dx, 12);
  });

  testWidgets('semantic profiles use central widths and wider gutters', (
    tester,
  ) async {
    await _pumpContent(
      tester,
      size: const Size(1200, 800),
      content: const ResponsiveContent.standard(
        child: _TestChild(key: childKey),
      ),
    );

    expect(tester.getSize(find.byKey(childKey)).width, 760);
    expect(tester.getTopLeft(find.byKey(childKey)).dx, 220);

    await _pumpContent(
      tester,
      size: const Size(1200, 800),
      content: const ResponsiveContent.catalog(
        child: _TestChild(key: childKey),
      ),
    );

    expect(tester.getSize(find.byKey(childKey)).width, 900);
    expect(tester.getTopLeft(find.byKey(childKey)).dx, 150);
  });

  testWidgets('the generic consumer reads its selected profile', (
    tester,
  ) async {
    await _pumpContent(
      tester,
      size: const Size(1000, 800),
      content: const ResponsiveContent(
        profile: ResponsiveContentProfile.form,
        child: _TestChild(key: childKey),
      ),
    );
    expect(tester.getSize(find.byKey(childKey)).width, 560);

    await _pumpContent(
      tester,
      size: const Size(1000, 800),
      content: const ResponsiveContent(
        profile: ResponsiveContentProfile.catalog,
        child: _TestChild(key: childKey),
      ),
    );
    expect(tester.getSize(find.byKey(childKey)).width, 900);
  });

  for (final direction in TextDirection.values) {
    testWidgets('preserves symmetric gutters in $direction', (tester) async {
      await _pumpContent(
        tester,
        size: const Size(600, 960),
        textDirection: direction,
        content: const ResponsiveContent.form(child: _TestChild(key: childKey)),
      );

      expect(tester.getSize(find.byKey(childKey)).width, 552);
      expect(tester.getTopLeft(find.byKey(childKey)).dx, 24);
    });
  }

  testWidgets('does not replace MediaQuery data or safe insets', (
    tester,
  ) async {
    const mediaQueryData = MediaQueryData(
      size: Size(600, 960),
      padding: EdgeInsets.only(top: 31, bottom: 17),
      viewInsets: EdgeInsets.only(bottom: 280),
    );
    MediaQueryData? observedData;

    await _pumpContent(
      tester,
      size: mediaQueryData.size,
      mediaQueryData: mediaQueryData,
      content: ResponsiveContent.standard(
        child: Builder(
          builder: (context) {
            observedData = MediaQuery.of(context);
            return const _TestChild(key: childKey);
          },
        ),
      ),
    );

    expect(observedData?.size, mediaQueryData.size);
    expect(observedData?.padding, mediaQueryData.padding);
    expect(observedData?.viewInsets, mediaQueryData.viewInsets);
  });

  testWidgets('sliver content leaves a surrounding header full width', (
    tester,
  ) async {
    const headerKey = Key('full-width-header');
    await _pumpContent(
      tester,
      size: const Size(1200, 800),
      content: const CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: SizedBox(key: headerKey, height: 20)),
          ResponsiveSliverContent.standard(
            slivers: [SliverToBoxAdapter(child: _TestChild(key: childKey))],
          ),
        ],
      ),
    );

    expect(tester.getSize(find.byKey(headerKey)).width, 1200);
    expect(tester.getSize(find.byKey(childKey)).width, 760);
    expect(tester.getTopLeft(find.byKey(childKey)).dx, 220);
    expect(tester.getTopLeft(find.byKey(childKey)).dy, 44);
  });
}

Future<void> _pumpContent(
  WidgetTester tester, {
  required Size size,
  required Widget content,
  TextDirection textDirection = TextDirection.ltr,
  MediaQueryData? mediaQueryData,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    MediaQuery(
      data: mediaQueryData ?? MediaQueryData(size: size),
      child: Directionality(textDirection: textDirection, child: content),
    ),
  );
}

class _TestChild extends StatelessWidget {
  const _TestChild({super.key});

  @override
  Widget build(BuildContext context) => const SizedBox(height: 20);
}
