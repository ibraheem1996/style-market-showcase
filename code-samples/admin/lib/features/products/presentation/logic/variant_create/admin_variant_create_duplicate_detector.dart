import '../../../domain/entities/admin_variant_create_entities.dart';
import '../../cubit/variant_create/admin_variant_create_state.dart';
import 'admin_variant_create_normalization.dart';

AdminVariantExistingCombinationEntity? findAdminVariantCreateDuplicate({
  required AdminVariantCreateDraft draft,
  required List<AdminVariantExistingCombinationEntity> existingCombinations,
}) {
  final selected = normalizedVariantCreateSelection(draft);
  if (selected == null) return null;

  for (final combination in existingCombinations) {
    if ((combination.colorId ?? 0) == selected.colorId &&
        (combination.sizeId ?? 0) == selected.sizeId) {
      return combination;
    }
  }
  return null;
}
