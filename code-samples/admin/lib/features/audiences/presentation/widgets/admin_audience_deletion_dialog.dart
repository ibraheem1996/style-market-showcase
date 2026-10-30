import 'package:flutter/material.dart';

import '../../../../core/responsive/app_spacing.dart';
import '../../domain/entities/admin_audience_entities.dart';
import '../logic/admin_audience_error_message_mapper.dart';

Future<bool> showAdminAudienceDeletionDialog({
  required BuildContext context,
  required AdminAudienceDeletionImpact impact,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('أثر حذف الفئة المستهدفة'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('الحالة: ${impact.active ? 'نشطة' : 'غير نشطة'}'),
          Text('المنتجات المرتبطة: ${impact.productCount}'),
          Text('المجموعات المرتبطة: ${impact.collectionCount}'),
          Text('البنرات المرتبطة: ${impact.bannerCount}'),
          const SizedBox(height: AppSpacing.md),
          if (impact.blockers.isNotEmpty)
            for (final blocker in impact.blockers)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: Text('• ${adminAudienceBlockerMessage(blocker)}'),
              )
          else
            const Text(
              'ستُحذف الفئة المستهدفة نهائيًا. لا يمكن التراجع عن العملية.',
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(impact.canDelete ? 'إلغاء' : 'إغلاق'),
        ),
        if (impact.canDelete)
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('حذف نهائي'),
          ),
      ],
    ),
  );
  return confirmed ?? false;
}
