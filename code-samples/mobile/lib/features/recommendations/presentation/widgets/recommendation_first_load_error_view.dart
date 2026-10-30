import 'package:flutter/material.dart';

import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/responsive/app_design_tokens.dart';

/// No-content feedback with a separate retry row to leave room for long copy.
class RecommendationFirstLoadErrorView extends StatelessWidget {
  const RecommendationFirstLoadErrorView({
    super.key,
    required this.message,
    required this.retryLabel,
    this.onRetry,
  });

  final String message;
  final String retryLabel;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  message,
                  textAlign: TextAlign.start,
                  style: context.appTypography.stateMessage.inlineMessage,
                ),
              ),
            ],
          ),
          if (onRetry != null) ...[
            const SizedBox(height: AppSpacing.sm),
            TextButton.icon(
              onPressed: onRetry,
              icon: Icon(
                Icons.settings_backup_restore_rounded,
                size: AppIconSizes.listLeading(context),
              ),

              label: Text(
                retryLabel,
                style: context.appTypography.button.label,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
