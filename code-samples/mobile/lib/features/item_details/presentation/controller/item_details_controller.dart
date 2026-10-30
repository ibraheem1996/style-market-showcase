import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_project/core/errors/failure.dart';
import 'package:my_project/features/favorites/presentation/services/favorites_service.dart';
import '../../../../core/errors/app_failure_key.dart';
import '../../../../core/navigation/items_details_route_args.dart';
import '../../../../core/translations/locale_keys.dart';
import '../../../../core/services/logger_service.dart';
import '../../../cart/domain/entities/cart_item_entity.dart';
import '../../../cart/presentation/extensions/cart_upsert_input_extensions.dart';
import '../../../cart/presentation/operations/cart_operations.dart';
import '../../../recently_viewed/presentation/services/recently_viewed_service.dart';
import '../../../cart/presentation/store/cart_store.dart';
import '../../../products/domain/entities/item_entity.dart';
import '../../../products/domain/entities/item_entity_extensions.dart';
import '../../../products/domain/entities/product_card_entity.dart';
import '../../domain/usecases/get_item_details_usecase.dart';
import '../event/item_details_event.dart';
import '../services/item_details_recommended_service.dart';
import '../state/item_details_data.dart';
import '../state/item_details_state.dart';
import '../logic/item_details_selector.dart';

class ItemDetailsController extends GetxController {
  final GetItemDetailsUseCase _getItemDetailsUseCase;
  final RecentlyViewedService _recentlyViewedService;
  final ItemsDetailsRouteArgs _args;
  final FavoritesService _favoritesService;
  final CartOperations _cartOperations;
  final CartStore _cartStore;
  final ItemDetailsRecommendedService recommendedService;

  ItemDetailsController({
    required GetItemDetailsUseCase getItemDetailsUseCase,
    required RecentlyViewedService recentlyViewedService,
    required ItemsDetailsRouteArgs args,
    required FavoritesService favoritesService,
    required CartOperations cartOperations,
    required CartStore cartStore,
    required this.recommendedService,
  }) : _getItemDetailsUseCase = getItemDetailsUseCase,
       _recentlyViewedService = recentlyViewedService,
       _args = args,
       _favoritesService = favoritesService,
       _cartOperations = cartOperations,
       _cartStore = cartStore;

  final state = const ItemDetailsState.initial().obs;
  final data = ItemDetailsData().obs;
  final events = Rxn<ItemDetailsEvent>();

  late final PageController pageController;
  bool _pageControllerReady = false;
  int _loadGeneration = 0;
  int? _activeLoadItemId;
  bool _didClose = false;
  bool _didRecordView = false;

  int get itemId => _args.itemId;

  int? get variantId => data.value.selectedVariant?.variantId;

  List<VariantEntity> get _variants =>
      state.value.maybeWhen(loaded: (item) => item.variants, orElse: () => []);

  ItemEntity get item => state.value.maybeWhen(
    loaded: (item) => item,
    orElse: () => ItemEntity.empty(),
  );

  String get heroTag => _args.heroTag;

  int stock() => resolveAvailableStock(
    item: item,
    variant: data.value.selectedVariant,
    cartQuantity: cartQuantityById(),
  );

  bool get isAddingToCart =>
      _cartOperations.isLineOperationInFlight(item.itemId, variantId);

  bool get isFavorite => _favoritesService.isFavorite(
    itemId,
    data.value.selectedVariant?.variantId,
  );

  bool get isFavoriteLoading => _favoritesService.isTogglePending(
    itemId,
    data.value.selectedVariant?.variantId,
  );

  bool get canToggleFavorite => _favoritesService.canToggle(
    itemId,
    data.value.selectedVariant?.variantId,
  );

  bool isRecommendedFavorite(ProductCardEntity item) {
    return _favoritesService.isFavorite(
      item.itemId,
      item.representativeVariantId,
    );
  }

  bool isRecommendedFavoritePending(ProductCardEntity item) {
    return _favoritesService.isTogglePending(
      item.itemId,
      item.representativeVariantId,
    );
  }

  bool canToggleRecommendedFavorite(ProductCardEntity item) {
    return _favoritesService.canToggle(
      item.itemId,
      item.representativeVariantId,
    );
  }

  // ---------------- lifecycle ----------------

  @override
  void onInit() {
    super.onInit();
    pageController = PageController();
    _pageControllerReady = true;
    if (_args.itemId <= 0 ||
        _args.heroTag.trim().isEmpty ||
        (_args.variantId != null && _args.variantId! <= 0)) {
      state.value = const ItemDetailsState.error(
        Failure.app(key: AppFailureKey.invalidArgument),
      );
      return;
    }
    load();
  }

  @override
  void onClose() {
    _didClose = true;
    _loadGeneration++;
    recommendedService.reset();

    if (_pageControllerReady) {
      pageController.dispose();
    }
    super.onClose();
  }

  // ---------------- public actions ----------------

  Future<void> load() async {
    if (state.value.maybeWhen(loading: () => true, orElse: () => false)) {
      return;
    }

    final requestedItemId = _args.itemId;
    final generation = ++_loadGeneration;
    _activeLoadItemId = requestedItemId;
    state.value = const ItemDetailsState.loading();

    final result = await _getItemDetailsUseCase(
      GetItemDetailsParams(itemId: requestedItemId),
    );

    if (!_isCurrentLoad(generation, requestedItemId)) return;

    result.fold(
      (failure) {
        state.value = ItemDetailsState.error(failure);
      },
      ((item) {
        state.value = ItemDetailsState.loaded(item);
        final initialVariant = defaultVariant(item, _args.variantId);
        _applyVariant(initialVariant);
        unawaited(
          recommendedService.fetchFirstPage(
            itemId: item.itemId,
            audienceId: item.targetAudienceId,
          ),
        );
        _recordSuccessfulOpen(
          itemId: requestedItemId,
          initialVariant: initialVariant,
          generation: generation,
        );
      }),
    );
  }

