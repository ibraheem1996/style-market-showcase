import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/entities/admin_dashboard_entities.dart';
import 'dashboard_view_data.dart';

/// Converts domain Dashboard data into immutable UI-ready view data.
///
/// Formatting lives here so Cubit state remains raw domain data and widgets only
/// render labels, tones, and values they receive.
class DashboardViewDataMapper {
  const DashboardViewDataMapper();

  DashboardViewData map({
    required AdminDashboardOverview overview,
    required AdminDashboardFilter filter,
    required String adminName,
  }) {
    return DashboardViewData(
      welcome: _welcome(adminName),
      dateFilter: _dateFilter(filter),
      metrics: _metrics(overview),
      audienceSales: _audienceSales(overview),
      recentOrders: _recentOrders(overview),
      salesSeries: _salesSeries(overview),
      inventoryHealth: _inventoryHealth(overview),
    );
  }

  DashboardWelcomeViewData _welcome(String adminName) {
    final name = adminName.trim().isEmpty ? 'الأدمن' : adminName.trim();
    return DashboardWelcomeViewData(
      title: 'مساء الخير، $name',
      subtitle: 'مؤشرات الفترة مع لقطات تشغيلية حالية للطلبات والمخزون.',
    );
  }

  DashboardDateFilterViewData _dateFilter(AdminDashboardFilter filter) {
    return DashboardDateFilterViewData(
      selectedRange: _selectedRange(filter),
      customRangeLabel: switch (filter) {
        AdminDashboardCustomFilter(:final dateFrom, :final dateTo) =>
          '${_dateLabel(dateFrom)} — ${_dateLabel(dateTo)}',
        _ => null,
      },
      options: const [
        DashboardDateFilterOptionViewData(
          range: DashboardDateRange.today,
          label: 'اليوم',
        ),
        DashboardDateFilterOptionViewData(
          range: DashboardDateRange.last7Days,
          label: 'آخر 7 أيام',
        ),
        DashboardDateFilterOptionViewData(
          range: DashboardDateRange.last30Days,
          label: 'آخر 30 يومًا',
        ),
        DashboardDateFilterOptionViewData(
          range: DashboardDateRange.custom,
          label: 'فترة مخصصة',
        ),
      ],
    );
  }

  List<DashboardMetricViewData> _metrics(AdminDashboardOverview overview) {
    final salesChangePercent = _salesChangePercent(overview);
    return [
      DashboardMetricViewData(
        title: 'المبيعات المسلّمة',
        value: _money(overview.deliveredSalesTotal),
        details:
            'الفترة السابقة: ${_money(overview.previousDeliveredSalesTotal)}',
        badgeLabel: _percentBadge(salesChangePercent),
        tone: _amountTone(salesChangePercent),
        icon: _iconByAmount(salesChangePercent),
      ),
      DashboardMetricViewData(
        title: 'الطلبات النشطة — لقطة حالية',
        value: '${overview.activeOrdersCount}',
        details:
            '${overview.pendingOrdersCount} قيد الانتظار، ${overview.processingOrdersCount} قيد المعالجة',
        badgeLabel: 'لقطة حالية',
        tone: DashboardTone.tertiary,
        icon: Icons.receipt_long_outlined,
      ),
      DashboardMetricViewData(
        title: 'العملاء الجدد',
        value: '${overview.newCustomersCount}',
        details: 'الفترة السابقة: ${overview.previousNewCustomersCount}',
        badgeLabel: _signedCount(overview.newCustomersChangeCount),
        tone: _countTone(overview.newCustomersChangeCount),
        icon: Icons.group_add_outlined,
      ),
      DashboardMetricViewData(
        title: 'تنبيهات المخزون — لقطة حالية',
        value: '${overview.inventoryAlertsCount}',
        details:
            '${overview.inventoryLowStockCount} منخفض، ${overview.inventoryOutOfStockCount} نافد',
        badgeLabel: 'حد منخفض: ${overview.inventoryLowStockThreshold}',
        tone: overview.inventoryAlertsCount > 0
            ? DashboardTone.warning
            : DashboardTone.success,
        icon: Icons.inventory_2_outlined,
      ),
    ];
  }

