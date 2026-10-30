import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_project/binding_route_middleware/route.dart';
import '../../../../core/translations/locale_keys.dart';
import '../../../../core/constants/app_pref_key.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/errors/failure_key.dart';
import '../../../../core/storage/prefs_storage.dart';

import '../../../addresses/domain/entities/address_entity.dart';
import '../../../addresses/domain/repositories/selected_address_reader.dart';
import '../../../cart/presentation/logic/cart_line_rules.dart';
import '../../../cart/presentation/logic/cart_pricing.dart';
import '../../../cart/presentation/operations/cart_operations.dart';
import '../../../cart/presentation/store/cart_store.dart';
import '../../../home/presentation/store/home_store.dart';
import '../../../orders/domain/params/create_order_params.dart';
import '../../../orders/presentation/services/order_service.dart';
import '../event/check_out_event.dart';
import '../state/state.dart';

class CheckoutController extends GetxController {
  CheckoutController({
    required this.cartOperations,
    required this.cartStore,
    required SelectedAddressReader selectedAddressReader,
    required this.orderService,
    required this.homeStore,
    required this.prefsStorage,
  }) : _selectedAddressReader = selectedAddressReader;

  final CartOperations cartOperations;
  final CartStore cartStore;
  final SelectedAddressReader _selectedAddressReader;
  final HomeStore homeStore;
  final OrderService orderService;
  final PrefsStorage prefsStorage;

  final PageController pageController = PageController();
  final TextEditingController noteController = TextEditingController();
  final state = const CheckoutState().obs;
  final Rxn<CheckoutEvent> event = Rxn<CheckoutEvent>();
  final RxnString inlineFeedback = RxnString();

  String? _currentIdempotencyKey;
  static const Duration _pendingAttemptTtl = Duration(hours: 24);

  AddressEntity? get selectedDeliveryAddress =>
      _selectedAddressReader.selectedAddress;

  @override
  void onInit() {
    super.onInit();

    // Sync currentStepIndex with page controller
    pageController.addListener(_onPageChanged);

    refreshCart();
  }

  void _onPageChanged() {
    if (!pageController.hasClients) return;
    final page = pageController.page?.round() ?? 0;
    if (page != state.value.currentStepIndex) {
      state.value = state.value.copyWith(currentStepIndex: page);
    }
  }

