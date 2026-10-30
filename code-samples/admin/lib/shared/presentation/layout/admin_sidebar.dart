import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../design_system/app_palette.dart';
import '../../design_system/app_text_styles.dart';
import '../../../core/responsive/app_icon_sizes.dart';
import '../../../core/responsive/app_radius.dart';
import '../../../core/responsive/app_spacing.dart';
import '../../../core/responsive/app_widths.dart';

enum AdminSidebarMode { expanded, collapsed, drawer }

class AdminSidebar extends StatelessWidget {
  const AdminSidebar({
    this.mode = AdminSidebarMode.expanded,
    this.onDestinationSelected,
    super.key,
  });

  final AdminSidebarMode mode;
  final VoidCallback? onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    final currentPath = GoRouterState.of(context).uri.path;
    final isDashboard = currentPath == AppRoutes.dashboard;
    final isOrders =
        currentPath == AppRoutes.orders ||
        currentPath.startsWith('${AppRoutes.orders}/');
    final isProducts =
        currentPath == AppRoutes.products ||
        currentPath.startsWith('${AppRoutes.products}/');
    final isCategories =
        currentPath == AppRoutes.categories ||
        currentPath.startsWith('${AppRoutes.categories}/');
    final isAudiences =
        currentPath == AppRoutes.audiences ||
        currentPath.startsWith('${AppRoutes.audiences}/');
    final isBanners =
        currentPath == AppRoutes.banners ||
        currentPath.startsWith('${AppRoutes.banners}/');
    final isCollections =
        currentPath == AppRoutes.collections ||
        currentPath.startsWith('${AppRoutes.collections}/');
    final isColors =
        currentPath == AppRoutes.colors ||
        currentPath.startsWith('${AppRoutes.colors}/');
    final isSizes =
        currentPath == AppRoutes.sizes ||
        currentPath.startsWith('${AppRoutes.sizes}/');
    final isNotifications = currentPath == AppRoutes.notifications;
    final isCollapsed = mode == AdminSidebarMode.collapsed;
    final colors = Theme.of(context).colorScheme;
    final semanticColors = Theme.of(context).semanticColors;
    final destinations = _AdminSidebarDestination.items;

