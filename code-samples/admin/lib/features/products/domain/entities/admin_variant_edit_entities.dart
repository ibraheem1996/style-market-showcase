import 'package:freezed_annotation/freezed_annotation.dart';
import 'admin_product_entities.dart';

part 'admin_variant_edit_entities.freezed.dart';

@freezed
abstract class AdminVariantDetailsEditBootstrapEntity
    with _$AdminVariantDetailsEditBootstrapEntity {
  const factory AdminVariantDetailsEditBootstrapEntity({
    required int variantId,
    required AdminVariantProductContextEntity product,
    required AdminVariantEditableDetailsEntity current,
    required AdminVariantReadonlyContextEntity readonly,
  }) = _AdminVariantDetailsEditBootstrapEntity;
}

@freezed
abstract class AdminVariantProductContextEntity
    with _$AdminVariantProductContextEntity {
  const factory AdminVariantProductContextEntity({
    required int id,
    required String arabicName,
    required String? englishName,
    required String itemPrice,
    required String itemDiscount,
  }) = _AdminVariantProductContextEntity;
}

@freezed
abstract class AdminVariantEditableDetailsEntity
    with _$AdminVariantEditableDetailsEntity {
  const factory AdminVariantEditableDetailsEntity({
    required String? descriptionAr,
    required String? descriptionEn,
    required String? variantPrice,
    required String? variantDiscount,
    required String? effectivePrice,
    required String effectiveDiscount,
    required String finalPrice,
    required bool priceIsInherited,
    required bool discountIsInherited,
  }) = _AdminVariantEditableDetailsEntity;
}

@freezed
abstract class AdminVariantReadonlyContextEntity
    with _$AdminVariantReadonlyContextEntity {
  const factory AdminVariantReadonlyContextEntity({
    required AdminProductColorSummaryEntity? color,
    required AdminProductSizeSummaryEntity? size,
    required int stock,
    required bool active,
    required String stockSource,
    required bool orderLinked,
    required DateTime? createdAt,
  }) = _AdminVariantReadonlyContextEntity;
}

@freezed
abstract class AdminVariantDetailsPatchEntity
    with _$AdminVariantDetailsPatchEntity {
  const factory AdminVariantDetailsPatchEntity({
    String? descriptionAr,
    bool? clearDescriptionAr,
    String? descriptionEn,
    bool? clearDescriptionEn,
    String? variantPrice,
    bool? clearVariantPrice,
    String? variantDiscount,
    bool? clearVariantDiscount,
  }) = _AdminVariantDetailsPatchEntity;
}
