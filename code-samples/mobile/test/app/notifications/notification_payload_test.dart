import 'package:flutter_test/flutter_test.dart';
import 'package:my_project/app/notifications/notification_payload.dart';

void main() {
  test('three actions share semantic local JSON without display text', () {
    for (final data in [
      {'action': 'no_action'},
      {'action': 'open_product', 'product_id': '42'},
      {'action': 'open_order', 'order_id': '178'},
    ]) {
      final payload = NotificationPayload.fromData(
        data,
        title: 'Title',
        body: 'Body',
        imageUrl: 'https://test.invalid/image.png',
      );
      final roundTrip = NotificationPayload.fromLocalJson(
        payload.toLocalJson(),
      );
      expect(roundTrip.action, payload.action);
      expect(roundTrip.targetId, payload.targetId);
      expect(payload.imageUrl, 'https://test.invalid/image.png');
      expect(roundTrip.imageUrl, isNull);
      expect(payload.toLocalJson(), isNot(contains('image')));
      expect(payload.toLocalJson(), isNot(contains('Title')));
      expect(payload.toLocalJson(), isNot(contains('Body')));
    }
  });
  test('invalid external data fails safely while retaining display text', () {
    for (final data in <Map<String, dynamic>>[
      {},
      {'action': '/orderDetails', 'order_id': '1'},
      {'action': 'open_product'},
      for (final id in ['0', '-1', '1.5', ' 1', '1 ', '+1', '01', 'x', 1, null])
        {'action': 'open_product', 'product_id': id},
      {'action': 'open_order', 'order_id': '1', 'product_id': '2'},
      {'action': 'open_product', 'product_id': '1', 'order_id': null},
      {'action': 'open_order', 'order_id': '99999999999999999999999999999'},
    ]) {
      final payload = NotificationPayload.fromData(
        data,
        title: 'Title',
        imageUrl: 'https://test.invalid/image.png',
      );
      expect(payload.action, NotificationAction.noAction);
      expect(payload.targetId, isNull);
      expect(payload.title, 'Title');
      expect(payload.imageUrl, 'https://test.invalid/image.png');
    }
    for (final json in [null, '', '{', '[]', '1', '{"action":true}']) {
      expect(
        NotificationPayload.fromLocalJson(json).action,
        NotificationAction.noAction,
      );
    }
  });
}
