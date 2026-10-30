import 'package:flutter/material.dart';

import '../../../shared/design_system/app_text_styles.dart';
import '../../../core/responsive/app_icon_sizes.dart';
import '../../../core/responsive/app_spacing.dart';
import '../../../core/responsive/app_widths.dart';

class AppErrorView extends StatelessWidget {
  const AppErrorView({
    required this.message,
    this.title = 'حدث خطأ',
    this.onRetry,
    super.key,
  });

  final String title;
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppWidths.errorViewMax),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.error,
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
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.lg),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('إعادة المحاولة'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
