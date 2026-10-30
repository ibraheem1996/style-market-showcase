import 'dart:convert';

/// The only navigation vocabulary accepted from remote and local notifications.
enum NotificationAction { noAction, openProduct, openOrder }

class NotificationPayload {
  const NotificationPayload._(
    this.action,
    this.targetId,
    this.title,
    this.body,
    this.imageUrl,
  );

  final NotificationAction action;
  final int? targetId;
  final String? title;
  final String? body;
  final String? imageUrl;

  static int? _parseId(dynamic value) {
    if (value is! String) return null;
    if (!RegExp(r'^[1-9][0-9]*$').hasMatch(value)) return null;

    return int.tryParse(value);
  }

  factory NotificationPayload.fromData(
    Map<String, dynamic> data, {
    String? title,
    String? body,
    String? imageUrl,
  }) {
    final action = data['action'];

    switch (action) {
      case 'open_product':
        final productId = _parseId(data['product_id']);

        if (productId == null || data.containsKey('order_id')) {
          return NotificationPayload._noAction(title, body, imageUrl);
        }

        return NotificationPayload._(
          NotificationAction.openProduct,
          productId,
          title,
          body,
          imageUrl,
        );

      case 'open_order':
        final orderId = _parseId(data['order_id']);

        if (orderId == null || data.containsKey('product_id')) {
          return NotificationPayload._noAction(title, body, imageUrl);
        }

        return NotificationPayload._(
          NotificationAction.openOrder,
          orderId,
          title,
          body,
          imageUrl,
        );

      default:
        return NotificationPayload._noAction(title, body, imageUrl);
    }
  }

  factory NotificationPayload.fromLocalJson(String? value) {
    try {
      final decoded = jsonDecode(value ?? '');
      if (decoded is Map<String, dynamic>) {
        return NotificationPayload.fromData(decoded);
      }
    } catch (_) {
      // A malformed local launch still opens the app normally.
    }
    return NotificationPayload._noAction(null, null);
  }

  factory NotificationPayload._noAction(
    String? title,
    String? body, [
    String? imageUrl,
  ]) => NotificationPayload._(
    NotificationAction.noAction,
    null,
    title,
    body,
    imageUrl,
  );

  /// Local taps carry semantic data only; display text is not duplicated.
  String toLocalJson() => jsonEncode(switch (action) {
    NotificationAction.noAction => {'action': 'no_action'},
    NotificationAction.openProduct => {
      'action': 'open_product',
      'product_id': '$targetId',
    },
    NotificationAction.openOrder => {
      'action': 'open_order',
      'order_id': '$targetId',
    },
  });
}
