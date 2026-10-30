import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:get/get.dart';
import 'package:my_project/core/errors/api_result.dart';
import 'package:my_project/core/errors/failure.dart';
import 'package:my_project/features/auth/session/session_service.dart';

import '../../domain/usecases/clear_recently_viewed_usecase.dart';
import '../../domain/usecases/get_recently_viewed_usecase.dart';
import '../../domain/usecases/record_recently_viewed_usecase.dart';
import '../../domain/usecases/sync_recently_viewed_usecase.dart';
import '../states/recently_viewed_state.dart';

class RecentlyViewedService extends GetxService {
  RecentlyViewedService({
    required RecordRecentlyViewedUseCase recordUseCase,
    required GetRecentlyViewedUseCase getUseCase,
    required SyncRecentlyViewedUseCase syncUseCase,
    required ClearRecentlyViewedUseCase clearUseCase,
    required this.sessionService,
  }) : _recordUseCase = recordUseCase,
       _getUseCase = getUseCase,
       _syncUseCase = syncUseCase,
       _clearUseCase = clearUseCase;

  final RecordRecentlyViewedUseCase _recordUseCase;

  final GetRecentlyViewedUseCase _getUseCase;
  final SyncRecentlyViewedUseCase _syncUseCase;
  final ClearRecentlyViewedUseCase _clearUseCase;

  final SessionService sessionService;

  final state = Rx<RecentlyViewedState>(const RecentlyViewedState.initial());
  StreamSubscription<int>? _sessionSubscription;

  Future<void> _mutationTail = Future<void>.value();
  Future<Failure?>? _inFlightFetch;
  int? _inFlightRevision;
  int _revision = 0;
  int _sessionRevision = 0;

  /// Loads the history for the current guest or authenticated scope.
  ///
  /// Pending guest keys are merged before the first authenticated read. A
  /// failed merge stays pending locally while the account history still loads.
  Future<void> fetch() async {
    await _fetchForCurrentScope();
  }

  /// Starts Home's first fetch only when no Session transition has started it.
  Future<void> fetchForHomeBootstrap() {
    final isInitial = state.value.maybeWhen(
      initial: () => true,
      orElse: () => false,
    );
    return isInitial ? fetch() : Future<void>.value();
  }

  /// Refreshes while exposing a non-blocking failure when data stays visible.
  Future<Failure?> refreshWithFailure() => _fetchForCurrentScope();

  Future<Failure?> _fetchForCurrentScope() {
    final sessionRevision = _sessionRevision;

    final revision = _revision;

    final activeFetch = _inFlightFetch;

    if (activeFetch != null && _inFlightRevision == revision) {
      return activeFetch;
    }

    final future = _fetch(sessionRevision: sessionRevision, revision: revision);

    _inFlightFetch = future;
    _inFlightRevision = revision;

    return future.whenComplete(() {
      if (identical(_inFlightFetch, future)) {
        _inFlightFetch = null;
        _inFlightRevision = null;
      }
    });
  }

  Future<Failure?> _fetch({
    required int sessionRevision,
    required int revision,
  }) async {
    final hasSnapshot = _hasUsableSnapshot;
    if (!hasSnapshot) {
      state.value = const RecentlyViewedState.loading();
    }
    if (sessionService.isAuthenticated) {
      await _syncUseCase();
    }

    if (!_isCurrent(sessionRevision, revision)) return null;

    final result = await _getUseCase();
    if (!_isCurrent(sessionRevision, revision)) return null;

    Failure? fetchFailure;

    result.fold(
      (failure) {
        fetchFailure = hasSnapshot ? failure : null;
        if (!hasSnapshot) {
          state.value = RecentlyViewedState.error(failure);
        }
      },
      (items) {
        state.value = items.isEmpty
            ? const RecentlyViewedState.empty()
            : RecentlyViewedState.success(items);
      },
    );
    return fetchFailure;
  }

  /// Records one successful Product Details opening and refreshes shared UI.
  Future<ApiResult<void>> recordView({
    required int itemId,
    int? colorGroupId,
  }) async {
    final sessionRevision = _sessionRevision;
    final revision = ++_revision;
    final previousRecord = _mutationTail;
    final recordCompleted = Completer<void>();
    _mutationTail = recordCompleted.future;
    await previousRecord;

    try {
      if (sessionRevision != _sessionRevision) {
        return const Right(null);
      }

      final result = await _recordUseCase(
        itemId: itemId,
        colorGroupId: colorGroupId,
      );

      if (result.isRight() && _isCurrent(sessionRevision, revision)) {
        await fetch();
      }
      return result;
    } finally {
      recordCompleted.complete();
    }
  }

  Future<ApiResult<void>> clearRecentlyViewed() async {
    final sessionRevision = _sessionRevision;
    final revision = ++_revision;

    final previousMutation = _mutationTail;
    final mutationCompleted = Completer<void>();

    _mutationTail = mutationCompleted.future;

    try {
      await previousMutation;

      if (sessionRevision != _sessionRevision) {
        return const Right(null);
      }

      final result = await _clearUseCase();

      if (result.isRight() && _isCurrent(sessionRevision, revision)) {
        state.value = const RecentlyViewedState.empty();
      }

      return result;
    } finally {
      mutationCompleted.complete();
    }
  }

  /// Invalidates pending responses when a session ends or changes owner.
  void reset() {
    _revision++;
    _sessionRevision++;
    state.value = const RecentlyViewedState.initial();
  }

  bool get _hasUsableSnapshot => state.value.maybeWhen(
    success: (_) => true,
    empty: () => true,
    orElse: () => false,
  );

  bool _isCurrent(int sessionRevision, int revision) {
    return sessionRevision == _sessionRevision && _revision == revision;
  }

  @override
  void onInit() {
    super.onInit();
    _sessionSubscription = sessionService.sessionChanges.listen((_) {
      reset();
      if (sessionService.isAuthenticated) {
        unawaited(fetch());
      }
    });
  }

  @override
  void onClose() {
    _sessionSubscription?.cancel();
    super.onClose();
  }
}