  DashboardAudienceSalesViewData _audienceSales(
    AdminDashboardOverview overview,
  ) {
    return DashboardAudienceSalesViewData(
      title: 'القطع المباعة حسب الجمهور',
      subtitle: 'قطع ضمن الطلبات المسلّمة في الفترة المحددة.',
      values: [
        for (var index = 0; index < overview.salesByAudience.length; index++)
          DashboardAudienceValueViewData(
            label: _audienceName(overview.salesByAudience[index]),
            itemsSold: overview.salesByAudience[index].itemsSoldCount
                .toDouble(),
            itemsSoldLabel:
                '${overview.salesByAudience[index].itemsSoldCount} قطعة',
            salesTotalLabel: _money(
              overview.salesByAudience[index].deliveredSalesTotal,
            ),
            colorIndex: index,
          ),
      ],
    );
  }

  DashboardRecentOrdersViewData _recentOrders(AdminDashboardOverview overview) {
    return DashboardRecentOrdersViewData(
      title: 'آخر 5 طلبات',
      subtitle: 'أحدث الطلبات كلقطة حالية لا تتأثر بفلتر الفترة.',
      rows: overview.recentOrders.map(_orderRow).toList(growable: false),
    );
  }

  DashboardOrderRowViewData _orderRow(AdminDashboardRecentOrder order) {
    return DashboardOrderRowViewData(
      orderId: order.orderId,
      orderNumber: '#${order.orderId}',
      customerName: _blankFallback(order.customerName, 'عميل غير محدد'),
      itemsCountLabel: '${order.itemsCount} قطعة',
      status: _status(order.orderStatus),
      statusLabel: _blankFallback(order.orderStatusLabel, 'غير محدد'),
      totalLabel: _money(order.orderTotal),
      dateLabel: order.orderDate == null
          ? 'تاريخ غير محدد'
          : _dateTimeLabel(order.orderDate!),
    );
  }

  DashboardSalesSeriesViewData _salesSeries(AdminDashboardOverview overview) {
    final points = overview.salesSeries
        .map(
          (point) => DashboardChartPointViewData(
            label: _shortDateLabel(point.date),
            tooltipLabel: _dateLabel(point.date),
            value: point.deliveredSalesTotal,
          ),
        )
        .toList(growable: false);

    return DashboardSalesSeriesViewData(
      title: 'المبيعات المسلّمة خلال الفترة',
      subtitle: 'سلسلة الفترة الحالية فقط حسب تاريخ التسليم.',
      seriesLabel: 'مبيعات الفترة الحالية',
      points: points,
      axisLabelIndexes: _axisLabelIndexes(points.length),
    );
  }

  DashboardInventoryHealthViewData _inventoryHealth(
    AdminDashboardOverview overview,
  ) {
    final total = overview.inventoryTotalActiveProducts;
    if (total == 0) {
      return DashboardInventoryHealthViewData(
        title: 'صحة المخزون',
        subtitle:
            'لقطة حالية للمنتجات النشطة. حد المخزون المنخفض: ${overview.inventoryLowStockThreshold}.',
        primaryPercentLabel: '0%',
        primaryLabel: 'لا توجد منتجات نشطة',
        segments: const [],
      );
    }

    final inStockPercent = _percentOf(overview.inventoryInStockCount, total);
    return DashboardInventoryHealthViewData(
      title: 'صحة المخزون',
      subtitle:
          'لقطة حالية للمنتجات النشطة. حد المخزون المنخفض: ${overview.inventoryLowStockThreshold}.',
      primaryPercentLabel: _percentLabel(inStockPercent),
      primaryLabel: 'متوفر',
      segments: [
        DashboardInventorySegmentViewData(
          label: 'متوفر',
          percentLabel: _percentLabel(inStockPercent),
          value: inStockPercent,
          seriesKey: DashboardSeriesKey.inStock,
        ),
        DashboardInventorySegmentViewData(
          label: 'منخفض',
          percentLabel: _percentLabel(
            _percentOf(overview.inventoryLowStockCount, total),
          ),
          value: _percentOf(overview.inventoryLowStockCount, total),
          seriesKey: DashboardSeriesKey.lowInventory,
        ),
        DashboardInventorySegmentViewData(
          label: 'نافد',
          percentLabel: _percentLabel(
            _percentOf(overview.inventoryOutOfStockCount, total),
          ),
          value: _percentOf(overview.inventoryOutOfStockCount, total),
          seriesKey: DashboardSeriesKey.outOfStock,
        ),
      ],
    );
  }

