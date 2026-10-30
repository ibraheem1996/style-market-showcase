import 'package:freezed_annotation/freezed_annotation.dart';

import 'backend_error_code.dart';
import 'validation_error.dart';

part 'app_failure.freezed.dart';

@freezed
sealed class AppFailure with _$AppFailure {
  const factory AppFailure.network({
    @Default('تعذر الاتصال بالخادم.') String message,
    int? statusCode,
    BackendErrorCode? errorCode,
    String? rawMessage,
  }) = NetworkFailure;

  const factory AppFailure.timeout({
    @Default('انتهت مهلة الاتصال بالخادم.') String message,
    int? statusCode,
    BackendErrorCode? errorCode,
    String? rawMessage,
  }) = TimeoutFailure;

  const factory AppFailure.unauthorized({
    @Default('انتهت الجلسة. يرجى تسجيل الدخول مرة أخرى.') String message,
    int? statusCode,
    BackendErrorCode? errorCode,
    String? rawMessage,
  }) = UnauthorizedFailure;

  const factory AppFailure.forbidden({
    @Default('لا توجد صلاحية كافية لتنفيذ هذا الإجراء.') String message,
    int? statusCode,
    BackendErrorCode? errorCode,
    String? rawMessage,
  }) = ForbiddenFailure;

  const factory AppFailure.validation({
    @Default('يرجى مراجعة البيانات المدخلة.') String message,
    int? statusCode,
    BackendErrorCode? errorCode,
    String? rawMessage,
    ValidationError? validation,
  }) = ValidationFailure;

  const factory AppFailure.conflict({
    @Default('توجد بيانات متعارضة مع الطلب الحالي.') String message,
    int? statusCode,
    BackendErrorCode? errorCode,
    String? rawMessage,
  }) = ConflictFailure;

  const factory AppFailure.notFound({
    @Default('تعذر العثور على المورد المطلوب.') String message,
    int? statusCode,
    BackendErrorCode? errorCode,
    String? rawMessage,
  }) = NotFoundFailure;

  const factory AppFailure.server({
    @Default('حدث خطأ في الخادم.') String message,
    int? statusCode,
    BackendErrorCode? errorCode,
    String? rawMessage,
  }) = ServerFailure;

  const factory AppFailure.parsing({
    @Default('تعذر قراءة استجابة الخادم.') String message,
    int? statusCode,
    BackendErrorCode? errorCode,
    String? rawMessage,
  }) = ParsingFailure;

  const factory AppFailure.cancelled({
    @Default('تم إلغاء الطلب.') String message,
    int? statusCode,
    BackendErrorCode? errorCode,
    String? rawMessage,
  }) = CancelledFailure;

  const factory AppFailure.unexpected({
    @Default('حدث خطأ غير متوقع.') String message,
    int? statusCode,
    BackendErrorCode? errorCode,
    String? rawMessage,
  }) = UnexpectedFailure;
}
