import '../cubit/audience_form/admin_audience_form_state.dart';

class AdminAudienceFormValidation {
  const AdminAudienceFormValidation({
    required this.arabicName,
    required this.englishName,
    required this.sortOrder,
    required this.errors,
  });

  final String arabicName;
  final String englishName;
  final int? sortOrder;
  final Map<String, String> errors;
}

/// Normalizes and validates the shared create/edit fields in one place.
AdminAudienceFormValidation validateAdminAudienceForm(
  AdminAudienceFormDraft draft,
) {
  final errors = <String, String>{};
  final arabicName = draft.arabicName.trim();
  final englishName = draft.englishName.trim();

  if (arabicName.isEmpty) {
    errors['arabicName'] = 'الاسم العربي مطلوب.';
  } else if (arabicName.length > 100) {
    errors['arabicName'] = 'الاسم العربي يجب ألا يتجاوز 100 حرف.';
  }
  if (englishName.isEmpty) {
    errors['englishName'] = 'الاسم الإنجليزي مطلوب.';
  } else if (englishName.length > 100) {
    errors['englishName'] = 'الاسم الإنجليزي يجب ألا يتجاوز 100 حرف.';
  }

  final sortOrder = int.tryParse(draft.sortOrder.trim());
  if (sortOrder == null) {
    errors['sortOrder'] = 'ترتيب العرض يجب أن يكون عددًا صحيحًا.';
  } else if (sortOrder < 0) {
    errors['sortOrder'] = 'ترتيب العرض يجب ألا يكون سالبًا.';
  }

  return AdminAudienceFormValidation(
    arabicName: arabicName,
    englishName: englishName,
    sortOrder: sortOrder,
    errors: errors,
  );
}