    return Container(
      width: switch (mode) {
        AdminSidebarMode.collapsed => AppWidths.sidebarCollapsed,
        AdminSidebarMode.expanded => AppWidths.sidebarExpanded,
        AdminSidebarMode.drawer => double.infinity,
      },
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(left: BorderSide(color: semanticColors.border)),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(isCollapsed ? AppSpacing.md : AppSpacing.lg),
          child: Column(
            crossAxisAlignment: isCollapsed
                ? CrossAxisAlignment.center
                : CrossAxisAlignment.stretch,
            children: [
              if (isCollapsed)
                Icon(
                  Icons.storefront_outlined,
                  color: semanticColors.textPrimary,
                  size: AppIconSizes.large,
                )
              else
                Text(
                  'إدارة المتجر',
                  style: AppTextStyles.sectionTitle(context),
                ),
              const SizedBox(height: AppSpacing.xxl),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: isCollapsed
                        ? CrossAxisAlignment.center
                        : CrossAxisAlignment.stretch,
                    children: [
                      for (final destination in destinations) ...[
                        _SidebarItem(
                          label: destination.label,
                          icon: destination.icon,
                          selected: destination.isSelected(
                            isDashboard: isDashboard,
                            isOrders: isOrders,
                            isProducts: isProducts,
                            isCategories: isCategories,
                            isAudiences: isAudiences,
                            isBanners: isBanners,
                            isCollections: isCollections,
                            isColors: isColors,
                            isSizes: isSizes,
                            isNotifications: isNotifications,
                          ),
                          collapsed: isCollapsed,
                          enabled: destination.enabled,
                          onTap: destination.enabled
                              ? () {
                                  context.go(destination.path);
                                  onDestinationSelected?.call();
                                }
                              : null,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({
    required this.label,
    required this.icon,
    required this.selected,
    required this.collapsed,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final bool collapsed;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final semanticColors = Theme.of(context).semanticColors;

    return Tooltip(
      message: enabled ? label : 'قريبًا',
      child: Material(
        color: selected ? semanticColors.surfaceVariant : Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.md),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: collapsed ? AppSpacing.md : AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            child: Row(
              mainAxisAlignment: collapsed
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.start,
              children: [
                Icon(
                  icon,
                  size: AppIconSizes.medium,
                  color: selected
                      ? colors.primary
                      : semanticColors.textSecondary.withValues(
                          alpha: enabled ? 1 : 0.55,
                        ),
                ),
                if (!collapsed) ...[
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      label,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.body(context).copyWith(
                        color: selected
                            ? semanticColors.textPrimary
                            : semanticColors.textSecondary.withValues(
                                alpha: enabled ? 1 : 0.55,
                              ),
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AdminSidebarDestination {
  const _AdminSidebarDestination({
    required this.label,
    required this.icon,
    required this.path,
    this.section = _AdminSidebarSection.other,
  });

  final String label;
  final IconData icon;
  final String path;
  final _AdminSidebarSection section;

  bool get enabled => section != _AdminSidebarSection.other;

  bool isSelected({
    required bool isDashboard,
    required bool isOrders,
    required bool isProducts,
    required bool isCategories,
    required bool isAudiences,
    required bool isBanners,
    required bool isCollections,
    required bool isColors,
    required bool isSizes,
    required bool isNotifications,
  }) {
    return switch (section) {
      _AdminSidebarSection.dashboard => isDashboard,
      _AdminSidebarSection.orders => isOrders,
      _AdminSidebarSection.products => isProducts,
      _AdminSidebarSection.categories => isCategories,
      _AdminSidebarSection.audiences => isAudiences,
      _AdminSidebarSection.banners => isBanners,
      _AdminSidebarSection.collections => isCollections,
      _AdminSidebarSection.colors => isColors,
      _AdminSidebarSection.sizes => isSizes,
      _AdminSidebarSection.notifications => isNotifications,
      _AdminSidebarSection.other => false,
    };
  }

  static const items = [
    _AdminSidebarDestination(
      label: 'الإشعارات',
      icon: Icons.notifications_outlined,
      path: AppRoutes.notifications,
      section: _AdminSidebarSection.notifications,
    ),
    _AdminSidebarDestination(
      label: 'لوحة التحكم',
      icon: Icons.dashboard_outlined,
      path: AppRoutes.dashboard,
      section: _AdminSidebarSection.dashboard,
    ),
    _AdminSidebarDestination(
      label: 'الطلبات',
      icon: Icons.inventory_2_outlined,
      path: AppRoutes.orders,
      section: _AdminSidebarSection.orders,
    ),
    _AdminSidebarDestination(
      label: 'الكتالوج',
      icon: Icons.sell_outlined,
      path: AppRoutes.products,
      section: _AdminSidebarSection.products,
    ),
    _AdminSidebarDestination(
      label: 'التصنيفات',
      icon: Icons.account_tree_outlined,
      path: AppRoutes.categories,
      section: _AdminSidebarSection.categories,
    ),
    _AdminSidebarDestination(
      label: 'الفئات المستهدفة',
      icon: Icons.groups_2_outlined,
      path: AppRoutes.audiences,
      section: _AdminSidebarSection.audiences,
    ),
    _AdminSidebarDestination(
      label: 'البنرات',
      icon: Icons.campaign_outlined,
      path: AppRoutes.banners,
      section: _AdminSidebarSection.banners,
    ),
    _AdminSidebarDestination(
      label: 'المجموعات',
      icon: Icons.collections_bookmark_outlined,
      path: AppRoutes.collections,
      section: _AdminSidebarSection.collections,
    ),
    _AdminSidebarDestination(
      label: 'الألوان',
      icon: Icons.palette_outlined,
      path: AppRoutes.colors,
      section: _AdminSidebarSection.colors,
    ),
    _AdminSidebarDestination(
      label: 'المقاسات',
      icon: Icons.straighten_outlined,
      path: AppRoutes.sizes,
      section: _AdminSidebarSection.sizes,
    ),
    _AdminSidebarDestination(
      label: 'العملاء',
      icon: Icons.groups_outlined,
      path: AppRoutes.dashboard,
    ),
    _AdminSidebarDestination(
      label: 'البيانات المرجعية',
      icon: Icons.storage_outlined,
      path: AppRoutes.dashboard,
    ),
    _AdminSidebarDestination(
      label: 'الإعدادات',
      icon: Icons.settings_outlined,
      path: AppRoutes.dashboard,
    ),
  ];
}

enum _AdminSidebarSection {
  dashboard,
  orders,
  products,
  categories,
  audiences,
  banners,
  collections,
  colors,
  sizes,
  notifications,
  other,
}
