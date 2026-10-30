import 'package:json_annotation/json_annotation.dart';

part 'admin_dashboard_response_models.g.dart';

@JsonSerializable()
class AdminDashboardOverviewDataDto {
  const AdminDashboardOverviewDataDto({
    required this.period,
    required this.timezone,
    required this.dateFrom,
    required this.dateTo,
    required this.previousDateFrom,
    required this.previousDateTo,
    required this.deliveredSalesTotal,
    required this.previousDeliveredSalesTotal,
    required this.deliveredSalesChangePercent,
    required this.activeOrdersCount,
    required this.pendingOrdersCount,
    required this.processingOrdersCount,
    required this.newCustomersCount,
    required this.previousNewCustomersCount,
    required this.newCustomersChangeCount,
    required this.inventoryTotalActiveProducts,
    required this.inventoryInStockCount,
    required this.inventoryLowStockCount,
    required this.inventoryOutOfStockCount,
    required this.inventoryAlertsCount,
    required this.inventoryLowStockThreshold,
    required this.recentOrders,
    required this.salesByAudience,
    required this.salesSeries,
  });

  final String period;
  final String timezone;
  @JsonKey(name: 'date_from')
  final String dateFrom;
  @JsonKey(name: 'date_to')
  final String dateTo;
  @JsonKey(name: 'previous_date_from')
  final String previousDateFrom;
  @JsonKey(name: 'previous_date_to')
  final String previousDateTo;
  @JsonKey(name: 'delivered_sales_total')
  final num deliveredSalesTotal;
  @JsonKey(name: 'previous_delivered_sales_total')
  final num previousDeliveredSalesTotal;
  @JsonKey(name: 'delivered_sales_change_percent')
  final num? deliveredSalesChangePercent;
  @JsonKey(name: 'active_orders_count')
  final int activeOrdersCount;
  @JsonKey(name: 'pending_orders_count')
  final int pendingOrdersCount;
  @JsonKey(name: 'processing_orders_count')
  final int processingOrdersCount;
  @JsonKey(name: 'new_customers_count')
  final int newCustomersCount;
  @JsonKey(name: 'previous_new_customers_count')
  final int previousNewCustomersCount;
  @JsonKey(name: 'new_customers_change_count')
  final int newCustomersChangeCount;
  @JsonKey(name: 'inventory_total_active_products')
  final int inventoryTotalActiveProducts;
  @JsonKey(name: 'inventory_in_stock_count')
  final int inventoryInStockCount;
  @JsonKey(name: 'inventory_low_stock_count')
  final int inventoryLowStockCount;
  @JsonKey(name: 'inventory_out_of_stock_count')
  final int inventoryOutOfStockCount;
  @JsonKey(name: 'inventory_alerts_count')
  final int inventoryAlertsCount;
  @JsonKey(name: 'inventory_low_stock_threshold')
  final int inventoryLowStockThreshold;
  @JsonKey(name: 'recent_orders')
  final List<AdminDashboardRecentOrderDto> recentOrders;
  @JsonKey(name: 'sales_by_audience')
  final List<AdminDashboardSalesByAudienceDto> salesByAudience;
  @JsonKey(name: 'sales_series')
  final List<AdminDashboardSalesSeriesPointDto> salesSeries;

  factory AdminDashboardOverviewDataDto.fromJson(Map<String, dynamic> json) =>
      _$AdminDashboardOverviewDataDtoFromJson(json);

  Map<String, dynamic> toJson() => _$AdminDashboardOverviewDataDtoToJson(this);
}

@JsonSerializable()
class AdminDashboardRecentOrderDto {
  const AdminDashboardRecentOrderDto({
    required this.orderId,
    required this.customerName,
    required this.itemsCount,
    required this.orderStatus,
    required this.orderStatusLabel,
    required this.orderTotal,
    required this.orderDate,
  });

  @JsonKey(name: 'order_id')
  final int orderId;
  @JsonKey(name: 'customer_name')
  final String? customerName;
  @JsonKey(name: 'items_count')
  final int itemsCount;
  @JsonKey(name: 'order_status')
  final String? orderStatus;
  @JsonKey(name: 'order_status_label')
  final String? orderStatusLabel;
  @JsonKey(name: 'order_total')
  final num orderTotal;
  @JsonKey(name: 'order_date')
  final String? orderDate;

  factory AdminDashboardRecentOrderDto.fromJson(Map<String, dynamic> json) =>
      _$AdminDashboardRecentOrderDtoFromJson(json);

  Map<String, dynamic> toJson() => _$AdminDashboardRecentOrderDtoToJson(this);
}

@JsonSerializable()
class AdminDashboardSalesByAudienceDto {
  const AdminDashboardSalesByAudienceDto({
    required this.audienceId,
    required this.audienceNameAr,
    required this.audienceNameEn,
    required this.deliveredSalesTotal,
    required this.itemsSoldCount,
  });

  @JsonKey(name: 'audience_id')
  final int audienceId;
  @JsonKey(name: 'audience_name_ar')
  final String? audienceNameAr;
  @JsonKey(name: 'audience_name_en')
  final String? audienceNameEn;
  @JsonKey(name: 'delivered_sales_total')
  final num deliveredSalesTotal;
  @JsonKey(name: 'items_sold_count')
  final int itemsSoldCount;

  factory AdminDashboardSalesByAudienceDto.fromJson(
    Map<String, dynamic> json,
  ) => _$AdminDashboardSalesByAudienceDtoFromJson(json);

  Map<String, dynamic> toJson() =>
      _$AdminDashboardSalesByAudienceDtoToJson(this);
}

@JsonSerializable()
class AdminDashboardSalesSeriesPointDto {
  const AdminDashboardSalesSeriesPointDto({
    required this.date,
    required this.deliveredSalesTotal,
  });

  final String date;
  @JsonKey(name: 'delivered_sales_total')
  final num deliveredSalesTotal;

  factory AdminDashboardSalesSeriesPointDto.fromJson(
    Map<String, dynamic> json,
  ) => _$AdminDashboardSalesSeriesPointDtoFromJson(json);

  Map<String, dynamic> toJson() =>
      _$AdminDashboardSalesSeriesPointDtoToJson(this);
}
