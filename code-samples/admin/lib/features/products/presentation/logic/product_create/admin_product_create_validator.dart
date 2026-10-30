import '../../../domain/entities/admin_product_create_entities.dart';
import '../../cubit/product_create/admin_product_create_state.dart';

Map<String, String> validateAdminProductCreateDraft({
  required AdminProductCreateDraft? draft,
  required AdminProductCreateOptionsEntity? options,
}) {
  final errors = <String, String>{};
  if (draft == null || options == null) return errors;

  final arabicName = draft.arabicName.trim();
  if (arabicName.isEmpty) {
    errors['arabicName'] = 'الاسم العربي مطلوب.';
  } else if (arabicName.length > 100) {
    errors['arabicName'] = 'الاسم العربي يجب ألا يتجاوز ${100} حرفًا.';
  }

  final englishName = draft.englishName.trim();
  if (englishName.isEmpty) {
    errors['englishName'] = 'الاسم الإنجليزي مطلوب.';
  } else if (englishName.length > 100) {
    errors['englishName'] = 'الاسم الإنجليزي يجب ألا يتجاوز ${100} حرفًا.';
  }

  _validateOptionalLength(
    errors,
    key: 'descriptionAr',
    value: draft.descriptionAr,
    max: 1000,
    message: 'الوصف العربي طويل جدًا.',
  );
  _validateOptionalLength(
    errors,
    key: 'descriptionEn',
    value: draft.descriptionEn,
    max: 1000,
    message: 'الوصف الإنجليزي طويل جدًا.',
  );

  _validateReference(
    errors,
    key: 'categoryId',
    value: draft.categoryId,
    selectableIds: options.categories
        .where((item) => item.selectable)
        .map((item) => item.id)
        .toSet(),
    requiredMessage: 'التصنيف مطلوب.',
    unavailableMessage: 'التصنيف المحدد غير متاح. أعد تحميل الخيارات.',
  );
  _validateReference(
    errors,
    key: 'audienceId',
    value: draft.audienceId,
    selectableIds: options.audiences
        .where((item) => item.selectable)
        .map((item) => item.id)
        .toSet(),
    requiredMessage: 'الجمهور مطلوب.',
    unavailableMessage: 'الجمهور المحدد غير متاح. أعد تحميل الخيارات.',
  );

  if (draft.sizeGroupId != null &&
      !options.sizeGroups.any((item) => item.id == draft.sizeGroupId)) {
    errors['sizeGroupId'] =
        'مجموعة المقاسات المحددة غير متاحة. أعد تحميل الخيارات.';
  }

  _validateDecimal(
    errors,
    key: 'itemPrice',
    value: draft.itemPrice,
    required: true,
    min: _parseLimit(options.limits.priceMin, fallback: 0),
    max: _parseLimit(options.limits.priceMax, fallback: 99999999.99),
    requiredMessage: 'السعر الأساسي مطلوب.',
    rangeMessage:
        'السعر الأساسي يجب أن يكون بين ${options.limits.priceMin} و ${options.limits.priceMax}.',
  );

  _validateDecimal(
    errors,
    key: 'itemDiscount',
    value: draft.itemDiscount,
    required: false,
    min: _parseLimit(options.limits.discountMin, fallback: 0),
    max: _parseLimit(options.limits.discountMax, fallback: 100),
    requiredMessage: '',
    rangeMessage:
        'الخصم يجب أن يكون بين ${options.limits.discountMin} و ${options.limits.discountMax}.',
  );

  final stockText = draft.simpleStock.trim();
  final stock = int.tryParse(stockText);
  if (stockText.isEmpty) {
    errors['simpleStock'] = 'المخزون الابتدائي مطلوب.';
  } else if (stock == null || stock < 0) {
    errors['simpleStock'] = 'المخزون يجب أن يكون عددًا صحيحًا لا يقل عن صفر.';
  }

  return errors;
}

void _validateReference(
  Map<String, String> errors, {
  required String key,
  required int? value,
  required Set<int> selectableIds,
  required String requiredMessage,
  required String unavailableMessage,
}) {
  if (value == null) {
    errors[key] = requiredMessage;
    return;
  }
  if (!selectableIds.contains(value)) {
    errors[key] = unavailableMessage;
  }
}

void _validateOptionalLength(
  Map<String, String> errors, {
  required String key,
  required String value,
  required int max,
  required String message,
}) {
  if (value.trim().length > max) {
    errors[key] = message;
  }
}

void _validateDecimal(
  Map<String, String> errors, {
  required String key,
  required String value,
  required bool required,
  required double min,
  required double max,
  required String requiredMessage,
  required String rangeMessage,
}) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) {
    if (required) errors[key] = requiredMessage;
    return;
  }
  if (!RegExp(r'^\d+(\.\d{1,2})?$').hasMatch(trimmed)) {
    errors[key] = 'أدخل رقمًا صحيحًا وبحد أقصى منزلتين عشريتين.';
    return;
  }
  final parsed = double.tryParse(trimmed);
  if (parsed == null || parsed < min || parsed > max) {
    errors[key] = rangeMessage;
  }
}

double _parseLimit(String value, {required double fallback}) {
  return double.tryParse(value.trim()) ?? fallback;
}
