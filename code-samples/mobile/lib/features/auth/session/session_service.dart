import 'package:get/get.dart';

import '../../../core/constants/app_pref_key.dart';
import '../../../core/storage/prefs_storage.dart';
import '../../../core/storage/token_storage.dart';
import '../domain/entities/user_entity.dart';

/// Owns the authenticated user's runtime session.
///
/// The repository persists tokens and user data.
/// This service restores that persisted session when the app starts.
class SessionService extends GetxService {
  SessionService(this._prefsStorage, this._tokenStorage);

  final PrefsStorage _prefsStorage;
  final TokenStorage _tokenStorage;

  final Rxn<UserEntity> _currentUser = Rxn<UserEntity>();

  UserEntity? get currentUser => _currentUser.value;

  int? get userId => currentUser?.userId;

  bool get isAuthenticated => currentUser != null;

  bool get hasStoredUserSession => _readStoredUser() != null;

  int _restoreRevision = 0;

  final _sessionVersion = 0.obs;

  int get sessionVersion => _sessionVersion.value;

  Stream<int> get sessionChanges => _sessionVersion.stream;

  Future<bool> restoreStoredSession() async {
    if (isAuthenticated) return true;

    final restoreRevision = _restoreRevision;

    final storedUser = _readStoredUser();
    if (storedUser == null) {
      return false;
    }

    final accessToken = await _tokenStorage.readAccessToken;
    final refreshToken = await _tokenStorage.readRefreshToken;

    if (restoreRevision != _restoreRevision) {
      return isAuthenticated;
    }

    final hasAccessToken = accessToken?.trim().isNotEmpty ?? false;
    final hasRefreshToken = refreshToken?.trim().isNotEmpty ?? false;

    if (!hasAccessToken || !hasRefreshToken) {
      _replaceUser(null);
      return false;
    }

    _replaceUser(storedUser);
    return true;
  }

  void _replaceUser(UserEntity? nextUser) {
    final previousUserId = userId;
    final nextUserId = nextUser?.userId;

    _currentUser.value = nextUser;

    if (previousUserId != nextUserId) {
      _sessionVersion.value++;
    }
  }

  void setUser(UserEntity user) {
    _restoreRevision++;
    _replaceUser(user);
  }

  void clear() {
    _restoreRevision++;
    _replaceUser(null);
  }

  UserEntity? _readStoredUser() {
    final isLoggedIn = _prefsStorage.getBool(AppStorageKey.isLogin) ?? false;

    final userId = _prefsStorage.getInt(AppStorageKey.userId);
    final userName =
        _prefsStorage.getString(AppStorageKey.userName)?.trim() ?? '';
    final userEmail =
        _prefsStorage.getString(AppStorageKey.userEmail)?.trim() ?? '';
    final userPhone =
        _prefsStorage.getString(AppStorageKey.userPhone)?.trim() ?? '';

    if (!isLoggedIn ||
        userId == null ||
        userName.isEmpty ||
        userEmail.isEmpty) {
      return null;
    }

    return UserEntity(
      userId: userId,
      userName: userName,
      userEmail: userEmail,
      userPhone: userPhone,
    );
  }
}
