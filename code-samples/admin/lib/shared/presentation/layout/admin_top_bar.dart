import 'package:flutter/material.dart';

import '../../../core/responsive/app_icon_sizes.dart';
import '../../../core/responsive/app_layout_values.dart';
import '../../../core/responsive/app_responsive.dart';
import '../../../core/responsive/app_spacing.dart';
import '../../design_system/app_palette.dart';
import '../../design_system/app_text_styles.dart';

@immutable
class AdminTopBarData {
  const AdminTopBarData({
    required this.title,
    required this.subtitle,
    required this.searchHint,
    required this.notificationCount,
    required this.adminName,
    required this.adminInitials,
    this.showSearch = true,
  });

  final String title;
  final String subtitle;
  final String searchHint;
  final int notificationCount;
  final String adminName;
  final String adminInitials;
  final bool showSearch;
}

class AdminTopBar extends StatelessWidget {
  const AdminTopBar({
    required this.data,
    this.onMenuPressed,
    this.onSearchChanged,
    this.onSearchSubmitted,
    this.onNotificationsPressed,
    this.onProfilePressed,
    this.onLogoutPressed,
    super.key,
  });

  final AdminTopBarData data;
  final VoidCallback? onMenuPressed;
  final ValueChanged<String>? onSearchChanged;
  final ValueChanged<String>? onSearchSubmitted;
  final VoidCallback? onNotificationsPressed;
  final VoidCallback? onProfilePressed;
  final VoidCallback? onLogoutPressed;

  @override
  Widget build(BuildContext context) {
    final screen = AppResponsive.of(context);
    final isCompact = screen.isCompact;
    final colors = Theme.of(context).colorScheme;
    final semanticColors = Theme.of(context).semanticColors;

    return Container(
      height: AppLayoutValues.topBarHeight(screen),
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.pageHorizontal(screen),
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(bottom: BorderSide(color: semanticColors.border)),
      ),
      child: isCompact
          ? _CompactTopBar(data: data, host: this)
          : _WideTopBar(data: data, host: this),
    );
  }
}

class _WideTopBar extends StatelessWidget {
  const _WideTopBar({required this.data, required this.host});

  final AdminTopBarData data;
  final AdminTopBar host;

  @override
  Widget build(BuildContext context) {
    final screen = AppResponsive.of(context);

    return Row(
      children: [
        Expanded(flex: 3, child: _TopBarTitle(data: data)),
        const SizedBox(width: AppSpacing.lg),
        if (data.showSearch) ...[
          Flexible(
            flex: 4,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: screen.isMedium ? 260 : 420,
                minWidth: 180,
              ),
              child: _TopBarSearch(data: data, host: host),
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
        ],
        _TopBarActions(data: data, host: host, compact: screen.isMedium),
      ],
    );
  }
}

class _CompactTopBar extends StatelessWidget {
  const _CompactTopBar({required this.data, required this.host});

  final AdminTopBarData data;
  final AdminTopBar host;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            if (host.onMenuPressed != null) ...[
              IconButton(
                tooltip: 'فتح القائمة',
                onPressed: host.onMenuPressed,
                icon: const Icon(Icons.menu, size: AppIconSizes.large),
              ),
              const SizedBox(width: AppSpacing.sm),
            ],
            Expanded(child: _TopBarTitle(data: data)),
            _TopBarActions(data: data, host: host, compact: true),
          ],
        ),
        if (data.showSearch) ...[
          const SizedBox(height: AppSpacing.sm),
          _TopBarSearch(data: data, host: host),
        ],
      ],
    );
  }
}

class _TopBarTitle extends StatelessWidget {
  const _TopBarTitle({required this.data});

  final AdminTopBarData data;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          data.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.sectionTitle(context),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          data.subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.label(context),
        ),
      ],
    );
  }
}

class _TopBarSearch extends StatelessWidget {
  const _TopBarSearch({required this.data, required this.host});

  final AdminTopBarData data;
  final AdminTopBar host;

  @override
  Widget build(BuildContext context) {
    final semanticColors = Theme.of(context).semanticColors;

    return SizedBox(
      height: 40,
      child: TextField(
        onChanged: host.onSearchChanged,
        onSubmitted: host.onSearchSubmitted,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: data.searchHint,
          hintStyle: AppTextStyles.label(context),
          prefixIcon: Icon(
            Icons.search,
            size: AppIconSizes.medium,
            color: semanticColors.textSecondary,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
        ),
      ),
    );
  }
}

class _TopBarActions extends StatelessWidget {
  const _TopBarActions({
    required this.data,
    required this.host,
    this.compact = false,
  });

  final AdminTopBarData data;
  final AdminTopBar host;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final semanticColors = Theme.of(context).semanticColors;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Tooltip(
          message: 'الإشعارات',
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                onPressed: host.onNotificationsPressed,
                icon: const Icon(
                  Icons.notifications_none_outlined,
                  size: AppIconSizes.large,
                ),
              ),
              if (data.notificationCount > 0)
                PositionedDirectional(
                  top: 2,
                  end: 2,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: colors.error,
                      shape: BoxShape.circle,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.xs),
                      child: Text(
                        data.notificationCount.toString(),
                        style: AppTextStyles.tooltip(context),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Tooltip(
          message: data.adminName,
          child: PopupMenuButton<_TopBarProfileAction>(
            tooltip: 'حساب الأدمن',
            onOpened: host.onProfilePressed,
            onSelected: (action) {
              if (action == _TopBarProfileAction.logout) {
                host.onLogoutPressed?.call();
              }
            },
            itemBuilder: (context) => [
              if (!compact)
                PopupMenuItem<_TopBarProfileAction>(
                  enabled: false,
                  child: Text(data.adminName),
                ),
              if (host.onLogoutPressed != null)
                const PopupMenuItem<_TopBarProfileAction>(
                  value: _TopBarProfileAction.logout,
                  child: Text('خروج'),
                ),
            ],
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 17,
                  backgroundColor: semanticColors.surfaceVariant,
                  child: Text(
                    data.adminInitials,
                    style: AppTextStyles.label(
                      context,
                    ).copyWith(color: semanticColors.textPrimary),
                  ),
                ),
                if (!compact) ...[
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    data.adminName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.label(
                      context,
                    ).copyWith(color: semanticColors.textPrimary),
                  ),
                  const Icon(Icons.expand_more, size: AppIconSizes.small),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

enum _TopBarProfileAction { logout }
