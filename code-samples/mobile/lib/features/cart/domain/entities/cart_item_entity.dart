import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'cart_item_entity.freezed.dart';

@freezed
abstract class CartItemEntity with _$CartItemEntity {
  const factory CartItemEntity({
    required int cartId,
    required int userId,
    required int itemId,
    required int? variantId,
    required int cartQuantity,
    required DateTime addedAt,
    required String itemName,
    String? itemNameEn,
    required String itemDescription,
    String? itemDescriptionEn,

    /// Base unit price before the current cart discount is applied.
    ///
    /// Backend cart rows also return `lineTotal`, which is the final discounted
    /// total for the row and is the source used for checkout price validation.
    required double price,
    required double discount,
    required int? stock,
    required String image,
    required bool isSelected,

    required List<String> images,
    required String variantColor, // Arabic name
    String? variantColorEn,
    String? colorHex,
    required String variantSize, // Arabic name
    String? variantSizeEn,
    required String variantDescription,
    String? variantDescriptionEn,

    /// Final discounted total for this cart line.
    required double lineTotal,
    required bool isAvailable,
    @Default('OK') String status,
  }) = _CartItemEntity;

  const factory CartItemEntity.local({
    @Default(0) int cartId,
    @Default(0) int userId,
    @Default(0) int itemId,
    int? variantId,
    @Default(0) int cartQuantity,
    DateTime? addedAt,

    @Default("") String itemName,
    String? itemNameEn,
    @Default("") String itemDescription,
    String? itemDescriptionEn,
    @Default(0) double price,
    @Default(0) double discount,
    @Default(0) int stock,
    required String image,
    @Default(true) bool isSelected,
    @Default([]) List<String> images,
    @Default("") String variantColor,
    String? variantColorEn,
    String? colorHex,
    @Default("") String variantSize,
    String? variantSizeEn,
    @Default("") String variantDescription,
    String? variantDescriptionEn,
    @Default(0) double lineTotal,
    @Default(false) bool isAvailable,
    @Default('OK') String status,
  }) = _CartItemEntityOptional;
}

enum CartAction { added, updated, removed }

class ToggleCartResult {
  final CartAction action;
  final CartItemEntity? item;

  ToggleCartResult({required this.action, this.item});
}
