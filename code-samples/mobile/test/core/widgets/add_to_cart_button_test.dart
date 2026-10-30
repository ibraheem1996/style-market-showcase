import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:my_project/core/widgets/add_to_cart_button.dart';

void main() {
  group('ReactiveCartActionButton', () {
    testWidgets('does not show a badge when quantity is zero', (tester) async {
      final quantity = 0.obs;
      final isLoading = false.obs;

      await tester.pumpWidget(
        _wrap(
          ReactiveCartActionButton(
            quantity: () => quantity.value,
            isLoading: () => isLoading.value,
            onPressed: () {},
          ),
        ),
      );

      expect(find.text('0'), findsNothing);
    });

    testWidgets('rebuilds when observed quantity changes', (tester) async {
      final quantity = 0.obs;
      final isLoading = false.obs;

      await tester.pumpWidget(
        _wrap(
          ReactiveCartActionButton(
            quantity: () => quantity.value,
            isLoading: () => isLoading.value,
            onPressed: () {},
          ),
        ),
      );

      quantity.value = 3;
      await tester.pump();

      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('calls callback when pressed', (tester) async {
      var taps = 0;
      final quantity = 0.obs;
      final isLoading = false.obs;

      await tester.pumpWidget(
        _wrap(
          ReactiveCartActionButton(
            quantity: () => quantity.value,
            isLoading: () => isLoading.value,
            onPressed: () => taps++,
          ),
        ),
      );

      await tester.tap(find.byType(ReactiveCartActionButton));
      await tester.pump();

      expect(taps, 1);
    });

    testWidgets('shows loading state from observed cart state', (tester) async {
      final quantity = 1.obs;
      final isLoading = false.obs;

      await tester.pumpWidget(
        _wrap(
          ReactiveCartActionButton(
            quantity: () => quantity.value,
            isLoading: () => isLoading.value,
            onPressed: () {},
          ),
        ),
      );

      isLoading.value = true;
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}

Widget _wrap(Widget child) {
  return MaterialApp(
    home: Scaffold(body: Center(child: child)),
  );
}