  Future<void> refreshCart() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      unawaited(_refreshCartNow());
    });
  }

  // ---------- Payment ----------
  void changePaymentMethod(PaymentMethod? method) {
    if (method == null) return;
    clearInlineFeedback();
    state.value = state.value.copyWith(selectedPaymentMethod: method);
  }

  void showInlineFeedback(String message) => inlineFeedback.value = message;

  void clearInlineFeedback() => inlineFeedback.value = null;

  bool get canGoNext {
    final step = state.value.currentStepIndex;

    if (step == 0) {
      return state.value.selectedPaymentMethod != PaymentMethod.none;
    }

    if (step == 1) {
      return selectedDeliveryAddress != null;
    }

    return false;
  }

  bool get canGoBack => state.value.currentStepIndex > 0;

  Future<void> nextStep() async {
    clearInlineFeedback();
    final step = state.value.currentStepIndex;

    // Step 0 validation
    if (step == 0) {
      if (state.value.selectedPaymentMethod == PaymentMethod.visa) {
        event.value = CheckoutEvent.errorMessage(
          LocaleKeys.checkoutOnlinePaymentUnavailable.tr,
        );
        return;
      }
      if (state.value.selectedPaymentMethod == PaymentMethod.none) {
        event.value = CheckoutEvent.errorMessage(
          LocaleKeys.checkoutSelectPaymentMethod.tr,
        );
        return;
      }
    }

    // Step 1 validation
    if (step == 1) {
      if (selectedDeliveryAddress == null) {
        event.value = CheckoutEvent.errorMessage(
          LocaleKeys.checkoutSelectDeliveryAddress.tr,
        );
        return;
      }
      final cartReady = await _refreshAndValidateCartForCheckout();
      if (!cartReady) return;
      final previewOk = await _refreshCheckoutPreview();
      if (!previewOk) return;
    }

    if (pageController.hasClients) {
      await pageController.nextPage(
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> previousStep() async {
    if (!pageController.hasClients) return;

    await pageController.previousPage(
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeInOut,
    );
  }

  // ---------- Place Order ----------
  Future<void> placeOrder() async {
    if (state.value.isPlacingOrder) return;
    clearInlineFeedback();

    final selectedAddress = selectedDeliveryAddress;

    if (selectedAddress == null) {
      event.value = CheckoutEvent.errorMessage(
        LocaleKeys.checkoutSelectDeliveryAddress.tr,
      );
      if (pageController.hasClients) {
        await pageController.animateToPage(
          1,
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeInOut,
        );
      }
      return;
    }

    if (state.value.selectedPaymentMethod == PaymentMethod.none) {
      event.value = CheckoutEvent.errorMessage(
        LocaleKeys.checkoutSelectPaymentMethod.tr,
      );
      return;
    }

    final cartReady = await _refreshAndValidateCartForCheckout();
    if (!cartReady) return;

    final items = _selectedItemParams();
    final previewOk = await _refreshCheckoutPreview(items: items);
    if (!previewOk) return;

    final fingerprint = _checkoutFingerprint(items);
    _currentIdempotencyKey = await _resolvePendingIdempotencyKey(fingerprint);
    final purchasedItems = cartStore.selectedItems;

    state.value = state.value.copyWith(isPlacingOrder: true);
    final result = await orderService.createOrder(
      params: CreateOrderParams(
        addressId: selectedAddress.addressId,
        idempotencyKey: _currentIdempotencyKey!,
        items: items,
        paymentMethod: _backendPaymentMethod,
        userNote: noteController.text,
      ),
    );
    if (isClosed) return;
    result.fold(
      (failure) {
        _refreshCartAfterCheckoutFailure(failure);
        if (_isAddressPhoneFailure(failure)) {
          event.value = CheckoutEvent.addressPhoneVerificationRequired(
            failure,
            selectedAddress,
          );
        } else {
          event.value = CheckoutEvent.failure(failure);
        }
      },
      (order) {
        // Clear it after success
        _currentIdempotencyKey = null;
        unawaited(prefsStorage.remove(AppStorageKey.pendingCheckoutAttempt));
        cartOperations.removePurchasedLocal(purchasedItems);
        event.value = CheckoutEvent.successOrder(
          LocaleKeys.checkoutOrderConfirmed.tr,
          order.orderId,
        );
      },
    );
    state.value = state.value.copyWith(isPlacingOrder: false);
  }

  Future<bool> _refreshCheckoutPreview({List<ItemOrderParams>? items}) async {
    final selectedAddress = selectedDeliveryAddress;
    if (selectedAddress == null) return false;

    final previewItems = items ?? _selectedItemParams();
    if (previewItems.isEmpty) {
      event.value = CheckoutEvent.errorMessage(LocaleKeys.checkoutCartEmpty.tr);
      return false;
    }

    state.value = state.value.copyWith(isPreviewingOrder: true);
    final result = await orderService.previewOrder(
      params: CheckoutPreviewParams(
        addressId: selectedAddress.addressId,
        items: previewItems,
        paymentMethod: _backendPaymentMethod,
      ),
    );
    if (isClosed) return false;

    var success = false;
    result.fold(
      (failure) {
        _refreshCartAfterCheckoutFailure(failure);
        if (_isAddressPhoneFailure(failure)) {
          event.value = CheckoutEvent.addressPhoneVerificationRequired(
            failure,
            selectedAddress,
          );
        } else {
          event.value = CheckoutEvent.failure(failure);
        }
      },
      (preview) {
        state.value = state.value.copyWith(
          previewSubtotal: preview.subtotal,
          deliveryFee: preview.deliveryFee,
          previewTotal: preview.total,
        );
        success = true;
      },
    );
    state.value = state.value.copyWith(isPreviewingOrder: false);
    return success;
  }

  List<ItemOrderParams> _selectedItemParams() {
    return cartStore.selectedItems
        .map(
          (item) => ItemOrderParams(
            itemId: item.itemId,
            quantity: item.cartQuantity,
            submittedUnitPrice: _roundMoney(
              item.cartFinalUnitPrice.clamp(0.0, double.infinity),
            ),
            variantId: item.variantId,
          ),
        )
        .toList();
  }

  String _checkoutFingerprint(List<ItemOrderParams> items) {
    final normalizedItems =
        items
            .map(
              (item) => {
                'item_id': item.itemId,
                'variant_id': item.variantId,
                'quantity': item.quantity,
              },
            )
            .toList()
          ..sort((a, b) {
            final byItem = (a['item_id'] as int).compareTo(b['item_id'] as int);
            if (byItem != 0) return byItem;
            return _compareNullableInt(a['variant_id'], b['variant_id']);
          });

    return jsonEncode({
      'address_id': selectedDeliveryAddress?.addressId,
      'payment_method': _backendPaymentMethod,
      'user_note': noteController.text.trim(),
      'items': normalizedItems,
    });
  }

  int _compareNullableInt(int? a, int? b) {
    if (a == b) return 0;
    if (a == null) return -1;
    if (b == null) return 1;
    return a.compareTo(b);
  }

  Future<bool> _refreshAndValidateCartForCheckout() async {
    final refreshed = await _refreshCartNow();
    if (!refreshed) return false;
    return _validateSelectedCartForCheckout();
  }

  Future<bool> _refreshCartNow() async {
    if (state.value.isRefreshingCart) {
      event.value = CheckoutEvent.errorMessage(
        LocaleKeys.checkoutCartPendingChanges.tr,
      );
      return false;
    }

    state.value = state.value.copyWith(isRefreshingCart: true);
    try {
      final result = await cartOperations.refreshCart();
      return result.fold((failure) {
        event.value = CheckoutEvent.failure(failure);
        return false;
      }, (outcome) => outcome == CartRefreshOutcome.applied);
    } finally {
      if (!isClosed) {
        state.value = state.value.copyWith(isRefreshingCart: false);
      }
    }
  }

  bool _validateSelectedCartForCheckout() {
    final selectedItems = cartStore.selectedItems;
    final blockReason = selectedCartCheckoutBlockReason(
      selectedItems,
      hasPendingSelectedOperation: cartOperations.hasPendingCheckoutOperation,
    );
    if (blockReason == null) return true;

    event.value = CheckoutEvent.errorMessage(switch (blockReason) {
      CartCheckoutBlockReason.empty => LocaleKeys.checkoutCartEmpty.tr,
      CartCheckoutBlockReason.pendingChanges =>
        LocaleKeys.checkoutCartPendingChanges.tr,
      CartCheckoutBlockReason.needsReview =>
        LocaleKeys.checkoutCartNeedsReview.tr,
      CartCheckoutBlockReason.stockChanged =>
        LocaleKeys.checkoutCartStockChanged.tr,
    });
    return false;
  }

  void _refreshCartAfterCheckoutFailure(Failure failure) {
    final shouldRefresh = failure.maybeWhen(
      http: (key, _, __, ___, ____) => switch (key) {
        FailureKey.priceChanged ||
        FailureKey.outOfStock ||
        FailureKey.insufficientQuantity ||
        FailureKey.itemNotActive ||
        FailureKey.variantNotActive ||
        FailureKey.variantRequired ||
        FailureKey.invalidVariant ||
        FailureKey.invalidCheckoutData ||
        FailureKey.checkoutOutOfStock => true,
        _ => false,
      },
      orElse: () => false,
    );
    if (shouldRefresh) {
      unawaited(_refreshCartNow());
    }
  }

  String get _backendPaymentMethod {
    return switch (state.value.selectedPaymentMethod) {
      PaymentMethod.cash => 'cash',
      PaymentMethod.visa => 'card',
      PaymentMethod.none => 'cash',
    };
  }

  Future<String> _resolvePendingIdempotencyKey(String fingerprint) async {
    final now = DateTime.now();
    final raw = prefsStorage.getString(AppStorageKey.pendingCheckoutAttempt);
    if (raw != null) {
      try {
        final parsed = jsonDecode(raw) as Map<String, dynamic>;
        final createdAt = DateTime.tryParse(
          parsed['created_at'] as String? ?? '',
        );
        final key = parsed['key'] as String?;

        if (key != null &&
            createdAt != null &&
            now.difference(createdAt) <= _pendingAttemptTtl &&
            parsed['fingerprint'] == fingerprint) {
          return key;
        }
      } catch (_) {}
    }

    final key = 'checkout-${now.microsecondsSinceEpoch}';
    await prefsStorage.setString(
      AppStorageKey.pendingCheckoutAttempt,
      jsonEncode({
        'key': key,
        'fingerprint': fingerprint,
        'created_at': now.toIso8601String(),
      }),
    );
    return key;
  }

  double _roundMoney(double value) => (value * 100).roundToDouble() / 100.0;

  bool _isAddressPhoneFailure(Failure failure) {
    return failure.maybeWhen(
      http: (key, _, __, ___, ____) =>
          key == FailureKey.phoneRequired || key == FailureKey.phoneNotVerified,
      orElse: () => false,
    );
  }

  void finalizeOrder() {
    // Navigate immediately so the user doesn't wait.
    homeStore.resetToHome();
    Get.offAllNamed(RouteName.homeScreen);
  }

  @override
  void onClose() {
    pageController.removeListener(_onPageChanged);
    pageController.dispose();
    noteController.dispose();
    super.onClose();
  }
}
