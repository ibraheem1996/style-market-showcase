import 'dart:async';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_project/core/constants/app_pref_key.dart';
import 'package:my_project/core/storage/prefs_storage.dart';
import 'package:my_project/core/storage/token_storage.dart';
import 'package:my_project/features/auth/domain/entities/user_entity.dart';
import 'package:my_project/features/auth/session/session_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeTokenStorage extends TokenStorage {
  _FakeTokenStorage() : super(const FlutterSecureStorage());

  @override
  Future<String?> get readAccessToken async => 'fake-access-token';

  @override
  Future<String?> get readRefreshToken async => 'fake-refresh-token';
}

class _DelayedTokenStorage extends TokenStorage {
  _DelayedTokenStorage() : super(const FlutterSecureStorage());

  final Completer<void> _readGate = Completer<void>();

  void releaseReads() => _readGate.complete();

  @override
  Future<String?> get readAccessToken async {
    await _readGate.future;
    return 'fake-access-token';
  }

  @override
  Future<String?> get readRefreshToken async {
    await _readGate.future;
    return 'fake-refresh-token';
  }
}

void main() {
  test(
    'hydrates scalar user data and removes the legacy JSON snapshot',
    () async {
      SharedPreferences.setMockInitialValues({
        AppStorageKey.isLogin: true,
        AppStorageKey.userId: 7,
        AppStorageKey.userName: 'Stored User',
        AppStorageKey.userEmail: 'stored@example.com',
        AppStorageKey.userPhone: '0790000000',
      });
      final prefs = PrefsStorage(await SharedPreferences.getInstance());
      final service = SessionService(prefs, _FakeTokenStorage());

      expect(await service.restoreStoredSession(), isTrue);
      expect(service.isAuthenticated, isTrue);
      expect(service.currentUser?.userId, 7);
      expect(service.currentUser?.userPhone, '0790000000');
    },
  );

  test(
    'set replaces the current user and clear removes runtime auth',
    () async {
      SharedPreferences.setMockInitialValues({});
      final service = SessionService(
        PrefsStorage(await SharedPreferences.getInstance()),
        _FakeTokenStorage(),
      );
      final first = UserEntity(
        userId: 1,
        userName: 'First',
        userEmail: 'first@example.com',
      );
      final second = UserEntity(
        userId: 2,
        userName: 'Second',
        userEmail: 'second@example.com',
      );

      service.setUser(first);
      service.setUser(second);
      expect(service.currentUser, same(second));

      service.clear();
      expect(service.currentUser, isNull);
      expect(service.isAuthenticated, isFalse);
    },
  );

  test('late hydration cannot restore a user after clear', () async {
    SharedPreferences.setMockInitialValues({
      AppStorageKey.isLogin: true,
      AppStorageKey.userId: 7,
      AppStorageKey.userName: 'Stored User',
      AppStorageKey.userEmail: 'stored@example.com',
    });
    final sharedPreferences = await SharedPreferences.getInstance();
    final tokenStorage = _DelayedTokenStorage();
    final service = SessionService(
      PrefsStorage(sharedPreferences),
      tokenStorage,
    );

    final hydration = service.restoreStoredSession();
    await Future<void>.delayed(Duration.zero);
    service.clear();
    tokenStorage.releaseReads();

    expect(await hydration, isFalse);
    expect(service.currentUser, isNull);
  });
}
