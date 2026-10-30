import 'package:flutter/material.dart';

import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/responsive/app_radius.dart';
import '../../../../core/utils/responsive/app_design_tokens.dart';

/// Pagination feedback with a separate retry row so enlarged text can wrap.
class RecommendationLoadMoreErrorFooter extends StatelessWidget {
  const RecommendationLoadMoreErrorFooter({
    super.key,
    this.onRetry,
    required this.message,
    required this.retryLabel,
  });

  final VoidCallback? onRetry;
  final String message;
  final String retryLabel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Container(
        padding: EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.md(context)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.error_outline,
                  color: Theme.of(context).colorScheme.error,
                  size: AppIconSizes.listLeading(context),
                ),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    message,
                    style: context.appTypography.stateMessage.inlineMessage,
                  ),
                ),
              ],
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.sm),
              TextButton.icon(
                label: Text(
                  retryLabel,
                  style: context.appTypography.textAction.secondary,
                ),
                icon: Icon(Icons.settings_backup_restore_rounded),
                onPressed: onRetry,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
