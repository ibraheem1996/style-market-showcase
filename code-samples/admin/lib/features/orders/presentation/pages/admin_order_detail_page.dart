import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di/injection.dart';
import '../../../../app/router/app_routes.dart';
import '../../../../core/responsive/app_responsive.dart';
import '../../../../core/responsive/app_spacing.dart';
import '../../../../shared/presentation/widgets/app_error_view.dart';
import '../../../../shared/presentation/widgets/page_header.dart';
import '../../domain/entities/admin_order_enums.dart';
import '../cubit/admin_order_detail_cubit.dart';
import '../cubit/admin_order_detail_state.dart';
import '../cubit/admin_order_effect.dart';
import '../widgets/admin_order_actions.dart';
import '../widgets/admin_order_detail_sections.dart';
import '../widgets/admin_order_internal_note_editor.dart';

class AdminOrderDetailPage extends StatelessWidget {
  const AdminOrderDetailPage({required this.orderId, super.key});

  final int orderId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AdminOrderDetailCubit>()..load(orderId),
      child: _AdminOrderDetailView(orderId: orderId),
    );
  }
}

class _AdminOrderDetailView extends StatelessWidget {
  const _AdminOrderDetailView({required this.orderId});

  final int orderId;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AdminOrderDetailCubit, AdminOrderDetailState>(
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
      child: BlocBuilder<AdminOrderDetailCubit, AdminOrderDetailState>(
        builder: (context, state) {
          final cubit = context.read<AdminOrderDetailCubit>();
          final screen = AppResponsive.of(context);
          final order = state.order;

          if (state.isLoading && order == null) {
            return const _InlineLoading(message: 'جار تحميل تفاصيل الطلب...');
          }

          if (state.errorMessage != null && order == null) {
            return AppErrorView(
              message: state.errorMessage!,
              onRetry: () => cubit.load(orderId),
            );
          }

          if (order == null) {
            return const AppErrorView(message: 'تعذر تحميل تفاصيل الطلب.');
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PageHeader(
                  title: 'طلب #${order.orderId}',
                  subtitle: 'تفاصيل الطلب وإجراءاته',
                  actions: [
                    OutlinedButton.icon(
                      onPressed: () => context.go(AppRoutes.orders),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('العودة للطلبات'),
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.section(screen)),

                AdminOrderActions(
                  allowedActions: order.allowedActions,
                  isSubmitting: state.isSubmitting,
                  compact: true,
                  onAction: (action, reason) {
                    return switch (action) {
                      AdminOrderAction.approve => cubit.approve(),
                      AdminOrderAction.reject => cubit.reject(
                        reason: reason ?? '',
                      ),
                      AdminOrderAction.cancel => cubit.cancel(
                        reason: reason ?? '',
                      ),
                      AdminOrderAction.delivered => cubit.markDelivered(),
                      AdminOrderAction.returned => cubit.markReturned(
                        reason: reason ?? '',
                      ),
                    };
                  },
                ),

                const SizedBox(height: AppSpacing.md),

                AdminOrderDetailSections(order: order),
                const SizedBox(height: AppSpacing.md),

                AdminOrderInternalNoteEditor(
                  initialValue: order.adminInternalNote,
                  isSubmitting: state.isSubmitting,
                  onSave: cubit.updateInternalNote,
                ),
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
