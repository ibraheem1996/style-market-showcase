import 'package:flutter/material.dart';
import 'package:my_project/core/utils/responsive/app_radius.dart';

import '../../theme/app_typography.dart';
import '../../utils/responsive/app_design_tokens.dart';

/// A presentation-only notice for a failed refresh with retained content.
class AppInlineRefreshFailure extends StatelessWidget {
  const AppInlineRefreshFailure({
    super.key,
    required this.message,
    required this.retryLabel,
    required this.onRetry,
  });

  final String message;
  final String retryLabel;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Semantics(
      liveRegion: true,
      child: Material(
        borderRadius: BorderRadius.circular(AppRadius.lg(context)),
        color: colors.error.withValues(alpha: 0.2),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  message,
                  style: context.appTypography.stateMessage.inlineMessage
                      .copyWith(color: colors.onErrorContainer),
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              OutlinedButton(
                onPressed: onRetry,
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.all(AppSpacing.sm),
                ),
                child: Text(
                  retryLabel,
                  style: context.appTypography.button.label,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
