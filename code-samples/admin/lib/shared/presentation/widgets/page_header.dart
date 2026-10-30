import 'package:flutter/material.dart';

import '../../design_system/app_text_styles.dart';
import '../../../core/responsive/app_responsive.dart';
import '../../../core/responsive/app_spacing.dart';

class PageHeader extends StatelessWidget {
  const PageHeader({
    required this.title,
    this.subtitle,
    this.actions,
    super.key,
  });

  final String title;
  final String? subtitle;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    final screen = AppResponsive.of(context);
    final titleGroup = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.title(context)),
        if (subtitle != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(subtitle!, style: AppTextStyles.body(context)),
        ],
      ],
    );

    final actionWidgets = actions;
    if (screen.isCompact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          titleGroup,
          if (actionWidgets != null && actionWidgets.isNotEmpty) ...[
            SizedBox(height: AppSpacing.section(screen)),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: actionWidgets,
            ),
          ],
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: titleGroup),
        if (actionWidgets != null && actionWidgets.isNotEmpty) ...[
          const SizedBox(width: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: actionWidgets,
          ),
        ],
      ],
    );
  }
}
