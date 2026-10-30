import '../../../domain/entities/admin_variant_create_entities.dart';
import '../../cubit/variant_create/admin_variant_create_state.dart';
import 'admin_variant_create_duplicate_detector.dart';
import 'admin_variant_create_shape_rules.dart';

Map<String, String> validateAdminVariantCreateDraft({
  required AdminVariantCreateDraft? draft,
  required AdminVariantCreateOptionsEntity? options,
}) {
  final errors = <String, String>{};
  if (draft == null || options == null) return errors;

  final shape = draft.shape;
  if (shape == null) {
    errors['shape'] = 'اختر نوع الخيار.';
  } else if (!adminVariantCreateShapeAllowed(shape, options.allowedShapes)) {
    errors['shape'] = 'نوع الخيار المحدد غير متاح لهذا المنتج.';
  }

  if (adminVariantCreateShapeRequiresColor(shape)) {
    final color = _colorById(options.colors, draft.colorId);
    if (draft.colorId == null) {
      errors['colorId'] = 'اختر اللون.';
    } else if (color == null || !color.selectable) {
      errors['colorId'] = 'اللون المحدد غير متاح. أعد تحميل الخيارات.';
    }
  }

  if (adminVariantCreateShapeRequiresSize(shape)) {
    final size = _sizeById(options.sizes, draft.sizeId);
    if (draft.sizeId == null) {
      errors['sizeId'] = 'اختر المقاس.';
    } else if (size == null || !size.selectable) {
      errors['sizeId'] = 'المقاس المحدد غير متاح. أعد تحميل الخيارات.';
    }
  }

  final duplicate = findAdminVariantCreateDuplicate(
    draft: draft,
    existingCombinations: options.existingCombinations,
  );
  if (duplicate != null) {
    errors['combination'] = 'هذا الخيار موجود مسبقًا: ${duplicate.label}.';
  }

  _validateOptionalLength(
    errors,
    key: 'descriptionAr',
    value: draft.descriptionAr,
    max: 1000,
    message: 'الوصف العربي طويل جداً.',
  );
  _validateOptionalLength(
    errors,
    key: 'descriptionEn',
    value: draft.descriptionEn,
    max: 1000,
    message: 'الوصف الإنجليزي طويل جداً.',
  );

  final trimmedStock = draft.stockText.trim();
  final stock = int.tryParse(trimmedStock);
  if (trimmedStock.isEmpty) {
    errors['stock'] = 'المخزون الابتدائي مطلوب.';
  } else if (stock == null || stock < 0) {
    errors['stock'] = 'المخزون يجب أن يكون عددًا صحيحًا لا يقل عن صفر.';
  }

  if (!draft.priceIsInherited) {
    _validateDecimal(
      errors,
      key: 'variantPrice',
      value: draft.variantPrice,
      requiredMessage: 'السعر مطلوب عند إلغاء الوراثة.',
      rangeMessage: 'السعر يجب أن يكون بين 0.00 و 99999999.99.',
      min: 0,
      max: 99999999.99,
    );
  }

  if (!draft.discountIsInherited) {
    _validateDecimal(
      errors,
      key: 'variantDiscount',
      value: draft.variantDiscount,
      requiredMessage: 'الخصم مطلوب عند إلغاء الوراثة.',
      rangeMessage: 'الخصم يجب أن يكون بين 0.00 و 100.00.',
      min: 0,
      max: 100,
    );
  }

  return errors;
}

AdminVariantCreateColorOptionEntity? _colorById(
  List<AdminVariantCreateColorOptionEntity> colors,
  int? id,
) {
  if (id == null) return null;
  for (final color in colors) {
    if (color.id == id) return color;
  }
  return null;
}

AdminVariantCreateSizeOptionEntity? _sizeById(
  List<AdminVariantCreateSizeOptionEntity> sizes,
  int? id,
) {
  if (id == null) return null;
  for (final size in sizes) {
    if (size.id == id) return size;
  }
  return null;
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
  required String requiredMessage,
  required String rangeMessage,
  required double min,
  required double max,
}) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) {
    errors[key] = requiredMessage;
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
