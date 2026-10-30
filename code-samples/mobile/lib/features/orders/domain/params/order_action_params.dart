class CancelOrderParams {
  final int orderId;
  final String? reason;

  const CancelOrderParams({required this.orderId, this.reason});
}

class SubmitOrderNoteParams {
  final int orderId;
  final String note;

  const SubmitOrderNoteParams({required this.orderId, required this.note});
}
