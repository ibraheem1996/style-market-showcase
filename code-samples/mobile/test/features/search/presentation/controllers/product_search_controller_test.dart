import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:my_project/core/errors/api_result.dart';
import 'package:my_project/core/errors/failure.dart';
import 'package:my_project/core/errors/failure_key.dart';
import 'package:my_project/features/cart/domain/entities/cart_item_entity.dart';
import 'package:my_project/features/cart/presentation/operations/cart_operations.dart';
import 'package:my_project/features/cart/presentation/store/cart_store.dart';
import 'package:my_project/features/favorites/presentation/services/favorites_service.dart';
import 'package:my_project/features/products/domain/entities/pagination_entity.dart';
import 'package:my_project/features/products/domain/entities/product_badge_entity.dart';
import 'package:my_project/features/products/domain/entities/product_card_entity.dart';
import 'package:my_project/features/products/domain/entities/product_search_response_entity.dart';
import 'package:my_project/features/products/domain/usecases/search_products_usecase.dart';
import 'package:my_project/features/search/presentation/controllers/product_search_controller.dart';
import 'package:my_project/features/search/presentation/events/product_search_event.dart';
import 'package:my_project/features/search/presentation/state/product_search_state.dart';

import 'product_search_controller_test.mocks.dart';

@GenerateMocks([
  SearchProductsUseCase,
  FavoritesService,
  CartOperations,
  CartStore,
])
void main() {
  late MockSearchProductsUseCase useCase;
  late ProductSearchController controller;

  setUp(() {
    Get.testMode = true;
    useCase = MockSearchProductsUseCase();
    controller = ProductSearchController(
      searchProductsUseCase: useCase,
      audienceId: 7,
      favoritesService: MockFavoritesService(),
      cartOperations: MockCartOperations(),
      cartStore: MockCartStore(),
    );
  });

  tearDown(() {
    controller.onClose();
    Get.reset();
  });

  test('normalizes trim and repeated Unicode whitespace', () {
    expect(
      ProductSearchController.normalizeQuery(' \tقميص\u2003   أحمر\n '),
      'قميص أحمر',
    );
  });

  test('does not request before the two-character minimum', () {
    fakeAsync((async) {
      controller.onQueryChanged('ق');
      async.elapse(ProductSearchController.debounceDuration);

      verifyNever(
        useCase(
          audienceId: anyNamed('audienceId'),
          query: anyNamed('query'),
          page: anyNamed('page'),
          limit: anyNamed('limit'),
        ),
      );
      expect(
        controller.state.value.maybeWhen(
          initial: (isLongQuery) => isLongQuery,
          orElse: () => false,
        ),
        false,
      );
    });
  });

  test('debounces a valid query and forwards the route audience', () {
    fakeAsync((async) {
      when(
        useCase(
          audienceId: anyNamed('audienceId'),
          query: anyNamed('query'),
          page: anyNamed('page'),
          limit: anyNamed('limit'),
        ),
      ).thenAnswer((_) async => Right(_response([_card(1, null)])));

      controller.onQueryChanged(' shirt ');
      async.elapse(
        ProductSearchController.debounceDuration -
            const Duration(milliseconds: 1),
      );
      verifyNever(
        useCase(
          audienceId: anyNamed('audienceId'),
          query: anyNamed('query'),
          page: anyNamed('page'),
          limit: anyNamed('limit'),
        ),
      );

      async.elapse(const Duration(milliseconds: 1));
      async.flushMicrotasks();

      verify(
        useCase(audienceId: 7, query: 'shirt', page: 1, limit: 16),
      ).called(1);
    });
  });

  test('submit cancels debounce and searches the normalized query', () async {
    when(
      useCase(
        audienceId: anyNamed('audienceId'),
        query: anyNamed('query'),
        page: anyNamed('page'),
        limit: anyNamed('limit'),
      ),
    ).thenAnswer((_) async => Right(_response([_card(1, null)])));

    controller.textController.text = '  shirt  ';
    controller.onQueryChanged(controller.textController.text);
    await controller.submit();
    await controller.submit();

    verify(
      useCase(audienceId: 7, query: 'shirt', page: 1, limit: 16),
    ).called(2);
  });

  test('a slower old response cannot replace the newer query', () async {
    final oldResult = Completer<ApiResult<ProductSearchResponseEntity>>();
    final newResult = Completer<ApiResult<ProductSearchResponseEntity>>();
    when(
      useCase(audienceId: 7, query: 'old', page: 1, limit: 16),
    ).thenAnswer((_) => oldResult.future);
    when(
      useCase(audienceId: 7, query: 'new', page: 1, limit: 16),
    ).thenAnswer((_) => newResult.future);

    controller.textController.text = 'old';
    final oldRequest = controller.submit();
    controller.textController.text = 'new';
    final newRequest = controller.submit();

    newResult.complete(Right(_response([_card(2, 4)])));
    await newRequest;
    oldResult.complete(Right(_response([_card(1, null)])));
    await oldRequest;

    final ids = controller.state.value.maybeWhen(
      results: (_, items, __, ___, ____) =>
          items.map((item) => item.itemId).toList(),
      orElse: () => <int>[],
    );
    expect(ids, [2]);
  });

  test('an invalidated A request does not block a new A first page', () {
    fakeAsync((async) {
      final firstA = Completer<ApiResult<ProductSearchResponseEntity>>();
      final secondA = Completer<ApiResult<ProductSearchResponseEntity>>();
      var aRequestCount = 0;
      when(
        useCase(audienceId: 7, query: 'alpha', page: 1, limit: 16),
      ).thenAnswer((_) {
        return [firstA.future, secondA.future][aRequestCount++];
      });

      controller.textController.text = 'alpha';
      unawaited(controller.submit());
      controller.onQueryChanged('beta');
      controller.onQueryChanged('alpha');
      async.elapse(ProductSearchController.debounceDuration);
      async.flushMicrotasks();

      verify(
        useCase(audienceId: 7, query: 'alpha', page: 1, limit: 16),
      ).called(2);
      expect(
        controller.state.value.maybeWhen(
          loading: (query) => query,
          orElse: () => null,
        ),
        'alpha',
      );

      secondA.complete(Right(_response([_card(3, null)])));
      async.flushMicrotasks();
      firstA.complete(Right(_response([_card(1, null)])));
      async.flushMicrotasks();

      final ids = controller.state.value.maybeWhen(
        results: (_, items, __, ___, ____) =>
            items.map((item) => item.itemId).toList(),
        orElse: () => <int>[],
      );
      expect(ids, [3]);
    });
  });

  test(
    'an invalidated A pagination request does not block a new A first page',
    () {
      fakeAsync((async) {
        final nextPage = Completer<ApiResult<ProductSearchResponseEntity>>();
        final latestA = Completer<ApiResult<ProductSearchResponseEntity>>();
        var firstPageARequestCount = 0;
        when(
          useCase(audienceId: 7, query: 'alpha', page: 1, limit: 16),
        ).thenAnswer((_) {
          firstPageARequestCount++;
          if (firstPageARequestCount == 1) {
            return Future.value(
              Right(_response([_card(1, null)], page: 1, hasMore: true)),
            );
          }
          return latestA.future;
        });
        when(
          useCase(audienceId: 7, query: 'alpha', page: 2, limit: 16),
        ).thenAnswer((_) => nextPage.future);
        controller.textController.text = 'alpha';
        unawaited(controller.submit());
        async.flushMicrotasks();
        unawaited(controller.loadNextPage());
        controller.onQueryChanged('beta');
        controller.onQueryChanged('alpha');
        async.elapse(ProductSearchController.debounceDuration);
        async.flushMicrotasks();

        verify(
          useCase(audienceId: 7, query: 'alpha', page: 1, limit: 16),
        ).called(2);
        expect(
          controller.state.value.maybeWhen(
            loading: (query) => query,
            orElse: () => null,
          ),
          'alpha',
        );

        latestA.complete(Right(_response([_card(3, null)])));
        async.flushMicrotasks();
        nextPage.complete(Right(_response([_card(4, null)], page: 2)));
        async.flushMicrotasks();

        final snapshot = controller.state.value.maybeWhen(
          results: (_, items, __, isLoadingMore, ___) =>
              (items.map((item) => item.itemId).toList(), isLoadingMore),
          orElse: () => (<int>[], true),
        );
        expect(snapshot.$1, [3]);
        expect(snapshot.$2, isFalse);
      });
    },
  );

  test(
    'accepts a normalized query containing exactly 100 characters',
    () async {
      final query = List.filled(100, 'a').join();
      when(
        useCase(audienceId: 7, query: query, page: 1, limit: 16),
      ).thenAnswer((_) async => Right(_response([_card(1, null)])));

      controller.textController.text = '  $query  ';
      await controller.submit();

      verify(
        useCase(audienceId: 7, query: query, page: 1, limit: 16),
      ).called(1);
    },
  );

  test(
    'rejects a normalized query longer than 100 characters locally',
    () async {
      controller.textController.text = '  ${List.filled(101, 'a').join()}  ';

      await controller.submit();

      verifyNever(
        useCase(
          audienceId: anyNamed('audienceId'),
          query: anyNamed('query'),
          page: anyNamed('page'),
          limit: anyNamed('limit'),
        ),
      );
      expect(
        controller.event.value?.whenOrNull(
          interactionFailure: (failure) => failure.whenOrNull(
            http: (_, __, ___, ____, errorCode) =>
                errorCode == ProductSearchController.queryTooLongErrorCode,
          ),
        ),
        isTrue,
      );
      expect(
        controller.state.value.maybeWhen(
          initial: (isLongQuery) => isLongQuery,
          orElse: () => false,
        ),
        isTrue,
      );
    },
  );

  test('reports an overlong typing run only once until it is valid', () {
    controller.onQueryChanged(List.filled(101, 'a').join());
    expect(controller.event.value, isNotNull);

    controller.clearEvent();
    controller.onQueryChanged(List.filled(102, 'a').join());
    expect(controller.event.value, isNull);

    controller.onQueryChanged(List.filled(100, 'a').join());
    controller.onQueryChanged(List.filled(101, 'a').join());
    expect(controller.event.value, isNotNull);
    verifyNever(
      useCase(
        audienceId: anyNamed('audienceId'),
        query: anyNamed('query'),
        page: anyNamed('page'),
        limit: anyNamed('limit'),
      ),
    );
  });

  test(
    'pagination keeps existing cards and deduplicates card identity',
    () async {
      when(
        useCase(audienceId: 7, query: 'shirt', page: 1, limit: 16),
      ).thenAnswer(
        (_) async => Right(
          _response([_card(1, null), _card(2, 4)], page: 1, hasMore: true),
        ),
      );
      when(
        useCase(audienceId: 7, query: 'shirt', page: 2, limit: 16),
      ).thenAnswer(
        (_) async => Right(_response([_card(2, 4), _card(2, 8)], page: 2)),
      );

      controller.textController.text = 'shirt';
      await controller.submit();
      await controller.loadNextPage();

      final keys = controller.state.value.maybeWhen(
        results: (_, items, __, ___, ____) =>
            items.map((item) => '${item.itemId}:${item.colorGroupId}').toList(),
        orElse: () => <String>[],
      );
      expect(keys, ['1:null', '2:4', '2:8']);
    },
  );

  test(
    'page-two failure preserves the first page and exposes retry state',
    () async {
      when(
        useCase(audienceId: 7, query: 'shirt', page: 1, limit: 16),
      ).thenAnswer(
        (_) async => Right(_response([_card(1, null)], page: 1, hasMore: true)),
      );
      when(
        useCase(audienceId: 7, query: 'shirt', page: 2, limit: 16),
      ).thenAnswer(
        (_) async => Left(Failure.http(key: FailureKey.serverGeneric)),
      );

      controller.textController.text = 'shirt';
      await controller.submit();
      await controller.loadNextPage();

      final snapshot = controller.state.value.maybeWhen(
        results: (_, items, __, ___, failure) => (items, failure),
        orElse: () => (<ProductCardEntity>[], null),
      );
      expect(snapshot.$1.map((item) => item.itemId), [1]);
      expect(snapshot.$2, isNotNull);
    },
  );

  test(
    'favorite delegates the exact product and representative variant',
    () async {
      final item = _card(2, 4);
      final favorites = MockFavoritesService();
      controller.onClose();
      controller = ProductSearchController(
        searchProductsUseCase: useCase,
        audienceId: 7,
        favoritesService: favorites,
        cartOperations: MockCartOperations(),
        cartStore: MockCartStore(),
      );
      when(
        favorites.toggle(2, variantId: 20),
      ).thenAnswer((_) async => const Right(ToggleFavoriteResult.added));

      await controller.toggleFavorite(item);

      verify(favorites.toggle(2, variantId: 20)).called(1);
    },
  );

  test('cart delegates the exact product and representative variant', () async {
    final item = _card(2, 4);
    final cartOperations = MockCartOperations();
    controller.onClose();
    controller = ProductSearchController(
      searchProductsUseCase: useCase,
      audienceId: 7,
      favoritesService: MockFavoritesService(),
      cartOperations: cartOperations,
      cartStore: MockCartStore(),
    );
    when(
      cartOperations.upsertInput(any, quantityDelta: anyNamed('quantityDelta')),
    ).thenAnswer((_) async => const Right(CartAction.added));

    await controller.addToCart(item);

    final captured = verify(
      cartOperations.upsertInput(
        captureAny,
        quantityDelta: captureAnyNamed('quantityDelta'),
      ),
    ).captured;
    expect(captured.first.itemId, 2);
    expect(captured.first.variantId, 20);
    expect(captured.last, 1);
  });
}

ProductSearchResponseEntity _response(
  List<ProductCardEntity> items, {
  int page = 1,
  bool hasMore = false,
}) {
  return ProductSearchResponseEntity(
    items: items,
    pagination: PaginationEntity(
      page: page,
      limit: 16,
      total: items.length,
      hasMore: hasMore,
    ),
  );
}

ProductCardEntity _card(int itemId, int? colorGroupId) {
  return ProductCardEntity(
    itemId: itemId,
    itemNameAr: 'منتج $itemId',
    itemNameEn: 'Product $itemId',
    displayPrice: 10,
    originalPrice: 10,
    hasDiscount: false,
    maxDiscountPct: 0,
    itemDisplayImage: '',
    availableColors: const [],
    availableSizes: const [],
    isFeatured: false,
    representativeVariantId: colorGroupId == null ? null : itemId * 10,
    colorGroupId: colorGroupId,
    images: const [],
    stockQuantity: 3,
    badges: const <ProductBadgeEntity>[],
  );
}
