import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../features/audiences/presentation/pages/admin_audience_create_page.dart';
import '../../features/audiences/presentation/pages/admin_audience_edit_page.dart';
import '../../features/audiences/presentation/pages/admin_audiences_page.dart';
import '../../features/banners/presentation/pages/admin_banner_create_page.dart';
import '../../features/banners/presentation/pages/admin_banner_edit_page.dart';
import '../../features/banners/presentation/pages/admin_banner_form_view.dart';
import '../../features/banners/presentation/pages/admin_banners_page.dart';
import '../../features/collections/presentation/pages/admin_collection_create_page.dart';
import '../../features/collections/presentation/pages/admin_collection_edit_page.dart';
import '../../features/collections/presentation/pages/admin_collections_page.dart';
import '../../features/colors/presentation/pages/colors_page.dart';
import '../../features/auth/presentation/cubit/admin_session_cubit.dart';
import '../../features/auth/presentation/cubit/admin_session_state.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/categories/presentation/pages/admin_categories_page.dart';
import '../../features/categories/presentation/pages/admin_category_create_page.dart';
import '../../features/categories/presentation/pages/admin_category_edit_page.dart';
import '../../features/categories/presentation/pages/admin_category_form_view.dart';
import '../../features/orders/presentation/pages/admin_order_detail_page.dart';
import '../../features/orders/presentation/pages/admin_orders_page.dart';
import '../../features/products/presentation/pages/admin_product_detail_page.dart';
import '../../features/products/presentation/pages/admin_product_create_page.dart';
import '../../features/products/presentation/pages/admin_product_edit_page.dart';
import '../../features/products/presentation/pages/admin_product_media_page.dart';
import '../../features/products/presentation/pages/admin_products_page.dart';
import '../../features/products/presentation/pages/admin_variant_create_page.dart';
import '../../features/products/presentation/pages/admin_variant_edit_page.dart';
import '../../features/sizes/presentation/pages/admin_sizes_page.dart';
import '../../shared/presentation/layout/admin_shell.dart';
import '../../shared/presentation/layout/admin_top_bar.dart';
import '../../shared/presentation/widgets/app_error_view.dart';
import '../../shared/presentation/widgets/app_loading_view.dart';
import 'app_routes.dart';
import 'auth_redirect.dart';
import 'router_refresh_notifier.dart';

