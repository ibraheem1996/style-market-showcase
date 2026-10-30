import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_project/core/storage/token_storage.dart';

void main() {
  late TokenStorage tokenStorage;

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    tokenStorage = TokenStorage(const FlutterSecureStorage());
  });

  test('saves and reads non-empty tokens', () async {
    await tokenStorage.saveTokensIfPresent(
      accessToken: 'access',
      refreshToken: 'refresh',
    );

    expect(await tokenStorage.readAccessToken, 'access');
    expect(await tokenStorage.readRefreshToken, 'refresh');
  });

  test('empty values do not replace stored tokens', () async {
    await tokenStorage.saveTokensIfPresent(
      accessToken: 'access',
      refreshToken: 'refresh',
    );
    await tokenStorage.saveTokensIfPresent(accessToken: '', refreshToken: null);

    expect(await tokenStorage.readAccessToken, 'access');
    expect(await tokenStorage.readRefreshToken, 'refresh');
  });

  test('clearTokens removes only the auth token keys', () async {
    const storage = FlutterSecureStorage();
    await storage.write(key: 'unrelated', value: 'keep');
    await tokenStorage.saveTokensIfPresent(
      accessToken: 'access',
      refreshToken: 'refresh',
    );

    await tokenStorage.clearTokens();

    expect(await tokenStorage.readAccessToken, isNull);
    expect(await tokenStorage.readRefreshToken, isNull);
    expect(await storage.read(key: 'unrelated'), 'keep');
  });

  test('clearAll removes every secure value', () async {
    const storage = FlutterSecureStorage();
    await storage.write(key: 'unrelated', value: 'remove');
    await tokenStorage.saveTokensIfPresent(
      accessToken: 'access',
      refreshToken: 'refresh',
    );

    await tokenStorage.clearAll();

    expect(await tokenStorage.readAccessToken, isNull);
    expect(await tokenStorage.readRefreshToken, isNull);
    expect(await storage.read(key: 'unrelated'), isNull);
  });
}
