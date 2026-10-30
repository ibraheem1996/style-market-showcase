import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:my_project/binding_route_middleware/route.dart';
import 'package:my_project/core/media/image_url_normalizer.dart';
import 'package:my_project/core/navigation/full_image_route_args.dart';
import 'package:my_project/core/widgets/app_product_image_viewer.dart';

void main() {
  tearDown(Get.reset);

  testWidgets('image tap opens the viewer without triggering the card tap', (
    tester,
  ) async {
    var cardTaps = 0;
    const imageKey = ValueKey('product-image');

    await tester.pumpWidget(
      GetMaterialApp(
        getPages: [
          GetPage(
            name: RouteName.fullImage,
            page: () => const Scaffold(body: Text('full image')),
          ),
        ],
        home: Scaffold(
          body: Material(
            child: InkWell(
              onTap: () => cardTaps++,
              child: AppProductImageViewer(
                displayImage: '/third.jpg',
                images: const [
                  '/first.jpg',
                  ' /second.jpg ',
                  '',
                  '/second.jpg',
                  '/third.jpg',
                ],
                child: const SizedBox(key: imageKey, width: 120, height: 120),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tapAt(tester.getCenter(find.byKey(imageKey)));
    await tester.pumpAndSettle();

    expect(cardTaps, 0);
    expect(find.text('full image'), findsOneWidget);

    final args = Get.arguments as FullImageRouteArgs;
    expect(args.initialIndex, 2);
    expect(args.images, [
      normalizeProductImageUrl('/first.jpg'),
      normalizeProductImageUrl('/second.jpg'),
      normalizeProductImageUrl('/third.jpg'),
    ]);
  });

  testWidgets('missing display image is appended and selected', (tester) async {
    const imageKey = ValueKey('missing-display-image');

    await tester.pumpWidget(
      GetMaterialApp(
        getPages: [
          GetPage(
            name: RouteName.fullImage,
            page: () => const Scaffold(body: Text('full image')),
          ),
        ],
        home: const Scaffold(
          body: AppProductImageViewer(
            displayImage: '/display.jpg',
            images: ['/first.jpg', '/second.jpg'],
            child: SizedBox(key: imageKey, width: 120, height: 120),
          ),
        ),
      ),
    );

    await tester.tapAt(tester.getCenter(find.byKey(imageKey)));
    await tester.pumpAndSettle();

    final args = Get.arguments as FullImageRouteArgs;
    expect(args.initialIndex, 2);
    expect(args.images, [
      normalizeProductImageUrl('/first.jpg'),
      normalizeProductImageUrl('/second.jpg'),
      normalizeProductImageUrl('/display.jpg'),
    ]);
  });

  testWidgets('unusable media leaves the surrounding card tap available', (
    tester,
  ) async {
    var cardTaps = 0;
    const imageKey = ValueKey('empty-product-image');

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Material(
            child: InkWell(
              onTap: () => cardTaps++,
              child: const AppProductImageViewer(
                displayImage: '',
                images: [],
                child: SizedBox(key: imageKey, width: 120, height: 120),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tapAt(tester.getCenter(find.byKey(imageKey)));
    await tester.pump();

    expect(cardTaps, 1);
  });
}
