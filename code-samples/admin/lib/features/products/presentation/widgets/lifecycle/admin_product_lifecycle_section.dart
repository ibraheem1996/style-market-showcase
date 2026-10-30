import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/responsive/app_spacing.dart';
import '../../../../../shared/design_system/app_text_styles.dart';
import '../../../../../shared/presentation/dialogs/confirm_dialog.dart';
import '../../cubit/product_lifecycle/admin_product_lifecycle_cubit.dart';
import '../../cubit/product_lifecycle/admin_product_lifecycle_state.dart';
import '../admin_product_status_chips.dart';
import 'admin_deletion_impact_dialog.dart';

class AdminProductLifecycleSection extends StatelessWidget {
  const AdminProductLifecycleSection({
    required this.formBusy,
    required this.hasUnsavedChanges,
    super.key,
  });

  final bool formBusy;
  final bool hasUnsavedChanges;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminProductLifecycleCubit, AdminProductLifecycleState>(
      builder: (context, state) {
        final impact = state.impact;
        final busy = formBusy || state.isMutating;
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'حالة المنتج والحذف',
                  style: AppTextStyles.sectionTitle(context),
                ),
                const SizedBox(height: AppSpacing.md),
                if (state.isLoadingImpact)
                  const Center(child: CircularProgressIndicator.adaptive())
                else if (impact == null) ...[
                  Text(state.impactErrorMessage ?? 'تعذر تحميل حالة المنتج.'),
                  const SizedBox(height: AppSpacing.sm),
                  OutlinedButton.icon(
                    onPressed: state.isRefreshingImpact
                        ? null
                        : context
                              .read<AdminProductLifecycleCubit>()
                              .refreshImpact,
                    icon: const Icon(Icons.refresh),
                    label: const Text('إعادة المحاولة'),
                  ),
                ] else ...[
                  Row(
                    children: [
                      const Expanded(child: Text('حالة الظهور:')),
                      AdminProductBooleanChip(
                        enabled: impact.active,
                        trueLabel: 'نشط',
                        falseLabel: 'غير نشط',
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  OutlinedButton.icon(
                    key: const Key('product-lifecycle-visibility'),
                    onPressed: busy
                        ? null
                        : () => _confirmVisibility(context, !impact.active),
                    icon: state.isUpdatingVisibility
                        ? const SizedBox.square(
                            dimension: 16,
                            child: CircularProgressIndicator.adaptive(
                              strokeWidth: 2,
                            ),
                          )
                        : Icon(
                            impact.active
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                    label: Text(
                      impact.active ? 'تعطيل المنتج' : 'تفعيل المنتج',
                    ),
                  ),
                  const Divider(height: AppSpacing.xl),
                  if (state.deleteErrorMessage != null) ...[
                    Text(state.deleteErrorMessage!),
                    const SizedBox(height: AppSpacing.sm),
                  ],
                  FilledButton.icon(
                    key: const Key('product-lifecycle-delete'),
                    onPressed: busy
                        ? null
                        : () async {
                            final confirmed =
                                await showAdminProductDeletionImpactDialog(
                                  context: context,
                                  impact: impact,
                                  hasUnsavedChanges: hasUnsavedChanges,
                                );
                            if (!confirmed || !context.mounted) return;
                            await context
                                .read<AdminProductLifecycleCubit>()
                                .delete();
                          },
                    icon: state.isDeleting
                        ? const SizedBox.square(
                            dimension: 16,
                            child: CircularProgressIndicator.adaptive(
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.delete_forever_outlined),
                    label: const Text('مراجعة الحذف النهائي'),
                  ),
                  TextButton.icon(
                    onPressed: busy || state.isRefreshingImpact
                        ? null
                        : context
                              .read<AdminProductLifecycleCubit>()
                              .refreshImpact,
                    icon: const Icon(Icons.refresh),
                    label: const Text('تحديث أثر الحذف'),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmVisibility(BuildContext context, bool active) async {
    final confirmed = await showAppConfirmDialog(
      context: context,
      title: active ? 'تفعيل المنتج' : 'تعطيل المنتج',
      message: active
          ? 'سيظهر المنتج مجددًا في قراءات المتجر العامة وفق قواعد Backend.'
          : 'سيُخفى المنتج من قراءات المتجر العامة دون حذف السلة أو المفضلة أو الطلبات.',
      confirmLabel: active ? 'تفعيل' : 'تعطيل',
      cancelLabel: 'إلغاء',
    );
    if (!confirmed || !context.mounted) return;
    await context.read<AdminProductLifecycleCubit>().setActive(active);
  }
}
