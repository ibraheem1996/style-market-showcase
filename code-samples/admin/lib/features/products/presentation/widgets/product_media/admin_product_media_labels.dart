import '../../../domain/entities/admin_product_enums.dart';
import '../../../domain/entities/admin_product_media_entities.dart';

extension AdminProductMediaScopeLabel on AdminProductMediaScope {
  String get label {
    return switch (this) {
      AdminProductMediaScope.item => 'عام',
      AdminProductMediaScope.color => 'لون',
      AdminProductMediaScope.size => 'مقاس',
      AdminProductMediaScope.variant => 'خيار',
    };
  }

  String get tabLabel {
    return switch (this) {
      AdminProductMediaScope.item => 'عام',
      AdminProductMediaScope.color => 'الألوان',
      AdminProductMediaScope.size => 'المقاسات',
      AdminProductMediaScope.variant => 'الخيارات',
    };
  }
}

extension AdminProductImageSourceLabel on AdminProductImageSource {
  String get label {
    return switch (this) {
      AdminProductImageSource.item => 'عام',
      AdminProductImageSource.color => 'لون',
      AdminProductImageSource.size => 'مقاس',
      AdminProductImageSource.variant => 'خيار',
      AdminProductImageSource.none => 'لا يوجد',
    };
  }
}

extension AdminProductMediaTargetLabel on AdminProductMediaTargetEntity {
  String get headerName {
    return switch (label) {
      "Product images" => 'الصور الرئيسية للمنتج',
      _ => label,
    };
  }
}
