import 'package:dartz/dartz.dart';
import 'package:my_project/core/base/base_repository.dart';
import 'package:my_project/core/errors/api_result.dart';
import 'package:my_project/core/errors/failure_key.dart';
import 'package:my_project/core/errors/failure.dart';
import 'package:my_project/core/errors/backend_error_code_resolver.dart';
import 'package:my_project/core/network/api_response.dart';
import 'package:my_project/core/services/crashlytics_service.dart';
import 'package:my_project/features/auth/session/session_service.dart';
import 'package:my_project/features/products/data/mappers/product_card_mapper.dart';
import 'package:my_project/features/products/domain/entities/product_card_entity.dart';

import '../../../../core/network/response_mapper.dart';
import '../../../products/data/model/product_card_model.dart';
import '../../../products/data/model/product_catalog_response_model.dart';
import '../models/record_view_request.dart';
import '../../domain/repositories/recently_viewed_repository.dart';
import '../datasources/recently_viewed_local_datasource.dart';
import '../datasources/recently_viewed_remote_datasource.dart';
import '../models/cards_by_keys_request_model.dart';
import '../models/sync_keys_request_model.dart';

class RecentlyViewedRepositoryImpl extends BaseRepository
    implements RecentlyViewedRepository {
  final RecentlyViewedRemoteDataSource _remote;
  final RecentlyViewedLocalDataSource _local;
  final CrashlyticsService _crash;
  final SessionService _sessionService;

  RecentlyViewedRepositoryImpl({
    required RecentlyViewedRemoteDataSource remote,
    required RecentlyViewedLocalDataSource local,
    required super.crash,
    required SessionService sessionService,
  }) : _remote = remote,
       _local = local,
       _crash = crash,
       _sessionService = sessionService;

  @override
  Future<ApiResult<void>> recordView({
    required int itemId,
    int? colorGroupId,
  }) async {
    if (_sessionService.isAuthenticated) {
      final result = await handleApiCall(
        () => _remote.recordView(
          RecordViewRequest(itemId: itemId, colorGroupId: colorGroupId),
        ),
      );
      return result.fold((l) => Left(l), (r) {
        return r.isSuccess ? const Right(null) : Left(_failureFromResponse(r));
      });
    } else {
      final result = await handleApiCall(
        () => _local.addKey(
          RecentlyViewedKeyModel(itemId: itemId, colorGroupId: colorGroupId),
        ),
      );
      return result;
    }
  }

  @override
  Future<ApiResult<List<ProductCardEntity>>> getRecentlyViewed() async {
    if (_sessionService.isAuthenticated) {
      return _fetchFromRemote();
    } else {
      return _fetchFromLocalKeys();
    }
  }

  @override
  Future<ApiResult<void>> syncGuestKeysIfAny() async {
    final keysResult = await handleApiCall(_local.getKeys);
    if (keysResult.isLeft()) {
      return keysResult.fold(
        (failure) => Left(failure),
        (_) => const Right(null),
      );
    }

    final keys = keysResult.getOrElse(() => []);
    if (keys.isEmpty) return const Right(null);

    final result = await handleApiCall(
      () => _remote.syncKeys(SyncKeysRequest(keys: keys.reversed.toList())),
    );

    final checked = result.fold<ApiResult<void>>(
      (failure) => Left(failure),
      (response) => response.isSuccess
          ? const Right(null)
          : Left(_failureFromResponse(response)),
    );
    if (checked.isRight()) {
      final clearResult = await handleApiCall(_local.clearKeys);
      return clearResult;
    }
    return checked;
  }

  @override
  Future<void> clearLocalKeys() => _local.clearKeys();

  @override
  Future<ApiResult<void>> clearRecentlyViewed() async {
    if (_sessionService.isAuthenticated) {
      final result = await handleApiCall(() => _remote.clearRecentlyViewed());
      final checked = result.fold<ApiResult<void>>(
        (failure) => Left(failure),
        (response) => response.isSuccess
            ? const Right(null)
            : Left(_failureFromResponse(response)),
      );
      if (checked.isRight()) return handleApiCall(_local.clearKeys);
      return checked;
    } else {
      return handleApiCall(_local.clearKeys);
    }
  }

  Future<ApiResult<List<ProductCardEntity>>> _fetchFromRemote() async {
    final apiResult = await handleApiCall(() => _remote.getRecentlyViewed());
    return apiResult.fold((l) => Left(l), (r) {
      return mapNestedListResponse<
        ProductCatalogResponseModel,
        ProductCardModel,
        ProductCardEntity
      >(
        r: r,
        extractList: (data) => data.items,
        mapper: (m) => m.toEntity(),
        requireAllItems: false,
        logTag: 'RecentlyViewedRepo._fetchFromRemote',
        crash: _crash,
      );
    });
  }

  Future<ApiResult<List<ProductCardEntity>>> _fetchFromLocalKeys() async {
    final keysResult = await handleApiCall(_local.getKeys);
    if (keysResult.isLeft()) {
      return keysResult.fold(
        (failure) => Left(failure),
        (_) => const Right([]),
      );
    }
    final keys = keysResult.getOrElse(() => []);
    if (keys.isEmpty) return const Right([]);

    final apiResult = await handleApiCall(
      () => _remote.getCardsByKeys(CardsByKeysRequestModel(keys: keys)),
    );

    return apiResult.fold((l) => Left(l), (r) {
      return mapNestedListResponse<
        ProductCatalogResponseModel,
        ProductCardModel,
        ProductCardEntity
      >(
        r: r,
        extractList: (data) => data.items,
        mapper: (m) => m.toEntity(),
        requireAllItems: false,
        logTag: 'RecentlyViewedRepo._fetchFromLocalKeys',
        crash: _crash,
      );
    });
  }

  Failure _failureFromResponse(ApiResponse<dynamic> response) => Failure.http(
    key:
        BackendErrorCodeResolver.httpFailureKeyOf(response.errorCode) ??
        FailureKey.serverGeneric,
    errorCode: response.errorCode,
    rawServerMessage: response.message,
  );
}
