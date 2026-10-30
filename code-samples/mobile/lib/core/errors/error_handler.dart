// Dart imports:
import 'dart:io';

// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import 'backend_error_code_resolver.dart';
import 'failure.dart';
import 'failure_key.dart';
import 'mapping_exception.dart';

class ErrorHandler {
  const ErrorHandler._();

  static Failure handle(dynamic error) {
    try {
      // Dio covers most network/http errors
      if (error is DioException) return ErrorHandler._handleDio(error);

      // Rare outside Dio, but safe to keep
      if (error is SocketException) {
        return const Failure.http(key: FailureKey.networkNoInternet);
      }

      // Parsing / type mismatch
      if (error is FormatException ||
          error is MappingException ||
          error is TypeError ||
          error is NoSuchMethodError) {
        return const Failure.http(key: FailureKey.invalidData);
      }

      return const Failure.http(key: FailureKey.unexpected);
    } catch (_) {
      return const Failure.http(key: FailureKey.unexpected);
    }
  }

  static Failure _handleDio(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return const Failure.http(key: FailureKey.networkTimeout);

      case DioExceptionType.cancel:
        return const Failure.http(key: FailureKey.cancelled);

      case DioExceptionType.connectionError:
        return Failure.http(key: _mapConnectionError(e.error));

      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final data = e.response?.data;
        final rawMsg = _extractServerMessage(data);
        final errorCode = _extractErrorCode(data);

        final key =
            BackendErrorCodeResolver.httpFailureKeyOf(errorCode) ??
            _mapHttpCodeToKey(statusCode);

        return Failure.http(
          key: key,
          statusCode: statusCode,
          rawServerMessage: rawMsg,
          errorCode: errorCode,
          data: data is Map<String, dynamic> ? data : null,
        );

      case DioExceptionType.unknown:
        // No internet / DNS / socket issues often end up here
        if (e.error is SocketException) {
          return const Failure.http(key: FailureKey.networkNoInternet);
        }
        // Sometimes invalid SSL, etc.
        return const Failure.http(key: FailureKey.unexpected);

      default:
        return const Failure.http(key: FailureKey.unexpected);
    }
  }

  static FailureKey _mapConnectionError(Object? error) {
    if (error is SocketException) {
      final message = error.message.toLowerCase();
      if (message.contains('refused')) {
        return FailureKey.serverUnavailable;
      }
      return FailureKey.networkNoInternet;
    }

    return FailureKey.serverUnavailable;
  }

  static String? _extractServerMessage(dynamic data) {
    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }
    return null;
  }

  static String? _extractErrorCode(dynamic data) {
    if (data is Map && data['error_code'] != null) {
      return data['error_code'].toString();
    }
    return null;
  }

  static FailureKey _mapHttpCodeToKey(int? code) {
    switch (code) {
      case 400:
        return FailureKey.badRequest;
      case 401:
        return FailureKey.unauthorized;
      case 403:
        return FailureKey.forbidden;
      case 404:
        return FailureKey.notFound;
      case 408: // optional
        return FailureKey.networkTimeout;
      case 409:
        return FailureKey.conflict;
      case 422:
        return FailureKey.validation;
      case 429:
        return FailureKey.tooManyRequests;
      case 500:
        return FailureKey.serverInternal;
      case 502: // optional
      case 503:
      case 504: // optional
        return FailureKey.serverUnavailable;
      default:
        return FailureKey.serverGeneric;
    }
  }
}
