import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import 'notification_payload.dart';

enum NotificationPermission {
  allowed,
  denied,
  deniedPermanently,
  notDetermined,
}

/// Keeps Firebase types and APNs prerequisites at the SDK boundary.
class NotificationMessaging {
  NotificationMessaging(this._messaging);
  final FirebaseMessaging _messaging;

  bool get isSupported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  bool get isAndroid => defaultTargetPlatform == TargetPlatform.android;

  Stream<NotificationPayload> get foreground =>
      FirebaseMessaging.onMessage.map(_payload);

  Stream<NotificationPayload> get opened =>
      FirebaseMessaging.onMessageOpenedApp.map(_payload);

  Stream<String> get tokenRefresh => _messaging.onTokenRefresh;

  Future<NotificationPermission> permission() async => _permission(
    (await _messaging.getNotificationSettings()).authorizationStatus,
  );

  Future<NotificationPermission> requestPermission() async =>
      _permission((await _messaging.requestPermission()).authorizationStatus);

  Future<String?> token() async {
    if (!isSupported) return null;
    if (!isAndroid && await _messaging.getAPNSToken() == null) return null;
    return _messaging.getToken();
  }

  Future<void> subscribePublic() => _messaging.subscribeToTopic('all_users');

  Future<void> configureForeground() =>
      _messaging.setForegroundNotificationPresentationOptions(
        alert: false,
        badge: false,
        sound: false,
      );

  Future<NotificationPayload?> initialTap() async {
    final message = await _messaging.getInitialMessage();
    return message == null ? null : _payload(message);
  }

  static NotificationPayload _payload(RemoteMessage message) =>
      NotificationPayload.fromData(
        message.data,
        title: message.notification?.title,
        body: message.notification?.body,
        imageUrl:
            message.notification?.android?.imageUrl ??
            message.notification?.apple?.imageUrl,
      );

  static NotificationPermission _permission(AuthorizationStatus status) =>
      switch (status) {
        AuthorizationStatus.authorized ||
        AuthorizationStatus.provisional => NotificationPermission.allowed,
        AuthorizationStatus.notDetermined =>
          NotificationPermission.notDetermined,
        AuthorizationStatus.denied => NotificationPermission.denied,
        AuthorizationStatus.deniedPermanently =>
          NotificationPermission.deniedPermanently,
      };
}
