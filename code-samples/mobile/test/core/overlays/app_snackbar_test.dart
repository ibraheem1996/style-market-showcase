import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:my_project/core/overlays/app_snackbar.dart';
import 'package:my_project/core/theme/app_semantic_colors.dart';
import 'package:my_project/core/utils/responsive/app_text_scale_limits.dart';

void main() {
  setUp(() => Get.testMode = true);
  tearDown(Get.reset);

  testWidgets('renders message-only App-owned feedback for every tone', (
    tester,
  ) async {
    await _pump(tester);

    for (final tone in AppSnackbarTone.values) {
      await _showSnackbar(tester, 'Message for ${tone.name}', tone: tone);

      expect(find.text('Message for ${tone.name}'), findsOneWidget);
      await _removeSnackbars(tester);
    }
  });

  testWidgets('keeps only the latest request from a rapid burst', (
    tester,
  ) async {
    await _pump(tester);

    final requests = List.generate(
      20,
      (index) => AppSnackbar.show(
        'Message $index',
        duration: const Duration(hours: 1),
      ),
    );
    await Future.wait(requests);
    await tester.pumpAndSettle();

    expect(find.text('Message 19'), findsOneWidget);
    expect(find.text('Message 0'), findsNothing);
    await _removeSnackbars(tester);
    expect(find.text('Message 0'), findsNothing);
  });

  testWidgets('replaces an already visible snackbar with the latest request', (
    tester,
  ) async {
    await _pump(tester);
    await _showSnackbar(tester, 'Visible message');

    final superseded = AppSnackbar.show(
      'Superseded message',
      duration: const Duration(hours: 1),
    );
    final latest = AppSnackbar.show(
      'Latest message',
      duration: const Duration(hours: 1),
    );
    await Future.wait([superseded, latest]);
    await tester.pumpAndSettle();

    expect(find.text('Visible message'), findsNothing);
    expect(find.text('Superseded message'), findsNothing);
    expect(find.text('Latest message'), findsOneWidget);
    await _removeSnackbars(tester);
    expect(find.text('Superseded message'), findsNothing);
  });

  testWidgets('clamps the complete snackbar presentation at the shared limit', (
    tester,
  ) async {
    await _pump(tester, textScale: 3);

    await _showSnackbar(tester, 'Scaled message');

    final scalers = tester
        .widgetList<MediaQuery>(
          find.ancestor(
            of: find.text('Scaled message'),
            matching: find.byType(MediaQuery),
          ),
        )
        .map((mediaQuery) => mediaQuery.data.textScaler.scale(1));

    expect(scalers, contains(AppTextScaleLimits.snackbar));
    await _removeSnackbars(tester);
  });
}

Future<void> _removeSnackbars(WidgetTester tester) async {
  final messenger = AppSnackbar.messengerKey.currentState;
  messenger?.clearSnackBars();
  messenger?.removeCurrentSnackBar();
  await tester.pumpAndSettle();
  expect(find.byType(SnackBar), findsNothing);
}

Future<void> _showSnackbar(
  WidgetTester tester,
  String message, {
  AppSnackbarTone tone = AppSnackbarTone.neutral,
}) async {
  await AppSnackbar.show(
    message,
    tone: tone,
    duration: const Duration(hours: 1),
  );
  await tester.pumpAndSettle();
}

Future<void> _pump(WidgetTester tester, {double textScale = 1}) {
  return tester.pumpWidget(
    GetMaterialApp(
      scaffoldMessengerKey: AppSnackbar.messengerKey,
      theme: ThemeData(
        extensions: const [AppSemanticColors(warning: Colors.orange)],
      ),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(textScale)),
        child: child!,
      ),
      home: const Scaffold(body: SizedBox.expand()),
    ),
  );
}
