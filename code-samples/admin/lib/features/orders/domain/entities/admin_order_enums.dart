enum AdminOrderStatus {
  pending,
  processing,
  delivered,
  cancelled,
  rejected,
  returned,
}

enum AdminPaymentMethod { cash, card }

enum AdminPaymentStatus { unpaid, paid, failed, refunded }

enum AdminOrderSort { newest, oldest, highestTotal, lowestTotal }

enum AdminOrderAction { approve, reject, cancel, delivered, returned }
