import '../../domain/entities/pagination_entity.dart';
import '../../domain/entities/product_catalog_response_entity.dart';
import '../../domain/entities/source_meta_entity.dart';
import '../model/pagination_model.dart';
import '../model/product_catalog_response_model.dart';
import '../model/source_meta_model.dart';
import 'product_card_mapper.dart';

extension ProductCatalogResponseMapper on ProductCatalogResponseModel {
  ProductCatalogResponseEntity toEntity() {
    return ProductCatalogResponseEntity(
      items: (items ?? []).map((m) => m.toEntity()).toList(),
      pagination: pagination?.toEntity() ?? const PaginationEntity(),
      sourceMeta: sourceMeta?.toEntity() ?? const SourceMetaEntity(),
    );
  }
}

extension PaginationMapper on PaginationModel {
  PaginationEntity toEntity() {
    return PaginationEntity(
      page: page ?? 1,
      limit: limit ?? 16,
      total: total ?? 0,
      hasMore: hasMore ?? false,
    );
  }
}

extension SourceMetaMapper on SourceMetaModel {
  SourceMetaEntity toEntity() {
    String fallbackName(String? primary, String? fallback) {
      if (primary != null && primary.trim().isNotEmpty) {
        return primary;
      }

      if (fallback != null && fallback.trim().isNotEmpty) {
        return fallback;
      }
      return "";
    }

    return SourceMetaEntity(
      nameAr: fallbackName(nameAr, nameEn),
      nameEn: fallbackName(nameEn, nameAr),
      sourceType: sourceType ?? '',
      sourceId: sourceId ?? '',
    );
  }
}
