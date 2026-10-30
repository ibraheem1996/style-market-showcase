// Package imports:
import 'package:dartz/dartz.dart';

// Project imports:
import '../../../../core/base/base_repository.dart';
import '../../../../core/errors/api_result.dart';
import '../../../../core/errors/app_failure_key.dart';
import '../../../../core/errors/backend_error_code_resolver.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/errors/failure_key.dart';
import '../../../../core/network/response_mapper.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/services/crashlytics_service.dart';
import 'package:my_project/features/auth/session/session_service.dart';
import '../../domain/entities/favorite_entity.dart';
import '../../domain/entities/favorites_toggle_result.dart';
import '../../domain/repositories/favorites_repository.dart';
import '../datasources/remote/favorites_remote_datasource.dart';
import '../mappers/favorite_mapper.dart';
import '../models/toggle_favorite_request.dart';
import '../models/favorite_model.dart';

//! Repository implementation for favorites feature
class FavoritesRepositoryImpl extends BaseRepository
    implements FavoritesRepository {
  final FavoritesRemoteDataSource remoteDataSource;
  final CrashlyticsService crash;
  final SessionService sessionService;
  FavoritesRepositoryImpl({
    required this.remoteDataSource,
    required super.analytics,
    required this.crash,
    required super.performance,
    required this.sessionService,
  }) : super(crash: crash);

  @override
  Future<ApiResult<List<FavoriteEntity>>> getFavorites() async {
    if (sessionService.userId == null) {
      return Left(Failure.app(key: AppFailureKey.loginRequired));
    }
    final apiResult = await handleApiCall(remoteDataSource.getFavorites);
    return apiResult.fold((l) => Left(l), (r) {
      return mapListResponse<FavoriteModel, FavoriteEntity>(
        r: r,
        mapper: (m) => m.toEntity(),
        logTag: "FavoritesRepository",
        crash: crash,
        // Partial snapshots remain until the Favorites contract is reviewed.
        requireAllItems: false,
      );
    });
  }

  @override
  Future<ApiResult<FavoritesToggleResult>> toggleFavorite({
    required int itemId,
    int? variantId,
  }) async {
    if (sessionService.userId == null) {
      return Left(Failure.app(key: AppFailureKey.loginRequired));
    }
    final request = ToggleFavoriteRequest(itemId: itemId, variantId: variantId);
    final apiResult = await handleApiCall(
      () => remoteDataSource.toggleFavorite(request),
    );
    return apiResult.fold((l) => Left(l), (r) {
      if (!r.isSuccess) return Left(_responseFailure(r));
      if (r.action == 'removed') {
        if (r.data != null) return Left(_invalidToggleResponse);
        return Right(
          FavoritesToggleResult(
            favorite: null,
            action: FavoritesToggleAction.removed,
          ),
        );
      }
      if (r.action != 'added' || r.data is! Map<String, dynamic>) {
        return Left(_invalidToggleResponse);
      }
      try {
        final favorite = FavoriteModel.fromJson(
          r.data! as Map<String, dynamic>,
        ).toEntity();
        if (favorite.itemId != itemId ||
            favorite.variantId != variantId ||
            (favorite.targetType == FavoriteTargetType.item &&
                favorite.variantId != null)) {
          return Left(_invalidToggleResponse);
        }
        return Right(
          FavoritesToggleResult(
            favorite: favorite,
            action: FavoritesToggleAction.added,
          ),
        );
      } catch (error, stackTrace) {
        crash.logError(
          error,
          stackTrace,
          reason: 'FavoritesRepository.toggleFavorite mapping',
        );
        return Left(_invalidToggleResponse);
      }
    });
  }

  @override
  Future<ApiResult<void>> clearFavorites() async {
    if (sessionService.userId == null) {
      return Left(Failure.app(key: AppFailureKey.loginRequired));
    }
    final result = await handleApiCall(remoteDataSource.clearFavorites);
    return result.fold(
      (failure) => Left(failure),
      (response) => response.isSuccess
          ? const Right(null)
          : Left(_responseFailure(response)),
    );
  }

  static const Failure _invalidToggleResponse = Failure.http(
    key: FailureKey.invalidData,
    statusCode: 200,
  );

  Failure _responseFailure(ApiResponse<Object?> response) => Failure.http(
    key:
        BackendErrorCodeResolver.httpFailureKeyOf(response.errorCode) ??
        FailureKey.serverGeneric,
    rawServerMessage: response.message,
    errorCode: response.errorCode,
  );
}
