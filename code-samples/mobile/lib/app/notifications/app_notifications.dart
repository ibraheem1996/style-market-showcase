import 'dart:async';

import 'package:dio/dio.dart';

import '../../core/constants/app_pref_key.dart';
import '../../core/services/logger_service.dart';
import '../../core/storage/prefs_storage.dart';
import '../../features/auth/session/session_service.dart';
import 'local_notification_display.dart';
import 'notification_messaging.dart';
import 'notification_payload.dart';
import 'notification_token_api.dart';

/// Owns listeners for one root lifetime, independent of screens and public auth.
class AppNotifications {
  AppNotifications({
    required this.messaging,
    required this.display,
    required this.tokenApi,
    required this.session,
    required this.prefs,
    required this.onTap,
  });

  final NotificationMessaging messaging;
  final LocalNotificationDisplay display;
  final NotificationTokenApi tokenApi;
  final SessionService session;
  final PrefsStorage prefs;
  final void Function(NotificationPayload) onTap;
  final _subscriptions = <StreamSubscription<dynamic>>[];
  bool _started = false;
  bool _disposed = false;
  bool _privatePaused = false;
  bool _displayReady = false;
  bool _publicPending = false;
  bool _privatePending = false;
  bool _readTokenPending = false;
  bool _allowPromptPending = false;
  Future<void>? _reconciliation;
  String? _lastKnownToken;
  CancelToken? _privateRequest;
  CancelToken? _logoutRequest;

  Future<void> start() async {
    if (_started || _disposed) return;
    _started = true;
    if (!messaging.isSupported) return;
    await _reconcile(
      public: true,
      private: true,
      readToken: true,
      allowPrompt: true,
    );
    _listen(() => messaging.foreground, (payload) {
      unawaited(_showForeground(payload));
    });
    _listen(() => messaging.opened, _tap);
    _listen(() => messaging.tokenRefresh, (token) {
      _lastKnownToken = token;
      unawaited(_reconcile(public: true, private: true));
    });
    // Setup paths are independent; local-plugin failure cannot stop token work.
    unawaited(_setupDisplayAndLaunch());
    unawaited(_attempt('foreground_settings', messaging.configureForeground));
  }

  void _listen<T>(Stream<T> Function() stream, void Function(T) callback) {
    try {
      _subscriptions.add(
        stream().listen(
          (value) {
            if (!_disposed) callback(value);
          },
          onError: (Object err) => _report('listener error: ${err.toString()}'),
        ),
      );
    } catch (err) {
      _report('listener_setup error: ${err.toString()}');
    }
  }

  Future<void> _setupDisplayAndLaunch() async {
    final initialized = await _attempt(
      'local_setup',
      () => display.initialize(_tap),
    );
    if (_disposed) return;
    _displayReady = initialized;
    NotificationPayload? launch;
    await _attempt('local_launch', () async {
      launch = await display.initialTap();
    });
    if (_disposed) return;
    // Local launch takes precedence, including a malformed/no-action payload.
    if (launch != null) {
      _tap(launch!);
    } else {
      await _attempt('remote_launch', () async {
        final remote = await messaging.initialTap();
        if (remote != null) _tap(remote);
      });
    }
  }

  void _tap(NotificationPayload payload) {
    if (!_disposed) onTap(payload);
  }

  Future<void> _showForeground(NotificationPayload payload) async {
    if (!_displayReady || _disposed) return;
    await _attempt('foreground_display', () async {
      final permission = await messaging.permission();
      if (_disposed || permission != NotificationPermission.allowed) return;
      await display.show(payload);
    });
  }

  /// AppInit is the only auth readiness signal, including same-user new sessions.
  void sessionReady() {
    if (_disposed) return;
    _privatePaused = false;
    unawaited(_reconcile(private: true, readToken: true));
  }

  void resume() {
    if (!_started || _disposed || !messaging.isSupported) return;
    unawaited(_reconcile(public: true, private: true, readToken: true));
  }

  Future<void> _reconcile({
    bool public = false,
    bool private = false,
    bool readToken = false,
    bool allowPrompt = false,
  }) {
    if (_disposed || !messaging.isSupported) {
      return Future.value();
    }

    _publicPending |= public;
    _privatePending |= private;
    _readTokenPending |= readToken;
    _allowPromptPending |= allowPrompt;

    return _reconciliation ??= _drain().whenComplete(
      () => _reconciliation = null,
    );
  }

