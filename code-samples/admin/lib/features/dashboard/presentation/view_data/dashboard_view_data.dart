import 'package:flutter/material.dart';

enum DashboardDateRange { today, last7Days, last30Days, custom }

enum DashboardTone {
  primary,
  secondary,
  tertiary,
  success,
  warning,
  danger,
  neutral,
}

enum DashboardOrderStatus {
  pending,
  processing,
  delivered,
  cancelled,
  rejected,
  returned,
  unknown,
}

enum DashboardSeriesKey { currentPeriod, inStock, lowInventory, outOfStock }

@immutable
class DashboardViewData {
  const DashboardViewData({
    required this.welcome,
    required this.dateFilter,
    required this.metrics,
    required this.audienceSales,
    required this.recentOrders,
    required this.salesSeries,
    required this.inventoryHealth,
  });

  final DashboardWelcomeViewData welcome;
  final DashboardDateFilterViewData dateFilter;
  final List<DashboardMetricViewData> metrics;
  final DashboardAudienceSalesViewData audienceSales;
  final DashboardRecentOrdersViewData recentOrders;
  final DashboardSalesSeriesViewData salesSeries;
  final DashboardInventoryHealthViewData inventoryHealth;
}

@immutable
class DashboardWelcomeViewData {
  const DashboardWelcomeViewData({required this.title, required this.subtitle});

  final String title;
  final String subtitle;
}

@immutable
class DashboardDateFilterViewData {
  const DashboardDateFilterViewData({
    required this.options,
    required this.selectedRange,
    required this.customRangeLabel,
  });

  final List<DashboardDateFilterOptionViewData> options;
  final DashboardDateRange selectedRange;
  final String? customRangeLabel;
}

@immutable
class DashboardDateFilterOptionViewData {
  const DashboardDateFilterOptionViewData({
    required this.range,
    required this.label,
  });

  final DashboardDateRange range;
  final String label;
}

@immutable
class DashboardMetricViewData {
  const DashboardMetricViewData({
    required this.title,
    required this.value,
    required this.details,
    required this.badgeLabel,
    required this.tone,
    required this.icon,
  });

  final String title;
  final String value;
  final String details;
  final String badgeLabel;
  final DashboardTone tone;
  final IconData icon;
}

@immutable
class DashboardAudienceSalesViewData {
  const DashboardAudienceSalesViewData({
    required this.title,
    required this.subtitle,
    required this.values,
  });

  final String title;
  final String subtitle;
  final List<DashboardAudienceValueViewData> values;
}

@immutable
class DashboardAudienceValueViewData {
  const DashboardAudienceValueViewData({
    required this.label,
    required this.itemsSold,
    required this.itemsSoldLabel,
    required this.salesTotalLabel,
    required this.colorIndex,
  });

  final String label;
  final double itemsSold;
  final String itemsSoldLabel;
  final String salesTotalLabel;
  final int colorIndex;
}

@immutable
class DashboardRecentOrdersViewData {
  const DashboardRecentOrdersViewData({
    required this.title,
    required this.subtitle,
    required this.rows,
  });

  final String title;
  final String subtitle;
  final List<DashboardOrderRowViewData> rows;
}

@immutable
class DashboardOrderRowViewData {
  const DashboardOrderRowViewData({
    required this.orderId,
    required this.orderNumber,
    required this.customerName,
    required this.itemsCountLabel,
    required this.status,
    required this.statusLabel,
    required this.totalLabel,
    required this.dateLabel,
  });

  final int orderId;
  final String orderNumber;
  final String customerName;
  final String itemsCountLabel;
  final DashboardOrderStatus status;
  final String statusLabel;
  final String totalLabel;
  final String dateLabel;
}

@immutable
class DashboardChartPointViewData {
  const DashboardChartPointViewData({
    required this.label,
    required this.tooltipLabel,
    required this.value,
  });

  final String label;
  final String tooltipLabel;
  final double value;
}

@immutable
class DashboardSalesSeriesViewData {
  const DashboardSalesSeriesViewData({
    required this.title,
    required this.subtitle,
    required this.seriesLabel,
    required this.points,
    required this.axisLabelIndexes,
  });

  final String title;
  final String subtitle;
  final String seriesLabel;
  final List<DashboardChartPointViewData> points;
  final Set<int> axisLabelIndexes;
}

@immutable
class DashboardInventoryHealthViewData {
  const DashboardInventoryHealthViewData({
    required this.title,
    required this.subtitle,
    required this.primaryPercentLabel,
    required this.primaryLabel,
    required this.segments,
  });

  final String title;
  final String subtitle;
  final String primaryPercentLabel;
  final String primaryLabel;
  final List<DashboardInventorySegmentViewData> segments;
}

@immutable
class DashboardInventorySegmentViewData {
  const DashboardInventorySegmentViewData({
    required this.label,
    required this.percentLabel,
    required this.value,
    required this.seriesKey,
  });

  final String label;
  final String percentLabel;
  final double value;
  final DashboardSeriesKey seriesKey;
}
