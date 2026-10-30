import 'package:flutter/material.dart';

import '../../../../shared/presentation/dialogs/confirm_dialog.dart';
import '../../domain/entities/admin_order_enums.dart';
import '../view_data/admin_order_view_data.dart';
import 'admin_order_reason_dialog.dart';

class AdminOrderActions extends StatelessWidget {
  const AdminOrderActions({
    required this.allowedActions,
    required this.isSubmitting,
    required this.onAction,
    this.compact = false,
    super.key,
  });

  final List<AdminOrderAction> allowedActions;
  final bool isSubmitting;
  final Future<void> Function(AdminOrderAction action, String? reason) onAction;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (allowedActions.isEmpty) {
      return const SizedBox.shrink();
    }

    final children = allowedActions
        .map((action) {
          return OutlinedButton(
            onPressed: isSubmitting
                ? null
                : () => _handleAction(context, action),
            child: Text(action.arabicLabel),
          );
        })
        .toList(growable: false);

    if (compact) {
      return Wrap(spacing: 8, runSpacing: 8, children: children);
    }

    return Row(mainAxisSize: MainAxisSize.min, children: _spaced(children));
  }

  List<Widget> _spaced(List<Widget> children) {
    return [
      for (var index = 0; index < children.length; index++) ...[
        if (index > 0) const SizedBox(width: 8),
        children[index],
      ],
    ];
  }

  Future<void> _handleAction(
    BuildContext context,
    AdminOrderAction action,
  ) async {
    if (_requiresReason(action)) {
      final reason = await showAdminOrderReasonDialog(
        context: context,
        title: action.arabicLabel,
        message: 'أدخل سبب ${action.arabicLabel} الطلب.',
        confirmLabel: action.arabicLabel,
      );
      if (!context.mounted || reason == null) {
        return;
      }
      await onAction(action, reason);
      return;
    }

    final confirmed = await showAppConfirmDialog(
      context: context,
      title: action.arabicLabel,
      message: 'هل تريد تنفيذ هذا الإجراء على الطلب؟',
      confirmLabel: action.arabicLabel,
    );
    if (!context.mounted || !confirmed) {
      return;
    }
    await onAction(action, null);
  }

  bool _requiresReason(AdminOrderAction action) {
    return switch (action) {
      AdminOrderAction.reject ||
      AdminOrderAction.cancel ||
      AdminOrderAction.returned => true,
      AdminOrderAction.approve || AdminOrderAction.delivered => false,
    };
  }
}
