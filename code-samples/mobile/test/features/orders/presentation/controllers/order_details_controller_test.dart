import 'dart:async';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_project/core/errors/api_result.dart';
import 'package:my_project/core/errors/failure.dart';
import 'package:my_project/core/errors/failure_key.dart';
import 'package:my_project/features/auth/session/session_service.dart';
import 'package:my_project/features/orders/domain/entities/checkout_preview_entity.dart';
import 'package:my_project/features/orders/domain/entities/order_details_entity.dart';
import 'package:my_project/features/orders/domain/entities/order_item_entity.dart';
import 'package:my_project/features/orders/domain/entities/order_status.dart';
import 'package:my_project/features/orders/domain/entities/order_summary_entity.dart';
import 'package:my_project/features/orders/domain/params/create_order_params.dart';
import 'package:my_project/features/orders/domain/params/order_action_params.dart';
import 'package:my_project/features/orders/domain/repositories/orders_repository.dart';
import 'package:my_project/features/orders/domain/usecases/cancel_order_usecase.dart';
import 'package:my_project/features/orders/domain/usecases/create_order_usecase.dart';
import 'package:my_project/features/orders/domain/usecases/get_order_details_usecase.dart';
import 'package:my_project/features/orders/domain/usecases/preview_order_usecase.dart';
import 'package:my_project/features/orders/domain/usecases/submit_order_note_usecase.dart';
import 'package:my_project/features/orders/presentation/controllers/order_details_controller.dart';
import 'package:my_project/features/orders/presentation/controllers/order_details_ui_event.dart';
import 'package:my_project/features/orders/presentation/services/order_service.dart';
import 'package:my_project/features/orders/presentation/state/order_state.dart';

void main() {
  late _FakeSessionService sessionService;

  setUp(() {
    sessionService = _FakeSessionService();
  });

  tearDown(() async {
    await sessionService.close();
  });

  test('controller source contains no direct Get UI side effects', () {
    final source = File(
      'lib/features/orders/presentation/controllers/order_details_controller.dart',
    ).readAsStringSync();

    expect(source, isNot(contains('Get.snackbar')));
    expect(source, isNot(contains('Get.dialog')));
    expect(source, isNot(contains('Get.bottomSheet')));
    expect(source, isNot(contains('Get.back')));
  });

  test('submit note success emits event and refreshes details once', () async {
    final repository = _FakeOrdersRepository();
    final refreshCompleter = Completer<ApiResult<OrderDetailsEntity>>();
    repository.detailsResult = refreshCompleter.future;
    final controller = _controller(repository, sessionService);
    controller.state.value = OrderState.success(_order());

    final submitFuture = controller.submitOrderNote('  Leave at door  ');
    await Future<void>.delayed(Duration.zero);

    expect(repository.submitCalls, 1);
    expect(repository.submittedNote, 'Leave at door');
    expect(repository.getDetailsCalls, 1);
    expect(controller.uiEvent.value, isA<OrderDetailsNoteSucceededEvent>());

    refreshCompleter.complete(right(_order(canSubmitNote: false)));
    await submitFuture;
    expect(controller.isSubmittingNote.value, isFalse);
    controller.state.value.maybeWhen(
      success: (order) {
        expect(order.hasUserNote, isTrue);
        expect(order.canSubmitNote, isFalse);
        expect(order.availableActions, ['cancel']);
      },
      orElse: () => fail('Expected success state'),
    );
  });

  test(
    'submit note generic failure emits error event without refresh',
    () async {
      final repository = _FakeOrdersRepository()
        ..submitResult = Future.value(
          left(const Failure.http(key: FailureKey.networkTimeout)),
        );
      final controller = _controller(repository, sessionService);
      controller.state.value = OrderState.success(_order());

      await controller.submitOrderNote('Retry later');

      expect(repository.submitCalls, 1);
      expect(repository.getDetailsCalls, 0);
      expect(controller.uiEvent.value, isA<OrderDetailsActionFailedEvent>());
    },
  );

  test(
    'submit note availability failure emits event and refreshes details',
    () async {
      final repository = _FakeOrdersRepository()
        ..submitResult = Future.value(
          left(const Failure.http(key: FailureKey.orderNoteAlreadySubmitted)),
        );
      final controller = _controller(repository, sessionService);
      controller.state.value = OrderState.success(_order());

      await controller.submitOrderNote('Already sent');

      expect(repository.getDetailsCalls, 1);
      expect(
        controller.uiEvent.value,
        isA<OrderDetailsActionUnavailableEvent>(),
      );
    },
  );

  test('cancel success emits event and refreshes details once', () async {
    final repository = _FakeOrdersRepository();
    final refreshCompleter = Completer<ApiResult<OrderDetailsEntity>>();
    repository.detailsResult = refreshCompleter.future;
    final controller = _controller(repository, sessionService);
    controller.state.value = OrderState.success(_order());

    final cancelFuture = controller.cancelOrder(reason: '  changed mind  ');
    await Future<void>.delayed(Duration.zero);

    expect(repository.cancelCalls, 1);
    expect(repository.cancelReason, 'changed mind');
    expect(repository.getDetailsCalls, 1);
    expect(controller.uiEvent.value, isA<OrderDetailsCancelSucceededEvent>());

    refreshCompleter.complete(right(_order(canCancel: false)));
    await cancelFuture;
    expect(controller.isCancelling.value, isFalse);
    controller.state.value.maybeWhen(
      success: (order) {
        expect(order.canCancel, isFalse);
      },
      orElse: () => fail('Expected success state'),
    );
  });

  test('cancel not allowed emits event and refreshes details', () async {
    final repository = _FakeOrdersRepository()
      ..cancelResult = Future.value(
        left(const Failure.http(key: FailureKey.orderNotCancelable)),
      );
    final controller = _controller(repository, sessionService);
    controller.state.value = OrderState.success(_order());

    await controller.cancelOrder(reason: '');

    expect(repository.cancelCalls, 1);
    expect(repository.cancelReason, isNull);
    expect(repository.getDetailsCalls, 1);
    expect(controller.uiEvent.value, isA<OrderDetailsActionUnavailableEvent>());
  });

  test('submit note ignores duplicate request while loading', () async {
    final repository = _FakeOrdersRepository();
    final submitCompleter = Completer<ApiResult<void>>();
    repository.submitResult = submitCompleter.future;
    final controller = _controller(repository, sessionService);
    controller.state.value = OrderState.success(_order());

    final first = controller.submitOrderNote('First');
    final second = controller.submitOrderNote('Second');
    await Future<void>.delayed(Duration.zero);

    expect(repository.submitCalls, 1);
    expect(controller.isSubmittingNote.value, isTrue);

    submitCompleter.complete(
      left(const Failure.http(key: FailureKey.serverGeneric)),
    );
    await Future.wait([first, second]);
    expect(controller.isSubmittingNote.value, isFalse);
  });

  test(
    'authenticated Session transition refreshes retained details once',
    () async {
      final repository = _FakeOrdersRepository();
      final controller = _controller(repository, sessionService);
      controller.onReady();

      sessionService.authenticate();
      await Future<void>.delayed(Duration.zero);

      expect(repository.getDetailsCalls, 1);
      controller.onClose();

      sessionService.emitAuthenticatedChange();
      await Future<void>.delayed(Duration.zero);

      expect(repository.getDetailsCalls, 1);
    },
  );
}

