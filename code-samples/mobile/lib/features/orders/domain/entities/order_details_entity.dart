import 'package:freezed_annotation/freezed_annotation.dart';

import 'order_status.dart';
part 'order_details_entity.freezed.dart';

@freezed
abstract class OrderDetailsEntity with _$OrderDetailsEntity {
  const factory OrderDetailsEntity({
    required int orderId,
    required OrderStatus orderStatus,
    required double finalOrderTotal,
    required double subtotal,
    required double deliveryFee,
    required double totalOrderDiscount,
    required double totalOrderDiscountPercentage,
    required String paymentMethod,
    required String paymentStatus,
    DateTime? deliveredAt,
    DateTime? cancelledAt,
    DateTime? rejectedAt,
    DateTime? returnedAt,
    @Default(false) bool canCancel,
    @Default(false) bool canSubmitNote,
    @Default(false) bool hasUserNote,
    @Default([]) List<String> availableActions,
    DateTime? orderDate,
    required OrderAddressEntity? address,
    required List<OrderDetailItemEntity> items,
  }) = _OrderDetailsEntity;
}

@freezed
abstract class OrderAddressEntity with _$OrderAddressEntity {
  const factory OrderAddressEntity({
    required String cityAr,
    required String cityEn,
    required String areaAr,
    required String areaEn,
    required String street,
    @Default('') String? streetTwo,
    required String phone,
  }) = _OrderAddressEntity;
}

@freezed
abstract class OrderDetailItemEntity with _$OrderDetailItemEntity {
  const factory OrderDetailItemEntity({
    required bool isActive,

    required int itemId,

    required String nameAr,
    required String nameEn,

    required String descriptionAr,
    required String descriptionEn,

    required int quantity,

    required int stockQuantity,

    required double originalPrice,

    required double discountAmount,

    required double discountPercentage,

    required double finalPrice,

    required String displayImage,

    required List<String> itemImages,

    OrderVariantEntity? variant,
  }) = _OrderDetailItemEntity;
}

@freezed
abstract class OrderVariantEntity with _$OrderVariantEntity {
  const factory OrderVariantEntity({
    int? variantId,
    @Default('') String? colorNameAr,
    @Default('') String? colorNameEn,
    @Default('') String? colorHex,
    @Default('') String? sizeNameAr,
    @Default('') String? sizeNameEn,
    @Default('') String? descriptionAr,
    @Default('') String? descriptionEn,
    @Default([]) List<String>? images,
  }) = _OrderVariantEntity;
}

extension OrderAddressLocalization on OrderAddressEntity {
  String displayCity({required bool isArabic}) => isArabic ? cityAr : cityEn;

  String displayArea({required bool isArabic}) => isArabic ? areaAr : areaEn;
}

extension OrderDetailItemLocalization on OrderDetailItemEntity {
  String displayName({required bool isArabic}) => isArabic ? nameAr : nameEn;

  String displayDescription({required bool isArabic}) =>
      isArabic ? descriptionAr : descriptionEn;
}
