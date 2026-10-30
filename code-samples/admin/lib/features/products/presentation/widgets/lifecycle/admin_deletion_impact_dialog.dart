import 'package:flutter/material.dart';

import '../../../../../core/responsive/app_spacing.dart';
import '../../../domain/entities/admin_product_lifecycle_entities.dart';

Future<bool> showAdminProductDeletionImpactDialog({
  required BuildContext context,
  required AdminProductDeletionImpactEntity impact,
  required bool hasUnsavedChanges,
}) {
  final blockers = <String>[
    if (impact.blockers.active) 'يجب تعطيل المنتج قبل الحذف.',
    if (impact.blockers.orderItemCount > 0)
      'مرتبط بـ ${impact.blockers.orderItemCount} من عناصر الطلبات، ولا يمكن حذف السجل التاريخي.',
    if (impact.blockers.cartRowCount > 0)
      'موجود في ${impact.blockers.cartRowCount} من سطور السلة، لذلك يمنع Backend الحذف.',
  ];
  final effects = <String>[
    if (impact.deleteEffects.favoriteRowCount > 0)
      'حذف ${impact.deleteEffects.favoriteRowCount} من المفضلة',
    if (impact.deleteEffects.variantCount > 0)
      'حذف ${impact.deleteEffects.variantCount} من الخيارات',
    if (impact.deleteEffects.variantAttributeCount > 0)
      'حذف ${impact.deleteEffects.variantAttributeCount} من سمات الخيارات',
    if (impact.deleteEffects.mediaRowCount > 0)
      'حذف ${impact.deleteEffects.mediaRowCount} من سجلات الصور',
    if (impact.deleteEffects.mediaFileCount > 0)
      'محاولة تنظيف ${impact.deleteEffects.mediaFileCount} من ملفات الصور',
    if (impact.deleteEffects.collectionItemCount > 0)
      'إزالة ${impact.deleteEffects.collectionItemCount} من روابط المجموعات',
    if (impact.deleteEffects.itemAttributeMetaCount > 0)
      'حذف ${impact.deleteEffects.itemAttributeMetaCount} من بيانات السمات',
    if (impact.deleteEffects.recentlyViewedCount > 0)
      'حذف ${impact.deleteEffects.recentlyViewedCount} من المشاهدات الأخيرة',
  ];
  return _showImpactDialog(
    context: context,
    title: 'أثر حذف المنتج',
    blockers: blockers,
    effects: effects,
    hasUnsavedChanges: hasUnsavedChanges,
    canDelete: impact.canDelete,
    confirmLabel: 'حذف المنتج نهائيًا',
  );
}

Future<bool> showAdminVariantDeletionImpactDialog({
  required BuildContext context,
  required AdminVariantDeletionImpactEntity impact,
  required bool hasUnsavedChanges,
}) {
  final blockers = <String>[
    if (impact.blockers.active) 'يجب تعطيل الخيار قبل الحذف.',
    if (impact.blockers.orderItemCount > 0)
      'مرتبط بـ ${impact.blockers.orderItemCount} من عناصر الطلبات، ولا يمكن حذف السجل التاريخي.',
    if (impact.blockers.cartRowCount > 0)
      'موجود في ${impact.blockers.cartRowCount} من سطور السلة، لذلك يمنع Backend الحذف.',
    if (impact.blockers.isLastVariant)
      'هذا آخر خيار للمنتج ولا يمكن حذفه دون مسار تحويل صريح إلى منتج بسيط.',
  ];
  final effects = <String>[
    if (impact.deleteEffects.favoriteRowCount > 0)
      'حذف ${impact.deleteEffects.favoriteRowCount} من المفضلة',
    if (impact.deleteEffects.variantAttributeCount > 0)
      'حذف ${impact.deleteEffects.variantAttributeCount} من سمات الخيار',
    if (impact.deleteEffects.variantMediaRowCount > 0)
      'حذف ${impact.deleteEffects.variantMediaRowCount} من صور الخيار',
    if (impact.deleteEffects.orphanColorMediaRowCount > 0)
      'حذف ${impact.deleteEffects.orphanColorMediaRowCount} من صور اللون غير المستخدمة',
    if (impact.deleteEffects.orphanSizeMediaRowCount > 0)
      'حذف ${impact.deleteEffects.orphanSizeMediaRowCount} من صور المقاس غير المستخدمة',
    if (impact.deleteEffects.orphanItemAttributeMetaCount > 0)
      'حذف ${impact.deleteEffects.orphanItemAttributeMetaCount} من بيانات اللون غير المستخدمة',
    if (impact.deleteEffects.mediaFileCount > 0)
      'محاولة تنظيف ${impact.deleteEffects.mediaFileCount} من ملفات الصور',
    'سيبقى ${impact.deleteEffects.remainingVariantCount} من الخيارات بعد الحذف',
  ];
  return _showImpactDialog(
    context: context,
    title: 'أثر حذف الخيار',
    blockers: blockers,
    effects: effects,
    hasUnsavedChanges: hasUnsavedChanges,
    canDelete: impact.canDelete,
    confirmLabel: 'حذف الخيار نهائيًا',
  );
}

Future<bool> _showImpactDialog({
  required BuildContext context,
  required String title,
  required List<String> blockers,
  required List<String> effects,
  required bool hasUnsavedChanges,
  required bool canDelete,
  required String confirmLabel,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(title),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (blockers.isNotEmpty) ...[
                const Text('موانع الحذف:'),
                const SizedBox(height: AppSpacing.sm),
                ...blockers.map(
                  (text) => _ImpactRow(text: text, blocked: true),
                ),
              ] else ...[
                const Text('الحذف نهائي ولا يمكن التراجع عنه.'),
                if (effects.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.md),
                  const Text('البيانات التي ستُنظف:'),
                  const SizedBox(height: AppSpacing.sm),
                  ...effects.map((text) => _ImpactRow(text: text)),
                ],
              ],
              if (hasUnsavedChanges) ...[
                const SizedBox(height: AppSpacing.md),
                const Text('توجد تعديلات غير محفوظة وستُفقد عند نجاح الحذف.'),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          key: const Key('lifecycle-delete-cancel'),
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('إلغاء'),
        ),
        if (canDelete)
          FilledButton(
            key: const Key('lifecycle-delete-confirm'),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(confirmLabel),
          ),
      ],
    ),
  );
  return result ?? false;
}

class _ImpactRow extends StatelessWidget {
  const _ImpactRow({required this.text, this.blocked = false});
  final String text;
  final bool blocked;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            blocked ? Icons.block_outlined : Icons.remove_circle_outline,
            size: 18,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
