import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_project/core/media/app_media_profile.dart';

void main() {
  test('profiles keep independent ratio and fit contracts', () {
    expect(AppMediaProfile.productCard.aspectRatio, 3 / 4);
    expect(AppMediaProfile.productCard.fit, BoxFit.cover);

    expect(AppMediaProfile.homeBanner.aspectRatio, 2);
    expect(AppMediaProfile.homeBanner.fit, BoxFit.cover);

    expect(AppMediaProfile.homeCollection.aspectRatio, 3 / 2);

    expect(AppMediaProfile.homeCategory.aspectRatio, 1);
    expect(AppMediaProfile.homeCategory.fit, BoxFit.cover);

    expect(AppMediaProfile.categoryThumbnail.aspectRatio, 1);
    expect(AppMediaProfile.categoryThumbnail.fit, BoxFit.cover);

    expect(AppMediaProfile.orderThumbnail.aspectRatio, 1);
    expect(AppMediaProfile.orderThumbnail.fit, BoxFit.cover);

    expect(AppMediaProfile.productDetails.aspectRatio, 3 / 4);
    expect(AppMediaProfile.productDetails.fit, BoxFit.contain);
  });

  testWidgets('decode size follows layout, DPR, quality, and profile caps', (
    tester,
  ) async {
    late BuildContext testContext;

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(devicePixelRatio: 2),
        child: Builder(
          builder: (context) {
            testContext = context;
            return const SizedBox();
          },
        ),
      ),
    );

    final normal = AppMediaProfile.productCard.resolveDecodeSize(
      laidOutSize: const Size(120, 160),
      context: testContext,
    );

    final capped = AppMediaProfile.productCard.resolveDecodeSize(
      laidOutSize: const Size(400, 600),
      qualityFactor: 1.2,
      context: testContext,
    );

    expect([normal?.width, normal?.height], [240, 320]);

    expect([capped?.width, capped?.height], [960, 1280]);
  });

  testWidgets('category thumbnails keep a square 256-pixel decode cap', (
    tester,
  ) async {
    late BuildContext testContext;

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(devicePixelRatio: 3),
        child: Builder(
          builder: (context) {
            testContext = context;
            return const SizedBox();
          },
        ),
      ),
    );

    final decodeSize = AppMediaProfile.categoryThumbnail.resolveDecodeSize(
      laidOutSize: const Size.square(96),
      context: testContext,
    );

    expect([decodeSize?.width, decodeSize?.height], [256, 256]);
  });

  testWidgets('order thumbnails keep a square 512-pixel decode cap', (
    tester,
  ) async {
    late BuildContext testContext;

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(devicePixelRatio: 3),
        child: Builder(
          builder: (context) {
            testContext = context;
            return const SizedBox();
          },
        ),
      ),
    );

    final decodeSize = AppMediaProfile.orderThumbnail.resolveDecodeSize(
      laidOutSize: const Size.square(200),
      context: testContext,
    );

    expect([decodeSize?.width, decodeSize?.height], [512, 512]);
  });

  testWidgets('decode size stays absent for unbounded or invalid geometry', (
    tester,
  ) async {
    late BuildContext testContext;

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(devicePixelRatio: 2),
        child: Builder(
          builder: (context) {
            testContext = context;
            return const SizedBox();
          },
        ),
      ),
    );

    expect(
      AppMediaProfile.productCard.resolveDecodeSize(
        laidOutSize: const Size(double.infinity, 200),
        context: testContext,
      ),
      isNull,
    );

    expect(
      AppMediaProfile.productCard.resolveDecodeSize(
        laidOutSize: Size.zero,
        context: testContext,
      ),
      isNull,
    );
  });
}
