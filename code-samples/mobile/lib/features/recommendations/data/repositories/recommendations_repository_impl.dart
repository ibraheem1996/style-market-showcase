import 'dart:async';

import 'package:dartz/dartz.dart';

import '../../../../core/base/base_repository.dart';
import '../../../../core/errors/api_result.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/errors/failure_key.dart';
import '../../../../core/errors/backend_error_code_resolver.dart';
import '../../../../core/network/api_status.dart';
import '../../../../core/services/crashlytics_service.dart';
import '../../../products/domain/entities/product_card_entity.dart';
import '../../../products/data/mappers/product_card_mapper.dart';
import '../../domain/entities/recommendation_context.dart';
import '../../domain/entities/recommendations_response_entity.dart';
import '../../domain/repositories/recommendations_repository.dart';
import '../datasources/recommendations_remote_datasource.dart';
import '../mappers/recommendations_pagination_mapper.dart';

class RecommendationsRepositoryImpl extends BaseRepository
    implements RecommendationsRepository {
  final RecommendationsRemoteDataSource remote;
  final CrashlyticsService crash;

  RecommendationsRepositoryImpl({
    required this.remote,
    required this.crash,
    required super.analytics,
    required super.performance,
  }) : super(crash: crash);

  @override
  Future<ApiResult<RecommendationsResponseEntity>> getRecommendations({
    required RecommendationContext context,
    required int page,
    required int limit,
    int? itemId,
    int? audienceId,
  }) async {
    final apiResult = await handleApiCall(
      () => remote.getRecommendations(
        context.apiValue,
        page,
        limit,
        itemId,
        audienceId,
      ),
    );

    return apiResult.fold((l) => Left(l), (r) {
      if (!parseApiStatus(r.status).isSuccess) {
        return Left(
          Failure.http(
            key:
                BackendErrorCodeResolver.httpFailureKeyOf(r.errorCode) ??
                FailureKey.serverGeneric,
            errorCode: r.errorCode,
            rawServerMessage: r.message,
          ),
        );
      }
      if (r.data == null) {
        return const Left(Failure.http(key: FailureKey.missingServerData));
      }

      try {
        final data = r.data!;
        final rawItems = data.items;
        final paginationModel = data.pagination;

        if (rawItems == null || paginationModel == null) {
          unawaited(
            crash.logError(
              const FormatException(
                'Recommendations response is missing items or pagination',
              ),
              StackTrace.current,
              reason:
                  'Recommendations response contract context=${context.apiValue} page=$page',
            ),
          );
          return Left(const Failure.http(key: FailureKey.invalidData));
        }

        if (rawItems.isEmpty) {
          return Right(
            RecommendationsResponseEntity(
              context: context,
              strategy: data.strategy ?? '',
              items: const [],
              pagination: paginationModel.toEntity(),
            ),
          );
        }

        final validItems = <ProductCardEntity>[];
        var failCount = 0;
        Object? firstMappingError;
        StackTrace? firstMappingStack;

        for (var index = 0; index < rawItems.length; index++) {
          try {
            validItems.add(rawItems[index].toEntity());
          } catch (e, s) {
            firstMappingError ??= e;
            firstMappingStack ??= s;
            failCount++;
          }
        }

        if (failCount > 0) {
          unawaited(
            crash.logError(
              firstMappingError ??
                  const FormatException('Invalid product card'),
              firstMappingStack,
              reason:
                  'Recommendations card mapping context=${context.apiValue} '
                  'page=$page raw=${rawItems.length} failed=$failCount',
            ),
          );
        }

        if (validItems.isEmpty && rawItems.isNotEmpty) {
          return Left(const Failure.http(key: FailureKey.invalidData));
        }

        return Right(
          RecommendationsResponseEntity(
            context: context,
            strategy: data.strategy ?? '',
            items: validItems,
            pagination: paginationModel.toEntity(),
          ),
        );
      } catch (e, s) {
        unawaited(
          crash.logError(
            e,
            s,
            reason:
                'Recommendations response mapping context=${context.apiValue} page=$page',
          ),
        );
        return Left(const Failure.http(key: FailureKey.invalidData));
      }
    });
  }
}
