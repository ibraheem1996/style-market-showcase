import 'package:freezed_annotation/freezed_annotation.dart';

import 'admin_order_enums.dart';
import 'admin_orders_pagination.dart';

part 'admin_order_entities.freezed.dart';

@freezed
abstract class AdminOrdersPageEntity with _$AdminOrdersPageEntity {
  const factory AdminOrdersPageEntity({
    required List<AdminOrderSummaryEntity> items,
    required AdminOrdersPagination pagination,
  }) = _AdminOrdersPageEntity;
}

@freezed
abstract class AdminOrderCustomerEntity with _$AdminOrderCustomerEntity {
  const factory AdminOrderCustomerEntity({
    required int userId,
    required String? name,
    required String? email,
    required String? phone,
  }) = _AdminOrderCustomerEntity;
}

@freezed
abstract class AdminOrderSummaryEntity with _$AdminOrderSummaryEntity {
  const factory AdminOrderSummaryEntity({
    required int orderId,
    required AdminOrderCustomerEntity customer,
    required String? addressPhone,
    required int itemsCount,
    required double orderTotal,
    required double discountAmount,
    required AdminPaymentMethod paymentMethod,
    required AdminPaymentStatus paymentStatus,
    required AdminOrderStatus orderStatus,
    required String? statusReason,
    required String? adminInternalNote,
    required DateTime? orderDate,
    required DateTime? updatedAt,
    required List<AdminOrderAction> allowedActions,
  }) = _AdminOrderSummaryEntity;
}

@freezed
abstract class AdminOrderDetailEntity with _$AdminOrderDetailEntity {
  const factory AdminOrderDetailEntity({
    required int orderId,
    required AdminOrderCustomerEntity customer,
    required AdminOrderAddressEntity? deliveryAddress,
    required List<AdminOrderItemEntity> items,
    required double orderTotal,
    required double discountAmount,
    required double? deliveryFee,
    required AdminPaymentMethod paymentMethod,
    required AdminPaymentStatus paymentStatus,
    required AdminOrderStatus orderStatus,
    required String? statusReason,
    required String? adminInternalNote,
    required String? userNote,
    required DateTime? userNoteSubmittedAt,
    required DateTime? orderDate,
    required DateTime? updatedAt,
    required DateTime? deliveredAt,
    required DateTime? cancelledAt,
    required DateTime? rejectedAt,
    required DateTime? returnedAt,
    required List<AdminOrderAction> allowedActions,
  }) = _AdminOrderDetailEntity;
}

@freezed
abstract class AdminOrderAddressEntity with _$AdminOrderAddressEntity {
  const factory AdminOrderAddressEntity({
    required int addressId,
    required int? cityId,
    required String? cityNameAr,
    required String? cityNameEn,
    required int? areaId,
    required String? areaNameAr,
    required String? areaNameEn,
    required String? streetOne,
    required String? streetTwo,
    required String? phone,
  }) = _AdminOrderAddressEntity;
}

@freezed
abstract class AdminOrderItemEntity with _$AdminOrderItemEntity {
  const factory AdminOrderItemEntity({
    required int orderItemId,
    required int itemId,
    required int? variantId,
    required String? itemName,
    required String? itemNameEn,
    required int quantity,
    required double price,
    required double originalPrice,
    required double discountSnapshot,
    required double lineTotal,
    required AdminOrderVariantEntity? variant,
  }) = _AdminOrderItemEntity;
}

@freezed
abstract class AdminOrderVariantEntity with _$AdminOrderVariantEntity {
  const factory AdminOrderVariantEntity({
    required int variantId,
    required int? colorValueId,
    required String? colorNameAr,
    required String? colorNameEn,
    required String? colorHex,
    required int? sizeValueId,
    required String? sizeNameAr,
    required String? sizeNameEn,
    required String? descriptionAr,
    required String? descriptionEn,
  }) = _AdminOrderVariantEntity;
}
