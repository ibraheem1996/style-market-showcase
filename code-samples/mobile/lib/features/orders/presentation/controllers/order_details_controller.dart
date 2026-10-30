import 'dart:async';

import 'package:get/get.dart';

import '../../../../core/errors/app_failure_key.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/errors/failure_key.dart';
import '../../../../core/navigation/order_details_route_args.dart';
import '../../../../core/translations/locale_keys.dart';
import '../../../auth/session/session_service.dart';
import '../../domain/params/order_action_params.dart';
import '../../domain/usecases/get_order_details_usecase.dart';
import '../services/order_service.dart';
import '../state/order_state.dart';
import 'order_details_ui_event.dart';

class OrderDetailsController extends GetxController {
  final GetOrderDetailsUseCase getOrderDetailsUseCase;
  final OrderService orderService;
  final SessionService sessionService;

  final state = const OrderState.initial().obs;
  final isCancelling = false.obs;
  final isSubmittingNote = false.obs;
  final uiEvent = Rxn<OrderDetailsUiEvent>();
  OrderDetailsRouteArgs? routeArgs;

  OrderDetailsController({
    required this.getOrderDetailsUseCase,
    required this.orderService,
    required this.sessionService,
  });

  int? orderId;
  StreamSubscription<int>? _sessionSubscription;

  @override
  void onInit() {
    super.onInit();

    final arguments = Get.arguments;

    if (arguments is! OrderDetailsRouteArgs) {
      _setInvalidArgumentError();
      return;
    }

    routeArgs = arguments;
    orderId = arguments.orderId;
    fetchOrderDetails();
  }

  @override
  void onReady() {
    super.onReady();
    _sessionSubscription = sessionService.sessionChanges.listen((_) {
      if (sessionService.isAuthenticated && orderId != null) {
        unawaited(fetchOrderDetails());
      }
    });
  }

  @override
  void onClose() {
    _sessionSubscription?.cancel();
    super.onClose();
  }

  void clearUiEvent() {
    uiEvent.value = null;
  }

  Future<void> fetchOrderDetails({bool showLoading = true}) async {
    final id = orderId;

    if (id == null) {
      _setInvalidArgumentError();
      return;
    }

    if (showLoading) {
      state.value = const OrderState.loading();
    }

    final result = await getOrderDetailsUseCase(id);

    if (isClosed) return;

    result.fold(
      (failure) {
        state.value = OrderState.error(failure);
      },
      (order) {
        state.value = OrderState.success(order);
      },
    );
  }

  Future<void> cancelOrder({String? reason}) async {
    final id = orderId;

    if (id == null || isCancelling.value) {
      return;
    }

    final trimmedReason = reason?.trim();
    final normalizedReason = trimmedReason == null || trimmedReason.isEmpty
        ? null
        : trimmedReason;

    isCancelling.value = true;

    try {
      final result = await orderService.cancelOrder(
        params: CancelOrderParams(orderId: id, reason: normalizedReason),
      );

      if (isClosed) return;

      await result.fold(
        (failure) async {
          await _emitActionFailure(failure);
        },
        (_) async {
          uiEvent.value = const OrderDetailsCancelSucceededEvent();

          await fetchOrderDetails(showLoading: false);
        },
      );
    } finally {
      if (!isClosed) {
        isCancelling.value = false;
      }
    }
  }

  Future<void> submitOrderNote(String noteText) async {
    final id = orderId;

    if (id == null || isSubmittingNote.value) {
      return;
    }

    final note = noteText.trim();

    if (note.isEmpty) {
      uiEvent.value = const OrderDetailsMessageEvent(
        LocaleKeys.ordersNoteRequired,
      );
      return;
    }

    isSubmittingNote.value = true;

    try {
      final result = await orderService.submitOrderNote(
        params: SubmitOrderNoteParams(orderId: id, note: note),
      );

      if (isClosed) return;

      await result.fold(
        (failure) async {
          await _emitActionFailure(failure);
        },
        (_) async {
          uiEvent.value = const OrderDetailsNoteSucceededEvent();

          await fetchOrderDetails(showLoading: false);
        },
      );
    } finally {
      if (!isClosed) {
        isSubmittingNote.value = false;
      }
    }
  }

  Future<void> _emitActionFailure(Failure failure) async {
    if (_isUnavailableActionFailure(failure)) {
      uiEvent.value = OrderDetailsActionUnavailableEvent(failure);
      await fetchOrderDetails(showLoading: false);
      return;
    }

    uiEvent.value = OrderDetailsActionFailedEvent(failure);
  }

  bool _isUnavailableActionFailure(Failure failure) {
    return failure.maybeWhen(
      http: (key, _, __, ___, ____) {
        return key == FailureKey.orderNotCancelable ||
            key == FailureKey.orderNoteAlreadySubmitted ||
            key == FailureKey.orderNoteNotAllowed;
      },
      orElse: () => false,
    );
  }

  void _setInvalidArgumentError() {
    state.value = OrderState.error(
      Failure.app(key: AppFailureKey.invalidArgument),
    );
  }
}
