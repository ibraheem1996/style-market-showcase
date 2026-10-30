import 'package:json_annotation/json_annotation.dart';

import '../../../products/data/model/product_card_model.dart';
import '../../../products/data/model/product_card_list_parser.dart';
import 'recommendations_pagination_model.dart';

part 'recommendations_response_model.g.dart';

@JsonSerializable()
class RecommendationsResponseModel {
  final String? context;
  final String? strategy;
  @JsonKey(fromJson: parseProductCardList)
  final List<ProductCardModel>? items;
  final RecommendationsPaginationModel? pagination;

  const RecommendationsResponseModel({
    this.context,
    this.strategy,
    this.items,
    this.pagination,
  });

  factory RecommendationsResponseModel.fromJson(Map<String, dynamic> json) =>
      _$RecommendationsResponseModelFromJson(json);
  Map<String, dynamic> toJson() => _$RecommendationsResponseModelToJson(this);
}
