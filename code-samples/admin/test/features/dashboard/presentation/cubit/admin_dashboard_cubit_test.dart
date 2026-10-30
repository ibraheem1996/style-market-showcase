import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:multi_product_store_admin_web/core/errors/app_failure.dart';
import 'package:multi_product_store_admin_web/core/result/app_result.dart';
import 'package:multi_product_store_admin_web/features/dashboard/domain/entities/admin_dashboard_entities.dart';
import 'package:multi_product_store_admin_web/features/dashboard/domain/usecases/get_admin_dashboard_overview_use_case.dart';
import 'package:multi_product_store_admin_web/features/dashboard/presentation/cubit/admin_dashboard_cubit.dart';

import '../../dashboard_test_helpers.dart';

void main() {
  late FakeAdminDashboardRepository repository;
  late AdminDashboardCubit cubit;

  setUp(() {
    repository = FakeAdminDashboardRepository();
    cubit = AdminDashboardCubit(GetAdminDashboardOverviewUseCase(repository));
  });

  tearDown(() => cubit.close());

  test('loads initial today overview', () async {
    await cubit.loadInitial();

    expect(cubit.state.isLoading, isFalse);
    expect(cubit.state.errorMessage, isNull);
    expect(cubit.state.overview, isNotNull);
    expect(repository.lastFilter, AdminDashboardFilter.today());
  });

  test('failure turns off loading and retry uses the same filter', () async {
    repository.result = const AppResult.failure(
      AppFailure.server(message: 'فشل التحميل'),
    );

    await cubit.selectPreset(AdminDashboardPreset.last7Days);

    expect(cubit.state.isLoading, isFalse);
    expect(cubit.state.errorMessage, 'فشل التحميل');
    expect(cubit.state.filter, isA<AdminDashboardPresetFilter>());

    repository.result = AppResult.success(testDashboardOverview());
    await cubit.retry();

    expect(repository.lastFilter, cubit.state.filter);
    expect(cubit.state.errorMessage, isNull);
  });

  test('preset and custom success update filter and overview', () async {
    await cubit.selectPreset(AdminDashboardPreset.last30Days);
    expect(
      repository.lastFilter,
      const AdminDashboardFilter.preset(AdminDashboardPreset.last30Days),
    );

    await cubit.selectCustomRange(
      dateFrom: DateTime(2026, 7, 1),
      dateTo: DateTime(2026, 7, 11),
    );

    expect(cubit.state.filter, isA<AdminDashboardCustomFilter>());
    expect(cubit.state.overview, isNotNull);
  });

  test('exact duplicate while loading performs one request', () async {
    final filter = AdminDashboardFilter.today();
    final completer = Completer<AppResult<AdminDashboardOverview>>();
    repository.pending[filter] = completer;

    final first = cubit.loadInitial();
    await Future<void>.delayed(Duration.zero);
    final second = cubit.loadInitial();
    await Future<void>.delayed(Duration.zero);

    expect(repository.calls, 1);
    completer.complete(AppResult.success(testDashboardOverview()));
    await Future.wait([first, second]);
  });

  test('older overlapping result cannot replace the latest filter', () async {
    final today = AdminDashboardFilter.today();
    const last7 = AdminDashboardFilter.preset(AdminDashboardPreset.last7Days);
    final todayCompleter = Completer<AppResult<AdminDashboardOverview>>();
    final last7Completer = Completer<AppResult<AdminDashboardOverview>>();
    repository.pending[today] = todayCompleter;
    repository.pending[last7] = last7Completer;

    final first = cubit.loadInitial();
    await Future<void>.delayed(Duration.zero);
    final second = cubit.selectPreset(AdminDashboardPreset.last7Days);
    await Future<void>.delayed(Duration.zero);

    todayCompleter.complete(
      AppResult.success(
        testDashboardOverview(period: AdminDashboardResponsePeriod.today),
      ),
    );
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state.isLoading, isTrue);
    expect(cubit.state.overview, isNull);

    last7Completer.complete(
      AppResult.success(
        testDashboardOverview(period: AdminDashboardResponsePeriod.last7Days),
      ),
    );
    await Future.wait([first, second]);

    expect(cubit.state.filter, last7);
    expect(
      cubit.state.overview?.period,
      AdminDashboardResponsePeriod.last7Days,
    );
  });

  test('does not emit after close', () async {
    final filter = AdminDashboardFilter.today();
    final completer = Completer<AppResult<AdminDashboardOverview>>();
    repository.pending[filter] = completer;

    final load = cubit.loadInitial();
    await Future<void>.delayed(Duration.zero);
    await cubit.close();
    completer.complete(AppResult.success(testDashboardOverview()));

    await load;
    expect(repository.calls, 1);
  });
}
