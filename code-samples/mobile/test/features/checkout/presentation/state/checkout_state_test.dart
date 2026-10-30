import 'package:flutter_test/flutter_test.dart';
import 'package:my_project/features/checkout/presentation/state/state.dart';

void main() {
  test('checkout state starts at payment step with no method selected', () {
    const state = CheckoutState();

    expect(state.currentStepIndex, 0);
    expect(state.selectedPaymentMethod, PaymentMethod.none);
    expect(state.isPlacingOrder, isFalse);
    expect(state.isPreviewingOrder, isFalse);
  });

  test('copyWith keeps checkout progress explicit', () {
    const state = CheckoutState();

    final next = state.copyWith(
      currentStepIndex: 1,
      selectedPaymentMethod: PaymentMethod.cash,
    );

    expect(next.currentStepIndex, 1);
    expect(next.selectedPaymentMethod, PaymentMethod.cash);
  });
}
