import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:multi_product_store_admin_web/core/network/api_response.dart';
import 'package:multi_product_store_admin_web/core/network/network_error_mapper.dart';
import 'package:multi_product_store_admin_web/core/result/app_result.dart';
import 'package:multi_product_store_admin_web/features/dashboard/data/datasources/admin_dashboard_remote_data_source.dart';
import 'package:multi_product_store_admin_web/features/dashboard/data/mappers/admin_dashboard_mapper.dart';
import 'package:multi_product_store_admin_web/features/dashboard/data/models/admin_dashboard_response_models.dart';
import 'package:multi_product_store_admin_web/features/dashboard/data/repositories/admin_dashboard_repository_impl.dart';
import 'package:multi_product_store_admin_web/features/dashboard/domain/entities/admin_dashboard_entities.dart';

class _MockRemote extends Mock implements AdminDashboardRemoteDataSource {}

void main() {
  late _MockRemote remote;
  late AdminDashboardRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
  });

  setUp(() {
    remote = _MockRemote();
    repository = AdminDashboardRepositoryImpl(
      remote,
      const NetworkErrorMapper(),
    );
  });

  test('domain filter validates custom ranges once', () {
    expect(
      AdminDashboardFilter.customValidated(
        dateFrom: DateTime(2026, 1, 1),
        dateTo: DateTime(2026, 1, 1),
      ),
      isA<AdminDashboardCustomFilter>(),
    );
    expect(
      AdminDashboardFilter.customValidated(
        dateFrom: DateTime(2025, 1, 1),
        dateTo: DateTime(2026, 1, 1),
      ),
      isA<AdminDashboardCustomFilter>(),
    );
    expect(
      () => AdminDashboardFilter.customValidated(
        dateFrom: DateTime(2026, 1, 2),
        dateTo: DateTime(2026, 1, 1),
      ),
      throwsA(isA<FormatException>()),
    );
    expect(
      () => AdminDashboardFilter.customValidated(
        dateFrom: DateTime(2025, 1, 1),
        dateTo: DateTime(2026, 1, 2),
      ),
      throwsA(isA<FormatException>()),
    );
  });

  test('preset query sends only period', () {
    final query = const AdminDashboardFilter.preset(
      AdminDashboardPreset.last7Days,
    ).toQuery();

    expect(query, {'period': 'last_7_days'});
  });

  test('custom query sends only date_from and date_to', () {
    final query = AdminDashboardFilter.customValidated(
      dateFrom: DateTime(2026, 7, 1, 8),
      dateTo: DateTime(2026, 7, 11, 23),
    ).toQuery();

    expect(query, {'date_from': '2026-07-01', 'date_to': '2026-07-11'});
  });

  test(
    'repository parses success envelope and preserves null percent',
    () async {
      when(() => remote.getOverview(any())).thenAnswer(
        (_) async => ApiResponse(status: 'success', data: _dto(percent: null)),
      );

      final result = await repository.getOverview(
        const AdminDashboardFilter.preset(AdminDashboardPreset.today),
      );

      final overview =
          (result as AppResultSuccess).data as AdminDashboardOverview;
      expect(overview.deliveredSalesChangePercent, isNull);
      expect(overview.recentOrders.single.orderId, 1048);
      expect(overview.salesByAudience.single.itemsSoldCount, 4);
      expect(overview.salesSeries.single.deliveredSalesTotal, 0);
    },
  );

  test('zero values and empty lists are valid success data', () {
    final overview = _dto(
      activeOrdersCount: 0,
      pendingOrdersCount: 0,
      processingOrdersCount: 0,
      inventoryTotal: 0,
      inventoryInStock: 0,
      inventoryLow: 0,
      inventoryOut: 0,
      inventoryAlerts: 0,
      recentOrders: const [],
      salesByAudience: const [],
      salesSeries: const [],
    ).toEntity();

    expect(overview.inventoryTotalActiveProducts, 0);
    expect(overview.recentOrders, isEmpty);
  });

  test('mapper rejects malformed contract values and invariants', () {
    expect(
      () => _dto(period: 'weekly').toEntity(),
      throwsA(isA<FormatException>()),
    );
    expect(
      () => _dto(timezone: 'UTC').toEntity(),
      throwsA(isA<FormatException>()),
    );
    expect(
      () => _dto(dateFrom: '2026/07/11').toEntity(),
      throwsA(isA<FormatException>()),
    );
    expect(
      () => _dto(activeOrdersCount: 5).toEntity(),
      throwsA(isA<FormatException>()),
    );
    expect(
      () =>
          _dto(recentOrders: [_orderDto(status: 'unknown_status')]).toEntity(),
      throwsA(isA<FormatException>()),
    );
    expect(
      () => _dto(
        salesSeries: [
          const AdminDashboardSalesSeriesPointDto(
            date: '2026-07-12',
            deliveredSalesTotal: 1,
          ),
        ],
      ).toEntity(),
      throwsA(isA<FormatException>()),
    );
  });

  test(
    'repository maps API errors, missing data, Dio, and parsing failures',
    () async {
      when(() => remote.getOverview({'period': 'today'})).thenAnswer(
        (_) async => const ApiResponse(status: 'error', message: 'bad'),
      );
      expect(
        await repository.getOverview(
          const AdminDashboardFilter.preset(AdminDashboardPreset.today),
        ),
        isA<AppResultFailure>(),
      );

      when(() => remote.getOverview({'period': 'last_7_days'})).thenAnswer(
        (_) async => ApiResponse(
          status: 'success',
          data: _dto(timezone: 'UTC'),
        ),
      );
      expect(
        await repository.getOverview(
          const AdminDashboardFilter.preset(AdminDashboardPreset.last7Days),
        ),
        isA<AppResultFailure>(),
      );

      when(() => remote.getOverview({'period': 'last_30_days'})).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/admin/dashboard/overview'),
          type: DioExceptionType.connectionError,
        ),
      );
      expect(
        await repository.getOverview(
          const AdminDashboardFilter.preset(AdminDashboardPreset.last30Days),
        ),
        isA<AppResultFailure>(),
      );
    },
  );
}

