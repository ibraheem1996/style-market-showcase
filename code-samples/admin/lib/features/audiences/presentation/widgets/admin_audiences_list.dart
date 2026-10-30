import 'package:flutter/material.dart';

import '../../../../core/responsive/app_responsive.dart';
import '../../../../core/responsive/app_spacing.dart';
import '../../../../shared/design_system/app_text_styles.dart';
import '../../domain/entities/admin_audience_entities.dart';
import '../cubit/audiences_list/admin_audiences_state.dart';

class AdminAudiencesList extends StatelessWidget {
  const AdminAudiencesList({
    required this.audiences,
    required this.operationAudienceId,
    required this.operation,
    required this.onEdit,
    required this.onVisibility,
    required this.onDelete,
    super.key,
  });

  final List<AdminAudienceEntity> audiences;
  final int? operationAudienceId;
  final AdminAudienceListOperation? operation;
  final ValueChanged<int> onEdit;
  final ValueChanged<AdminAudienceEntity> onVisibility;
  final ValueChanged<int> onDelete;

  @override
  Widget build(BuildContext context) {
    final appResponsive = AppResponsive.of(context);
    if (appResponsive.isCompact || appResponsive.isMedium) {
      return Column(
        children: [
          for (final audience in audiences)
            _AudienceCard(audience: audience, host: this),
        ],
      );
    }
    return Card(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('الاسم العربي')),
            DataColumn(label: Text('الاسم الإنجليزي')),
            DataColumn(label: Text('الترتيب')),
            DataColumn(label: Text('الحالة')),
            DataColumn(label: Text('المنتجات')),
            DataColumn(label: Text('المجموعات')),
            DataColumn(label: Text('البنرات')),
            DataColumn(label: Text('الإجراءات')),
          ],
          rows: [
            for (final audience in audiences)
              DataRow(
                cells: [
                  DataCell(Text(audience.arabicName)),
                  DataCell(Text(audience.englishName)),
                  DataCell(Text('${audience.sortOrder}')),
                  DataCell(_AudienceStatusChip(active: audience.active)),
                  DataCell(Text('${audience.productCount}')),
                  DataCell(Text('${audience.collectionCount}')),
                  DataCell(Text('${audience.bannerCount}')),
                  DataCell(_AudienceActions(audience: audience, host: this)),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _AudienceCard extends StatelessWidget {
  const _AudienceCard({required this.audience, required this.host});

  final AdminAudienceEntity audience;
  final AdminAudiencesList host;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              audience.arabicName,
              style: AppTextStyles.body(
                context,
              ).copyWith(fontWeight: FontWeight.w700),
            ),
            Text(audience.englishName, style: AppTextStyles.label(context)),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                _AudienceStatusChip(active: audience.active),
                Chip(label: Text('الترتيب: ${audience.sortOrder}')),
                Chip(label: Text('المنتجات: ${audience.productCount}')),
                Chip(label: Text('المجموعات: ${audience.collectionCount}')),
                Chip(label: Text('البنرات: ${audience.bannerCount}')),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: _AudienceActions(audience: audience, host: host),
            ),
          ],
        ),
      ),
    );
  }
}

class _AudienceStatusChip extends StatelessWidget {
  const _AudienceStatusChip({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    return Chip(label: Text(active ? 'نشط' : 'غير نشط'));
  }
}

class _AudienceActions extends StatelessWidget {
  const _AudienceActions({required this.audience, required this.host});

  final AdminAudienceEntity audience;
  final AdminAudiencesList host;

  @override
  Widget build(BuildContext context) {
    final isBusy = host.operationAudienceId == audience.id;
    if (isBusy) {
      return const SizedBox.square(
        dimension: 22,
        child: CircularProgressIndicator.adaptive(strokeWidth: 2),
      );
    }
    final enabled = host.operation == null;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: 'تعديل',
          onPressed: enabled ? () => host.onEdit(audience.id) : null,
          icon: const Icon(Icons.edit_outlined),
        ),
        IconButton(
          tooltip: audience.active ? 'إيقاف' : 'تفعيل',
          onPressed: enabled ? () => host.onVisibility(audience) : null,
          icon: Icon(
            audience.active
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
          ),
        ),
        IconButton(
          tooltip: 'فحص الحذف',
          color: Theme.of(context).colorScheme.error,
          onPressed: enabled ? () => host.onDelete(audience.id) : null,
          icon: const Icon(Icons.delete_outline),
        ),
      ],
    );
  }
}
