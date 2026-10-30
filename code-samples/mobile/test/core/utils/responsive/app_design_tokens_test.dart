import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_project/core/utils/responsive/app_design_tokens.dart';

typedef _IconSizeResolver = double Function(BuildContext context);

void main() {
  test('design tokens expose a fixed spacing scale', () {
    expect(
      [
        AppSpacing.xs,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.xxl,
      ],
      [4, 8, 12, 16, 24, 32],
    );
  });

  test('control tokens preserve non-glyph geometry baselines', () {
    expect(AppControlSizes.small, 32);
    expect(AppControlSizes.medium, 40);
    expect(AppControlSizes.minimumTapTarget, 48);
    expect(AppControlSizes.appBarActionLane, 48);
  });

  testWidgets('semantic icon roles resolve their own window-class values', (
    tester,
  ) async {
    final roles =
        <String, ({_IconSizeResolver resolve, List<double> expected})>{
          'appBarAction': (
            resolve: AppIconSizes.appBarAction,
            expected: [24, 26, 28],
          ),
          'standardAction': (
            resolve: AppIconSizes.standardAction,
            expected: [20, 23, 26],
          ),
          'navigationDestination': (
            resolve: AppIconSizes.navigationDestination,
            expected: [20, 22, 24],
          ),
          'fieldIcon': (
            resolve: AppIconSizes.fieldIcon,
            expected: [20, 22, 24],
          ),
          'listLeading': (
            resolve: AppIconSizes.listLeading,
            expected: [20, 22, 24],
          ),
          'listDisclosure': (
            resolve: AppIconSizes.listDisclosure,
            expected: [20, 22, 24],
          ),
          'compactAction': (
            resolve: AppIconSizes.compactAction,
            expected: [17, 19, 21],
          ),
          'buttonAction': (
            resolve: AppIconSizes.buttonAction,
            expected: [22, 23, 24],
          ),
          'selectionIndicator': (
            resolve: AppIconSizes.selectionIndicator,
            expected: [24, 26, 28],
          ),
          'swatchSelectionIndicator': (
            resolve: AppIconSizes.swatchSelectionIndicator,
            expected: [20, 22, 24],
          ),
          'productCartAction': (
            resolve: AppIconSizes.productCartAction,
            expected: [20, 22, 24],
          ),
          'productFavoriteAction': (
            resolve: AppIconSizes.productFavoriteAction,
            expected: [32, 34, 36],
          ),
          'homeBrand': (
            resolve: AppIconSizes.homeBrand,
            expected: [24, 26, 28],
          ),
          'inlineDisclosure': (
            resolve: AppIconSizes.inlineDisclosure,
            expected: [20, 22, 24],
          ),
          'orderStatus': (
            resolve: AppIconSizes.orderStatus,
            expected: [24, 26, 28],
          ),
          'avatarPlaceholder': (
            resolve: AppIconSizes.avatarPlaceholder,
            expected: [24, 26, 28],
          ),
          'checkoutStep': (
            resolve: AppIconSizes.checkoutStep,
            expected: [24, 26, 28],
          ),
          'mediaStatusSmall': (
            resolve: AppIconSizes.mediaStatusSmall,
            expected: [18, 20, 22],
          ),
          'mediaStatus': (
            resolve: AppIconSizes.mediaStatus,
            expected: [20, 22, 24],
          ),
          'prominentMediaStatus': (
            resolve: AppIconSizes.prominentMediaStatus,
            expected: [24, 26, 28],
          ),
          'largeMediaStatus': (
            resolve: AppIconSizes.largeMediaStatus,
            expected: [44, 48, 52],
          ),
          'heroMediaStatus': (
            resolve: AppIconSizes.heroMediaStatus,
            expected: [100, 104, 108],
          ),
          'pageState': (
            resolve: AppIconSizes.pageState,
            expected: [64, 68, 72],
          ),
          'prominentPageState': (
            resolve: AppIconSizes.prominentPageState,
            expected: [72, 76, 80],
          ),
        };

    const sizes = [Size(599, 800), Size(600, 800), Size(840, 800)];
    for (var index = 0; index < sizes.length; index++) {
      final resolved = await _iconRolesAt(tester, sizes[index], roles);
      for (final entry in roles.entries) {
        expect(
          resolved[entry.key],
          entry.value.expected[index],
          reason: '${entry.key} at ${sizes[index].width}',
        );
      }
    }
  });

  test('fixed micro icon role remains stable across window classes', () {
    expect(AppIconSizes.decorativeMicro, 16);
  });

  testWidgets('Compact semantic roles preserve existing visual baselines', (
    tester,
  ) async {
    late List<double> values;
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(size: Size(360, 800)),
        child: Builder(
          builder: (context) {
            values = [
              AppIconSizes.compactAction(context),
              AppIconSizes.standardAction(context),
              AppIconSizes.appBarAction(context),
              AppIconSizes.selectionIndicator(context),
              AppIconSizes.productFavoriteAction(context),
              AppIconSizes.pageState(context),
              AppIconSizes.prominentPageState(context),
            ];
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(values, [17, 20, 24, 24, 32, 64, 72]);
  });

  testWidgets('selected semantic icon roles grow with large text', (
    tester,
  ) async {
    late List<double> values;
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(
          size: Size(360, 800),
          textScaler: TextScaler.linear(2),
        ),
        child: Builder(
          builder: (context) {
            values = [
              AppIconSizes.appBarAction(context),
              AppIconSizes.fieldIcon(context),
              AppIconSizes.listLeading(context),
              AppIconSizes.buttonAction(context),
              AppIconSizes.selectionIndicator(context),
              AppIconSizes.checkoutStep(context),
            ];
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(values, [30, 26, 26, 28, 30, 30]);
  });

  testWidgets('semantic roles are calibrated without a global multiplier', (
    tester,
  ) async {
    late List<double> values;
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(size: Size(840, 800)),
        child: Builder(
          builder: (context) {
            values = [
              AppIconSizes.decorativeMicro,
              AppIconSizes.navigationDestination(context),
              AppIconSizes.productFavoriteAction(context),
              AppIconSizes.largeMediaStatus(context),
              AppIconSizes.heroMediaStatus(context),
            ];
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(values, [16, 24, 36, 52, 108]);
  });

  testWidgets('shared chrome geometry uses discrete window-class steps', (
    tester,
  ) async {
    expect(await _chromeAt(tester, const Size(599, 800)), [56, 24]);
    expect(await _chromeAt(tester, const Size(600, 800)), [60, 26]);
    expect(await _chromeAt(tester, const Size(840, 800)), [64, 28]);
  });
}

Future<List<double>> _chromeAt(WidgetTester tester, Size size) async {
  late List<double> values;
  await tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(size: size),
      child: Builder(
        builder: (context) {
          values = [
            AppControlSizes.appBarToolbarHeight(context),
            AppIconSizes.appBarAction(context),
          ];
          return const SizedBox.shrink();
        },
      ),
    ),
  );
  return values;
}

Future<Map<String, double>> _iconRolesAt(
  WidgetTester tester,
  Size size,
  Map<String, ({_IconSizeResolver resolve, List<double> expected})> roles,
) async {
  late Map<String, double> values;
  await tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(size: size),
      child: Builder(
        builder: (context) {
          values = {
            for (final entry in roles.entries)
              entry.key: entry.value.resolve(context),
          };
          return const SizedBox.shrink();
        },
      ),
    ),
  );
  return values;
}
