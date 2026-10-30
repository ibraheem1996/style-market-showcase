import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:my_project/core/overlays/app_bottom_sheet.dart';
import 'package:my_project/core/theme/app_bottom_sheet_theme.dart';
import 'package:my_project/core/utils/responsive/app_text_scale_limits.dart';
import 'package:my_project/core/utils/responsive/responsive_content_profile.dart';

void main() {
  setUp(() => Get.testMode = true);
  tearDown(Get.reset);

  testWidgets('propagates a typed result from the sheet child', (tester) async {
    int? result;
    await _pump(
      tester,
      child: _SheetLauncher(onResult: (value) => result = value),
    );

    await tester.tap(find.text('Open sheet'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Return result'));
    await tester.pumpAndSettle();

    expect(result, 7);
  });

  testWidgets('uses the standard profile width and whole-sheet scale scope', (
    tester,
  ) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.binding.setSurfaceSize(const Size(1000, 700));
    await _pump(tester, child: const _SheetLauncher(), textScale: 3);

    await tester.tap(find.text('Open sheet'));
    await tester.pumpAndSettle();

    final sheet = tester.getSize(
      find
          .ancestor(
            of: find.text('Sheet content'),
            matching: find.byType(ConstrainedBox),
          )
          .first,
    );
    final scalers = tester
        .widgetList<MediaQuery>(
          find.ancestor(
            of: find.text('Sheet content'),
            matching: find.byType(MediaQuery),
          ),
        )
        .map((mediaQuery) => mediaQuery.data.textScaler.scale(1));

    expect(sheet.width, ResponsiveContentProfile.standard.maxWidth);
    expect(scalers, contains(AppTextScaleLimits.bottomSheet));
  });
}

Future<void> _pump(
  WidgetTester tester, {
  required Widget child,
  double textScale = 1,
}) {
  return tester.pumpWidget(
    GetMaterialApp(
      theme: ThemeData(useMaterial3: true),
      builder: (context, appChild) => Theme(
        data: Theme.of(
          context,
        ).copyWith(bottomSheetTheme: appBottomSheetTheme(context)),
        child: MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: appChild!,
        ),
      ),
      home: Scaffold(body: child),
    ),
  );
}

class _SheetLauncher extends StatelessWidget {
  const _SheetLauncher({this.onResult});

  final ValueChanged<int>? onResult;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () async {
        final result = await AppBottomSheet.show<int>(
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Sheet content'),
                TextButton(
                  onPressed: () => Get.back(result: 7),
                  child: const Text('Return result'),
                ),
              ],
            ),
          ),
        );
        onResult?.call(result ?? 0);
      },
      child: const Text('Open sheet'),
    );
  }
}
