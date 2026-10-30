import 'package:json_annotation/json_annotation.dart';

import 'pagination_model.dart';
import 'product_card_model.dart';
import 'product_card_list_parser.dart';

part 'product_search_response_model.g.dart';

@JsonSerializable()
class ProductSearchResponseModel {
  const ProductSearchResponseModel({this.items, this.pagination});

  @JsonKey(fromJson: parseProductCardList)
  final List<ProductCardModel>? items;
  final PaginationModel? pagination;

  factory ProductSearchResponseModel.fromJson(Map<String, dynamic> json) =>
      _$ProductSearchResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProductSearchResponseModelToJson(this);
}
