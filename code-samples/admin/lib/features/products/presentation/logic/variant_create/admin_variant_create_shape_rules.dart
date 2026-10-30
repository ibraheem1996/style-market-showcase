import '../../cubit/variant_create/admin_variant_create_state.dart';
import '../../../domain/entities/admin_variant_create_entities.dart';

bool adminVariantCreateShapeRequiresColor(AdminVariantCreateShape? shape) {
  return switch (shape) {
    AdminVariantCreateShape.colorSize ||
    AdminVariantCreateShape.colorOnly => true,
    AdminVariantCreateShape.sizeOnly || null => false,
  };
}

AdminVariantCreateShape adminVariantCreatePresentationShape(
  AdminVariantShape shape,
) {
  return switch (shape) {
    AdminVariantShape.colorOnly => AdminVariantCreateShape.colorOnly,
    AdminVariantShape.sizeOnly => AdminVariantCreateShape.sizeOnly,
    AdminVariantShape.colorSize => AdminVariantCreateShape.colorSize,
  };
}

String adminVariantShapeArabicLabel(AdminVariantShape shape) {
  return switch (shape) {
    AdminVariantShape.colorOnly => 'لون فقط',
    AdminVariantShape.sizeOnly => 'مقاس فقط',
    AdminVariantShape.colorSize => 'لون ومقاس',
  };
}

String adminVariantShapeInconsistencyArabicMessage(
  AdminVariantShapeInconsistency inconsistency,
) {
  return switch (inconsistency) {
    AdminVariantShapeInconsistency.mixedShapes =>
      'لا يمكن إضافة خيار جديد لأن المنتج يحتوي على أنواع خيارات مختلطة. راجع الخيارات الحالية ونظّف البيانات قبل المتابعة.',
    AdminVariantShapeInconsistency.sizeGroupMissing =>
      'لا يمكن إضافة خيار جديد لأن المنتج يحتوي على خيارات بمقاسات بدون مجموعة مقاسات مرتبطة بالمنتج. يلزم تصحيح بيانات المنتج أولاً.',
    AdminVariantShapeInconsistency.sizeGroupMismatch =>
      'لا يمكن إضافة خيار جديد لأن بعض المقاسات لا تنتمي إلى مجموعة مقاسات المنتج الحالية.',
    AdminVariantShapeInconsistency.multipleSizeGroups =>
      'لا يمكن إضافة خيار جديد لأن الخيارات الحالية تستخدم أكثر من مجموعة مقاسات.',
    AdminVariantShapeInconsistency.unsupportedEmptyShape ||
    AdminVariantShapeInconsistency.invalidVariantRelation =>
      'لا يمكن إضافة خيار جديد لأن بيانات الخيارات الحالية غير مكتملة أو غير صالحة. راجع البيانات قبل المتابعة.',
  };
}

bool adminVariantCreateShapeRequiresSize(AdminVariantCreateShape? shape) {
  return switch (shape) {
    AdminVariantCreateShape.colorSize ||
    AdminVariantCreateShape.sizeOnly => true,
    AdminVariantCreateShape.colorOnly || null => false,
  };
}

bool adminVariantCreateShapeAllowed(
  AdminVariantCreateShape shape,
  AdminVariantAllowedShapesEntity allowed,
) {
  return switch (shape) {
    AdminVariantCreateShape.colorSize => allowed.colorSize,
    AdminVariantCreateShape.colorOnly => allowed.colorOnly,
    AdminVariantCreateShape.sizeOnly => allowed.sizeOnly,
  };
}

List<AdminVariantCreateShape> adminVariantCreateAllowedShapes(
  AdminVariantAllowedShapesEntity allowed,
) {
  return <AdminVariantCreateShape>[
    if (allowed.colorSize) AdminVariantCreateShape.colorSize,
    if (allowed.colorOnly) AdminVariantCreateShape.colorOnly,
    if (allowed.sizeOnly) AdminVariantCreateShape.sizeOnly,
  ];
}
