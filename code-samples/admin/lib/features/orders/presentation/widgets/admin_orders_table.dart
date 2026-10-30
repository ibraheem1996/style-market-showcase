import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/responsive/app_radius.dart';
import '../../../../core/responsive/app_spacing.dart';
import '../../../../core/responsive/app_widths.dart';
import '../../../../shared/design_system/app_palette.dart';
import '../../../../shared/design_system/app_text_styles.dart';
import '../../domain/entities/admin_order_entities.dart';
import '../../domain/entities/admin_order_enums.dart';
import '../view_data/admin_order_view_data.dart';
import 'admin_order_actions.dart';
import 'admin_order_status_chip.dart';

class AdminOrdersTable extends StatelessWidget {
  const AdminOrdersTable({
    required this.orders,
    required this.isActionSubmitting,
    required this.onAction,
    required this.onNavigateToDetails,
    super.key,
  });

  final List<AdminOrderSummaryEntity> orders;
  final bool isActionSubmitting;
  final Future<void> Function(
    int orderId,
    AdminOrderAction action,
    String? reason,
  )
  onAction;

  final void Function(int orderId) onNavigateToDetails;

  @override
  Widget build(BuildContext context) {
    final semanticColors = Theme.of(context).semanticColors;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(color: semanticColors.border),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: AppWidths.tableMinDenseAdmin,
            ),
            child: DataTable(
              headingTextStyle: AppTextStyles.table(context),
              dataTextStyle: AppTextStyles.body(context),
              columns: const [
                DataColumn(label: Text('رقم الطلب')),
                DataColumn(label: Text('اسم العميل')),
                DataColumn(label: Text('رقم الهاتف')),
                DataColumn(label: Text('عدد القطع')),
                DataColumn(label: Text('الإجمالي')),
                DataColumn(label: Text('طريقة الدفع')),
                DataColumn(label: Text('حالة الدفع')),
                DataColumn(label: Text('حالة الطلب')),
                DataColumn(label: Text('تاريخ الطلب')),
                DataColumn(label: Text('إجراء سريع')),
              ],
              rows: [
                for (final order in orders)
                  DataRow(
                    cells: [
                      DataCell(
                        TextButton(
                          onPressed: () => context.go(
                            AppRoutes.orderDetailPath(order.orderId),
                          ),
                          child: Text('#${order.orderId}'),
                        ),
                      ),
                      DataCell(Text(order.customer.name ?? '-')),
                      DataCell(
                        Text(order.customer.phone ?? order.addressPhone ?? '-'),
                      ),
                      DataCell(Text(order.itemsCount.toString())),
                      DataCell(Text(formatAdminOrderMoney(order.orderTotal))),
                      DataCell(Text(order.paymentMethod.arabicLabel)),
                      DataCell(
                        AdminPaymentStatusChip(status: order.paymentStatus),
                      ),
                      DataCell(AdminOrderStatusChip(status: order.orderStatus)),
                      DataCell(Text(formatAdminOrderDate(order.orderDate))),
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AdminOrderActions(
                              allowedActions: order.allowedActions
                                  .take(1)
                                  .toList(),
                              isSubmitting: isActionSubmitting,
                              onAction: (action, reason) =>
                                  onAction(order.orderId, action, reason),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            OutlinedButton(
                              onPressed: () =>
                                  onNavigateToDetails(order.orderId),

                              child: const Text('عرض'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
