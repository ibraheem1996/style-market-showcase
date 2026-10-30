import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:fake_async/fake_async.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_project/app/notifications/app_notifications.dart';
import 'package:my_project/app/notifications/notification_payload.dart';
import 'package:my_project/app/notifications/notification_messaging.dart';
import 'package:my_project/app/notifications/local_notification_display.dart';
import 'package:my_project/app/notifications/notification_token_api.dart';
import 'package:my_project/core/constants/app_pref_key.dart';
import 'package:my_project/core/errors/api_result.dart';
import 'package:my_project/core/storage/prefs_storage.dart';
import 'package:my_project/core/storage/token_storage.dart';
import 'package:my_project/features/auth/session/session_service.dart';
import 'package:my_project/features/auth/domain/entities/user_entity.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MemoryTokens extends TokenStorage {
  MemoryTokens() : super(const FlutterSecureStorage());
  String bearer = 'session-one';
  @override
  Future<String?> get readAccessToken async => bearer;
}

class FakeFirebase implements FirebaseMessaging {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeMessaging extends NotificationMessaging {
  FakeMessaging() : super(FakeFirebase());
  final messages = StreamController<NotificationPayload>.broadcast(sync: true);
  final taps = StreamController<NotificationPayload>.broadcast(sync: true);
  final refreshes = StreamController<String>.broadcast(sync: true);
  NotificationPermission status = NotificationPermission.allowed;
  int prompts = 0, topics = 0, initialReads = 0;
  bool failTopic = false, failSettings = false;
  String? currentToken = 'installation-one';
  Future<String?>? tokenFuture;
  NotificationPayload? launch;
  @override
  bool get isSupported => true;
  @override
  bool get isAndroid => true;
  @override
  Stream<NotificationPayload> get foreground => messages.stream;
  @override
  Stream<NotificationPayload> get opened => taps.stream;
  @override
  Stream<String> get tokenRefresh => refreshes.stream;
  @override
  Future<NotificationPermission> permission() async {
    if (failSettings) throw StateError('unavailable');
    return status;
  }

  @override
  Future<NotificationPermission> requestPermission() async {
    prompts++;
    return status;
  }

  @override
  Future<String?> token() => tokenFuture ?? Future.value(currentToken);
  @override
  Future<void> subscribePublic() async {
    topics++;
    if (failTopic) throw StateError('unavailable');
  }

  @override
  Future<void> configureForeground() async {}
  @override
  Future<NotificationPayload?> initialTap() async {
    initialReads++;
    return launch;
  }

  Future<void> close() async {
    await messages.close();
    await taps.close();
    await refreshes.close();
  }
}

class FakeDisplay extends LocalNotificationDisplay {
  FakeDisplay() : super(FlutterLocalNotificationsPlugin());
  bool failSetup = false;
  int shows = 0, setups = 0;
  NotificationPayload? launch;
  void Function(NotificationPayload)? tap;
  @override
  Future<void> initialize(void Function(NotificationPayload) onTap) async {
    setups++;
    tap = onTap;
    if (failSetup) throw StateError('unavailable');
  }

  @override
  Future<NotificationPayload?> initialTap() async => launch;
  @override
  Future<void> show(NotificationPayload payload) async {
    shows++;
  }
}

class FakeTokenApi implements NotificationTokenApi {
  final puts = <String>[];
  int deletes = 0;
  Future<ApiResult<void>>? putFuture;
  CancelToken? lastCancellation;
  @override
  Future<ApiResult<void>> register(
    String token, {
    required CancelToken cancelToken,
    required bool Function() canDispatch,
  }) async {
    lastCancellation = cancelToken;
    if (canDispatch()) puts.add(token);
    return await (putFuture ?? Future.value(right(null)));
  }

  @override
  Future<ApiResult<void>> remove(
    String token, {
    required CancelToken cancelToken,
  }) async {
    deletes++;
    return right(null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late FakeMessaging messaging;
  late FakeDisplay display;
  late FakeTokenApi api;
  late PrefsStorage prefs;
  late SessionService session;
  late AppNotifications owner;
  late List<NotificationPayload> taps;
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = PrefsStorage(await SharedPreferences.getInstance());
    session = SessionService(prefs, MemoryTokens());
    messaging = FakeMessaging();
    display = FakeDisplay();
    api = FakeTokenApi();
    taps = [];
    owner = AppNotifications(
      messaging: messaging,
      display: display,
      tokenApi: api,
      session: session,
      prefs: prefs,
      onTap: taps.add,
    );
  });
  tearDown(() async {
    owner.dispose();
    await messaging.close();
  });
  Future<void> flush() async {
    for (var i = 0; i < 20; i++) {
      await Future<void>.value();
    }
  }

  void authenticate() => session.setUser(
    UserEntity(
      userId: 7,
      userName: 'User',
      userEmail: 'user@example.com',
      userPhone: '',
    ),
  );
  final payload = NotificationPayload.fromData({
    'action': 'open_order',
    'order_id': '7',
  }, title: 'Title');

