import 'dart:async';

import 'package:multi_product_store_admin_web/core/result/app_result.dart';
import 'package:multi_product_store_admin_web/features/dashboard/domain/entities/admin_dashboard_entities.dart';
import 'package:multi_product_store_admin_web/features/dashboard/domain/repositories/admin_dashboard_repository.dart';

AdminDashboardOverview testDashboardOverview({
  AdminDashboardResponsePeriod period = AdminDashboardResponsePeriod.today,
  double deliveredSalesTotal = 245,
  double previousDeliveredSalesTotal = 226.5,
  double? deliveredSalesChangePercent = 8.17,
  int activeOrdersCount = 3,
  int pendingOrdersCount = 1,
  int processingOrdersCount = 2,
  int newCustomersCount = 7,
  int previousNewCustomersCount = 5,
  int newCustomersChangeCount = 2,
  int inventoryTotalActiveProducts = 10,
  int inventoryInStockCount = 7,
  int inventoryLowStockCount = 2,
  int inventoryOutOfStockCount = 1,
  int inventoryAlertsCount = 3,
  List<AdminDashboardRecentOrder>? recentOrders,
  List<AdminDashboardAudienceSales>? salesByAudience,
  List<AdminDashboardSalesSeriesPoint>? salesSeries,
}) {
  return AdminDashboardOverview(
    period: period,
    timezone: 'Asia/Amman',
    dateFrom: DateTime(2026, 7, 11),
    dateTo: DateTime(2026, 7, 11),
    previousDateFrom: DateTime(2026, 7, 10),
    previousDateTo: DateTime(2026, 7, 10),
    deliveredSalesTotal: deliveredSalesTotal,
    previousDeliveredSalesTotal: previousDeliveredSalesTotal,
    deliveredSalesChangePercent: deliveredSalesChangePercent,
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
    inventoryLowStockThreshold: 5,
    recentOrders: recentOrders ?? [testRecentOrder()],
    salesByAudience: salesByAudience ?? [testAudienceSales()],
    salesSeries:
        salesSeries ??
        [
          AdminDashboardSalesSeriesPoint(
            date: DateTime(2026, 7, 11),
            deliveredSalesTotal: 245,
          ),
        ],
  );
}

AdminDashboardRecentOrder testRecentOrder({
  int orderId = 1048,
  String? customerName = 'عميل اختبار',
  AdminDashboardOrderStatus? status = AdminDashboardOrderStatus.pending,
  String? statusLabel = 'جديد',
}) {
  return AdminDashboardRecentOrder(
    orderId: orderId,
    customerName: customerName,
    itemsCount: 3,
    orderStatus: status,
    orderStatusLabel: statusLabel,
    orderTotal: 48.5,
    orderDate: DateTime(2026, 7, 11, 10, 15),
  );
}

AdminDashboardAudienceSales testAudienceSales({
  int audienceId = 2,
  String? audienceNameAr = 'رجالي',
  String? audienceNameEn = 'Men',
  int itemsSoldCount = 4,
  double deliveredSalesTotal = 99.5,
}) {
  return AdminDashboardAudienceSales(
    audienceId: audienceId,
    audienceNameAr: audienceNameAr,
    audienceNameEn: audienceNameEn,
    deliveredSalesTotal: deliveredSalesTotal,
    itemsSoldCount: itemsSoldCount,
  );
}

class FakeAdminDashboardRepository implements AdminDashboardRepository {
  AppResult<AdminDashboardOverview> result = AppResult.success(
    testDashboardOverview(),
  );
  final Map<AdminDashboardFilter, Completer<AppResult<AdminDashboardOverview>>>
  pending = {};
  int calls = 0;
  AdminDashboardFilter? lastFilter;

  @override
  Future<AppResult<AdminDashboardOverview>> getOverview(
    AdminDashboardFilter filter,
  ) {
    calls++;
    lastFilter = filter;
    final completer = pending[filter];
    if (completer != null) return completer.future;
    return Future.value(result);
  }
}
