import 'package:freezed_annotation/freezed_annotation.dart';

part 'admin_dashboard_entities.freezed.dart';

/// Backend preset periods supported by the Admin Dashboard overview endpoint.
enum AdminDashboardPreset { today, last7Days, last30Days }

/// Effective period returned by the backend after applying the query.
enum AdminDashboardResponsePeriod { today, last7Days, last30Days, custom }

/// Order statuses exposed by the Dashboard recent-orders projection.
enum AdminDashboardOrderStatus {
  pending,
  processing,
  delivered,
  cancelled,
  rejected,
  returned,
}

/// Immutable filter for the Dashboard overview request.
///
/// The custom factory is the single owner of client-side range validation so
/// widgets, Cubit, and repository code do not drift on date rules.
@freezed
sealed class AdminDashboardFilter with _$AdminDashboardFilter {
  const AdminDashboardFilter._();

  const factory AdminDashboardFilter.preset(AdminDashboardPreset preset) =
      AdminDashboardPresetFilter;

  const factory AdminDashboardFilter.custom({
    required DateTime dateFrom,
    required DateTime dateTo,
  }) = AdminDashboardCustomFilter;

  factory AdminDashboardFilter.today() {
    return const AdminDashboardFilter.preset(AdminDashboardPreset.today);
  }

  factory AdminDashboardFilter.customValidated({
    required DateTime dateFrom,
    required DateTime dateTo,
  }) {
    final from = dateOnly(dateFrom);
    final to = dateOnly(dateTo);
    if (to.isBefore(from)) {
      throw const FormatException(
        'Dashboard date_to must be greater than or equal to date_from.',
      );
    }

    final inclusiveDays = to.difference(from).inDays + 1;
    if (inclusiveDays < 1 || inclusiveDays > 366) {
      throw const FormatException(
        'Dashboard custom range must be between 1 and 366 days.',
      );
    }

    return AdminDashboardFilter.custom(dateFrom: from, dateTo: to);
  }

  static DateTime dateOnly(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }
}

@freezed
abstract class AdminDashboardOverview with _$AdminDashboardOverview {
  const factory AdminDashboardOverview({
    required AdminDashboardResponsePeriod period,
    required String timezone,
    required DateTime dateFrom,
    required DateTime dateTo,
    required DateTime previousDateFrom,
    required DateTime previousDateTo,
    required double deliveredSalesTotal,
    required double previousDeliveredSalesTotal,
    required double? deliveredSalesChangePercent,
    required int activeOrdersCount,
    required int pendingOrdersCount,
    required int processingOrdersCount,
    required int newCustomersCount,
    required int previousNewCustomersCount,
    required int newCustomersChangeCount,
    required int inventoryTotalActiveProducts,
    required int inventoryInStockCount,
    required int inventoryLowStockCount,
    required int inventoryOutOfStockCount,
    required int inventoryAlertsCount,
    required int inventoryLowStockThreshold,
    required List<AdminDashboardRecentOrder> recentOrders,
    required List<AdminDashboardAudienceSales> salesByAudience,
    required List<AdminDashboardSalesSeriesPoint> salesSeries,
  }) = _AdminDashboardOverview;
}

@freezed
abstract class AdminDashboardRecentOrder with _$AdminDashboardRecentOrder {
  const factory AdminDashboardRecentOrder({
    required int orderId,
    required String? customerName,
    required int itemsCount,
    required AdminDashboardOrderStatus? orderStatus,
    required String? orderStatusLabel,
    required double orderTotal,
    required DateTime? orderDate,
  }) = _AdminDashboardRecentOrder;
}

@freezed
abstract class AdminDashboardAudienceSales with _$AdminDashboardAudienceSales {
  const factory AdminDashboardAudienceSales({
    required int audienceId,
    required String? audienceNameAr,
    required String? audienceNameEn,
    required double deliveredSalesTotal,
    required int itemsSoldCount,
  }) = _AdminDashboardAudienceSales;
}

@freezed
abstract class AdminDashboardSalesSeriesPoint
    with _$AdminDashboardSalesSeriesPoint {
  const factory AdminDashboardSalesSeriesPoint({
    required DateTime date,
    required double deliveredSalesTotal,
  }) = _AdminDashboardSalesSeriesPoint;
}
