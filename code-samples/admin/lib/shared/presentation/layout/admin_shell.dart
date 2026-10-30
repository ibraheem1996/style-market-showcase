import 'package:flutter/material.dart';

import '../../../core/responsive/app_layout_values.dart';
import '../../../core/responsive/app_responsive.dart';
import '../../../core/responsive/app_spacing.dart';
import '../../../core/responsive/app_widths.dart';
import 'admin_sidebar.dart';
import 'admin_top_bar.dart';

class AdminShell extends StatelessWidget {
  const AdminShell({
    required this.child,
    required this.topBarData,
    this.onLogoutPressed,
    super.key,
  });

  final Widget child;
  final AdminTopBarData topBarData;
  final VoidCallback? onLogoutPressed;

  @override
  Widget build(BuildContext context) {
    final screen = AppResponsive.of(context);

    if (screen.isCompact) {
      return Scaffold(
        drawer: Drawer(
          width: AppWidths.drawerForScreen(screen.width),
          child: Builder(
            builder: (drawerContext) {
              return AdminSidebar(
                mode: AdminSidebarMode.drawer,
                onDestinationSelected: () => Navigator.of(drawerContext).pop(),
              );
            },
          ),
        ),
        body: Builder(
          builder: (scaffoldContext) {
            return Column(
              children: [
                AdminTopBar(
                  data: topBarData,
                  onMenuPressed: () =>
                      Scaffold.of(scaffoldContext).openDrawer(),
                  onLogoutPressed: onLogoutPressed,
                ),
                Expanded(child: _AdminContentArea(child: child)),
              ],
            );
          },
        ),
      );
    }

    return Scaffold(
      body: Row(
        children: [
          AdminSidebar(
            mode: screen.isMedium
                ? AdminSidebarMode.collapsed
                : AdminSidebarMode.expanded,
          ),
          Expanded(
            child: Column(
              children: [
                AdminTopBar(data: topBarData, onLogoutPressed: onLogoutPressed),
                Expanded(child: _AdminContentArea(child: child)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminContentArea extends StatelessWidget {
  const _AdminContentArea({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final screen = AppResponsive.of(context);

    return ColoredBox(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Padding(
        padding: AppSpacing.pagePadding(screen),
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: AppLayoutValues.contentMaxWidth(screen),
            ),
            child: SizedBox(width: double.infinity, child: child),
          ),
        ),
      ),
    );
  }
}