GoRouter createAppRouter({
  required AuthRedirect authRedirect,
  required RouterRefreshNotifier refreshNotifier,
}) {
  final router = GoRouter(
    initialLocation: AppRoutes.dashboard,
    refreshListenable: refreshNotifier,
    redirect: (_, state) => authRedirect.redirect(state),
    routes: [
      GoRoute(
        path: AppRoutes.authChecking,
        name: 'authChecking',
        builder: (_, _) => const Scaffold(
          body: AppLoadingView(message: 'جار التحقق من الجلسة...'),
        ),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (_, _) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.forbidden,
        name: 'forbidden',
        builder: (_, _) => const Scaffold(
          body: AppErrorView(
            title: 'غير مصرح',
            message: 'لا توجد صلاحية كافية لعرض هذه الصفحة.',
          ),
        ),
      ),
      ShellRoute(
        builder: (context, goRouterState, child) {
          return BlocBuilder<AdminSessionCubit, AdminSessionState>(
            builder: (context, state) {
              final adminName = _adminNameFromState(state);
              return AdminShell(
                topBarData: _topBarDataForPath(
                  path: goRouterState.uri.path,
                  adminName: adminName,
                ),
                onLogoutPressed: () =>
                    context.read<AdminSessionCubit>().logout(),
                child: child,
              );
            },
          );
        },
        routes: [
          GoRoute(
            path: AppRoutes.dashboard,
            name: 'dashboard',
            builder: (context, _) {
              final adminName = _adminNameFromState(
                context.watch<AdminSessionCubit>().state,
              );
              return DashboardPage(adminName: adminName);
            },
          ),
          GoRoute(
            path: AppRoutes.orders,
            name: 'orders',
            builder: (_, _) => const AdminOrdersPage(),
          ),
          GoRoute(
            path: AppRoutes.orderDetail,
            name: 'orderDetail',
            builder: (_, state) {
              final orderId = int.tryParse(
                state.pathParameters['orderId'] ?? '',
              );
              if (orderId == null) {
                return const Scaffold(
                  body: AppErrorView(
                    title: 'طلب غير صالح',
                    message: 'رقم الطلب في الرابط غير صالح.',
                  ),
                );
              }
              return AdminOrderDetailPage(orderId: orderId);
            },
          ),
          GoRoute(
            path: AppRoutes.products,
            name: 'products',
            builder: (_, _) => const AdminProductsPage(),
          ),
          GoRoute(
            path: AppRoutes.categories,
            name: 'categories',
            builder: (_, _) => const AdminCategoriesPage(),
          ),
          GoRoute(
            path: AppRoutes.categoryCreate,
            name: 'categoryCreate',
            onExit: (context, _) => confirmAdminCategoryFormExit(
              context,
              adminCategoryCreatePageKey,
            ),
            builder: (_, _) => const AdminCategoryCreatePage(),
          ),
          GoRoute(
            path: AppRoutes.categoryEdit,
            name: 'categoryEdit',
            onExit: (context, _) =>
                confirmAdminCategoryFormExit(context, adminCategoryEditPageKey),
            builder: (_, state) {
              final categoryId = int.tryParse(
                state.pathParameters['categoryId'] ?? '',
              );
              if (categoryId == null) {
                return const Scaffold(
                  body: AppErrorView(
                    title: 'تصنيف غير صالح',
                    message: 'رقم التصنيف في الرابط غير صالح.',
                  ),
                );
              }
              return AdminCategoryEditPage(categoryId: categoryId);
            },
          ),
          GoRoute(
            path: AppRoutes.audiences,
            name: 'audiences',
            builder: (_, _) => const AdminAudiencesPage(),
          ),
          GoRoute(
            path: AppRoutes.colors,
            name: 'colors',
            builder: (_, _) => const ColorsPage(),
          ),
          GoRoute(
            path: AppRoutes.sizes,
            name: 'sizes',
            builder: (_, _) => const AdminSizesPage(),
          ),
          GoRoute(
            path: AppRoutes.audienceCreate,
            name: 'audienceCreate',
            builder: (_, _) => const AdminAudienceCreatePage(),
          ),
          GoRoute(
            path: AppRoutes.audienceEdit,
            name: 'audienceEdit',
            builder: (_, state) {
              final audienceId = int.tryParse(
                state.pathParameters['audienceId'] ?? '',
              );
              if (audienceId == null) {
                return const Scaffold(
                  body: AppErrorView(
                    title: 'فئة مستهدفة غير صالحة',
                    message: 'رقم الفئة المستهدفة في الرابط غير صالح.',
                  ),
                );
              }
              return AdminAudienceEditPage(audienceId: audienceId);
            },
          ),
          GoRoute(
            path: AppRoutes.banners,
            name: 'banners',
            builder: (_, _) => const AdminBannersPage(),
          ),
          GoRoute(
            path: AppRoutes.bannerCreate,
            name: 'bannerCreate',
            onExit: (context, _) =>
                confirmAdminBannerFormExit(context, adminBannerCreatePageKey),
            builder: (_, _) => const AdminBannerCreatePage(),
          ),
          GoRoute(
            path: AppRoutes.bannerEdit,
            name: 'bannerEdit',
            onExit: (context, _) =>
                confirmAdminBannerFormExit(context, adminBannerEditPageKey),
            builder: (_, state) {
              final bannerId = int.tryParse(
                state.pathParameters['bannerId'] ?? '',
              );
              if (bannerId == null) {
                return const Scaffold(
                  body: AppErrorView(
                    title: 'بنر غير صالح',
                    message: 'رقم البنر في الرابط غير صالح.',
                  ),
                );
              }
              return AdminBannerEditPage(bannerId: bannerId);
            },
          ),
          GoRoute(
            path: AppRoutes.collections,
            name: 'collections',
            builder: (_, _) => const AdminCollectionsPage(),
          ),
          GoRoute(
            path: AppRoutes.collectionCreate,
            name: 'collectionCreate',
            builder: (_, _) => const AdminCollectionCreatePage(),
          ),
          GoRoute(
            path: AppRoutes.collectionEdit,
            name: 'collectionEdit',
            builder: (_, state) {
              final collectionId = int.tryParse(
                state.pathParameters['collectionId'] ?? '',
              );
              if (collectionId == null) {
                return const Scaffold(
                  body: AppErrorView(
                    title: 'مجموعة غير صالحة',
                    message: 'رقم المجموعة في الرابط غير صالح.',
                  ),
                );
              }
              return AdminCollectionEditPage(collectionId: collectionId);
            },
          ),
          GoRoute(
            path: AppRoutes.productCreate,
            name: 'productCreate',
            onExit: (context, _) => confirmProductCreateRouteExit(context),
            builder: (_, _) => const AdminProductCreatePage(),
          ),
          GoRoute(
            path: AppRoutes.productVariantCreate,
            name: 'productVariantCreate',
            onExit: (context, _) => confirmVariantCreateRouteExit(context),
            builder: (_, state) {
              final productId = int.tryParse(
                state.pathParameters['productId'] ?? '',
              );
              if (productId == null) {
                return const Scaffold(
                  body: AppErrorView(
                    title: 'منتج غير صالح',
                    message: 'رقم المنتج في الرابط غير صالح.',
                  ),
                );
              }
              return AdminVariantCreatePage(productId: productId);
            },
          ),
          GoRoute(
            path: AppRoutes.productVariantEdit,
            name: 'productVariantEdit',
            onExit: (context, _) => confirmVariantEditRouteExit(context),
            builder: (_, state) {
              final productId = int.tryParse(
                state.pathParameters['productId'] ?? '',
              );
              final variantId = int.tryParse(
                state.pathParameters['variantId'] ?? '',
              );
              if (productId == null || variantId == null) {
                return const Scaffold(
                  body: AppErrorView(
                    title: 'خيار غير صالح',
                    message: 'رقم المنتج أو الخيار غير صالح.',
                  ),
                );
              }
              return AdminVariantEditPage(
                productId: productId,
                variantId: variantId,
              );
            },
          ),
          GoRoute(
            path: AppRoutes.productMedia,
            name: 'productMedia',
            builder: (_, state) {
              final productId = int.tryParse(
                state.pathParameters['productId'] ?? '',
              );
              if (productId == null) {
                return const Scaffold(
                  body: AppErrorView(
                    title: 'منتج غير صالح',
                    message: 'رقم المنتج في الرابط غير صالح.',
                  ),
                );
              }
              final returnMarker = state.extra is AdminProductMediaReturnMarker
                  ? state.extra! as AdminProductMediaReturnMarker
                  : null;
              return AdminProductMediaPage(
                productId: productId,
                returnMarker: returnMarker,
              );
            },
          ),
          GoRoute(
            path: AppRoutes.productEdit,
            name: 'productEdit',
            onExit: (context, _) => confirmProductEditRouteExit(context),
            builder: (_, state) {
              final productId = int.tryParse(
                state.pathParameters['productId'] ?? '',
              );
              if (productId == null) {
                return const Scaffold(
                  body: AppErrorView(
                    title: 'منتج غير صالح',
                    message: 'رقم المنتج في الرابط غير صالح.',
                  ),
                );
              }
              final returnMarker = state.extra is AdminProductEditReturnMarker
                  ? state.extra! as AdminProductEditReturnMarker
                  : null;
              return AdminProductEditPage(
                productId: productId,
                returnMarker: returnMarker,
              );
            },
          ),
          GoRoute(
            path: AppRoutes.productDetail,
            name: 'productDetail',
            builder: (_, state) {
              final productId = int.tryParse(
                state.pathParameters['productId'] ?? '',
              );
              if (productId == null) {
                return const Scaffold(
                  body: AppErrorView(
                    title: 'منتج غير صالح',
                    message: 'رقم المنتج في الرابط غير صالح.',
                  ),
                );
              }
              final initialData = state.extra is AdminProductDetailInitialData
                  ? state.extra! as AdminProductDetailInitialData
                  : null;
              return AdminProductDetailPage(
                productId: productId,
                initialData: initialData,
              );
            },
          ),
        ],
      ),
    ],
    errorBuilder: (_, state) => Scaffold(
      body: AppErrorView(
        title: 'الصفحة غير موجودة',
        message: state.error?.message ?? 'تعذر العثور على الصفحة المطلوبة.',
      ),
    ),
  );
  return router;
}

