// Project imports:
import 'package:get/get.dart';

import 'app_failure_key.dart';
import 'auth_error_key.dart';
import 'failure.dart';
import 'failure_key.dart';

import '../translations/locale_keys.dart';

extension FailureExtension on Failure {
  String get message => FailureI18n.keyOf(this).tr;
}

class FailureI18n {
  static String keyOf(Failure failure) {
    return failure.when(
      http: (key, _, __, ___, ____) => _httpKey(key),
      auth: (key) => _authKey(key),
      app: (key) => _appKey(key),
    );
  }

  static String _httpKey(FailureKey key) {
    return switch (key) {
      FailureKey.networkNoInternet => LocaleKeys.errorHttpNoInternet,
      FailureKey.networkTimeout => LocaleKeys.errorHttpTimeout,
      FailureKey.validation => LocaleKeys.errorHttpValidation,
      FailureKey.conflict => LocaleKeys.errorHttpConflict,
      FailureKey.unauthorized => LocaleKeys.errorHttpUnauthorized,
      FailureKey.forbidden => LocaleKeys.errorHttpForbidden,
      FailureKey.notFound => LocaleKeys.errorHttpNotFound,
      FailureKey.tooManyRequests => LocaleKeys.errorHttpTooManyRequests,
      FailureKey.serverInternal => LocaleKeys.errorHttpServer,
      FailureKey.serverUnavailable => LocaleKeys.errorHttpServerUnavailable,
      FailureKey.invalidData => LocaleKeys.errorHttpInvalidData,
      FailureKey.cancelled => LocaleKeys.errorHttpCancelled,
      FailureKey.badRequest => LocaleKeys.errorHttpBadRequest,
      FailureKey.serverGeneric => LocaleKeys.errorHttpServerGeneric,
      FailureKey.unexpected => LocaleKeys.errorHttpUnexpected,
      FailureKey.empty => LocaleKeys.errorHttpEmpty,
      FailureKey.local => LocaleKeys.errorHttpLocal,
      FailureKey.missingServerData => LocaleKeys.errorHttpMissingServerData,
      FailureKey.invalidCheckoutData => LocaleKeys.errorHttpInvalidCheckoutData,
      FailureKey.itemNotFound => LocaleKeys.errorHttpItemNotFound,
      FailureKey.itemNotActive => LocaleKeys.errorHttpItemNotActive,
      FailureKey.variantRequired => LocaleKeys.errorHttpVariantRequired,
      FailureKey.invalidVariant => LocaleKeys.errorHttpInvalidVariant,
      FailureKey.variantNotActive => LocaleKeys.errorHttpVariantNotActive,
      FailureKey.priceChanged => LocaleKeys.errorHttpPriceChanged,
      FailureKey.outOfStock => LocaleKeys.errorHttpOutOfStock,
      FailureKey.insufficientQuantity =>
        LocaleKeys.errorHttpInsufficientQuantity,
      FailureKey.checkoutOutOfStock => LocaleKeys.errorHttpCheckoutOutOfStock,
      FailureKey.idempotencyKeyConflict =>
        LocaleKeys.errorHttpIdempotencyKeyConflict,
      FailureKey.paymentMethodUnavailable =>
        LocaleKeys.errorHttpPaymentMethodUnavailable,
      FailureKey.orderNotCancelable => LocaleKeys.errorHttpOrderNotCancelable,
      FailureKey.orderNoteRequired => LocaleKeys.errorHttpOrderNoteRequired,
      FailureKey.orderNoteAlreadySubmitted =>
        LocaleKeys.errorHttpOrderNoteAlreadySubmitted,
      FailureKey.orderNoteNotAllowed => LocaleKeys.errorHttpOrderNoteNotAllowed,
      FailureKey.cartMaxQty => LocaleKeys.errorHttpCartMaxQty,
      FailureKey.userNotFound => LocaleKeys.errorHttpUserNotFound,
      FailureKey.phoneRequired => LocaleKeys.errorHttpPhoneRequired,
      FailureKey.phoneVerificationRequired =>
        LocaleKeys.errorHttpPhoneVerificationRequired,
      FailureKey.invalidPhone => LocaleKeys.errorHttpInvalidPhone,
      FailureKey.phoneNotVerified => LocaleKeys.errorHttpPhoneNotVerified,
      FailureKey.phoneAlreadyInUse => LocaleKeys.errorHttpPhoneAlreadyInUse,
      FailureKey.addressNotFound => LocaleKeys.errorHttpAddressNotFound,
      FailureKey.addressNotOwned => LocaleKeys.errorHttpAddressNotOwned,
      FailureKey.otpInvalid => LocaleKeys.errorHttpOtpInvalid,
      FailureKey.otpExpired => LocaleKeys.errorHttpOtpExpired,
      FailureKey.otpAttemptsExceeded => LocaleKeys.errorHttpOtpAttemptsExceeded,
      FailureKey.otpResendCooldown => LocaleKeys.errorHttpOtpResendCooldown,
      FailureKey.otpResendLimitExceeded =>
        LocaleKeys.errorHttpOtpResendLimitExceeded,
      FailureKey.otpRateLimited => LocaleKeys.errorHttpOtpRateLimited,
    };
  }

