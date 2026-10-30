import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di/injection.dart';
import '../../../../app/router/app_routes.dart';
import '../../../../core/responsive/app_spacing.dart';
import '../../../../shared/presentation/dialogs/confirm_dialog.dart';
import '../../../../shared/presentation/widgets/app_empty_view.dart';
import '../../../../shared/presentation/widgets/app_error_view.dart';
import '../../../../shared/presentation/widgets/app_loading_view.dart';
import '../../../../shared/presentation/widgets/page_header.dart';
import '../../domain/entities/admin_audience_entities.dart';
import '../cubit/audience_form/admin_audience_form_effect.dart';
import '../cubit/audiences_list/admin_audiences_cubit.dart';
import '../cubit/audiences_list/admin_audiences_effect.dart';
import '../cubit/audiences_list/admin_audiences_state.dart';
import '../widgets/admin_audience_deletion_dialog.dart';
import '../widgets/admin_audiences_list.dart';

class AdminAudiencesPage extends StatelessWidget {
  const AdminAudiencesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AdminAudiencesCubit>()..load(),
      child: const _AdminAudiencesView(),
    );
  }
}

class _AdminAudiencesView extends StatelessWidget {
  const _AdminAudiencesView();

  Future<void> _openForm(BuildContext context, {int? audienceId}) async {
    final cubit = context.read<AdminAudiencesCubit>();
    final result = await context.push<AdminAudienceSavedAction>(
      audienceId == null
          ? AppRoutes.audienceCreate
          : AppRoutes.audienceEditPath(audienceId),
    );
    if (!context.mounted || result == null) return;
    final message = result == AdminAudienceSavedAction.created
        ? 'تم إنشاء الفئة المستهدفة.'
        : 'تم تحديث الفئة المستهدفة.';
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
    await cubit.refresh();
  }

  Future<void> _confirmVisibility(
    BuildContext context,
    AdminAudienceEntity audience,
  ) async {
    final activating = !audience.active;
    final confirmed = await showAppConfirmDialog(
      context: context,
      title: activating ? 'تفعيل الفئة المستهدفة' : 'إيقاف الفئة المستهدفة',
      message: activating
          ? 'هل تريد تفعيل هذه الفئة المستهدفة؟'
          : 'لن تظهر هذه الفئة في إنشاء المنتجات الجديدة. هل تريد إيقافها؟',
      confirmLabel: activating ? 'تفعيل' : 'إيقاف',
    );
    if (!context.mounted || !confirmed) return;
    await context.read<AdminAudiencesCubit>().changeVisibility(audience);
  }

  Future<void> _handleEffect(
    BuildContext context,
    AdminAudiencesEffect effect,
  ) async {
    switch (effect) {
      case AdminAudiencesMessageEffect(:final message):
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      case AdminAudiencesDeletionImpactEffect(:final impact):
        final confirmed = await showAdminAudienceDeletionDialog(
          context: context,
          impact: impact,
        );
        if (!context.mounted || !confirmed) return;
        await context.read<AdminAudiencesCubit>().deleteAudience(
          impact.audienceId,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AdminAudiencesCubit, AdminAudiencesState>(
      listenWhen: (previous, current) =>
          previous.effectId != current.effectId && current.effect != null,
      listener: (context, state) {
        final effect = state.effect;
        if (effect != null) _handleEffect(context, effect);
      },
      child: BlocBuilder<AdminAudiencesCubit, AdminAudiencesState>(
        builder: (context, state) {
          final cubit = context.read<AdminAudiencesCubit>();
          if (state.isLoading && state.audiences.isEmpty) {
            return const AppLoadingView(
              message: 'جار تحميل الفئات المستهدفة...',
            );
          }
          if (state.loadError != null && state.audiences.isEmpty) {
            return AppErrorView(message: state.loadError!, onRetry: cubit.load);
          }
          final busy = state.isRefreshing || state.operation != null;
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PageHeader(
                  title: 'الفئات المستهدفة',
                  subtitle: 'إدارة جماهير المتجر وحالة ظهورها.',
                  actions: [
                    FilledButton.icon(
                      onPressed: busy ? null : () => _openForm(context),
                      icon: const Icon(Icons.add),
                      label: const Text('إنشاء فئة مستهدفة'),
                    ),
                    OutlinedButton.icon(
                      onPressed: busy ? null : cubit.refresh,
                      icon: state.isRefreshing
                          ? const SizedBox.square(
                              dimension: 16,
                              child: CircularProgressIndicator.adaptive(
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.refresh),
                      label: const Text('تحديث'),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xxl),
                if (state.audiences.isEmpty)
                  const AppEmptyView(
                    title: 'لا توجد فئات مستهدفة',
                    message: 'ابدأ بإنشاء أول فئة مستهدفة للمتجر.',
                  )
                else
                  AdminAudiencesList(
                    audiences: state.audiences,
                    operationAudienceId: state.operationAudienceId,
                    operation: state.operation,
                    onEdit: (id) => _openForm(context, audienceId: id),
                    onVisibility: (audience) =>
                        _confirmVisibility(context, audience),
                    onDelete: cubit.requestDeletionImpact,
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
