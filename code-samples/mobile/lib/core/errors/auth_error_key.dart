enum AuthErrorKey {
  emailOrPhoneExists,
  accountNotVerified,
  invalidCredentials,
  cacheTokenFailed,
  cacheUserFailed,

  invalidCode, // 422 Invalid verification code
  userNotFound, // 404 User not found
  codeExpired, // 410 Code expired
  invalidToken, // 401 Invalid token
  emailExists, // 409 Email exists
  usernameExists, // 409 Username exists
  phoneExists, // 409 Phone exists
  rateLimitExceeded, // 429 Rate limit exceeded
  codeAttemptsExhausted,
  codeResendCooldown,
  emailDeliveryFailed,
  validationError, // 422 General validation error
  googleSignInCancelled,
  googleSignInFailed,
  googleVerificationFailed,
  googleConflict,
  googleTokenMissing,
}