  static String _authKey(AuthErrorKey key) {
    return switch (key) {
      AuthErrorKey.emailOrPhoneExists => LocaleKeys.errorAuthEmailOrPhoneExists,
      AuthErrorKey.accountNotVerified => LocaleKeys.errorAuthAccountNotVerified,
      AuthErrorKey.invalidCredentials => LocaleKeys.errorAuthInvalidCredentials,
      AuthErrorKey.invalidCode => LocaleKeys.errorAuthInvalidCode,
      AuthErrorKey.userNotFound => LocaleKeys.errorAuthUserNotFound,
      AuthErrorKey.codeExpired => LocaleKeys.errorAuthCodeExpired,
      AuthErrorKey.invalidToken => LocaleKeys.errorAuthInvalidToken,
      AuthErrorKey.emailExists => LocaleKeys.errorAuthEmailExists,
      AuthErrorKey.usernameExists => LocaleKeys.errorAuthUsernameExists,
      AuthErrorKey.phoneExists => LocaleKeys.errorAuthPhoneExists,
      AuthErrorKey.rateLimitExceeded => LocaleKeys.errorAuthRateLimitExceeded,
      AuthErrorKey.codeAttemptsExhausted =>
        LocaleKeys.errorAuthCodeAttemptsExhausted,
      AuthErrorKey.codeResendCooldown => LocaleKeys.errorAuthCodeResendCooldown,
      AuthErrorKey.emailDeliveryFailed =>
        LocaleKeys.errorAuthEmailDeliveryFailed,
      AuthErrorKey.validationError => LocaleKeys.errorAuthValidationError,
      AuthErrorKey.googleSignInCancelled =>
        LocaleKeys.errorAuthGoogleSignInFailed,
      AuthErrorKey.googleSignInFailed => LocaleKeys.errorAuthGoogleSignInFailed,
      AuthErrorKey.googleVerificationFailed =>
        LocaleKeys.errorAuthGoogleVerificationFailed,
      AuthErrorKey.googleConflict => LocaleKeys.errorAuthGoogleConflict,
      AuthErrorKey.googleTokenMissing => LocaleKeys.errorAuthGoogleTokenMissing,

      AuthErrorKey.cacheTokenFailed => LocaleKeys.errorAuthCacheTokenFailed,
      AuthErrorKey.cacheUserFailed => LocaleKeys.errorAuthCacheUserFailed,
    };
  }

  static String _appKey(AppFailureKey key) {
    return switch (key) {
      AppFailureKey.loginRequired => LocaleKeys.errorAppLoginRequired,
      AppFailureKey.loading => LocaleKeys.errorAppLoading,
      AppFailureKey.invalidArgument => LocaleKeys.errorAppInvalidArgument,
    };
  }
}
