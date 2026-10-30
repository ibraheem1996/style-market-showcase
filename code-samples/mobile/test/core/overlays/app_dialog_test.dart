import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:my_project/core/overlays/app_dialog.dart';
import 'package:my_project/core/utils/responsive/app_text_scale_limits.dart';

void main() {
  setUp(() => Get.testMode = true);
  tearDown(Get.reset);

  testWidgets('confirm closes with its typed decision', (tester) async {
    bool? result;
    await _pump(
      tester,
      child: _DialogLauncher(onConfirm: (value) => result = value),
    );

    await tester.tap(find.text('Open confirm'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();

    expect(result, isTrue);
  });

  testWidgets('dialog defaults to a non-dismissible barrier', (tester) async {
    await _pump(tester, child: const _DialogLauncher());

    await tester.tap(find.text('Open alert'));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(4, 4));
    await tester.pumpAndSettle();

    expect(find.text('Important message'), findsOneWidget);
  });

  testWidgets('dialog clamps its complete presentation at the shared limit', (
    tester,
  ) async {
    await _pump(tester, child: const _DialogLauncher(), textScale: 3);

    await tester.tap(find.text('Open alert'));
    await tester.pumpAndSettle();

    final scalers = tester
        .widgetList<MediaQuery>(
          find.ancestor(
            of: find.text('Important message'),
            matching: find.byType(MediaQuery),
          ),
        )
        .map((mediaQuery) => mediaQuery.data.textScaler.scale(1));

    expect(scalers, contains(AppTextScaleLimits.dialog));
    expect(find.byType(SingleChildScrollView), findsOneWidget);
  });
}

Future<void> _pump(
  WidgetTester tester, {
  required Widget child,
  double textScale = 1,
}) {
  return tester.pumpWidget(
    GetMaterialApp(
      builder: (context, appChild) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(textScale)),
        child: appChild!,
      ),
      home: Scaffold(body: child),
    ),
  );
}

class _DialogLauncher extends StatelessWidget {
  const _DialogLauncher({this.onConfirm});

  final ValueChanged<bool>? onConfirm;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextButton(
          onPressed: () async {
            final result = await AppDialog.confirm(
              'Decision message',
              confirmLabel: 'Confirm',
              cancelLabel: 'Cancel',
            );
            onConfirm?.call(result);
          },
          child: const Text('Open confirm'),
        ),
        TextButton(
          onPressed: () =>
              AppDialog.alert('Important message', actionLabel: 'Acknowledge'),
          child: const Text('Open alert'),
        ),
      ],
    );
  }
}
