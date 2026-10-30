import '../../cubit/variant_create/admin_variant_create_state.dart';
import 'admin_variant_create_shape_rules.dart';

typedef AdminVariantCreateSelection = ({int colorId, int sizeId});

String? optionalVariantCreateText(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

String normalizeVariantCreateDecimal(String value) {
  return double.parse(value.trim()).toStringAsFixed(2);
}

String normalizeVariantCreateDecimalForComparison(String value) {
  final trimmed = value.trim();
  final parsed = double.tryParse(trimmed);
  return parsed == null ? trimmed : parsed.toStringAsFixed(2);
}

AdminVariantCreateSelection? normalizedVariantCreateSelection(
  AdminVariantCreateDraft draft,
) {
  final shape = draft.shape;
  if (shape == null) return null;

  if (adminVariantCreateShapeRequiresColor(shape) && draft.colorId == null) {
    return null;
  }
  if (adminVariantCreateShapeRequiresSize(shape) && draft.sizeId == null) {
    return null;
  }

  // Existing backend combinations represent missing color or size as null;
  // this normalized key uses 0 so color-only and size-only compare consistently.
  return (
    colorId: adminVariantCreateShapeRequiresColor(shape) ? draft.colorId! : 0,
    sizeId: adminVariantCreateShapeRequiresSize(shape) ? draft.sizeId! : 0,
  );
}

Map<String, Object?> normalizedVariantCreateDraft(
  AdminVariantCreateDraft draft,
) {
  return {
    'shape': draft.shape,
    'colorId': adminVariantCreateShapeRequiresColor(draft.shape)
        ? draft.colorId
        : null,
    'sizeId': adminVariantCreateShapeRequiresSize(draft.shape)
        ? draft.sizeId
        : null,
    'descriptionAr': optionalVariantCreateText(draft.descriptionAr),
    'descriptionEn': optionalVariantCreateText(draft.descriptionEn),
    'stockText': draft.stockText.trim(),
    'active': draft.active,
    'priceIsInherited': draft.priceIsInherited,
    'variantPrice': draft.priceIsInherited
        ? null
        : normalizeVariantCreateDecimalForComparison(draft.variantPrice),
    'discountIsInherited': draft.discountIsInherited,
    'variantDiscount': draft.discountIsInherited
        ? null
        : normalizeVariantCreateDecimalForComparison(draft.variantDiscount),
  };
}
