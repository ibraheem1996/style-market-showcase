import 'package:freezed_annotation/freezed_annotation.dart';

part 'cart_upsert_input.freezed.dart';

@freezed
abstract class CartUpsertInput with _$CartUpsertInput {
  /// Carries the minimum cart line data needed for optimistic upserts.
  const factory CartUpsertInput({
    required int itemId,
    int? variantId,
    required String itemName,
    String? itemNameEn,
    required String itemDescription,
    String? itemDescriptionEn,
    required String image,
    @Default(<String>[]) List<String> images,
    required double price,
    required double discount,
    int? stock,
    @Default('') String variantDescription,
    String? variantDescriptionEn,
    @Default('') String variantColor,
    String? variantColorEn,
    String? colorHex,
    @Default('') String variantSize,
    String? variantSizeEn,
    @Default(true) bool isAvailable,
  }) = _CartUpsertInput;
}