AdminDashboardOverviewDataDto _dto({
  String period = 'today',
  String timezone = 'Asia/Amman',
  String dateFrom = '2026-07-11',
  String dateTo = '2026-07-11',
  num? percent = 0,
  int activeOrdersCount = 3,
  int pendingOrdersCount = 1,
  int processingOrdersCount = 2,
  int inventoryTotal = 10,
  int inventoryInStock = 7,
  int inventoryLow = 2,
  int inventoryOut = 1,
  int inventoryAlerts = 3,
  List<AdminDashboardRecentOrderDto>? recentOrders,
  List<AdminDashboardSalesByAudienceDto>? salesByAudience,
  List<AdminDashboardSalesSeriesPointDto>? salesSeries,
}) {
  return AdminDashboardOverviewDataDto(
    period: period,
    timezone: timezone,
    dateFrom: dateFrom,
    dateTo: dateTo,
    previousDateFrom: '2026-07-10',
    previousDateTo: '2026-07-10',
    deliveredSalesTotal: 245,
    previousDeliveredSalesTotal: 226.5,
    deliveredSalesChangePercent: percent,
    activeOrdersCount: activeOrdersCount,
    pendingOrdersCount: pendingOrdersCount,
    processingOrdersCount: processingOrdersCount,
    newCustomersCount: 7,
    previousNewCustomersCount: 5,
    newCustomersChangeCount: 2,
    inventoryTotalActiveProducts: inventoryTotal,
    inventoryInStockCount: inventoryInStock,
    inventoryLowStockCount: inventoryLow,
    inventoryOutOfStockCount: inventoryOut,
    inventoryAlertsCount: inventoryAlerts,
    inventoryLowStockThreshold: 5,
    recentOrders: recentOrders ?? [_orderDto()],
    salesByAudience: salesByAudience ?? [_audienceDto()],
    salesSeries:
        salesSeries ??
        const [
          AdminDashboardSalesSeriesPointDto(
            date: '2026-07-11',
            deliveredSalesTotal: 0,
          ),
        ],
  );
}

AdminDashboardRecentOrderDto _orderDto({String? status = 'pending'}) {
  return AdminDashboardRecentOrderDto(
    orderId: 1048,
    customerName: ' عميل اختبار ',
    itemsCount: 3,
    orderStatus: status,
    orderStatusLabel: ' جديد ',
    orderTotal: 48.5,
    orderDate: '2026-07-11T10:15:00',
  );
}

AdminDashboardSalesByAudienceDto _audienceDto() {
  return const AdminDashboardSalesByAudienceDto(
    audienceId: 2,
    audienceNameAr: ' رجالي ',
    audienceNameEn: 'Men',
    deliveredSalesTotal: 99.5,
    itemsSoldCount: 4,
  );
}
