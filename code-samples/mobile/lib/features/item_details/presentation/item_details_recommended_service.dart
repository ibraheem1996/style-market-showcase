import 'package:get/get.dart';

import '../../../../core/errors/app_failure_key.dart';
import '../../../../core/errors/failure.dart';
import '../../../recommendations/domain/entities/recommendation_context.dart';
import '../../../recommendations/domain/usecases/get_recommendations_usecase.dart';
import '../state/item_details_recommended_state.dart';

class ItemDetailsRecommendedService {
  ItemDetailsRecommendedService({required this.useCase});

  final GetRecommendationsUseCase useCase;

  static const int _limit = 20;
  static const RecommendationContext _context =
      RecommendationContext.productDetails;

  final state = Rx<ItemDetailsRecommendedState>(
    const ItemDetailsRecommendedState.initial(),
  );

  int? _currentItemId;
  int? _currentAudienceId;
  int _currentPage = 1;
  bool _isFetching = false;
  int _requestVersion = 0;

  Future<void> fetchFirstPage({
    required int itemId,
    required int audienceId,
  }) async {
    if (_isFetching) return;

    if (itemId <= 0 || audienceId <= 0) {
      state.value = const ItemDetailsRecommendedState.error(
        Failure.app(key: AppFailureKey.invalidArgument),
      );
      return;
    }

    final myVersion = ++_requestVersion;
    _currentItemId = itemId;
    _currentAudienceId = audienceId;
    _currentPage = 1;
    _isFetching = true;
    state.value = const ItemDetailsRecommendedState.loading();

    final result = await useCase(
      context: _context,
      itemId: itemId,
      audienceId: audienceId,
      page: 1,
      limit: _limit,
    );

    if (myVersion != _requestVersion) {
      _finishFetch(myVersion);
      return;
    }

    result.fold(
      (failure) {
        state.value = ItemDetailsRecommendedState.error(failure);
      },
      (response) {
        if (response.items.isEmpty && !response.pagination.hasMore) {
          state.value = const ItemDetailsRecommendedState.empty();
        } else {
          state.value = ItemDetailsRecommendedState.success(
            items: response.items,
            pagination: response.pagination,
          );
        }
      },
    );

    _finishFetch(myVersion);
  }

  Future<void> loadMore() async {
    if (_isFetching) return;

    final current = state.value;
    if (current is! ItemDetailsRecommendedSuccess) return;
    if (current.isLoadingMore) return;
    if (!current.pagination.hasMore) return;

    final itemId = _currentItemId;
    final audienceId = _currentAudienceId;
    if (itemId == null || audienceId == null) return;

    final myVersion = ++_requestVersion;
    final nextPage = _currentPage + 1;

    _isFetching = true;
    state.value = current.copyWith(isLoadingMore: true, loadMoreFailure: null);

    final result = await useCase(
      context: _context,
      itemId: itemId,
      audienceId: audienceId,
      page: nextPage,
      limit: _limit,
    );

    if (myVersion != _requestVersion) {
      _finishFetch(myVersion);
      return;
    }

    result.fold(
      (failure) {
        state.value = current.copyWith(
          isLoadingMore: false,
          loadMoreFailure: failure,
        );
      },
      (response) {
        _currentPage = nextPage;
        state.value = ItemDetailsRecommendedState.success(
          items: [...current.items, ...response.items],
          pagination: response.pagination,
        );
      },
    );

    _finishFetch(myVersion);
  }

  Future<void> refresh({required int itemId, required int audienceId}) async {
    _requestVersion++;
    _currentPage = 1;
    _isFetching = false;
    await fetchFirstPage(itemId: itemId, audienceId: audienceId);
  }

  Future<void> retryLoadMore() => loadMore();

  void reset() {
    _requestVersion++;
    _currentPage = 1;
    _currentItemId = null;
    _currentAudienceId = null;
    _isFetching = false;
    state.value = const ItemDetailsRecommendedState.initial();
  }

  void _finishFetch(int version) {
    // A stale response must not clear the fetch guard for a newer request.
    if (version == _requestVersion) {
      _isFetching = false;
    }
  }
}
