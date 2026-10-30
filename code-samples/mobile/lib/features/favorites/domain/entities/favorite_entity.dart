import 'package:freezed_annotation/freezed_annotation.dart';

part 'favorite_entity.freezed.dart';

@freezed
abstract class FavoriteEntity with _$FavoriteEntity {
  /// Backend-resolved favorite card data.
  ///
  /// Favorites intentionally keep their own entity instead of reusing
  /// ProductCardEntity because favorite rows have favorite-specific fields
  /// such as favId, status, selected attributes, and price alerts.
  const factory FavoriteEntity({
    required int favId,
    required int itemId,
    int? variantId,
    required FavoriteTargetType targetType,
    required String itemNameAr,
    required String itemNameEn,
    @Default('') String itemDescriptionAr,
    @Default('') String itemDescriptionEn,
    required String displayImage,
    @Default(<String>[]) List<String> images,
    required double displayPrice,
    required double originalPrice,
    required double discount,
    required int stockQuantity,
    required bool isAvailable,
    required FavoriteStatus status,
    @Default(<SelectedAttributeEntity>[])
    List<SelectedAttributeEntity> selectedAttributes,
    PriceAlertEntity? priceAlert,
    required DateTime createdAt,
  }) = _FavoriteEntity;
}

@freezed
abstract class SelectedAttributeEntity with _$SelectedAttributeEntity {
  const factory SelectedAttributeEntity({
    int? attributeTypeId,
    required String attributeTypeKey,
    required String attributeTypeNameAr,
    required String attributeTypeNameEn,
    int? valueId,
    required String valueNameAr,
    required String valueNameEn,
    String? valueHex,
  }) = _SelectedAttributeEntity;
}

@freezed
abstract class PriceAlertEntity with _$PriceAlertEntity {
  const factory PriceAlertEntity({
    required String type,
    double? oldPrice,
    double? newPrice,
    double? amount,
    double? percent,
  }) = _PriceAlertEntity;

  factory PriceAlertEntity.none() => const PriceAlertEntity(
    type: 'price_drop',
    oldPrice: 50,
    newPrice: 70,
    amount: 5,
    percent: 20,
  );
}

enum FavoriteTargetType { variant, item }

enum FavoriteStatus {
  ok,
  itemInactive,
  variantInactive,
  outOfStock,
  invalidVariant,
}
