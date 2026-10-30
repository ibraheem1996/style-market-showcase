import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/responsive/app_spacing.dart';
import '../../../../shared/presentation/widgets/app_error_view.dart';
import '../../../../shared/presentation/widgets/app_loading_view.dart';
import '../../../../shared/presentation/widgets/page_header.dart';
import '../cubit/audience_form/admin_audience_form_cubit.dart';
import '../cubit/audience_form/admin_audience_form_effect.dart';
import '../cubit/audience_form/admin_audience_form_state.dart';
import '../widgets/admin_audience_form.dart';

class AdminAudienceFormView extends StatelessWidget {
  const AdminAudienceFormView({required this.mode, super.key});

  final AdminAudienceFormMode mode;

  void _leave(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.audiences);
    }
  }

  void _handleSuccess(
    BuildContext context,
    AdminAudienceFormSuccessEffect effect,
  ) {
    final message = effect.action == AdminAudienceSavedAction.created
        ? 'تم إنشاء الفئة المستهدفة.'
        : 'تم تحديث الفئة المستهدفة.';
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
    if (context.canPop()) {
      context.pop(effect.action);
      return;
    }

    context.go(AppRoutes.audiences);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AdminAudienceFormCubit, AdminAudienceFormState>(
      listenWhen: (previous, current) =>
          previous.effectId != current.effectId && current.effect != null,
      listener: (context, state) {
        final effect = state.effect;
        switch (effect) {
          case AdminAudienceFormSuccessEffect effect:
            _handleSuccess(context, effect);
          case AdminAudienceFormFailureEffect(:final message):
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(message)));
          case null:
            break;
        }
      },
      child: BlocBuilder<AdminAudienceFormCubit, AdminAudienceFormState>(
        builder: (context, state) {
          final cubit = context.read<AdminAudienceFormCubit>();
          if (state.isLoading && state.draft == null) {
            return const AppLoadingView(
              message: 'جار تحميل بيانات الفئة المستهدفة...',
            );
          }
          if (state.loadError != null && state.draft == null) {
            return AppErrorView(
              message: state.loadError!,
              onRetry: state.audienceId == null
                  ? cubit.loadCreate
                  : () => cubit.loadEdit(state.audienceId!),
            );
          }
          if (state.draft == null) {
            return const AppErrorView(
              message: 'تعذر تجهيز نموذج الفئة المستهدفة.',
            );
          }
          final isCreate = mode == AdminAudienceFormMode.create;
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PageHeader(
                  title: isCreate
                      ? 'إنشاء فئة مستهدفة'
                      : 'تعديل الفئة المستهدفة',
                  subtitle: isCreate
                      ? 'أدخل بيانات الفئة المستهدفة الجديدة.'
                      : 'حدّث الأسماء وترتيب العرض.',
                  actions: [
                    FilledButton.icon(
                      onPressed: state.isSubmitting ? null : cubit.submit,
                      icon: state.isSubmitting
                          ? const SizedBox.square(
                              dimension: 16,
                              child: CircularProgressIndicator.adaptive(
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.save_outlined),
                      label: const Text('حفظ'),
                    ),
                    OutlinedButton.icon(
                      onPressed: state.isSubmitting
                          ? null
                          : () => _leave(context),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('العودة'),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                AdminAudienceForm(state: state, cubit: cubit),
              ],
            ),
          );
        },
      ),
    );
  }
}
