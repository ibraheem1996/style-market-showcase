import 'package:dartz/dartz.dart';

import '../errors/api_result.dart';
import '../errors/backend_error_code_resolver.dart';
import '../errors/failure.dart';
import '../errors/failure_key.dart';
import '../services/crashlytics_service.dart';
import '../services/logger_service.dart';
import 'api_response.dart';

/// Checks the envelope and maps each item of a required top-level list.
ApiResult<List<Entity>> mapListResponse<Model, Entity>({
  required ApiResponse<Object?> r,
  required Entity Function(Model) mapper,
  required String logTag,
  required CrashlyticsService crash,
  required bool requireAllItems,
}) {
  if (!r.isSuccess) {
    LoggerService.error('$logTag: Server error ${r.message}');
    return Left(_failureFromResponse(r));
  }
  final data = r.data;
  if (data == null) {
    LoggerService.error('$logTag: Missing data ${r.message}');
    crash.logError(
      const FormatException('Successful response missing required data'),
      StackTrace.current,
      reason: logTag,
    );
    return const Left(Failure.http(key: FailureKey.missingServerData));
  }
  if (data is! List) {
    LoggerService.error('$logTag: Data is not a list');
    crash.logError(
      const FormatException('Successful response data is not a list'),
      StackTrace.current,
      reason: logTag,
    );
    return const Left(Failure.http(key: FailureKey.invalidData));
  }
  return mapListSafely(
    models: data.cast<Model>(),
    mapper: mapper,
    logTag: logTag,
    crash: crash,
    requireAllItems: requireAllItems,
  );
}

/// Maps a required list inside a successful response payload.
ApiResult<List<Entity>> mapNestedListResponse<ContainerModel, Model, Entity>({
  required ApiResponse<ContainerModel> r,
  required List<Model>? Function(ContainerModel data) extractList,
  required Entity Function(Model) mapper,
  required String logTag,
  required CrashlyticsService crash,
  required bool requireAllItems,
}) {
  if (!r.isSuccess) {
    LoggerService.error('$logTag: Server error ${r.message}');
    return Left(_failureFromResponse(r));
  }
  final data = r.data;
  if (data == null) {
    LoggerService.error('$logTag: Missing data ${r.message}');
    crash.logError(
      const FormatException('Successful response missing required data'),
      StackTrace.current,
      reason: logTag,
    );
    return const Left(Failure.http(key: FailureKey.missingServerData));
  }
  final list = extractList(data);
  if (list == null) {
    LoggerService.error('$logTag: Missing nested list ${r.message}');
    crash.logError(
      const FormatException('Successful response missing required list'),
      StackTrace.current,
      reason: logTag,
    );
    return const Left(Failure.http(key: FailureKey.missingServerData));
  }
  return mapListSafely(
    models: list,
    mapper: mapper,
    logTag: logTag,
    crash: crash,
    requireAllItems: requireAllItems,
  );
}

/// Maps decoded items; partial mode fails when no item from a nonempty list survives.
ApiResult<List<Entity>> mapListSafely<Model, Entity>({
  required List<Model> models,
  required Entity Function(Model model) mapper,
  required String logTag,
  required CrashlyticsService crash,
  required bool requireAllItems,
}) {
  final out = <Entity>[];
  var failCount = 0;
  Object? firstError;
  StackTrace? firstStack;
  for (var index = 0; index < models.length; index++) {
    try {
      out.add(mapper(models[index]));
    } catch (error, stackTrace) {
      firstError ??= error;
      firstStack ??= stackTrace;
      failCount++;
      if (requireAllItems) break;
    }
  }
  if (firstError != null) {
    crash.logError(
      firstError,
      firstStack,
      reason: '$logTag: Invalid list item (failed=$failCount)',
    );
    if (requireAllItems) {
      return const Left(Failure.http(key: FailureKey.invalidData));
    }
  }
  if (out.isEmpty && models.isNotEmpty) {
    LoggerService.error('$logTag: All items failed to map');
    return const Left(Failure.http(key: FailureKey.invalidData));
  }
  return Right(out);
}

Failure _failureFromResponse<T>(ApiResponse<T> response) => Failure.http(
  key:
      BackendErrorCodeResolver.httpFailureKeyOf(response.errorCode) ??
      FailureKey.serverGeneric,
  rawServerMessage: response.message,
  errorCode: response.errorCode,
);
