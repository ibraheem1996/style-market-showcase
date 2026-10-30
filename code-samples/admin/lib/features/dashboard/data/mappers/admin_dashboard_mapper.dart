import '../../domain/entities/admin_dashboard_entities.dart';
import '../models/admin_dashboard_response_models.dart';

const _dashboardTimezone = 'Asia/Amman';

extension AdminDashboardFilterQueryMapper on AdminDashboardFilter {
  Map<String, dynamic> toQuery() {
    return switch (this) {
      AdminDashboardPresetFilter(:final preset) => {
        'period': preset.backendValue,
      },
      AdminDashboardCustomFilter(:final dateFrom, :final dateTo) => {
        'date_from': _formatDateOnly(dateFrom),
        'date_to': _formatDateOnly(dateTo),
      },
    };
  }
}

extension AdminDashboardPresetBackendValue on AdminDashboardPreset {
  String get backendValue {
    return switch (this) {
      AdminDashboardPreset.today => 'today',
      AdminDashboardPreset.last7Days => 'last_7_days',
      AdminDashboardPreset.last30Days => 'last_30_days',
    };
  }
}

extension AdminDashboardOverviewDtoMapper on AdminDashboardOverviewDataDto {
  AdminDashboardOverview toEntity() {
    final currentFrom = _parseDateOnly(dateFrom, 'date_from');
    final currentTo = _parseDateOnly(dateTo, 'date_to');
    final previousFrom = _parseDateOnly(previousDateFrom, 'previous_date_from');
    final previousTo = _parseDateOnly(previousDateTo, 'previous_date_to');

    _validatePeriodBounds(currentFrom, currentTo, 'current period');
    _validatePeriodBounds(previousFrom, previousTo, 'previous period');
    _validateNonNegativeMetrics();
    _validateSnapshotInvariants();

    final series = salesSeries
        .map(
          (point) =>
              point.toEntity(currentFrom: currentFrom, currentTo: currentTo),
        )
        .toList(growable: false);
    _validateSalesSeriesOrder(series);

    if (timezone != _dashboardTimezone) {
      throw FormatException('Unexpected dashboard timezone: $timezone');
    }

    return AdminDashboardOverview(
      period: _parsePeriod(period),
      timezone: timezone,
      dateFrom: currentFrom,
      dateTo: currentTo,
      previousDateFrom: previousFrom,
      previousDateTo: previousTo,
      deliveredSalesTotal: _nonNegativeDouble(
        deliveredSalesTotal,
        'delivered_sales_total',
      ),
      previousDeliveredSalesTotal: _nonNegativeDouble(
        previousDeliveredSalesTotal,
        'previous_delivered_sales_total',
      ),
      deliveredSalesChangePercent: deliveredSalesChangePercent?.toDouble(),
      activeOrdersCount: activeOrdersCount,
      pendingOrdersCount: pendingOrdersCount,
      processingOrdersCount: processingOrdersCount,
      newCustomersCount: newCustomersCount,
      previousNewCustomersCount: previousNewCustomersCount,
      newCustomersChangeCount: newCustomersChangeCount,
      inventoryTotalActiveProducts: inventoryTotalActiveProducts,
      inventoryInStockCount: inventoryInStockCount,
      inventoryLowStockCount: inventoryLowStockCount,
      inventoryOutOfStockCount: inventoryOutOfStockCount,
      inventoryAlertsCount: inventoryAlertsCount,
      inventoryLowStockThreshold: inventoryLowStockThreshold,
      recentOrders: recentOrders
          .map((order) => order.toEntity())
          .toList(growable: false),
      salesByAudience: salesByAudience
          .map((audience) => audience.toEntity())
          .toList(growable: false),
      salesSeries: series,
    );
  }

  void _validateNonNegativeMetrics() {
    final values = <String, int>{
      'active_orders_count': activeOrdersCount,
      'pending_orders_count': pendingOrdersCount,
      'processing_orders_count': processingOrdersCount,
      'new_customers_count': newCustomersCount,
      'previous_new_customers_count': previousNewCustomersCount,
      'inventory_total_active_products': inventoryTotalActiveProducts,
      'inventory_in_stock_count': inventoryInStockCount,
      'inventory_low_stock_count': inventoryLowStockCount,
      'inventory_out_of_stock_count': inventoryOutOfStockCount,
      'inventory_alerts_count': inventoryAlertsCount,
      'inventory_low_stock_threshold': inventoryLowStockThreshold,
    };
    for (final entry in values.entries) {
      _nonNegativeInt(entry.value, entry.key);
    }
    _nonNegativeDouble(deliveredSalesTotal, 'delivered_sales_total');
    _nonNegativeDouble(
      previousDeliveredSalesTotal,
      'previous_delivered_sales_total',
    );
  }

  void _validateSnapshotInvariants() {
    if (activeOrdersCount != pendingOrdersCount + processingOrdersCount) {
      throw const FormatException('Invalid dashboard active orders totals.');
    }
    if (inventoryAlertsCount !=
        inventoryLowStockCount + inventoryOutOfStockCount) {
      throw const FormatException('Invalid dashboard inventory alert totals.');
    }
    if (inventoryTotalActiveProducts !=
        inventoryInStockCount +
            inventoryLowStockCount +
            inventoryOutOfStockCount) {
      throw const FormatException('Invalid dashboard inventory stock totals.');
    }
  }
}

