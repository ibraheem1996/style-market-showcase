import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di/injection.dart';
import '../../../../app/router/app_routes.dart';
import '../../../../shared/presentation/widgets/app_error_view.dart';
import '../../../../shared/presentation/widgets/app_loading_view.dart';
import '../../domain/entities/admin_dashboard_entities.dart';
import '../cubit/admin_dashboard_cubit.dart';
import '../cubit/admin_dashboard_state.dart';
import '../view_data/dashboard_view_data.dart';
import '../view_data/dashboard_view_data_mapper.dart';
import '../widgets/custom_date_user.dart';
import '../widgets/dashboard_view.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({required this.adminName, super.key});

  final String adminName;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AdminDashboardCubit>()..loadInitial(),
      child: _DashboardPageView(adminName: adminName),
    );
  }
}

class _DashboardPageView extends StatelessWidget {
  const _DashboardPageView({required this.adminName});

  final String adminName;
  static const _mapper = DashboardViewDataMapper();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminDashboardCubit, AdminDashboardState>(
      builder: (context, state) {
        final cubit = context.read<AdminDashboardCubit>();
        if (state.isLoading && state.overview == null) {
          return const AppLoadingView(message: 'جار تحميل لوحة التحكم...');
        }
        if (state.errorMessage != null && state.overview == null) {
          return AppErrorView(
            message: state.errorMessage!,
            onRetry: cubit.retry,
          );
        }

        final overview = state.overview;
        if (overview == null) {
          return AppErrorView(
            message: state.errorMessage ?? 'لا توجد بيانات لوحة تحكم متاحة.',
            onRetry: cubit.retry,
          );
        }

        return DashboardView(
          data: _mapper.map(
            overview: overview,
            filter: state.filter,
            adminName: adminName,
          ),
          onDateRangeSelected: (range) => _selectRange(context, range),
          onOrderSelected: (orderId) =>
              context.go(AppRoutes.orderDetailPath(orderId)),
        );
      },
    );
  }

  Future<void> _selectRange(
    BuildContext context,
    DashboardDateRange range,
  ) async {
    final cubit = context.read<AdminDashboardCubit>();
    switch (range) {
      case DashboardDateRange.today:
        await cubit.selectPreset(AdminDashboardPreset.today);
      case DashboardDateRange.last7Days:
        await cubit.selectPreset(AdminDashboardPreset.last7Days);
      case DashboardDateRange.last30Days:
        await cubit.selectPreset(AdminDashboardPreset.last30Days);
      case DashboardDateRange.custom:
        await _selectCustomRange(context, cubit);
    }
  }

  Future<void> _selectCustomRange(
    BuildContext context,
    AdminDashboardCubit cubit,
  ) async {
    final today = DateUtils.dateOnly(DateTime.now());

    final firstAllowedDate = today.subtract(const Duration(days: 365));

    final currentFilter = cubit.state.filter;

    final initialRange = currentFilter.when(
      preset: (_) => DateTimeRange(
        start: today.subtract(const Duration(days: 9)),
        end: today,
      ),
      custom: (dateFrom, dateTo) => DateTimeRange(
        start: _clampDateToRange(
          DateUtils.dateOnly(dateFrom),
          firstAllowedDate,
          today,
        ),
        end: _clampDateToRange(
          DateUtils.dateOnly(dateTo),
          firstAllowedDate,
          today,
        ),
      ),
    );

    final selected = await showDialog<DateTimeRange>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return DashboardDateRangeDialog(
          initialRange: initialRange,
          firstDate: firstAllowedDate,
          lastDate: today,
        );
      },
    );

    if (!context.mounted || selected == null) {
      return;
    }

    try {
      await cubit.selectCustomRange(
        dateFrom: selected.start,
        dateTo: selected.end,
      );
    } on FormatException {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الفترة المخصصة يجب أن تكون بين يوم واحد و366 يومًا.'),
        ),
      );
    }
  }
}

DateTime _clampDateToRange(
  DateTime date,
  DateTime minimumDate,
  DateTime maximumDate,
) {
  if (date.isBefore(minimumDate)) {
    return minimumDate;
  }

  if (date.isAfter(maximumDate)) {
    return maximumDate;
  }

  return date;
}
