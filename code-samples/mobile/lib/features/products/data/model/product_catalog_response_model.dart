import 'package:json_annotation/json_annotation.dart';
import 'pagination_model.dart';
import 'product_card_model.dart';
import 'product_card_list_parser.dart';
import 'source_meta_model.dart';

part 'product_catalog_response_model.g.dart';

@JsonSerializable()
class ProductCatalogResponseModel {
  @JsonKey(fromJson: parseProductCardList)
  final List<ProductCardModel>? items;
  final PaginationModel? pagination;
  @JsonKey(name: 'source_meta')
  final SourceMetaModel? sourceMeta;

  ProductCatalogResponseModel({this.items, this.pagination, this.sourceMeta});

  factory ProductCatalogResponseModel.fromJson(Map<String, dynamic> json) =>
      _$ProductCatalogResponseModelFromJson(json);
  Map<String, dynamic> toJson() => _$ProductCatalogResponseModelToJson(this);
}
