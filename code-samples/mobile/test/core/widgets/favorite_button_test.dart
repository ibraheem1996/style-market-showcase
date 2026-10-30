import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_project/core/widgets/favorite_button.dart';

void main() {
  testWidgets('shows the supplied favorite state without animating on mount', (
    tester,
  ) async {
    for (final isFavorite in [false, true]) {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FavoriteButton(isFavorite: isFavorite, onPressed: _noOp),
          ),
        ),
      );

      final icon = tester.widget<Icon>(
        find.byIcon(isFavorite ? Icons.favorite : Icons.favorite_border),
      );
      final offColor = Theme.of(
        tester.element(find.byType(FavoriteButton)),
      ).colorScheme.onSurface;
      expect(icon.color, isFavorite ? Colors.red : offColor);
      expect(tester.hasRunningAnimations, isFalse);
      final transform = tester.widget<Transform>(
        find
            .descendant(
              of: find.byType(FavoriteButton),
              matching: find.byType(Transform),
            )
            .first,
      );
      expect(transform.transform.getMaxScaleOnAxis(), 1.0);
    }
  });

  testWidgets('animates when the supplied favorite state changes', (
    tester,
  ) async {
    Widget button(bool isFavorite) => MaterialApp(
      home: Scaffold(
        body: FavoriteButton(isFavorite: isFavorite, onPressed: _noOp),
      ),
    );

    await tester.pumpWidget(button(false));
    expect(tester.hasRunningAnimations, isFalse);

    await tester.pumpWidget(button(true));
    expect(tester.hasRunningAnimations, isTrue);
    final transform = tester.widget<Transform>(
      find
          .descendant(
            of: find.byType(FavoriteButton),
            matching: find.byType(Transform),
          )
          .first,
    );
    expect(transform.transform.getMaxScaleOnAxis(), 1.2);

    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.favorite), findsOneWidget);
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('renders only the supplied state and callback', (tester) async {
    var taps = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FavoriteButton(isFavorite: true, onPressed: () => taps++),
        ),
      ),
    );

    expect(find.byIcon(Icons.favorite), findsOneWidget);
    await tester.tap(find.byType(IconButton));
    expect(taps, 1);
  });

  testWidgets('blocks taps while the supplied target is loading', (
    tester,
  ) async {
    var taps = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FavoriteButton(
            isFavorite: false,
            isLoading: true,
            onPressed: () => taps++,
          ),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.tap(find.byType(IconButton));
    expect(taps, 0);
  });
}

void _noOp() {}
