import '../../domain/entities/product_search_response_entity.dart';
import '../model/product_search_response_model.dart';
import 'product_card_mapper.dart';
import 'product_catalog_response_mapper.dart';

extension ProductSearchResponseMapper on ProductSearchResponseModel {
  ProductSearchResponseEntity toEntity() {
    return ProductSearchResponseEntity(
      items: (items ?? []).map((item) => item.toEntity()).toList(),
      pagination: pagination!.toEntity(),
    );
  }
}
