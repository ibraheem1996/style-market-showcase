import 'package:flutter/material.dart';

import '../../../../core/responsive/app_radius.dart';
import '../../../../core/responsive/app_spacing.dart';
import '../../../../shared/design_system/app_palette.dart';
import '../../../../shared/design_system/app_text_styles.dart';

class AdminOrderInternalNoteEditor extends StatefulWidget {
  const AdminOrderInternalNoteEditor({
    required this.initialValue,
    required this.isSubmitting,
    required this.onSave,
    super.key,
  });

  final String? initialValue;
  final bool isSubmitting;
  final ValueChanged<String?> onSave;

  @override
  State<AdminOrderInternalNoteEditor> createState() =>
      _AdminOrderInternalNoteEditorState();
}

class _AdminOrderInternalNoteEditorState
    extends State<AdminOrderInternalNoteEditor> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(AdminOrderInternalNoteEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    final next = widget.initialValue ?? '';
    if (oldWidget.initialValue != widget.initialValue &&
        _controller.text != next) {
      _controller.text = next;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final semanticColors = Theme.of(context).semanticColors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(color: semanticColors.border),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('ملاحظة داخلية', style: AppTextStyles.sectionTitle(context)),
            const SizedBox(height: AppSpacing.md),
            TextField(
              key: const Key('admin-order-internal-note-field'),
              controller: _controller,
              enabled: !widget.isSubmitting,
              maxLength: 2000,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'ملاحظة الأدمن'),
            ),
            const SizedBox(height: AppSpacing.sm),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: FilledButton.icon(
                onPressed: widget.isSubmitting
                    ? null
                    : () {
                        final trimmed = _controller.text.trim();
                        widget.onSave(trimmed.isEmpty ? null : trimmed);
                      },
                icon: const Icon(Icons.save_outlined),
                label: const Text('حفظ الملاحظة'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