  test(
    'guest public topic; AppInit including same-user session only registers privately',
    () async {
      await owner.start();
      await owner.start();
      await flush();
      expect(messaging.topics, 1);
      expect(api.puts, isEmpty);
      expect(display.setups, 1);
      authenticate();
      owner.sessionReady();
      await flush();
      expect(api.puts, ['installation-one']);
      expect(messaging.topics, 1);
      owner.sessionReady();
      await flush();
      expect(api.puts, ['installation-one', 'installation-one']);
      await owner.beforeLogout();
      session.clear();
      expect(api.deletes, 1);
      expect(messaging.topics, 1);
      owner.resume();
      await flush();
      expect(messaging.topics, 2);
      expect(api.puts, hasLength(2));
    },
  );
  test(
    'denied prompt remembered through restart/logout; resume regrant syncs',
    () async {
      messaging.status = NotificationPermission.denied;
      await owner.start();
      await flush();
      expect(messaging.prompts, 1);
      expect(messaging.topics, 0);
      await prefs.clearSession();
      expect(
        prefs.getBool(AppStorageKey.notificationPermissionPromptAttempted),
        isTrue,
      );
      owner.dispose();
      owner = AppNotifications(
        messaging: messaging,
        display: display,
        tokenApi: api,
        session: session,
        prefs: prefs,
        onTap: taps.add,
      );
      await owner.start();
      owner.resume();
      await flush();
      expect(messaging.prompts, 1);
      messaging.status = NotificationPermission.allowed;
      owner.resume();
      await flush();
      expect(messaging.topics, 1);
    },
  );
  test(
    'plugin and topic failure do not stop private work; resume recovers',
    () async {
      authenticate();
      display.failSetup = true;
      messaging.failTopic = true;
      await owner.start();
      await flush();
      expect(api.puts, hasLength(1));
      messaging.failTopic = false;
      owner.resume();
      await flush();
      expect(api.puts, hasLength(2));
      expect(messaging.topics, 2);
    },
  );
  test('foreground shows once; opened/initial taps never display', () async {
    messaging.launch = payload;
    await owner.start();
    await owner.start();
    await flush();
    expect(taps, [payload]);
    expect(display.shows, 0);
    messaging.messages.add(payload);
    await flush();
    expect(display.shows, 1);
    messaging.taps.add(payload);
    await flush();
    expect(display.shows, 1);
    display.tap!(payload);
    expect(taps, hasLength(3));
    owner.dispose();
    messaging.messages.add(payload);
    messaging.taps.add(payload);
    display.tap!(payload);
    await flush();
    expect(display.shows, 1);
    expect(taps, hasLength(3));
  });
  test('local cold launch wins over remote cold launch', () async {
    display.launch = payload;
    messaging.launch = payload;
    await owner.start();
    await flush();
    expect(taps, [payload]);
    expect(messaging.initialReads, 0);
    expect(display.shows, 0);
  });
  test(
    'refresh during PUT coalesces to latest token and dispose cancels work',
    () async {
      authenticate();
      final pending = Completer<ApiResult<void>>();
      api.putFuture = pending.future;
      final start = owner.start();
      await flush();
      expect(api.puts, ['installation-one']);
      messaging.refreshes.add('old-refresh');
      messaging.refreshes.add('latest-refresh');
      api.putFuture = null;
      pending.complete(right(null));
      await start;
      expect(api.puts, ['installation-one', 'latest-refresh']);
      expect(messaging.topics, 2);
      final next = Completer<ApiResult<void>>();
      api.putFuture = next.future;
      owner.resume();
      await flush();
      owner.dispose();
      expect(api.lastCancellation!.isCancelled, isTrue);
      messaging.refreshes.add('after-dispose');
      next.complete(right(null));
      await flush();
      expect(api.puts, hasLength(3));
    },
  );
  test(
    'logout cancels PUT and timeout cannot dispatch a delayed DELETE',
    () async {
      authenticate();
      await owner.start();
      final tokenLookup = Completer<String?>();
      messaging.tokenFuture = tokenLookup.future;
      fakeAsync((async) {
        var completed = false;
        owner.beforeLogout().then((_) => completed = true);
        async.flushMicrotasks();
        async.elapse(const Duration(seconds: 3));
        async.flushMicrotasks();
        expect(completed, isTrue);
        expect(api.deletes, 0);
        tokenLookup.complete('late-token');
        async.flushMicrotasks();
        expect(api.deletes, 0);
      });
      messaging.tokenFuture = null;
      owner.resume();
      await flush();
      expect(api.puts, hasLength(1)); // Paused until successful AppInit.
      owner.sessionReady();
      await flush();
      expect(api.puts, hasLength(2));
    },
  );
  test(
    'logout falls back to cached token if lookup fails in the same session',
    () async {
      authenticate();
      await owner.start();
      final lookup = Completer<String?>();
      messaging.tokenFuture = lookup.future;
      final logout = owner.beforeLogout();
      await flush();
      lookup.completeError(StateError('token lookup unavailable'));
      await logout;
      expect(api.deletes, 1);
    },
  );

  test(
    'logout skips DELETE when the session changes during token lookup',
    () async {
      authenticate();
      await owner.start();
      final lookup = Completer<String?>();
      messaging.tokenFuture = lookup.future;
      final logout = owner.beforeLogout();
      await flush();
      session.clear();
      lookup.complete('installation-one');
      await logout;
      expect(api.deletes, 0);
    },
  );

  test(
    'logout skips cached-token DELETE after lookup failure in a changed session',
    () async {
      authenticate();
      await owner.start();
      final lookup = Completer<String?>();
      messaging.tokenFuture = lookup.future;
      final logout = owner.beforeLogout();
      await flush();
      session.setUser(
        UserEntity(
          userId: 8,
          userName: 'New user',
          userEmail: 'new@example.com',
          userPhone: '',
        ),
      );
      lookup.completeError(StateError('token lookup unavailable'));
      await logout;
      expect(api.deletes, 0);
    },
  );

  test('permission failure and null token remain nonfatal', () async {
    messaging.failSettings = true;
    await owner.start();
    expect(api.puts, isEmpty);
    messaging.failSettings = false;
    messaging.currentToken = null;
    owner.resume();
    await flush();
    expect(messaging.topics, 0);
  });
}