  DashboardDateRange _selectedRange(AdminDashboardFilter filter) {
    return switch (filter) {
      AdminDashboardPresetFilter(:final preset) => switch (preset) {
        AdminDashboardPreset.today => DashboardDateRange.today,
        AdminDashboardPreset.last7Days => DashboardDateRange.last7Days,
        AdminDashboardPreset.last30Days => DashboardDateRange.last30Days,
      },
      AdminDashboardCustomFilter() => DashboardDateRange.custom,
    };
  }

  String _audienceName(AdminDashboardAudienceSales audience) {
    return audience.audienceNameAr ??
        audience.audienceNameEn ??
        'جمهور #${audience.audienceId}';
  }

  DashboardOrderStatus _status(AdminDashboardOrderStatus? status) {
    return switch (status) {
      AdminDashboardOrderStatus.pending => DashboardOrderStatus.pending,
      AdminDashboardOrderStatus.processing => DashboardOrderStatus.processing,
      AdminDashboardOrderStatus.delivered => DashboardOrderStatus.delivered,
      AdminDashboardOrderStatus.cancelled => DashboardOrderStatus.cancelled,
      AdminDashboardOrderStatus.rejected => DashboardOrderStatus.rejected,
      AdminDashboardOrderStatus.returned => DashboardOrderStatus.returned,
      null => DashboardOrderStatus.unknown,
    };
  }

  double _salesChangePercent(AdminDashboardOverview overview) {
    final backendPercent = overview.deliveredSalesChangePercent;
    if (backendPercent != null) return backendPercent;

    final previousSales = overview.previousDeliveredSalesTotal;
    if (previousSales == 0) {
      return overview.deliveredSalesTotal == 0 ? 0 : 100;
    }

    return ((overview.deliveredSalesTotal - previousSales) / previousSales) *
        100;
  }

  String _percentBadge(double value) {
    if (value == 0) {
      return '0%';
    }
    final sign = value > 0 ? '+' : '';
    return '$sign${_compactNumber(value)}%';
  }

  String _signedCount(int value) {
    if (value == 0) return '0';
    final sign = value > 0 ? '+' : '';
    return '$sign$value';
  }

  DashboardTone _countTone(int value) {
    if (value == 0) return DashboardTone.neutral;
    return value > 0 ? DashboardTone.success : DashboardTone.danger;
  }

  double _percentOf(int value, int total) {
    if (total == 0) return 0;
    return (value / total) * 100;
  }

  Set<int> _axisLabelIndexes(int pointCount) {
    if (pointCount <= 0) return const {};
    if (pointCount <= 7) {
      return {for (var index = 0; index < pointCount; index++) index};
    }
    final step = math.max(1, (pointCount / 6).ceil());
    return {
      0,
      for (var index = step; index < pointCount - 1; index += step) index,
      pointCount - 1,
    };
  }

  String _money(double value) {
    return '${_compactNumber(value)} د.أ';
  }

  String _percentLabel(double value) {
    return '${_compactNumber(value)}%';
  }

  String _compactNumber(double value) {
    final fixed = value.toStringAsFixed(2);
    return fixed.replaceFirst(RegExp(r'\.?0+$'), '');
  }

  String _dateLabel(DateTime value) {
    return '${value.year.toString().padLeft(4, '0')}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
  }

  String _shortDateLabel(DateTime value) {
    return '${value.month.toString().padLeft(2, '0')}/${value.day.toString().padLeft(2, '0')}';
  }

  String _dateTimeLabel(DateTime value) {
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '${_dateLabel(value)} $hour:$minute';
  }

  String _blankFallback(String? value, String fallback) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? fallback : trimmed;
  }

  DashboardTone _amountTone(double value) {
    if (value == 0) return DashboardTone.neutral;
    return value > 0 ? DashboardTone.success : DashboardTone.danger;
  }

  IconData _iconByAmount(double value) {
    if (value == 0) return Icons.trending_flat;
    return value > 0 ? Icons.trending_up : Icons.trending_down;
  }
}
