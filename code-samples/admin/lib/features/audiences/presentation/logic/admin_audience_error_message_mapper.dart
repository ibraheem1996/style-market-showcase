import '../../../../core/errors/app_failure.dart';
import '../../../../core/errors/backend_error_code.dart';

String adminAudienceFailureMessage(AppFailure failure) {
  final known = switch (failure.errorCode) {
    BackendErrorCode.audienceNotFound =>
      'تعذر العثور على الفئة المستهدفة المطلوبة.',
    BackendErrorCode.audienceNameArConflict =>
      'الاسم العربي مستخدم لفئة مستهدفة أخرى.',
    BackendErrorCode.audienceNameEnConflict =>
      'الاسم الإنجليزي مستخدم لفئة مستهدفة أخرى.',
    BackendErrorCode.audienceLastActive =>
      'لا يمكن إيقاف آخر فئة مستهدفة نشطة.',
    BackendErrorCode.audienceMustBeInactive =>
      'يجب إيقاف الفئة المستهدفة قبل حذفها.',
    BackendErrorCode.audienceHasProducts =>
      'لا يمكن الحذف لوجود منتجات مرتبطة.',
    BackendErrorCode.audienceHasCollections =>
      'لا يمكن الحذف لوجود مجموعات مرتبطة.',
    BackendErrorCode.audienceHasBanners => 'لا يمكن الحذف لوجود بنرات مرتبطة.',
    BackendErrorCode.validationError => 'يرجى مراجعة بيانات الفئة المستهدفة.',
    _ => null,
  };
  if (known != null) return known;

  return switch (failure) {
    NetworkFailure() => 'تعذر الاتصال بالخادم.',
    TimeoutFailure() => 'انتهت مهلة الاتصال بالخادم.',
    UnauthorizedFailure() => 'انتهت الجلسة. يرجى تسجيل الدخول مرة أخرى.',
    ForbiddenFailure() => 'لا توجد صلاحية كافية لتنفيذ هذا الإجراء.',
    ValidationFailure() => 'يرجى مراجعة بيانات الفئة المستهدفة.',
    ConflictFailure() => 'توجد بيانات متعارضة مع هذا الإجراء.',
    NotFoundFailure() => 'تعذر العثور على الفئة المستهدفة المطلوبة.',
    ServerFailure() => 'حدث خطأ في الخادم.',
    ParsingFailure() => 'تعذر قراءة استجابة الخادم.',
    CancelledFailure() => 'تم إلغاء الطلب.',
    UnexpectedFailure() => 'حدث خطأ غير متوقع.',
  };
}

String adminAudienceBlockerMessage(String blocker) {
  return switch (blocker) {
    'AUDIENCE_MUST_BE_INACTIVE' => 'يجب إيقاف الفئة المستهدفة قبل حذفها.',
    'AUDIENCE_HAS_PRODUCTS' => 'لا يمكن الحذف لوجود منتجات مرتبطة.',
    'AUDIENCE_HAS_COLLECTIONS' => 'لا يمكن الحذف لوجود مجموعات مرتبطة.',
    'AUDIENCE_HAS_BANNERS' => 'لا يمكن الحذف لوجود بنرات مرتبطة.',
    _ => 'يوجد مانع غير معروف يمنع حذف هذه الفئة المستهدفة.',
  };
}
