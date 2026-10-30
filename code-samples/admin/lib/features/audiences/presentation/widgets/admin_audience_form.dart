import 'package:flutter/material.dart';

import '../../../../core/responsive/app_spacing.dart';
import '../cubit/audience_form/admin_audience_form_cubit.dart';
import '../cubit/audience_form/admin_audience_form_state.dart';

class AdminAudienceForm extends StatefulWidget {
  const AdminAudienceForm({
    required this.state,
    required this.cubit,
    super.key,
  });

  final AdminAudienceFormState state;
  final AdminAudienceFormCubit cubit;

  @override
  State<AdminAudienceForm> createState() => _AdminAudienceFormState();
}

class _AdminAudienceFormState extends State<AdminAudienceForm> {
  late final TextEditingController _arabicController;
  late final TextEditingController _englishController;
  late final TextEditingController _sortController;

  @override
  void initState() {
    super.initState();
    final draft = widget.state.draft!;
    _arabicController = TextEditingController(text: draft.arabicName);
    _englishController = TextEditingController(text: draft.englishName);
    _sortController = TextEditingController(text: draft.sortOrder);
  }

  @override
  void dispose() {
    _arabicController.dispose();
    _englishController.dispose();
    _sortController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final draft = state.draft!;
    final enabled = !state.isSubmitting;
    final errors = state.showValidationErrors
        ? state.fieldErrors
        : const <String, String>{};
    final isCreate = state.mode == AdminAudienceFormMode.create;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            TextField(
              controller: _arabicController,
              enabled: enabled,
              onChanged: widget.cubit.arabicNameChanged,
              decoration: InputDecoration(
                labelText: 'الاسم العربي',
                errorText: errors['arabicName'],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _englishController,
              enabled: enabled,
              textDirection: TextDirection.ltr,
              onChanged: widget.cubit.englishNameChanged,
              decoration: InputDecoration(
                labelText: 'الاسم الإنجليزي',
                errorText: errors['englishName'],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _sortController,
              enabled: enabled,
              keyboardType: const TextInputType.numberWithOptions(
                signed: false,
              ),
              onChanged: widget.cubit.sortOrderChanged,
              decoration: InputDecoration(
                labelText: 'ترتيب العرض',
                errorText: errors['sortOrder'],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            if (isCreate)
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('نشطة عند الإنشاء'),
                value: draft.active,
                onChanged: enabled ? widget.cubit.activeChanged : null,
              )
            else
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('الحالة الحالية'),
                trailing: Chip(label: Text(draft.active ? 'نشط' : 'غير نشط')),
              ),
          ],
        ),
      ),
    );
  }
}
