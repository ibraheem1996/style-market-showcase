import 'package:flutter_test/flutter_test.dart';
import 'package:multi_product_store_admin_web/features/dashboard/domain/entities/admin_dashboard_entities.dart';
import 'package:multi_product_store_admin_web/features/dashboard/presentation/view_data/dashboard_view_data.dart';
import 'package:multi_product_store_admin_web/features/dashboard/presentation/view_data/dashboard_view_data_mapper.dart';

import '../../dashboard_test_helpers.dart';

void main() {
  const mapper = DashboardViewDataMapper();

  test('maps the four KPI cards from the correct overview fields', () {
    final data = mapper.map(
      overview: testDashboardOverview(deliveredSalesChangePercent: null),
      filter: AdminDashboardFilter.today(),
      adminName: 'إبراهيم',
    );

    expect(data.metrics.map((metric) => metric.title), [
      'المبيعات المسلّمة',
      'الطلبات النشطة — لقطة حالية',
      'العملاء الجدد',
      'تنبيهات المخزون — لقطة حالية',
    ]);
    expect(data.metrics.first.value, '245 د.أ');
    expect(data.metrics.first.badgeLabel, '+8.17%');
    expect(data.metrics[1].details, contains('1 قيد الانتظار'));
    expect(data.metrics[2].badgeLabel, '+2');
    expect(data.metrics[3].badgeLabel, 'حد منخفض: 5');
  });

  test('maps positive, negative, and zero changes to labels and tones', () {
    final positive = mapper.map(
      overview: testDashboardOverview(),
      filter: AdminDashboardFilter.today(),
      adminName: '',
    );
    final negative = mapper.map(
      overview: testDashboardOverview(
        deliveredSalesChangePercent: -25,
        newCustomersChangeCount: -1,
      ),
      filter: AdminDashboardFilter.today(),
      adminName: '',
    );
    final zero = mapper.map(
      overview: testDashboardOverview(
        deliveredSalesChangePercent: 0,
        newCustomersChangeCount: 0,
      ),
      filter: AdminDashboardFilter.today(),
      adminName: '',
    );

    expect(positive.metrics.first.tone, DashboardTone.success);
    expect(negative.metrics.first.badgeLabel, '-25%');
    expect(negative.metrics.first.tone, DashboardTone.danger);
    expect(negative.metrics[2].badgeLabel, '-1');
    expect(zero.metrics.first.badgeLabel, '0%');
    expect(zero.metrics.first.tone, DashboardTone.neutral);
  });

  test('maps dynamic audiences with Arabic, English, and ID fallbacks', () {
    final data = mapper.map(
      overview: testDashboardOverview(
        salesByAudience: [
          testAudienceSales(audienceNameAr: 'نساء', audienceNameEn: 'Women'),
          testAudienceSales(
            audienceId: 8,
            audienceNameAr: null,
            audienceNameEn: 'Kids',
          ),
          testAudienceSales(
            audienceId: 9,
            audienceNameAr: null,
            audienceNameEn: null,
          ),
        ],
      ),
      filter: AdminDashboardFilter.today(),
      adminName: '',
    );

    expect(data.audienceSales.values.map((value) => value.label), [
      'نساء',
      'Kids',
      'جمهور #9',
    ]);
    expect(data.audienceSales.values.first.itemsSoldLabel, '4 قطعة');
    expect(data.audienceSales.values.first.salesTotalLabel, '99.5 د.أ');
  });

  test('maps inventory percentages and total-zero empty behavior', () {
    final filled = mapper.map(
      overview: testDashboardOverview(),
      filter: AdminDashboardFilter.today(),
      adminName: '',
    );
    final empty = mapper.map(
      overview: testDashboardOverview(
        inventoryTotalActiveProducts: 0,
        inventoryInStockCount: 0,
        inventoryLowStockCount: 0,
        inventoryOutOfStockCount: 0,
        inventoryAlertsCount: 0,
      ),
      filter: AdminDashboardFilter.today(),
      adminName: '',
    );

    expect(filled.inventoryHealth.primaryPercentLabel, '70%');
    expect(filled.inventoryHealth.segments, hasLength(3));
    expect(empty.inventoryHealth.segments, isEmpty);
    expect(empty.inventoryHealth.primaryLabel, 'لا توجد منتجات نشطة');
  });

  test('maps all order statuses and nullable fallbacks', () {
    final statuses = AdminDashboardOrderStatus.values;
    final data = mapper.map(
      overview: testDashboardOverview(
        recentOrders: [
          for (final status in statuses)
            testRecentOrder(orderId: 1000 + status.index, status: status),
          testRecentOrder(
            orderId: 2000,
            customerName: null,
            status: null,
            statusLabel: null,
          ),
        ],
      ),
      filter: AdminDashboardFilter.today(),
      adminName: '',
    );

    expect(data.recentOrders.rows.map((row) => row.status).take(6), [
      DashboardOrderStatus.pending,
      DashboardOrderStatus.processing,
      DashboardOrderStatus.delivered,
      DashboardOrderStatus.cancelled,
      DashboardOrderStatus.rejected,
      DashboardOrderStatus.returned,
    ]);
    expect(data.recentOrders.rows.last.status, DashboardOrderStatus.unknown);
    expect(data.recentOrders.rows.last.customerName, 'عميل غير محدد');
    expect(data.recentOrders.rows.last.statusLabel, 'غير محدد');
  });

  test(
    'sales chart contains current series points only and sparse axis labels',
    () {
      final points = [
        for (var index = 1; index <= 30; index++)
          AdminDashboardSalesSeriesPoint(
            date: DateTime(2026, 7, index),
            deliveredSalesTotal: index.isEven ? 0 : index.toDouble(),
          ),
      ];
      final data = mapper.map(
        overview: testDashboardOverview(salesSeries: points),
        filter: AdminDashboardFilter.today(),
        adminName: '',
      );

      expect(data.salesSeries.seriesLabel, 'مبيعات الفترة الحالية');
      expect(data.salesSeries.points, hasLength(30));
      expect(
        data.salesSeries.points.where((point) => point.value == 0),
        isNotEmpty,
      );
      expect(data.salesSeries.axisLabelIndexes.length, lessThanOrEqualTo(7));
    },
  );
}
