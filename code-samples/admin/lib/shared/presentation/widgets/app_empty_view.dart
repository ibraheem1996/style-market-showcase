import 'package:flutter/material.dart';

import '../../design_system/app_palette.dart';
import '../../design_system/app_text_styles.dart';
import '../../../core/responsive/app_icon_sizes.dart';
import '../../../core/responsive/app_spacing.dart';

class AppEmptyView extends StatelessWidget {
  const AppEmptyView({
    required this.message,
    this.title = 'لا توجد بيانات',
    super.key,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final semanticColors = Theme.of(context).semanticColors;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.inbox_outlined,
            color: semanticColors.textSecondary,
            size: AppIconSizes.emptyState,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(title, style: AppTextStyles.sectionTitle(context)),
          const SizedBox(height: AppSpacing.sm),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTextStyles.body(context),
          ),
        ],
      ),
    );
  }
}
