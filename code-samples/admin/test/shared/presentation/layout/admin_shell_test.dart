import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:multi_product_store_admin_web/app/router/app_routes.dart';
import 'package:multi_product_store_admin_web/app/theme/app_theme.dart';
import 'package:multi_product_store_admin_web/core/responsive/app_responsive.dart';
import 'package:multi_product_store_admin_web/shared/presentation/layout/admin_shell.dart';
import 'package:multi_product_store_admin_web/shared/presentation/layout/admin_top_bar.dart';

void main() {
  testWidgets('shows drawer menu on compact screens', (tester) async {
    await tester.binding.setSurfaceSize(const Size(375, 700));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_TestAdminShellApp());

    expect(find.byIcon(Icons.menu), findsOneWidget);
    expect(find.text('إدارة المتجر'), findsNothing);

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();

    expect(find.byType(Drawer), findsOneWidget);
    expect(find.text('إدارة المتجر'), findsOneWidget);
    expect(find.text('الطلبات'), findsOneWidget);
  });

  testWidgets('shows full sidebar on desktop screens', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_TestAdminShellApp());

    expect(find.byIcon(Icons.menu), findsNothing);
    expect(find.byType(Drawer), findsNothing);
    expect(find.text('إدارة المتجر'), findsOneWidget);
    expect(find.text('لوحة التحكم'), findsWidgets);
    expect(find.text('الطلبات'), findsOneWidget);
    expect(find.text('الكتالوج'), findsOneWidget);
    expect(find.text('التصنيفات'), findsOneWidget);
    expect(find.text('الفئات المستهدفة'), findsOneWidget);
    expect(find.text('البنرات'), findsOneWidget);
    expect(find.text('الألوان'), findsOneWidget);
    expect(find.text('المقاسات'), findsOneWidget);
    expect(find.text('العملاء'), findsOneWidget);
    expect(find.text('البيانات المرجعية'), findsOneWidget);
    expect(find.text('الإعدادات'), findsOneWidget);
  });

  testWidgets('passes top bar data and navigates to orders', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_TestAdminShellApp());

    expect(find.text('لوحة التحكم'), findsWidgets);
    expect(find.text('نظرة اختبارية'), findsOneWidget);
    expect(find.text('إبراهيم'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);

    await tester.tap(find.text('الطلبات'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('orders-child')), findsOneWidget);
  });

  testWidgets('catalog sidebar destination opens products', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_TestAdminShellApp());

    await tester.tap(find.text('الكتالوج'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('products-child')), findsOneWidget);
  });

  testWidgets('categories sidebar destination opens categories', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1280, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_TestAdminShellApp());
    await tester.tap(find.text('التصنيفات'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('categories-child')), findsOneWidget);
  });

  testWidgets('audiences sidebar destination opens audiences', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_TestAdminShellApp());
    await tester.tap(find.text('الفئات المستهدفة'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('audiences-child')), findsOneWidget);
  });

  testWidgets('sizes sidebar destination opens sizes', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_TestAdminShellApp());
    await tester.tap(find.text('المقاسات'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('sizes-child')), findsOneWidget);
  });

  testWidgets('banners sidebar destination opens banners', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_TestAdminShellApp());
    await tester.tap(find.text('البنرات'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('banners-child')), findsOneWidget);
  });

  testWidgets('collapsed sidebar exposes coming soon tooltips', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 700));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_TestAdminShellApp());

    expect(find.text('إدارة المتجر'), findsNothing);
    expect(find.byTooltip('قريبًا'), findsNWidgets(3));
  });
}

class _TestAdminShellApp extends StatelessWidget {
  _TestAdminShellApp();

  late final GoRouter _router = GoRouter(
    initialLocation: AppRoutes.dashboard,
    routes: [
      ShellRoute(
        builder: (_, _, child) => AdminShell(
          topBarData: const AdminTopBarData(
            title: 'لوحة التحكم',
            subtitle: 'نظرة اختبارية',
            searchHint: 'ابحث...',
            notificationCount: 3,
            adminName: 'إبراهيم',
            adminInitials: 'إ',
          ),
          onLogoutPressed: () {},
          child: child,
        ),
        routes: [
          GoRoute(
            path: AppRoutes.dashboard,
            builder: (_, _) => const SizedBox(key: Key('dashboard-child')),
          ),
          GoRoute(
            path: AppRoutes.orders,
            builder: (_, _) => const SizedBox(key: Key('orders-child')),
          ),
          GoRoute(
            path: AppRoutes.products,
            builder: (_, _) => const SizedBox(key: Key('products-child')),
          ),
          GoRoute(
            path: AppRoutes.categories,
            builder: (_, _) => const SizedBox(key: Key('categories-child')),
          ),
          GoRoute(
            path: AppRoutes.audiences,
            builder: (_, _) => const SizedBox(key: Key('audiences-child')),
          ),
          GoRoute(
            path: AppRoutes.banners,
            builder: (_, _) => const SizedBox(key: Key('banners-child')),
          ),
          GoRoute(
            path: AppRoutes.colors,
            builder: (_, _) => const SizedBox(key: Key('colors-child')),
          ),
          GoRoute(
            path: AppRoutes.sizes,
            builder: (_, _) => const SizedBox(key: Key('sizes-child')),
          ),
        ],
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: AppTheme.darkTheme,
      routerConfig: _router,
      builder: (context, child) {
        return AppResponsive(
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
    );
  }
}
