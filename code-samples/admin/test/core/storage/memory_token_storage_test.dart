import 'package:flutter_test/flutter_test.dart';
import 'package:multi_product_store_admin_web/core/storage/memory_token_storage.dart';

void main() {
  group('MemoryTokenStorage', () {
    test('saves and clears tokens', () async {
      final storage = MemoryTokenStorage();

      await storage.saveTokens(
        accessToken: 'access-token',
        refreshToken: 'refresh-token',
      );

      expect(await storage.readAccessToken(), 'access-token');
      expect(await storage.readRefreshToken(), 'refresh-token');
      expect(await storage.hasSession(), isTrue);

      await storage.clearTokens();

      expect(await storage.readAccessToken(), isNull);
      expect(await storage.readRefreshToken(), isNull);
      expect(await storage.hasSession(), isFalse);
    });

    test(
      'requires both access and refresh tokens for a valid session',
      () async {
        final storage = MemoryTokenStorage();

        await storage.saveTokens(accessToken: 'access-token', refreshToken: '');

        expect(await storage.hasSession(), isFalse);
      },
    );
  });
}
