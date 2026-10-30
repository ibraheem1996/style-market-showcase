import 'package:flutter_test/flutter_test.dart';
import 'package:my_project/core/utils/responsive/app_catalog_grid_layout.dart';

void main() {
  group('AppCatalogGridLayout', () {
    test('uses content-local width and central gaps', () {
      final compact = AppCatalogGridLayout.resolve(
        availableWidth: 336,
        textScaleFactor: 1,
      );
      final catalog = AppCatalogGridLayout.resolve(
        availableWidth: 900,
        textScaleFactor: 1,
      );

      expect(compact.crossAxisCount, 2);
      expect(catalog.crossAxisCount, 4);
      expect(catalog.horizontalGap, 12);
      expect(catalog.verticalGap, 16);
    });

    test('honors minimum-width boundaries', () {
      expect(
        AppCatalogGridLayout.resolve(
          availableWidth: 299,
          textScaleFactor: 1,
        ).crossAxisCount,
        1,
      );
      expect(
        AppCatalogGridLayout.resolve(
          availableWidth: 300,
          textScaleFactor: 1,
        ).crossAxisCount,
        2,
      );
    });

    test('reduces columns under discrete text pressure', () {
      expect(
        AppCatalogGridLayout.resolve(
          availableWidth: 760,
          textScaleFactor: 1,
        ).crossAxisCount,
        4,
      );
      expect(
        AppCatalogGridLayout.resolve(
          availableWidth: 760,
          textScaleFactor: 1.3,
        ).crossAxisCount,
        4,
      );
      expect(
        AppCatalogGridLayout.resolve(
          availableWidth: 760,
          textScaleFactor: 2,
        ).crossAxisCount,
        3,
      );
    });

    test('caps the catalog column count', () {
      final layout = AppCatalogGridLayout.resolve(
        availableWidth: 1400,
        textScaleFactor: 1,
      );

      expect(layout.crossAxisCount, AppCatalogGridLayout.maximumColumns);
    });

    test('rejects invalid inputs', () {
      for (final width in [0.0, -1.0, double.infinity, double.nan]) {
        expect(
          () => AppCatalogGridLayout.resolve(
            availableWidth: width,
            textScaleFactor: 1,
          ),
          throwsArgumentError,
        );
      }
      for (final scale in [0.0, -1.0, double.infinity, double.nan]) {
        expect(
          () => AppCatalogGridLayout.resolve(
            availableWidth: 360,
            textScaleFactor: scale,
          ),
          throwsArgumentError,
        );
      }
    });
  });
}
