import 'package:flutter_test/flutter_test.dart';
import 'package:multi_product_store_admin_web/core/config/api_config.dart';
import 'package:multi_product_store_admin_web/core/utils/image_url_resolver.dart';

void main() {
  group('ImageUrlResolver', () {
    const resolver = ImageUrlResolver();

    test('returns null for empty values', () {
      expect(resolver.resolve(null), isNull);
      expect(resolver.resolve('  '), isNull);
    });

    test('keeps full URLs unchanged', () {
      const url = 'https://example.com/images/item.png';

      expect(resolver.resolve(url), url);
    });

    test('builds backend image URLs from filenames', () {
      expect(
        resolver.resolve('/item.png'),
        '${ApiConfig.imagesBaseUrl}/item.png',
      );
    });

    test('keeps server-root image paths from duplicating the mount', () {
      expect(
        resolver.resolve('/images/item.png'),
        '${ApiConfig.serverBaseUrl}/images/item.png',
      );
    });
  });
}