extension AdminDashboardRecentOrderDtoMapper on AdminDashboardRecentOrderDto {
  AdminDashboardRecentOrder toEntity() {
    return AdminDashboardRecentOrder(
      orderId: _positiveInt(orderId, 'recent_orders.order_id'),
      customerName: _trimToNull(customerName),
      itemsCount: _nonNegativeInt(itemsCount, 'recent_orders.items_count'),
      orderStatus: _parseNullableStatus(orderStatus),
      orderStatusLabel: _trimToNull(orderStatusLabel),
      orderTotal: _nonNegativeDouble(orderTotal, 'recent_orders.order_total'),
      orderDate: _parseNullableDateTime(orderDate, 'recent_orders.order_date'),
    );
  }
}

extension AdminDashboardAudienceDtoMapper on AdminDashboardSalesByAudienceDto {
  AdminDashboardAudienceSales toEntity() {
    return AdminDashboardAudienceSales(
      audienceId: _positiveInt(audienceId, 'sales_by_audience.audience_id'),
      audienceNameAr: _trimToNull(audienceNameAr),
      audienceNameEn: _trimToNull(audienceNameEn),
      deliveredSalesTotal: _nonNegativeDouble(
        deliveredSalesTotal,
        'sales_by_audience.delivered_sales_total',
      ),
      itemsSoldCount: _nonNegativeInt(
        itemsSoldCount,
        'sales_by_audience.items_sold_count',
      ),
    );
  }
}

extension AdminDashboardSalesSeriesDtoMapper
    on AdminDashboardSalesSeriesPointDto {
  AdminDashboardSalesSeriesPoint toEntity({
    required DateTime currentFrom,
    required DateTime currentTo,
  }) {
    final parsedDate = _parseDateOnly(date, 'sales_series.date');
    if (parsedDate.isBefore(currentFrom) || parsedDate.isAfter(currentTo)) {
      throw FormatException(
        'Dashboard sales series date outside period: $date',
      );
    }
    return AdminDashboardSalesSeriesPoint(
      date: parsedDate,
      deliveredSalesTotal: _nonNegativeDouble(
        deliveredSalesTotal,
        'sales_series.delivered_sales_total',
      ),
    );
  }
}

AdminDashboardResponsePeriod _parsePeriod(String value) {
  return switch (value) {
    'today' => AdminDashboardResponsePeriod.today,
    'last_7_days' => AdminDashboardResponsePeriod.last7Days,
    'last_30_days' => AdminDashboardResponsePeriod.last30Days,
    'custom' => AdminDashboardResponsePeriod.custom,
    _ => throw FormatException('Unknown dashboard period: $value'),
  };
}

AdminDashboardOrderStatus? _parseNullableStatus(String? value) {
  final trimmed = _trimToNull(value);
  if (trimmed == null) return null;
  return switch (trimmed) {
    'pending' => AdminDashboardOrderStatus.pending,
    'processing' => AdminDashboardOrderStatus.processing,
    'delivered' => AdminDashboardOrderStatus.delivered,
    'cancelled' => AdminDashboardOrderStatus.cancelled,
    'rejected' => AdminDashboardOrderStatus.rejected,
    'returned' => AdminDashboardOrderStatus.returned,
    _ => throw FormatException('Unknown dashboard order status: $trimmed'),
  };
}

DateTime _parseDateOnly(String value, String field) {
  final parsed = DateTime.tryParse(value);
  if (parsed == null || value.length != 10) {
    throw FormatException('Invalid dashboard date for $field: $value');
  }
  return AdminDashboardFilter.dateOnly(parsed);
}

DateTime? _parseNullableDateTime(String? value, String field) {
  final trimmed = _trimToNull(value);
  if (trimmed == null) return null;
  final parsed = DateTime.tryParse(trimmed);
  if (parsed == null) {
    throw FormatException('Invalid dashboard datetime for $field: $value');
  }
  return parsed;
}

void _validatePeriodBounds(DateTime from, DateTime to, String label) {
  if (to.isBefore(from)) {
    throw FormatException('Invalid dashboard $label bounds.');
  }
}

void _validateSalesSeriesOrder(List<AdminDashboardSalesSeriesPoint> points) {
  DateTime? previous;
  for (final point in points) {
    if (previous != null && !point.date.isAfter(previous)) {
      throw const FormatException(
        'Dashboard sales series must be ascending without duplicates.',
      );
    }
    previous = point.date;
  }
}

int _positiveInt(int value, String field) {
  if (value <= 0) {
    throw FormatException('Invalid dashboard positive integer for $field.');
  }
  return value;
}

int _nonNegativeInt(int value, String field) {
  if (value < 0) {
    throw FormatException('Invalid dashboard non-negative integer for $field.');
  }
  return value;
}

double _nonNegativeDouble(num value, String field) {
  final parsed = value.toDouble();
  if (parsed < 0) {
    throw FormatException('Invalid dashboard non-negative number for $field.');
  }
  return parsed;
}

String? _trimToNull(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) return null;
  return trimmed;
}

String _formatDateOnly(DateTime value) {
  final date = AdminDashboardFilter.dateOnly(value);
  final year = date.year.toString().padLeft(4, '0');
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}