String _adminNameFromState(AdminSessionState state) {
  return switch (state) {
    AdminSessionAuthenticated(:final admin) => admin.name,
    _ => 'الأدمن',
  };
}

String _adminInitials(String name) {
  final trimmed = name.trim();
  if (trimmed.isEmpty) {
    return 'أ';
  }

  final parts = trimmed.split(RegExp(r'\s+'));
  if (parts.length == 1) {
    return parts.first.characters.first;
  }

  return '${parts.first.characters.first}${parts.last.characters.first}';
}

AdminTopBarData _topBarDataForPath({
  required String path,
  required String adminName,
}) {
  final isOrders =
      path == AppRoutes.orders || path.startsWith('${AppRoutes.orders}/');
  if (isOrders) {
    return AdminTopBarData(
      title: 'الطلبات',
      subtitle: 'إدارة ومتابعة طلبات المتجر',
      searchHint: '',
      showSearch: false,
      notificationCount: 3,
      adminName: adminName,
      adminInitials: _adminInitials(adminName),
    );
  }

  final isProducts =
      path == AppRoutes.products || path.startsWith('${AppRoutes.products}/');
  if (isProducts) {
    return AdminTopBarData(
      title: 'الكتالوج',
      subtitle: 'إدارة المنتجات والمخزون والظهور',
      searchHint: '',
      showSearch: false,
      notificationCount: 3,
      adminName: adminName,
      adminInitials: _adminInitials(adminName),
    );
  }

  final isCategories =
      path == AppRoutes.categories ||
      path.startsWith('${AppRoutes.categories}/');
  if (isCategories) {
    return AdminTopBarData(
      title: 'التصنيفات',
      subtitle: 'إدارة شجرة التصنيفات والظهور',
      searchHint: '',
      showSearch: false,
      notificationCount: 3,
      adminName: adminName,
      adminInitials: _adminInitials(adminName),
    );
  }

  final isAudiences =
      path == AppRoutes.audiences || path.startsWith('${AppRoutes.audiences}/');
  if (isAudiences) {
    return AdminTopBarData(
      title: 'الفئات المستهدفة',
      subtitle: 'إدارة جماهير المتجر وحالة ظهورها',
      searchHint: '',
      showSearch: false,
      notificationCount: 3,
      adminName: adminName,
      adminInitials: _adminInitials(adminName),
    );
  }

  final isBanners =
      path == AppRoutes.banners || path.startsWith('${AppRoutes.banners}/');
  if (isBanners) {
    return AdminTopBarData(
      title: 'البنرات',
      subtitle: 'إدارة بنرات الصفحة الرئيسية وصورها',
      searchHint: '',
      showSearch: false,
      notificationCount: 3,
      adminName: adminName,
      adminInitials: _adminInitials(adminName),
    );
  }

  final isCollections =
      path == AppRoutes.collections ||
      path.startsWith('${AppRoutes.collections}/');
  if (isCollections) {
    return AdminTopBarData(
      title: 'المجموعات',
      subtitle: 'إدارة مجموعات التسويق ومنتجاتها',
      searchHint: '',
      showSearch: false,
      notificationCount: 3,
      adminName: adminName,
      adminInitials: _adminInitials(adminName),
    );
  }

  final isColors =
      path == AppRoutes.colors || path.startsWith('${AppRoutes.colors}/');
  if (isColors) {
    return AdminTopBarData(
      title: 'الألوان',
      subtitle: 'إدارة ألوان المتجر المتاحة للمنتجات',
      searchHint: '',
      showSearch: false,
      notificationCount: 3,
      adminName: adminName,
      adminInitials: _adminInitials(adminName),
    );
  }

  final isSizes =
      path == AppRoutes.sizes || path.startsWith('${AppRoutes.sizes}/');
  if (isSizes) {
    return AdminTopBarData(
      title: 'المقاسات',
      subtitle: 'إدارة مجموعات المقاسات وقيمها',
      searchHint: '',
      showSearch: false,
      notificationCount: 3,
      adminName: adminName,
      adminInitials: _adminInitials(adminName),
    );
  }

  return AdminTopBarData(
    title: 'لوحة التحكم',
    subtitle: 'نظرة عامة على أداء المتجر',
    searchHint: 'ابحث عن طلب، منتج، أو عميل...',
    notificationCount: 3,
    adminName: adminName,
    adminInitials: _adminInitials(adminName),
  );
}
