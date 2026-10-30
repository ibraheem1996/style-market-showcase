import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../errors/api_result.dart';
import '../errors/error_handler.dart';
import '../services/crashlytics_service.dart';

abstract class BaseRepository {
  final CrashlyticsService _crash;

  BaseRepository({required CrashlyticsService crash}) : _crash = crash;

  Future<ApiResult<T>> handleApiCall<T>(Future<T> Function() action) async {
    try {
      final result = await action();
      return Right(result);
    } catch (error, stackTrace) {
      if (error is! DioException) {
        _runTelemetry(
          () => _crash.logError(
            error,
            stackTrace,
            reason: 'Repository non-network failure',
          ),
        );
      }
      return Left(ErrorHandler.handle(error));
    }
  }

  void _runTelemetry(Future<void> Function() action) {
    try {
      unawaited(action().catchError((_) {}));
    } catch (_) {}
  }
}
