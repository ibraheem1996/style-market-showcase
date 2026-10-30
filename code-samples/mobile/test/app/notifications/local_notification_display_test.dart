import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_project/app/notifications/local_notification_display.dart';
import 'package:my_project/app/notifications/notification_payload.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('dexterous.com/flutter/local_notifications');
  final calls = <MethodCall>[];
  final requests = <RequestOptions>[];
  final imageBytes = base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+aAn0AAAAASUVORK5CYII=',
  );
  late Dio imageClient;
  var failDownload = false;
  var failAttachment = false;
  String? attachmentPath;
  List<int>? attachedBytes;
  setUp(() {
    calls.clear();
    requests.clear();
    failDownload = false;
    failAttachment = false;
    attachmentPath = null;
    attachedBytes = null;
    imageClient = Dio();
    imageClient.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          requests.add(options);
          if (failDownload) {
            handler.reject(
              DioException(
                requestOptions: options,
                type: DioExceptionType.connectionTimeout,
              ),
            );
          } else {
            handler.resolve(
              Response<List<int>>(
                requestOptions: options,
                data: imageBytes,
                statusCode: 200,
                headers: Headers.fromMap({
                  Headers.contentTypeHeader: ['image/png'],
                }),
              ),
            );
          }
        },
      ),
    );
    FlutterLocalNotificationsPlatform.instance =
        AndroidFlutterLocalNotificationsPlugin();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call);
          if (call.method == 'show') {
            final details = (call.arguments as Map)['platformSpecifics'] as Map;
            final attachments = details['attachments'] as List?;
            if (attachments != null && attachments.isNotEmpty) {
              attachmentPath =
                  (attachments.single as Map)['filePath'] as String;
              attachedBytes = await File(attachmentPath!).readAsBytes();
            }
            final hasImage =
                attachments?.isNotEmpty == true ||
                (details['styleInformation'] as Map?)?['bigPicture'] != null;
            if (failAttachment && hasImage) {
              throw PlatformException(code: 'invalid_image');
            }
          }
          if (call.method == 'initialize') {
            return true;
          }
          if (call.method == 'getNotificationAppLaunchDetails') {
            return {
              'notificationLaunchedApp': true,
              'notificationResponse': {
                'notificationResponseType': 0,
                'payload': '{"action":"open_product","product_id":"42"}',
              },
            };
          }
          return null;
        });
  });
  tearDown(() {
    imageClient.close();
    debugDefaultTargetPlatformOverride = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test(
    'actual plugin receives one channel/icon and semantic payload for each foreground show',
    () async {
      final display = LocalNotificationDisplay(
        FlutterLocalNotificationsPlugin(),
        imageClient: imageClient,
      );
      await display.initialize((_) {});
      final payload = NotificationPayload.fromData(
        {'action': 'open_order', 'order_id': '7'},
        title: 'Title',
        body: 'Body',
      );
      await display.show(payload);
      await display.show(payload);
      expect(calls.where((c) => c.method == 'initialize'), hasLength(1));
      expect(
        calls.where((c) => c.method == 'createNotificationChannel'),
        hasLength(1),
      );
      expect(calls.where((c) => c.method.contains('Permission')), isEmpty);
      final shows = calls.where((c) => c.method == 'show').toList();
      expect(shows, hasLength(2));
      final first = shows.first.arguments as Map;
      final second = shows.last.arguments as Map;
      expect(first['id'], isNot(second['id']));
      expect(first['title'], 'Title');
      expect(first['body'], 'Body');
      expect(jsonDecode(first['payload'] as String), {
        'action': 'open_order',
        'order_id': '7',
      });
      expect(
        (first['platformSpecifics'] as Map)['channelId'],
        LocalNotificationDisplay.channelId,
      );
      expect(
        (first['platformSpecifics'] as Map)['icon'],
        LocalNotificationDisplay.icon,
      );
      final launch = await display.initialTap();
      expect(launch!.action, NotificationAction.openProduct);
      expect(launch.targetId, 42);
      await display.show(NotificationPayload.fromData({}));
      expect(calls.where((c) => c.method == 'show'), hasLength(2));
      expect(requests, isEmpty);
    },
  );

  for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
    for (final failure in [null, 'download', 'attachment']) {
      test('$platform image display with ${failure ?? 'success'}', () async {
        debugDefaultTargetPlatformOverride = platform;
        FlutterLocalNotificationsPlatform.instance =
            platform == TargetPlatform.iOS
            ? IOSFlutterLocalNotificationsPlugin()
            : AndroidFlutterLocalNotificationsPlugin();
        failDownload = failure == 'download';
        failAttachment = failure == 'attachment';
        final display = LocalNotificationDisplay(
          FlutterLocalNotificationsPlugin(),
          imageClient: imageClient,
        );
        final payload = NotificationPayload.fromData(
          {'action': 'open_product', 'product_id': '42'},
          title: 'Title',
          body: 'Body',
          imageUrl: 'https://test.invalid/image',
        );
        await display.show(payload);
        expect(requests, hasLength(1));
        expect(requests.single.headers.containsKey('Authorization'), isFalse);
        final shows = calls.where((c) => c.method == 'show').toList();
        expect(shows, hasLength(failure == 'attachment' ? 2 : 1));
        final shown = shows.last.arguments as Map;
        expect(shown['title'], 'Title');
        expect(shown['body'], 'Body');
        expect(jsonDecode(shown['payload'] as String), {
          'action': 'open_product',
          'product_id': '42',
        });
        final details = shown['platformSpecifics'] as Map;
        if (failure == null) {
          if (platform == TargetPlatform.android) {
            expect(
              (details['styleInformation'] as Map)['bigPicture'],
              imageBytes,
            );
            expect(
              (details['styleInformation'] as Map)['contentTitle'],
              'Title',
            );
            expect((details['styleInformation'] as Map)['summaryText'], 'Body');
          } else {
            expect(attachedBytes, imageBytes);
            expect(attachmentPath, endsWith('.png'));
            expect((details['attachments'] as List), hasLength(1));
          }
        } else {
          expect(details['attachments'], isNull);
          expect((details['styleInformation'] as Map?)?['bigPicture'], isNull);
          expect(shown['id'], (shows.first.arguments as Map)['id']);
        }
        if (attachmentPath != null) {
          expect(await File(attachmentPath!).parent.exists(), isFalse);
        }
      });
    }
  }
}
