import 'auth_error_key.dart';
import 'failure_key.dart';

class BackendErrorCodeResolver {
  const BackendErrorCodeResolver._();

  static FailureKey? httpFailureKeyOf(String? code) {
    if (code == null || code.isEmpty) return null;
    return _commonAndSession[code] ??
        _catalogAndVariants[code] ??
        _cartAndCheckout[code] ??
        _orders[code] ??
        _addressesAndPhone[code] ??
        _otp[code];
  }

  static AuthErrorKey? authFailureKeyOf(
    String? code, {
    bool isGoogleAuth = false,
  }) {
    if (code == null || code.isEmpty) return null;
    if (isGoogleAuth && code == 'INVALID_TOKEN') {
      return AuthErrorKey.googleVerificationFailed;
    }
    return _auth[code];
  }

  // Common/session codes can be returned from several features.
  static const Map<String, FailureKey> _commonAndSession = {
    'AUTH_TOKEN_MISSING': FailureKey.unauthorized,
    'INVALID_TOKEN': FailureKey.unauthorized,
    'INTERNAL_SERVER_ERROR': FailureKey.serverInternal,
    'USER_NOT_FOUND': FailureKey.userNotFound,
  };

  static const Map<String, FailureKey> _catalogAndVariants = {
    'ITEM_NOT_FOUND': FailureKey.itemNotFound,
    'ITEM_NOT_ACTIVE': FailureKey.itemNotActive,
    'VARIANT_REQUIRED': FailureKey.variantRequired,
    'INVALID_VARIANT': FailureKey.invalidVariant,
    'PRODUCT_VARIANT_CONFIGURATION_INVALID': FailureKey.invalidVariant,
    'VARIANT_NOT_ACTIVE': FailureKey.variantNotActive,
    'PRICE_CHANGED': FailureKey.priceChanged,
    'OUT_OF_STOCK': FailureKey.outOfStock,
    'INSUFFICIENT_QUANTITY': FailureKey.insufficientQuantity,
  };

  static const Map<String, FailureKey> _cartAndCheckout = {
    'INVALID_CHECKOUT_DATA': FailureKey.invalidCheckoutData,
    'CHECKOUT_OUT_OF_STOCK': FailureKey.checkoutOutOfStock,
    'IDEMPOTENCY_KEY_CONFLICT': FailureKey.idempotencyKeyConflict,
    'PAYMENT_METHOD_UNAVAILABLE': FailureKey.paymentMethodUnavailable,
    'CART_MAX_QTY': FailureKey.cartMaxQty,
  };

  static const Map<String, FailureKey> _orders = {
    'ORDER_NOT_FOUND': FailureKey.notFound,
    'ORDER_NOT_CANCELABLE': FailureKey.orderNotCancelable,
    'ORDER_NOTE_REQUIRED': FailureKey.orderNoteRequired,
    'ORDER_NOTE_ALREADY_SUBMITTED': FailureKey.orderNoteAlreadySubmitted,
    'ORDER_NOTE_NOT_ALLOWED': FailureKey.orderNoteNotAllowed,
  };

  static const Map<String, FailureKey> _addressesAndPhone = {
    'ADDRESS_NOT_FOUND': FailureKey.addressNotFound,
    'PHONE_REQUIRED': FailureKey.phoneRequired,
    'PHONE_VERIFICATION_REQUIRED': FailureKey.phoneVerificationRequired,
    'INVALID_PHONE': FailureKey.invalidPhone,
    'PHONE_NOT_VERIFIED': FailureKey.phoneNotVerified,
    'PHONE_ALREADY_IN_USE': FailureKey.phoneAlreadyInUse,
    'ADDRESS_NOT_OWNED': FailureKey.addressNotOwned,
  };

  static const Map<String, FailureKey> _otp = {
    'OTP_INVALID': FailureKey.otpInvalid,
    'INVALID_CODE': FailureKey.otpInvalid,
    'OTP_EXPIRED': FailureKey.otpExpired,
    'CODE_EXPIRED': FailureKey.otpExpired,
    'OTP_ATTEMPTS_EXCEEDED': FailureKey.otpAttemptsExceeded,
    'OTP_RESEND_COOLDOWN': FailureKey.otpResendCooldown,
    'OTP_RESEND_LIMIT_EXCEEDED': FailureKey.otpResendLimitExceeded,
    'OTP_RATE_LIMITED': FailureKey.otpRateLimited,
    'VERIFICATION_CANCELLED': FailureKey.otpExpired,
    'VERIFICATION_REPLACED': FailureKey.otpExpired,
    'VERIFICATION_NOT_FOUND': FailureKey.notFound,
  };

  static const Map<String, AuthErrorKey> _auth = {
    'INVALID_CREDENTIALS': AuthErrorKey.invalidCredentials,
    'ACCOUNT_NOT_VERIFIED': AuthErrorKey.accountNotVerified,
    'EMAIL_EXISTS': AuthErrorKey.emailExists,
    'USERNAME_EXISTS': AuthErrorKey.usernameExists,
    'PHONE_EXISTS': AuthErrorKey.phoneExists,
    'EMAIL_OR_PHONE_EXISTS': AuthErrorKey.emailOrPhoneExists,
    'USER_NOT_FOUND': AuthErrorKey.userNotFound,
    'INVALID_CODE': AuthErrorKey.invalidCode,
    'CODE_EXPIRED': AuthErrorKey.codeExpired,
    'CODE_ATTEMPTS_EXHAUSTED': AuthErrorKey.codeAttemptsExhausted,
    'CODE_RESEND_COOLDOWN': AuthErrorKey.codeResendCooldown,
    'EMAIL_DELIVERY_FAILED': AuthErrorKey.emailDeliveryFailed,
    'INVALID_TOKEN': AuthErrorKey.invalidToken,
    'RATE_LIMIT_EXCEEDED': AuthErrorKey.rateLimitExceeded,
    'RATE_LIMIT': AuthErrorKey.rateLimitExceeded,
    'VALIDATION_ERROR': AuthErrorKey.validationError,
    'AUTH_TOKEN_MISSING': AuthErrorKey.invalidToken,
    'REFRESH_TOKEN_MISSING': AuthErrorKey.invalidToken,
    'REFRESH_TOKEN_MALFORMED': AuthErrorKey.invalidToken,
    'REFRESH_TOKEN_INVALID': AuthErrorKey.invalidToken,
    'REFRESH_TOKEN_INVALID_SIGNATURE': AuthErrorKey.invalidToken,
    'REFRESH_TOKEN_EXPIRED': AuthErrorKey.invalidToken,
    'REFRESH_TOKEN_WRONG_TYPE': AuthErrorKey.invalidToken,
    'REFRESH_TOKEN_USER_MISSING': AuthErrorKey.invalidToken,
    'REFRESH_TOKEN_SESSION_MISSING': AuthErrorKey.invalidToken,
    'REFRESH_TOKEN_SESSION_NOT_FOUND': AuthErrorKey.invalidToken,
    'REFRESH_TOKEN_SESSION_EXPIRED': AuthErrorKey.invalidToken,
    'REFRESH_TOKEN_USER_NOT_FOUND': AuthErrorKey.invalidToken,
    'REFRESH_TOKEN_USER_UNAPPROVED': AuthErrorKey.invalidToken,
    'REFRESH_TOKEN_REPLACED': AuthErrorKey.invalidToken,
    'REFRESH_TOKEN_REVOKED': AuthErrorKey.invalidToken,
  };
}
