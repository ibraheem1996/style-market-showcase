import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_project/core/config/api_config.dart';
import 'package:my_project/core/widgets/app_remote_image.dart';

void main() {
  testWidgets('normalizes URL and applies profile fit and decode dimensions', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: Center(
          child: SizedBox(
            width: 120,
            height: 160,
            child: AppRemoteImage.productCard(
              source: '/products/item.png',
              semanticLabel: 'Blue shoe',
            ),
          ),
        ),
      ),
    );

    final image = tester.widget<CachedNetworkImage>(
      find.byType(CachedNetworkImage),
    );
    expect(image.imageUrl, '${ApiConfig.images}/products/item.png');
    expect(image.fit, BoxFit.cover);
    expect(image.memCacheWidth, 240);
    expect(image.memCacheHeight, 320);
    expect(find.bySemanticsLabel('Blue shoe'), findsOneWidget);
    expect(find.byType(Hero), findsNothing);
    expect(find.byType(GestureDetector), findsNothing);
  });

  testWidgets('category thumbnail applies shared square media policy', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: Center(
          child: SizedBox.square(
            dimension: 96,
            child: AppRemoteImage.categoryThumbnail(
              source: '/categories/shoes.png',
              semanticLabel: 'Shoes',
            ),
          ),
        ),
      ),
    );

    final image = tester.widget<CachedNetworkImage>(
      find.byType(CachedNetworkImage),
    );
    expect(image.imageUrl, '${ApiConfig.images}/categories/shoes.png');
    expect(image.fit, BoxFit.cover);
    expect(image.memCacheWidth, 256);
    expect(image.memCacheHeight, 256);
    expect(find.bySemanticsLabel('Shoes'), findsOneWidget);
  });

  testWidgets('order thumbnail applies shared square media policy', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: Center(
          child: SizedBox.square(
            dimension: 200,
            child: AppRemoteImage.orderThumbnail(
              source: '/orders/item.png',
              semanticLabel: 'Order item',
            ),
          ),
        ),
      ),
    );

    final image = tester.widget<CachedNetworkImage>(
      find.byType(CachedNetworkImage),
    );
    expect(image.imageUrl, '${ApiConfig.images}/orders/item.png');
    expect(image.fit, BoxFit.cover);
    expect(image.memCacheWidth, 512);
    expect(image.memCacheHeight, 512);
    expect(find.bySemanticsLabel('Order item'), findsOneWidget);
  });

  testWidgets('favorite card applies its own decode ceiling', (tester) async {
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: Center(
          child: SizedBox(
            width: 300,
            height: 400,
            child: AppRemoteImage.favoriteCard(source: '/favorites/item.png'),
          ),
        ),
      ),
    );

    final image = tester.widget<CachedNetworkImage>(
      find.byType(CachedNetworkImage),
    );
    expect(image.fit, BoxFit.cover);
    expect(image.memCacheWidth, 768);
    expect(image.memCacheHeight, 1024);
  });

  testWidgets('exposes default and custom loading/error builders', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SizedBox(
          width: 200,
          height: 100,
          child: AppRemoteImage.banner(source: 'banner.png'),
        ),
      ),
    );
    var image = tester.widget<CachedNetworkImage>(
      find.byType(CachedNetworkImage),
    );
    expect(
      image.placeholder!(tester.element(find.byType(CachedNetworkImage)), ''),
      isA<Center>(),
    );
    expect(
      image.errorWidget!(
        tester.element(find.byType(CachedNetworkImage)),
        '',
        StateError('failed'),
      ),
      isA<Center>(),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: SizedBox(
          width: 200,
          height: 100,
          child: AppRemoteImage.banner(
            source: 'banner.png',
            placeholderBuilder: (_) => const Text('custom loading'),
            errorBuilder: (_) => const Text('custom error'),
          ),
        ),
      ),
    );
    image = tester.widget<CachedNetworkImage>(find.byType(CachedNetworkImage));
    expect(
      image.placeholder!(tester.element(find.byType(CachedNetworkImage)), ''),
      isA<Text>(),
    );
    expect(
      image.errorWidget!(
        tester.element(find.byType(CachedNetworkImage)),
        '',
        StateError('failed'),
      ),
      isA<Text>(),
    );
  });

  testWidgets('leaves decode dimensions unset for an unbounded axis', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            height: 100,
            child: AppRemoteImage.collection(source: 'collection.png'),
          ),
        ),
      ),
    );

    final image = tester.widget<CachedNetworkImage>(
      find.byType(CachedNetworkImage),
    );
    expect(image.memCacheWidth, isNull);
    expect(image.memCacheHeight, isNull);
  });
}
