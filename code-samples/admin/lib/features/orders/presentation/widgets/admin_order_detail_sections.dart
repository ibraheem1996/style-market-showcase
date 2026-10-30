import 'package:flutter/material.dart';

import '../../../../core/responsive/app_radius.dart';
import '../../../../core/responsive/app_responsive.dart';
import '../../../../core/responsive/app_spacing.dart';
import '../../../../shared/design_system/app_palette.dart';
import '../../../../shared/design_system/app_text_styles.dart';
import '../../domain/entities/admin_order_entities.dart';
import '../view_data/admin_order_view_data.dart';
import 'admin_order_status_chip.dart';

class AdminOrderDetailSections extends StatelessWidget {
  const AdminOrderDetailSections({required this.order, super.key});

  final AdminOrderDetailEntity order;

  @override
  Widget build(BuildContext context) {
    final screen = AppResponsive.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (screen.isCompact || screen.isMedium)
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _CustomerSection(order: order),
              const SizedBox(height: AppSpacing.md),
              _PaymentSection(order: order),
            ],
          )
        else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _CustomerSection(order: order)),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: _PaymentSection(order: order)),
            ],
          ),
        const SizedBox(height: AppSpacing.md),
        _ItemsSection(order: order),
        const SizedBox(height: AppSpacing.md),
        _NotesSection(order: order),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final semanticColors = Theme.of(context).semanticColors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(color: semanticColors.border),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: AppTextStyles.sectionTitle(context)),
            const SizedBox(height: AppSpacing.md),
            child,
          ],
        ),
      ),
    );
  }
}

class _CustomerSection extends StatelessWidget {
  const _CustomerSection({required this.order});

  final AdminOrderDetailEntity order;

  @override
  Widget build(BuildContext context) {
    final address = order.deliveryAddress;
    final addressText = address == null
        ? '-'
        : [
                address.cityNameAr,
                address.areaNameAr,
                address.streetOne,
                address.streetTwo,
              ]
              .where((value) => value != null && value.trim().isNotEmpty)
              .join('، ');

    return _SectionCard(
      title: 'بيانات العميل',
      child: Column(
        children: [
          _InfoRow(label: 'الاسم', value: order.customer.name ?? '-'),
          _InfoRow(label: 'البريد', value: order.customer.email ?? '-'),
          _InfoRow(label: 'الهاتف', value: order.customer.phone ?? '-'),
          _InfoRow(label: 'هاتف العنوان', value: address?.phone ?? '-'),
          _InfoRow(
            label: 'العنوان',
            value: addressText.isEmpty ? '-' : addressText,
          ),
        ],
      ),
    );
  }
}

class _PaymentSection extends StatelessWidget {
  const _PaymentSection({required this.order});

  final AdminOrderDetailEntity order;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'الدفع والحالة',
      child: Column(
        children: [
          _InfoRow(
            label: 'الإجمالي',
            value: formatAdminOrderMoney(order.orderTotal),
          ),
          _InfoRow(
            label: 'الخصم',
            value: formatAdminOrderMoney(order.discountAmount),
          ),
          if (order.deliveryFee != null)
            _InfoRow(
              label: 'رسوم التوصيل',
              value: formatAdminOrderMoney(order.deliveryFee!),
            ),
          _InfoRow(
            label: 'طريقة الدفع',
            value: order.paymentMethod.arabicLabel,
          ),
          _ChipRow(
            label: 'حالة الدفع',
            child: AdminPaymentStatusChip(status: order.paymentStatus),
          ),
          _ChipRow(
            label: 'حالة الطلب',
            child: AdminOrderStatusChip(status: order.orderStatus),
          ),
          _InfoRow(
            label: 'تاريخ الطلب',
            value: formatAdminOrderDate(order.orderDate),
          ),
          _InfoRow(
            label: 'آخر تحديث',
            value: formatAdminOrderDate(order.updatedAt),
          ),
          _InfoRow(
            label: 'وقت التسليم',
            value: formatAdminOrderDate(order.deliveredAt),
          ),
          _InfoRow(
            label: 'وقت الإلغاء',
            value: formatAdminOrderDate(order.cancelledAt),
          ),
          _InfoRow(
            label: 'وقت الرفض',
            value: formatAdminOrderDate(order.rejectedAt),
          ),
          _InfoRow(
            label: 'وقت الإرجاع',
            value: formatAdminOrderDate(order.returnedAt),
          ),
        ],
      ),
    );
  }
}

class _ItemsSection extends StatelessWidget {
  const _ItemsSection({required this.order});

  final AdminOrderDetailEntity order;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'المنتجات',
      child: Column(
        children: [
          for (final item in order.items) ...[
            _OrderItemRow(item: item),
            if (item != order.items.last) const Divider(height: AppSpacing.xxl),
          ],
        ],
      ),
    );
  }
}

class _OrderItemRow extends StatelessWidget {
  const _OrderItemRow({required this.item});

  final AdminOrderItemEntity item;

  @override
  Widget build(BuildContext context) {
    final variantParts = <String>[
      if (item.variant?.colorNameAr != null)
        'اللون: ${item.variant!.colorNameAr}',
      if (item.variant?.sizeNameAr != null)
        'المقاس: ${item.variant!.sizeNameAr}',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          item.itemName ?? item.itemNameEn ?? '-',
          style: AppTextStyles.body(context),
        ),
        if (variantParts.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(variantParts.join('  ,  '), style: AppTextStyles.label(context)),
        ],
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.lg,
          runSpacing: AppSpacing.sm,
          children: [
            Text(
              'الكمية: ${item.quantity}',
              style: AppTextStyles.label(context),
            ),
            Text(
              'السعر: ${formatAdminOrderMoney(item.price)}',
              style: AppTextStyles.label(context),
            ),
            Text(
              'الإجمالي: ${formatAdminOrderMoney(item.lineTotal)}',
              style: AppTextStyles.label(context),
            ),
          ],
        ),
      ],
    );
  }
}

class _NotesSection extends StatelessWidget {
  const _NotesSection({required this.order});

  final AdminOrderDetailEntity order;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'الملاحظات',
      child: Column(
        children: [
          _InfoRow(label: 'سبب الحالة', value: order.statusReason ?? '-'),
          _InfoRow(
            label: 'ملاحظة الأدمن',
            value: order.adminInternalNote ?? '-',
          ),
          _InfoRow(
            label: 'ملاحظة العميل',
            value: _optionalText(order.userNote),
          ),
          _InfoRow(
            label: 'وقت إرسالها',
            value: formatAdminOrderDate(order.userNoteSubmittedAt),
          ),
        ],
      ),
    );
  }
}

String _optionalText(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) {
    return '-';
  }
  return trimmed;
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: AppTextStyles.label(context)),
          ),
          Expanded(child: Text(value, style: AppTextStyles.body(context))),
        ],
      ),
    );
  }
}

class _ChipRow extends StatelessWidget {
  const _ChipRow({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: AppTextStyles.label(context)),
          ),
          child,
        ],
      ),
    );
  }
}
