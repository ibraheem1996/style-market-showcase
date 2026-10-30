import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'notification_payload.dart';

/// Foreground-only system display; remote background display belongs to FCM.
class LocalNotificationDisplay {
  LocalNotificationDisplay(this._plugin, {Dio? imageClient})
    : _imageClient =
          imageClient ??
          Dio(
            BaseOptions(
              connectTimeout: const Duration(seconds: 5),
              receiveTimeout: const Duration(seconds: 5),
            ),
          );
  final FlutterLocalNotificationsPlugin _plugin;
  // Image URLs are public; this client must not use API authentication.
  final Dio _imageClient;
  static const channelId = 'style_market_notifications';
  static const icon = 'ic_notification';
  static const _channel = AndroidNotificationChannel(
    channelId,
    'الإشعارات',
    importance: Importance.high,
  );
  int _nextId = 0;

  Future<void> initialize(void Function(NotificationPayload) onTap) async {
    await _plugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings(icon),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
      onDidReceiveNotificationResponse: (response) =>
          onTap(NotificationPayload.fromLocalJson(response.payload)),
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_channel);
  }

  Future<NotificationPayload?> initialTap() async {
    final details = await _plugin.getNotificationAppLaunchDetails();
    if (details?.didNotificationLaunchApp != true) return null;
    return NotificationPayload.fromLocalJson(
      details?.notificationResponse?.payload,
    );
  }

  Future<void> show(NotificationPayload payload) async {
    if ((payload.title?.trim().isEmpty ?? true) &&
        (payload.body?.trim().isEmpty ?? true)) {
      return;
    }
    final id = _nextId++ & 0x7fffffff;
    final imageUrl = payload.imageUrl;
    if (imageUrl == null || imageUrl.trim().isEmpty) {
      await _show(id, payload);
      return;
    }

    Directory? temporaryDirectory;
    try {
      final response = await _imageClient.get<List<int>>(
        imageUrl,
        options: Options(responseType: ResponseType.bytes),
      );
      final bytes = Uint8List.fromList(response.data!);
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        temporaryDirectory = await Directory.systemTemp.createTemp(
          'foreground_notification_',
        );
        final extension = switch (response.headers
            .value(Headers.contentTypeHeader)
            ?.split(';')
            .first) {
          'image/png' => 'png',
          'image/jpeg' => 'jpg',
          'image/gif' => 'gif',
          _ => Uri.parse(imageUrl).path.split('/').last.split('.').last,
        };
        final file = File('${temporaryDirectory.path}/image.$extension');
        await file.writeAsBytes(bytes);
        await _show(
          id,
          payload,
          attachments: [DarwinNotificationAttachment(file.path)],
        );
      } else {
        final bitmap = ByteArrayAndroidBitmap(bytes);
        await _show(
          id,
          payload,
          style: BigPictureStyleInformation(
            bitmap,
            contentTitle: payload.title,
            summaryText: payload.body,
            // showBigPictureWhenCollapsed: true,
          ),
          largeIcon: bitmap,
        );
      }
      return;
    } catch (_) {
      // Download or attachment failure falls back to text, never another image attempt.
    } finally {
      try {
        await temporaryDirectory?.delete(recursive: true);
      } catch (_) {
        // Temporary-file cleanup must not prevent notification display.
      }
    }
    await _show(id, payload);
  }

  Future<void> _show(
    int id,
    NotificationPayload payload, {
    BigPictureStyleInformation? style,
    AndroidBitmap<Object>? largeIcon,
    List<DarwinNotificationAttachment>? attachments,
  }) => _plugin.show(
    id,
    payload.title,
    payload.body,
    NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        'الإشعارات',
        icon: icon,
        largeIcon: largeIcon,
        importance: Importance.high,
        priority: Priority.high,
        styleInformation: style,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBanner: true,
        presentSound: true,
        attachments: attachments,
      ),
    ),
    payload: payload.toLocalJson(),
  );
}
