import 'package:freezed_annotation/freezed_annotation.dart';

part 'product_badge_entity.freezed.dart';

@freezed
abstract class ProductBadgeEntity with _$ProductBadgeEntity {
  const factory ProductBadgeEntity({
    required String type,
    required String labelAr,
    required String labelEn,
  }) = _ProductBadgeEntity;
}