  void _recordSuccessfulOpen({
    required int itemId,
    required VariantEntity? initialVariant,
    required int generation,
  }) {
    if (_didRecordView) return;
    _didRecordView = true;

    _recentlyViewedService
        .recordView(
          itemId: itemId,
          colorGroupId: initialVariant?.colorGroupId ?? _args.colorGroupId,
        )
        .then((result) {
          if (!_isCurrentLoad(generation, itemId)) return;
          result.fold(
            (failure) => LoggerService.error(
              'RecordRecentlyViewed failed',
              failure,
              null,
            ),
            (_) {},
          );
        });
  }

  void selectColor(String colorCode) {
    final normalized = colorCode.trim().toLowerCase();
    if (normalized.isEmpty) return;
    if (normalized == data.value.selectedColorCode.toLowerCase().trim()) {
      return;
    }

    final match = variantForColor(_variants, normalized);

    if (match == null) return;

    _applyVariant(match);
  }

  void selectSize(String sizeLabel) {
    final selectedColor = data.value.selectedColorCode.trim().toLowerCase();
    final selectedSize = data.value.selectedSize.trim().toLowerCase();
    final targetSize = sizeLabel.trim().toLowerCase();

    if (selectedSize == targetSize) return;

    final match = variantForSize(
      _variants,
      colorCode: selectedColor,
      sizeLabel: targetSize,
    );

    if (match == null) return;

    _applyVariant(match);
  }

  // ---------------- private helpers ----------------

  void onPageChanged(int index) {
    if (index == data.value.pageIndex) return;
    data.value = data.value.copyWith(pageIndex: index);
  }

  void _applyVariant(VariantEntity? variant) {
    // For variant items, do not apply a null variant — wait for user selection.
    if (item.variants.isNotEmpty && variant == null) return;

    final availableStock = resolveAvailableStock(
      item: item,
      variant: variant,
      cartQuantity: cartQuantityById(),
    );
    final images = resolveImages(variant: variant, item: item);
    final imagesChanged = !listEquals(data.value.images, images);
    final variantChanged =
        data.value.selectedVariant?.variantId != variant?.variantId;
    final resetGallery = imagesChanged || variantChanged;
    data.value = data.value.copyWith(
      quantity: clampItemDetailsQuantity(1, availableStock),
      selectedVariant: variant,
      selectedColorCode: variant?.colorHex ?? "",
      selectedColorLabel: variant?.displayColor ?? "",
      selectedSize: variant?.displaySize ?? "",
      images: images,
      pageIndex: resetGallery ? 0 : data.value.pageIndex,
      price: resolvePrice(variant: variant, item: item),
    );
    if (resetGallery && _pageControllerReady && pageController.hasClients) {
      pageController.jumpToPage(0);
    }
  }

  // ---------------- actions ----------------

  void toggleFavorite(int itemId, int? variantId, String name) async {
    final result = await _favoritesService.toggle(itemId, variantId: variantId);
    result.fold(
      (failure) => events.value = ItemDetailsEvent.errToggleFav(failure),
      (r) {
        final isAdded = r == ToggleFavoriteResult.added;
        events.value = ItemDetailsEvent.toggleFavSuccess(
          isAdded
              ? LocaleKeys.addedToFavorites.tr
              : LocaleKeys.removedFromFavorites.tr,
        );
      },
    );
  }

  Future<void> addToCart({
    required int quantity,
    required ItemEntity item,
    VariantEntity? variant,
  }) async {
    if (isAddingToCart) return;

    final hasVariants = item.variants.isNotEmpty;
    if (hasVariants && variant == null) {
      events.value = ItemDetailsEvent.errUpdateCart(
        LocaleKeys.selectVariant.tr,
      );
      return;
    }

    _applyVariant(variant);
    final currentStock = stock();
    if (currentStock <= 0 || quantity <= 0 || currentStock < quantity) {
      events.value = ItemDetailsEvent.errUpdateCart(LocaleKeys.outOfStock.tr);
      return;
    }
    final input = item.toCartUpsertInput(variant: variant);

    final result = await _cartOperations.upsertInput(
      input,
      quantityDelta: quantity,
    );
    result.fold(
      (failure) => events.value = ItemDetailsEvent.errAddToCart(failure),
      (r) {
        events.value = ItemDetailsEvent.addToCartSuccess(_messageForAction(r));
      },
    );
  }

  set updateQuantity(int quantity) {
    data.value = data.value.copyWith(
      quantity: clampItemDetailsQuantity(quantity, stock()),
    );
  }

  int cartQuantityById() => _cartStore.getCartQuantity(itemId, variantId);

  String _messageForAction(CartAction action) {
    return switch (action) {
      CartAction.added => LocaleKeys.cartAddSuccess.tr,
      CartAction.updated => LocaleKeys.cartUpdateSuccess.tr,
      CartAction.removed => LocaleKeys.cartRemoveSuccess.tr,
    };
  }

  bool _isCurrentLoad(int generation, int requestedItemId) {
    return !_didClose &&
        !isClosed &&
        generation == _loadGeneration &&
        requestedItemId == _activeLoadItemId;
  }
}
