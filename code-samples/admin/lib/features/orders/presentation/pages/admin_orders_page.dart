import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di/injection.dart';
import '../../../../app/router/app_routes.dart';
import '../../../../core/responsive/app_responsive.dart';
import '../../../../core/responsive/app_spacing.dart';
import '../../../../shared/presentation/widgets/app_empty_view.dart';
import '../../../../shared/presentation/widgets/app_error_view.dart';
import '../../../../shared/presentation/widgets/page_header.dart';
import '../cubit/admin_order_effect.dart';
import '../cubit/admin_orders_cubit.dart';
import '../cubit/admin_orders_state.dart';
import '../widgets/admin_order_card_list.dart';
import '../widgets/admin_orders_filters_bar.dart';
import '../widgets/admin_orders_pagination_controls.dart';
import '../widgets/admin_orders_table.dart';

class AdminOrdersPage extends StatelessWidget {
  const AdminOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AdminOrdersCubit>()..loadInitial(),
      child: const _AdminOrdersView(),
    );
  }
}

class _AdminOrdersView extends StatelessWidget {
  const _AdminOrdersView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<AdminOrdersCubit, AdminOrdersState>(
      listenWhen: (previous, current) =>
          previous.effectId != current.effectId && current.effect != null,
      listener: (context, state) {
        final message = switch (state.effect!) {
          AdminOrderSuccessEffect(:final message) => message,
          AdminOrderFailureEffect(:final message) => message,
          _ => '',
        };
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      },
      child: BlocBuilder<AdminOrdersCubit, AdminOrdersState>(
        builder: (context, state) {
          final cubit = context.read<AdminOrdersCubit>();
          final screen = AppResponsive.of(context);

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PageHeader(
                  title: 'الطلبات',
                  subtitle: 'إدارة ومتابعة طلبات المتجر',
                  actions: [
                    OutlinedButton.icon(
                      onPressed: state.isRefreshing ? null : cubit.refresh,
                      icon: const Icon(Icons.refresh),
                      label: const Text('تحديث'),
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.section(screen)),
                AdminOrdersFiltersBar(
                  filters: state.filters,
                  onSearchChanged: cubit.searchChanged,
                  onStatusChanged: cubit.statusChanged,
                  onPaymentMethodChanged: cubit.paymentMethodChanged,
                  onPaymentStatusChanged: cubit.paymentStatusChanged,
                  onDateFromChanged: cubit.dateFromChanged,
                  onDateToChanged: cubit.dateToChanged,
                  onSortChanged: cubit.sortChanged,
                  onClear: cubit.clearFilters,
                ),
                SizedBox(height: AppSpacing.section(screen)),
                if (state.isLoading && state.orders.isEmpty)
                  const _InlineLoading(message: 'جار تحميل الطلبات...')
                else if (state.errorMessage != null && state.orders.isEmpty)
                  AppErrorView(
                    message: state.errorMessage!,
                    onRetry: cubit.loadInitial,
                  )
                else if (state.orders.isEmpty)
                  const AppEmptyView(
                    title: 'لا توجد طلبات',
                    message: 'لا توجد طلبات مطابقة للفلاتر الحالية.',
                  )
                else ...[
                  if (screen.isCompact)
                    AdminOrderCardList(
                      orders: state.orders,
                      isActionSubmitting: state.isActionSubmitting,
                      onAction: (orderId, action, reason) =>
                          cubit.performAction(
                            orderId: orderId,
                            action: action,
                            reason: reason,
                          ),
                    )
                  else
                    AdminOrdersTable(
                      orders: state.orders,
                      isActionSubmitting: state.isActionSubmitting,
                      onAction: (orderId, action, reason) =>
                          cubit.performAction(
                            orderId: orderId,
                            action: action,
                            reason: reason,
                          ),
                      onNavigateToDetails: (orderId) =>
                          context.go(AppRoutes.orderDetailPath(orderId)),
                    ),
                  if (state.pagination != null) ...[
                    const SizedBox(height: AppSpacing.lg),
                    AdminOrdersPaginationControls(
                      pagination: state.pagination!,
                      onPageChanged: cubit.goToPage,
                    ),
                  ],
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _InlineLoading extends StatelessWidget {
  const _InlineLoading({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator.adaptive(),
            const SizedBox(height: AppSpacing.md),
            Text(message),
          ],
        ),
      ),
    );
  }
}
