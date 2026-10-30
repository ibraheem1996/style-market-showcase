import '../../../domain/entities/admin_product_create_entities.dart';
import '../../cubit/product_create/admin_product_create_state.dart';
import 'admin_product_create_normalization.dart';

AdminProductCreateInputEntity buildAdminProductCreateInput(
  AdminProductCreateDraft draft,
) {
  return AdminProductCreateInputEntity(
    arabicName: draft.arabicName.trim(),
    englishName: draft.englishName.trim(),
    descriptionAr: optionalProductCreateText(draft.descriptionAr),
    descriptionEn: optionalProductCreateText(draft.descriptionEn),
    categoryId: draft.categoryId!,
    audienceId: draft.audienceId!,
    sizeGroupId: draft.sizeGroupId,
    itemPrice: normalizeProductCreateDecimal(draft.itemPrice),
    itemDiscount: normalizeProductCreateDiscount(draft.itemDiscount),
    active: draft.active,
    featured: draft.featured,
    simpleStock: int.parse(draft.simpleStock.trim()),
  );
}
