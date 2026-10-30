import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_project/core/utils/responsive/app_radius.dart';

void main() {
  testWidgets('radius tokens stay fixed across window sizes', (tester) async {
    late List<double> compactValues;
    late List<double> expandedValues;

    await tester.pumpWidget(
      _RadiusProbe(
        onBuild: (context) {
          compactValues = _values(context);
        },
      ),
    );

    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1200, 800);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(
      _RadiusProbe(
        onBuild: (context) {
          expandedValues = _values(context);
        },
      ),
    );

    expect(compactValues, [4, 8, 12, 16, 24, 32, 999]);
    expect(expandedValues, compactValues);
  });
}

List<double> _values(BuildContext context) => [
  AppRadius.xs(context),
  AppRadius.sm(context),
  AppRadius.md(context),
  AppRadius.lg(context),
  AppRadius.xl(context),
  AppRadius.xxl(context),
  AppRadius.circular(context),
];

class _RadiusProbe extends StatelessWidget {
  const _RadiusProbe({required this.onBuild});

  final void Function(BuildContext context) onBuild;

  @override
  Widget build(BuildContext context) {
    onBuild(context);
    return const SizedBox.shrink();
  }
}
