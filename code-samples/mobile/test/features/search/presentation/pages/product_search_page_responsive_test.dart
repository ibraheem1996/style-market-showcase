import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_project/core/constants/app_pref_key.dart';
import 'package:my_project/core/localization/languages.dart';
import 'package:my_project/core/media/app_media_profile.dart';
import 'package:my_project/core/storage/prefs_storage.dart';
import 'package:my_project/core/translations/app_translations.dart';
import 'package:my_project/core/utils/responsive/app_catalog_grid_layout.dart';
import 'package:my_project/core/widgets/app_remote_image.dart';
import 'package:my_project/features/products/domain/entities/product_card_entity.dart';
import 'package:my_project/features/search/presentation/widgets/product_search_result_card.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    Get.testMode = true;
    SharedPreferences.setMockInitialValues({
      AppStorageKey.language: Language.english.code,
    });
    final preferences = await SharedPreferences.getInstance();
    Get.put<Languages>(Languages(PrefsStorage(preferences)));
  });

  tearDown(Get.reset);

  test('product search follows the shared catalog column contract', () {
    expect(_grid(288).crossAxisCount, 1);
    expect(_grid(552).crossAxisCount, 3);
    expect(_grid(792).crossAxisCount, 4);
    expect(_grid(852).crossAxisCount, 4);
    expect(_grid(552, textScaleFactor: 2).crossAxisCount, 2);
  });

  for (final direction in TextDirection.values) {
    testWidgets('product search card keeps 3:4 image in compact $direction', (
      tester,
    ) async {
      final cartQuantity = 0.obs;
      final cartPending = false.obs;
      await tester.binding.setSurfaceSize(const Size(320, 690));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        GetMaterialApp(
          translations: AppTranslations(),
          locale: const Locale('en'),
          home: Directionality(
            textDirection: direction,
            child: Scaffold(
              body: Align(
                alignment: Alignment.topCenter,
                child: SizedBox(
                  width: 140,
                  child: ProductSearchResultCard(
                    item: _item(),
                    isFavorite: false,
                    isFavoritePending: false,
                    canToggleFavorite: true,
                    cartQuantity: () => cartQuantity.value,
                    isCartPending: () => cartPending.value,
                    onTap: (_) {},
                    onToggleFavorite: () {},
                    onAddToCart: () {},
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      final ratio = tester.widget<AspectRatio>(find.byType(AspectRatio));
      expect(ratio.aspectRatio, AppMediaProfile.productCard.aspectRatio);
      final image = tester.widget<AppRemoteImage>(find.byType(AppRemoteImage));
      expect(image.profile, AppMediaProfile.productCard);
      expect(image.semanticLabel, 'Shoe');
      expect(tester.widget<Text>(find.text('Shoe')).maxLines, 2);
      expect(tester.takeException(), isNull);
    });
  }

  for (final scaleAndLines in [(1.5, 3), (2.0, 4)]) {
    testWidgets(
      'product search card allows ${scaleAndLines.$2} name lines at ${scaleAndLines.$1}x text',
      (tester) async {
        final cartQuantity = 0.obs;
        final cartPending = false.obs;
        await tester.pumpWidget(
          GetMaterialApp(
            translations: AppTranslations(),
            locale: const Locale('en'),
            home: MediaQuery(
              data: MediaQueryData(
                textScaler: TextScaler.linear(scaleAndLines.$1),
              ),
              child: Scaffold(
                body: SizedBox(
                  width: 180,
                  child: ProductSearchResultCard(
                    item: _item(),
                    isFavorite: false,
                    isFavoritePending: false,
                    canToggleFavorite: true,
                    cartQuantity: () => cartQuantity.value,
                    isCartPending: () => cartPending.value,
                    onTap: (_) {},
                    onToggleFavorite: () {},
                    onAddToCart: () {},
                  ),
                ),
              ),
            ),
          ),
        );

        expect(
          tester.widget<Text>(find.text('Shoe')).maxLines,
          scaleAndLines.$2,
        );
        expect(tester.takeException(), isNull);
      },
    );
  }
}

AppCatalogGridLayout _grid(double width, {double textScaleFactor = 1}) {
  return AppCatalogGridLayout.resolve(
    availableWidth: width,
    textScaleFactor: textScaleFactor,
  );
}

ProductCardEntity _item() {
  return const ProductCardEntity(
    itemId: 1,
    itemNameAr: 'حذاء',
    itemNameEn: 'Shoe',
    displayPrice: 80,
    originalPrice: 100,
    hasDiscount: true,
    maxDiscountPct: 20,
    itemDisplayImage: '',
    availableColors: [],
    availableSizes: [],
    isFeatured: false,
    images: [],
    stockQuantity: 4,
    badges: [],
  );
}
