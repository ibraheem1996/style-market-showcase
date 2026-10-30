import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:my_project/core/base/base_repository.dart';
import 'package:my_project/core/network/api_response.dart';
import 'package:retrofit/dio.dart';
import 'package:retrofit/error_logger.dart';
import 'package:retrofit/http.dart';

import '../../core/errors/api_result.dart';
import '../../core/errors/error_handler.dart';
import '../../core/errors/failure.dart';
import '../../core/errors/failure_key.dart';
part 'notification_token_api.g.dart';

const _path = '/users/me/fcm-token';

class NotificationTokenApi extends BaseRepository {
  NotificationTokenApi(
    this._api, {
    required super.analytics,
    required super.crash,
    required super.performance,
  });

  final NotificationTokenRemoteApi _api;

  Future<ApiResult<void>> register(
    String token, {
    required CancelToken cancelToken,
    required bool Function() canDispatch,
  }) async {
    if (!canDispatch() || cancelToken.isCancelled) {
      return left(
        ErrorHandler.handle(
          const FormatException('Private synchronization stopped'),
        ),
      );
    }

    final result = await handleApiCall(
      () => _api.register({'token': token}, cancelToken),
    );

    return result.fold(Left.new, (response) {
      if (!response.isSuccess || response.errorCode != null) {
        return left(Failure.http(key: FailureKey.serverGeneric));
      }

      return right(null);
    });
  }

  Future<ApiResult<void>> remove(
    String token, {
    required CancelToken cancelToken,
  }) async {
    final result = await handleApiCall(
      () => _api.remove({'token': token}, cancelToken),
    );

    return result.fold(Left.new, (response) {
      if (!response.isSuccess || response.errorCode != null) {
        return left(Failure.http(key: FailureKey.serverGeneric));
      }

      return right(null);
    });
  }
}

@RestApi()
abstract class NotificationTokenRemoteApi {
  factory NotificationTokenRemoteApi(Dio dio) = _NotificationTokenRemoteApi;

  @PUT(_path)
  @Extra({'sensitiveNotificationToken': true})
  Future<ApiResponse<void>> register(
    @Body() Map<String, String> body,
    @CancelRequest() CancelToken cancelToken,
  );

  @DELETE(_path)
  @Extra({'sensitiveNotificationToken': true})
  Future<ApiResponse<void>> remove(
    @Body() Map<String, String> body,
    @CancelRequest() CancelToken cancelToken,
  );
}
