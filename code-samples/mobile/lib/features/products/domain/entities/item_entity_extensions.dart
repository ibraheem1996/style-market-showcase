import 'package:get/get.dart';
import 'package:my_project/core/localization/languages.dart';

import '../../../../core/config/api_config.dart';
import 'item_entity.dart';

extension ItemEntityDesblay on ItemEntity {
  bool get _isArabic => Get.find<Languages>().isArabic;

  String get displayName => _isArabic ? itemNameAr : itemNameEn;

  String get displayDescription =>
      _isArabic ? itemDescriptionAr : itemDescriptionEn;

  /// get just first image of item if there is no image return no_image.png
  String get displayItemImage {
    if (itemImages.isNotEmpty) {
      return itemImages.first;
    }
    if (variants.isNotEmpty && variants.first.variantImages.isNotEmpty) {
      return variants.first.variantImages.first;
    }
    return ApiConfig.placeholder;
  }
}

extension VariantEntityDisplay on VariantEntity {
  bool get _isArabic => Get.find<Languages>().isArabic;

  String get displayColor => _isArabic ? (variantColor) : (variantColorEn);

  String get displaySize => _isArabic ? (variantSize) : (variantSizeEn);

  String get displayDescription =>
      _isArabic ? variantDescriptionAr : variantDescriptionEn;

  String get displayColorDescription =>
      _isArabic ? (colorDescriptionAr) : (colorDescriptionEn);

  String get displayFullDescription {
    final vDesc = displayDescription.trim();
    final cDesc = displayColorDescription.trim();

    if (vDesc.isNotEmpty && cDesc.isNotEmpty) {
      return "$vDesc\n\n$cDesc";
    } else if (vDesc.isNotEmpty) {
      return vDesc;
    } else if (cDesc.isNotEmpty) {
      return cDesc;
    }
    return "";
  }
}
