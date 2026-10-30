import 'package:get/get.dart';
import 'product_card_entity.dart';
import '../../../../core/localization/languages.dart';

extension ProductCardEntityDisplay on ProductCardEntity {
  bool get _isArabic => Get.find<Languages>().isArabic;

  String get displayName => _isArabic ? itemNameAr : itemNameEn;
}
