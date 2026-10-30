import 'package:flutter/material.dart';

import '../../../../../core/responsive/app_radius.dart';
import '../../../../../core/responsive/app_spacing.dart';
import '../../../../../shared/design_system/app_palette.dart';
import '../../../../../shared/design_system/app_text_styles.dart';
import '../../../domain/entities/admin_product_media_entities.dart';

class AdminProductMediaSummaryBar extends StatelessWidget {
  const AdminProductMediaSummaryBar({required this.media, super.key});

  final AdminProductMediaBootstrapEntity media;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).semanticColors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: colors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.sm,
          children: [
            _SummaryItem(
              label: 'الأهداف',
              value: '${media.summary.targetCount}',
            ),
            _SummaryItem(
              label: 'الصور المملوكة',
              value: '${media.summary.ownedImageCount}',
            ),
            _SummaryItem(
              label: 'حد الرفع',
              value: '${media.limits.maxFilesPerRequest} صور',
            ),
            _SummaryItem(
              label: 'حجم الملف',
              value: _formatBytes(media.limits.maxFileBytes),
            ),
          ],
        ),
      ),
    );
  }

  String _formatBytes(int bytes) {
    final mib = bytes / (1024 * 1024);
    return '${mib.toStringAsFixed(mib >= 10 ? 0 : 1)} MiB';
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$label : ',
              style: AppTextStyles.label(context).copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            TextSpan(text: value, style: AppTextStyles.label(context)),
          ],
        ),
      ),
    );
  }
}
