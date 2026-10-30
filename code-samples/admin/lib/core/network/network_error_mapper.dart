import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../errors/app_failure.dart';
import '../errors/backend_error_code.dart';
import '../errors/validation_error.dart';

@lazySingleton
class NetworkErrorMapper {
  const NetworkErrorMapper();

  AppFailure map(Object error) {
    if (error is DioException) {
      return _mapDioException(error);
    }

    if (error is FormatException) {
      return AppFailure.parsing(rawMessage: error.message);
    }

    return AppFailure.unexpected(rawMessage: error.toString());
  }

  AppFailure mapResponse({required int? statusCode, required Object? data}) {
    final payload = _extractPayload(data);
    final message = _extractMessage(payload);
    final rawErrorCode = _extractString(payload, 'error_code');
    final errorCode = BackendErrorCode.fromValue(rawErrorCode);

    return _failureForStatus(
      statusCode: statusCode,
      message: message,
      errorCode: errorCode,
      rawMessage: message,
      payload: payload,
    );
  }

  AppFailure _mapDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return AppFailure.timeout(rawMessage: error.message);
      case DioExceptionType.connectionError:
        return AppFailure.network(rawMessage: error.message);
      case DioExceptionType.cancel:
        return AppFailure.cancelled(rawMessage: error.message);
      case DioExceptionType.badResponse:
        return mapResponse(
          statusCode: error.response?.statusCode,
          data: error.response?.data,
        );
      case DioExceptionType.badCertificate:
        return AppFailure.network(rawMessage: error.message);
      case DioExceptionType.unknown:
        return AppFailure.unexpected(rawMessage: error.message);
    }
  }

  AppFailure _failureForStatus({
    required int? statusCode,
    required String? message,
    required BackendErrorCode? errorCode,
    required String? rawMessage,
    required Map<String, Object?> payload,
  }) {
    final safeMessage = message ?? _messageForStatus(statusCode);

    switch (statusCode) {
      case 400:
      case 422:
        return AppFailure.validation(
          message: safeMessage,
          statusCode: statusCode,
          errorCode: errorCode,
          rawMessage: rawMessage,
          validation: _extractValidation(payload, safeMessage),
        );
      case 401:
        return AppFailure.unauthorized(
          message: safeMessage,
          statusCode: statusCode,
          errorCode: errorCode,
          rawMessage: rawMessage,
        );
      case 403:
        return AppFailure.forbidden(
          message: safeMessage,
          statusCode: statusCode,
          errorCode: errorCode,
          rawMessage: rawMessage,
        );
      case 404:
        return AppFailure.notFound(
          message: safeMessage,
          statusCode: statusCode,
          errorCode: errorCode,
          rawMessage: rawMessage,
        );
      case 409:
        return AppFailure.conflict(
          message: safeMessage,
          statusCode: statusCode,
          errorCode: errorCode,
          rawMessage: rawMessage,
        );
      case 500:
      case 502:
      case 503:
      case 504:
      case 429:
        return AppFailure.server(
          message: safeMessage,
          statusCode: statusCode,
          errorCode: errorCode,
          rawMessage: rawMessage,
        );
      default:
        if (statusCode == null) {
          return AppFailure.unexpected(
            message: safeMessage,
            rawMessage: rawMessage,
          );
        }
        return AppFailure.unexpected(
          message: safeMessage,
          statusCode: statusCode,
          errorCode: errorCode,
          rawMessage: rawMessage,
        );
    }
  }

  Map<String, Object?> _extractPayload(Object? data) {
    if (data is Map) {
      final normalized = data.map((key, value) => MapEntry('$key', value));
      final detail = normalized['detail'];
      if (detail is Map) {
        return detail.map((key, value) => MapEntry('$key', value));
      }
      return normalized;
    }

    return <String, Object?>{};
  }

  String? _extractMessage(Map<String, Object?> payload) {
    final directMessage = _extractString(payload, 'message');
    if (directMessage != null) {
      return directMessage;
    }

    final detail = payload['detail'];
    if (detail is String && detail.trim().isNotEmpty) {
      return detail.trim();
    }

    return null;
  }

  String? _extractString(Map<String, Object?> payload, String key) {
    final value = payload[key];
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }
    return null;
  }

  ValidationError? _extractValidation(
    Map<String, Object?> payload,
    String message,
  ) {
    final rawFields = payload['field_errors'] ?? payload['errors'];
    if (rawFields is! Map) {
      return null;
    }

    final fieldErrors = <String, List<String>>{};
    for (final entry in rawFields.entries) {
      final value = entry.value;
      if (value is List) {
        fieldErrors['${entry.key}'] = value.map((item) => '$item').toList();
      } else if (value is String) {
        fieldErrors['${entry.key}'] = [value];
      }
    }

    return ValidationError(message: message, fieldErrors: fieldErrors);
  }

  String _messageForStatus(int? statusCode) {
    switch (statusCode) {
      case 400:
      case 422:
        return 'يرجى مراجعة البيانات المدخلة.';
      case 401:
        return 'انتهت الجلسة. يرجى تسجيل الدخول مرة أخرى.';
      case 403:
        return 'لا توجد صلاحية كافية لتنفيذ هذا الإجراء.';
      case 404:
        return 'تعذر العثور على المورد المطلوب.';
      case 409:
        return 'توجد بيانات متعارضة مع الطلب الحالي.';
      case 429:
        return 'تم إرسال طلبات كثيرة. يرجى المحاولة لاحقًا.';
      case 500:
      case 502:
      case 503:
      case 504:
        return 'حدث خطأ في الخادم.';
      default:
        return 'حدث خطأ غير متوقع.';
    }
  }
}