OrderDetailsController _controller(
  _FakeOrdersRepository repository,
  SessionService sessionService,
) {
  final controller = OrderDetailsController(
    getOrderDetailsUseCase: GetOrderDetailsUseCase(repository),
    orderService: _orderService(repository),
    sessionService: sessionService,
  );
  controller.orderId = 101;
  return controller;
}

class _FakeSessionService extends Fake implements SessionService {
  final _changes = StreamController<int>.broadcast();
  bool _isAuthenticated = false;
  int _version = 0;

  @override
  bool get isAuthenticated => _isAuthenticated;

  @override
  Stream<int> get sessionChanges => _changes.stream;

  void authenticate() {
    _isAuthenticated = true;
    emitAuthenticatedChange();
  }

  void emitAuthenticatedChange() {
    _changes.add(++_version);
  }

  Future<void> close() => _changes.close();
}

OrderService _orderService(_FakeOrdersRepository repository) {
  return OrderService(
    createOrderUseCase: CreateOrderUseCase(repository),
    previewOrderUseCase: PreviewOrderUseCase(repository),
    cancelOrderUseCase: CancelOrderUseCase(repository),
    submitOrderNoteUseCase: SubmitOrderNoteUseCase(repository),
  );
}

OrderDetailsEntity _order({bool canCancel = true, bool canSubmitNote = true}) {
  return OrderDetailsEntity(
    orderId: 101,
    orderStatus: OrderStatus.processing,
    finalOrderTotal: 23,
    subtotal: 20,
    deliveryFee: 3,
    totalOrderDiscount: 0,
    totalOrderDiscountPercentage: 0,
    paymentMethod: 'cash',
    paymentStatus: 'unpaid',
    canCancel: canCancel,
    canSubmitNote: canSubmitNote,
    hasUserNote: !canSubmitNote,
    availableActions: [
      if (canCancel) 'cancel',
      if (canSubmitNote) 'submit_note',
    ],
    address: const OrderAddressEntity(
      cityAr: 'عمّان',
      cityEn: 'Amman',
      areaAr: 'الصويفية',
      areaEn: 'Sweifieh',
      street: 'Main',
      phone: '+962790000000',
    ),
    items: const [],
  );
}

class _FakeOrdersRepository implements OrdersRepository {
  int getDetailsCalls = 0;
  int cancelCalls = 0;
  int submitCalls = 0;
  String? cancelReason;
  String? submittedNote;

  Future<ApiResult<OrderDetailsEntity>> detailsResult = Future.value(
    right(_order()),
  );
  Future<ApiResult<void>> cancelResult = Future.value(right(null));
  Future<ApiResult<void>> submitResult = Future.value(right(null));

  @override
  Future<ApiResult<OrderDetailsEntity>> getOrderDetails(int orderId) {
    getDetailsCalls++;
    return detailsResult;
  }

  @override
  Future<ApiResult<void>> cancelOrder(CancelOrderParams params) {
    cancelCalls++;
    cancelReason = params.reason?.trim();
    if (cancelReason?.isEmpty == true) {
      cancelReason = null;
    }
    return cancelResult;
  }

  @override
  Future<ApiResult<void>> submitOrderNote(SubmitOrderNoteParams params) {
    submitCalls++;
    submittedNote = params.note;
    return submitResult;
  }

  @override
  Future<ApiResult<CreateOrderResultEntity>> createOrder(
    CreateOrderParams params,
  ) async {
    throw UnimplementedError();
  }

  @override
  Future<ApiResult<CheckoutPreviewEntity>> previewOrder(
    CheckoutPreviewParams params,
  ) async {
    throw UnimplementedError();
  }

  @override
  Future<ApiResult<List<OrderSummaryEntity>>> getOrders() async {
    throw UnimplementedError();
  }
}
