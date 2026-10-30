enum BackendErrorCode {
  invalidCredentials('INVALID_CREDENTIALS'),
  adminInvalidCredentials('ADMIN_INVALID_CREDENTIALS'),
  accountNotVerified('ACCOUNT_NOT_VERIFIED'),
  validationError('VALIDATION_ERROR'),
  userNotFound('USER_NOT_FOUND'),
  tokenMissing('TOKEN_MISSING'),
  tokenInvalid('TOKEN_INVALID'),
  tokenExpired('TOKEN_EXPIRED'),
  refreshTokenInvalid('REFRESH_TOKEN_INVALID'),
  sessionExpired('SESSION_EXPIRED'),
  adminSessionRevoked('ADMIN_SESSION_REVOKED'),
  adminForbidden('ADMIN_FORBIDDEN'),
  productNotFound('PRODUCT_NOT_FOUND'),
  categoryNotFound('CATEGORY_NOT_FOUND'),
  categoryValidationError('CATEGORY_VALIDATION_ERROR'),
  categoryImageInvalid('CATEGORY_IMAGE_INVALID'),
  categoryImageTooLarge('CATEGORY_IMAGE_TOO_LARGE'),
  categoryImageStorageFailed('CATEGORY_IMAGE_STORAGE_FAILED'),
  categoryParentNotFound('CATEGORY_PARENT_NOT_FOUND'),
  categoryHierarchyInvalid('CATEGORY_HIERARCHY_INVALID'),
  categoryCycleDetected('CATEGORY_CYCLE_DETECTED'),
  categoryMustBeInactive('CATEGORY_MUST_BE_INACTIVE'),
  categoryHasProducts('CATEGORY_HAS_PRODUCTS'),
  categoryHasChildren('CATEGORY_HAS_CHILDREN'),
  variantNotFound('VARIANT_NOT_FOUND'),
  productMustBeInactive('PRODUCT_MUST_BE_INACTIVE'),
  productDeleteBlocked('PRODUCT_DELETE_BLOCKED'),
  variantMustBeInactive('VARIANT_MUST_BE_INACTIVE'),
  variantDeleteBlocked('VARIANT_DELETE_BLOCKED'),
  lastVariantDeleteForbidden('LAST_VARIANT_DELETE_FORBIDDEN'),
  categoryNotAvailable('CATEGORY_NOT_AVAILABLE'),
  audienceNotAvailable('AUDIENCE_NOT_AVAILABLE'),
  audienceNotFound('AUDIENCE_NOT_FOUND'),
  audienceNameArConflict('AUDIENCE_NAME_AR_CONFLICT'),
  audienceNameEnConflict('AUDIENCE_NAME_EN_CONFLICT'),
  audienceLastActive('AUDIENCE_LAST_ACTIVE'),
  audienceMustBeInactive('AUDIENCE_MUST_BE_INACTIVE'),
  audienceHasProducts('AUDIENCE_HAS_PRODUCTS'),
  audienceHasCollections('AUDIENCE_HAS_COLLECTIONS'),
  audienceHasBanners('AUDIENCE_HAS_BANNERS'),
  bannerNotFound('BANNER_NOT_FOUND'),
  bannerImageRequired('BANNER_IMAGE_REQUIRED'),
  bannerImageStorageFailed('BANNER_IMAGE_STORAGE_FAILED'),
  bannerAudienceNotFound('BANNER_AUDIENCE_NOT_FOUND'),
  bannerAudienceInactive('BANNER_AUDIENCE_INACTIVE'),
  bannerActionTargetNotFound('BANNER_ACTION_TARGET_NOT_FOUND'),
  bannerActionTargetInactive('BANNER_ACTION_TARGET_INACTIVE'),
  collectionNotFound('COLLECTION_NOT_FOUND'),
  collectionImageRequired('COLLECTION_IMAGE_REQUIRED'),
  collectionImageStorageFailed('COLLECTION_IMAGE_STORAGE_FAILED'),
  collectionAudienceNotFound('COLLECTION_AUDIENCE_NOT_FOUND'),
  collectionAudienceInactive('COLLECTION_AUDIENCE_INACTIVE'),
  collectionProductNotFound('COLLECTION_PRODUCT_NOT_FOUND'),
  collectionProductInactive('COLLECTION_PRODUCT_INACTIVE'),
  collectionProductAudienceMismatch('COLLECTION_PRODUCT_AUDIENCE_MISMATCH'),
  collectionDuplicateProduct('COLLECTION_DUPLICATE_PRODUCT'),
  collectionDeleteRequiresInactive('COLLECTION_DELETE_REQUIRES_INACTIVE'),
  collectionDeleteBlockedByBanners('COLLECTION_DELETE_BLOCKED_BY_BANNERS'),
  sizeGroupNotAvailable('SIZE_GROUP_NOT_AVAILABLE'),
  sizeGroupLockedByVariants('SIZE_GROUP_LOCKED_BY_VARIANTS'),
  mediaTargetNotFound('MEDIA_TARGET_NOT_FOUND'),
  imageNotFound('IMAGE_NOT_FOUND'),
  imageNotInTarget('IMAGE_NOT_IN_TARGET'),
  mediaOrderConflict('MEDIA_ORDER_CONFLICT'),
  variantCombinationExists('VARIANT_COMBINATION_EXISTS'),
  variantShapeConflict('VARIANT_SHAPE_CONFLICT'),
  variantShapeInconsistent('VARIANT_SHAPE_INCONSISTENT'),
  colorNotFound('COLOR_NOT_FOUND'),
  colorNameConflict('COLOR_NAME_CONFLICT'),
  colorInUse('COLOR_IN_USE'),
  colorNotAvailable('COLOR_NOT_AVAILABLE'),
  sizeGroupNameConflict('SIZE_GROUP_NAME_CONFLICT'),
  sizeValueNameConflict('SIZE_VALUE_NAME_CONFLICT'),
  sizeGroupNotFound('SIZE_GROUP_NOT_FOUND'),
  sizeValueNotFound('SIZE_VALUE_NOT_FOUND'),
  sizeNotAvailable('SIZE_NOT_AVAILABLE'),
  notificationProductNotFound('NOTIFICATION_PRODUCT_NOT_FOUND'),
  notificationPayloadTooLarge('NOTIFICATION_PAYLOAD_TOO_LARGE'),
  notificationsUnavailable('NOTIFICATIONS_UNAVAILABLE'),
  notificationSendFailed('NOTIFICATION_SEND_FAILED'),
  orderNotificationTemplateNotFound('ORDER_NOTIFICATION_TEMPLATE_NOT_FOUND'),
  orderNotificationTemplatesUnavailable(
    'ORDER_NOTIFICATION_TEMPLATES_UNAVAILABLE',
  ),
  internalServerError('INTERNAL_SERVER_ERROR'),
  unknown('UNKNOWN');

  const BackendErrorCode(this.v);

  final String v;

  static BackendErrorCode? fromValue(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    for (final code in BackendErrorCode.values) {
      if (code.v == value) {
        return code;
      }
    }

    return BackendErrorCode.unknown;
  }
}
