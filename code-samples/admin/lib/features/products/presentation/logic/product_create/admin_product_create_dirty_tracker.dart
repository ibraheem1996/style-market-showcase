import '../../cubit/product_create/admin_product_create_state.dart';
import 'admin_product_create_normalization.dart';

bool hasAdminProductCreateDraftChanges({
  required AdminProductCreateDraft? initialDraft,
  required AdminProductCreateDraft? currentDraft,
}) {
  if (initialDraft == null || currentDraft == null) return false;
  return !_mapEquals(_normalized(initialDraft), _normalized(currentDraft));
}

Map<String, Object?> _normalized(AdminProductCreateDraft draft) {
  return {
    'arabicName': draft.arabicName.trim(),
    'englishName': draft.englishName.trim(),
    'descriptionAr': optionalProductCreateText(draft.descriptionAr),
    'descriptionEn': optionalProductCreateText(draft.descriptionEn),
    'categoryId': draft.categoryId,
    'audienceId': draft.audienceId,
    'sizeGroupId': draft.sizeGroupId,
    'itemPrice': _normalizedDecimalOrRaw(draft.itemPrice),
    'itemDiscount': _normalizedDiscountOrRaw(draft.itemDiscount),
    'active': draft.active,
    'featured': draft.featured,
    'simpleStock': int.tryParse(draft.simpleStock.trim()) ?? draft.simpleStock,
  };
}

String _normalizedDecimalOrRaw(String value) {
  final parsed = double.tryParse(value.trim());
  if (parsed == null) return value.trim();
  return parsed.toStringAsFixed(2);
}

String _normalizedDiscountOrRaw(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) return '0.00';
  return _normalizedDecimalOrRaw(trimmed);
}

bool _mapEquals(Map<String, Object?> first, Map<String, Object?> second) {
  if (first.length != second.length) return false;
  for (final entry in first.entries) {
    if (second[entry.key] != entry.value) return false;
  }
  return true;
}