  Future<void> _drain() async {
    while (!_disposed && (_publicPending || _privatePending)) {
      final public = _publicPending;
      final private = _privatePending;
      final readToken = _readTokenPending;
      final allowPrompt = _allowPromptPending;

      _publicPending = _privatePending = _readTokenPending =
          _allowPromptPending = false;

      await _attempt(
        'reconcile',
        () => _runReconciliation(
          public: public,
          private: private,
          readToken: readToken,
          allowPrompt: allowPrompt,
        ),
      );
    }
  }

  Future<void> _runReconciliation({
    required bool public,
    required bool private,
    required bool readToken,
    required bool allowPrompt,
  }) async {
    final permission = await _resolvePermission(allowPrompt: allowPrompt);

    if (_disposed || permission != NotificationPermission.allowed) {
      return;
    }

    final token = await _resolveToken(readToken: readToken);

    if (_disposed || token == null) {
      return;
    }

    if (public) {
      await _attempt('public_topic', messaging.subscribePublic);
    }

    if (private) {
      await _syncPrivateToken(token);
    }
  }

  Future<NotificationPermission?> _resolvePermission({
    required bool allowPrompt,
  }) async {
    var permission = await messaging.permission();

    if (_disposed) {
      return null;
    }

    if (permission == NotificationPermission.allowed) {
      return permission;
    }

    if (!allowPrompt ||
        permission == NotificationPermission.deniedPermanently) {
      return null;
    }

    final canRequest =
        messaging.isAndroid ||
        permission == NotificationPermission.notDetermined;

    if (!canRequest) {
      return null;
    }

    final attempted =
        prefs.getBool(AppStorageKey.notificationPermissionPromptAttempted) ??
        false;

    if (attempted) {
      return null;
    }

    final recorded = await prefs.setBool(
      AppStorageKey.notificationPermissionPromptAttempted,
      true,
    );

    if (_disposed) {
      return null;
    }

    if (!recorded) {
      _report('permission_prompt_memory');
      return null;
    }

    permission = await messaging.requestPermission();

    if (_disposed || permission != NotificationPermission.allowed) {
      return null;
    }

    return permission;
  }

  Future<String?> _resolveToken({required bool readToken}) async {
    if (readToken || _lastKnownToken == null) {
      final beforeRead = _lastKnownToken;
      final token = await messaging.token();

      if (_disposed) {
        return null;
      }

      if (_lastKnownToken == beforeRead) {
        _lastKnownToken = token;
      }
    }

    if (_lastKnownToken == null || _lastKnownToken!.isEmpty) {
      return null;
    }

    return _lastKnownToken;
  }

  Future<void> _syncPrivateToken(String token) async {
    if (_privatePaused || !session.isAuthenticated) {
      return;
    }

    final cancellation = CancelToken();
    _privateRequest = cancellation;

    try {
      final result = await tokenApi.register(
        token,
        cancelToken: cancellation,
        canDispatch: () =>
            !_disposed && !_privatePaused && session.isAuthenticated,
      );

      if (!_disposed && result.isLeft()) {
        _report('private_registration');
      }
    } finally {
      if (identical(_privateRequest, cancellation)) {
        _privateRequest = null;
      }
    }
  }

  /// Cancels registration and bounds all pre-logout SDK/storage/DELETE preparation.
  Future<void> beforeLogout() async {
    if (_disposed) return;
    _privatePaused = true;
    _privateRequest?.cancel();
    final cancellation = CancelToken();
    _logoutRequest = cancellation;
    try {
      await _attempt('logout_detach', () async {
        if (_disposed || cancellation.isCancelled) {
          return;
        }
        String? token;
        final sessionVersion = session.sessionVersion;
        try {
          token = await messaging.token();
        } catch (_) {
          _report('logout_token');
        }
        if (sessionVersion != session.sessionVersion) return;
        token ??= _lastKnownToken;
        if (_disposed ||
            cancellation.isCancelled ||
            token == null ||
            token.isEmpty) {
          return;
        }
        final result = await tokenApi.remove(token, cancelToken: cancellation);
        if (!_disposed && result.isLeft()) _report('logout_delete');
      }).timeout(
        const Duration(seconds: 3),
        onTimeout: () {
          cancellation.cancel();
          _report('logout_timeout');
          return false;
        },
      );
    } finally {
      if (identical(_logoutRequest, cancellation)) _logoutRequest = null;
    }
  }

  Future<bool> _attempt(String stage, Future<void> Function() action) async {
    try {
      await action();
      return true;
    } catch (_) {
      if (!_disposed) _report(stage);
      return false;
    }
  }

  void _report(String stage) =>
      LoggerService.warning('Notifications: $stage unavailable');

  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _privateRequest?.cancel();
    _logoutRequest?.cancel();
    for (final subscription in _subscriptions) {
      unawaited(subscription.cancel());
    }
    _subscriptions.clear();
  }
}
