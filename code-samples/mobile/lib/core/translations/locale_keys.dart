abstract class LocaleKeys {
  // Common
  static const loading = 'common.loading';
  static const next = 'common.next';
  static const back = 'common.back';
  static const close = 'common.close';
  static const continueAction = 'common.continue';
  static const confirm = 'common.confirm';
  static const cancel = 'common.cancel';
  static const resend = 'common.resend';
  static const copy = 'common.copy';
  static const price = 'common.price';
  static const retry = 'common.retry';

  static const retryMessage = 'common.retry_message';
  static const showMore = 'common.show_more';
  static const showLess = 'common.show_less';
  static const outOfStock = 'common.out_of_stock';
  static const selectVariant = 'common.select_variant';
  static const noVariantsAvailable = 'common.no_variants_available';
  static const addToCart = 'common.add_to_cart';
  static const addedToFavorites = 'common.added_to_favorites';
  static const removedFromFavorites = 'common.removed_from_favorites';
  static const addToCartUnavailable = 'common.add_to_cart_unavailable';
  static const productQuantity = 'common.product_quantity';

  // App shell
  static const appExit = 'app.exit';
  static const appStay = 'app.stay';
  static const appExitConfirm = 'app.exit_confirm';

  // Onboarding
  static const onboardingTitle1 = 'onboarding.title.1';
  static const onboardingSubtitle1 = 'onboarding.subtitle.1';
  static const onboardingTitle2 = 'onboarding.title.2';
  static const onboardingSubtitle2 = 'onboarding.subtitle.2';
  static const onboardingTitle3 = 'onboarding.title.3';
  static const onboardingSubtitle3 = 'onboarding.subtitle.3';
  static const onboardingButtonNext = 'onboarding.button.next';
  static const onboardingButtonStart = 'onboarding.button.start';
  static const onboardingSignin = 'onboarding.signin';
  static const onboardingHaveAccount = 'onboarding.have_account';
  static const onboardingPageProgress = 'onboarding.page_progress';

  // Auth - Login
  static const authLoginTitle = 'auth.login.title';
  static const authLoginWelcomeBack = 'auth.login.welcome_back';
  static const authLoginSubtitle = 'auth.login.subtitle';
  static const authLoginEmailLabel = 'auth.login.email_label';
  static const authLoginEmailHint = 'auth.login.email_hint';
  static const authLoginPasswordLabel = 'auth.login.password_label';
  static const authLoginPasswordHint = 'auth.login.password_hint';
  static const authLoginForgetPassword = 'auth.login.forget_password';
  static const authLoginButton = 'auth.login.button';
  static const authLoginLoadingButton = 'auth.login_loading.button';
  static const authLoginNoAccount = 'auth.login.no_account';
  static const authLoginSignupLink = 'auth.login.signup_link';
  static const authContinueAsGuest = 'auth.continue_as_guest';
  static const authContinueWithGoogle = 'auth.continue_with_google';
  static const authGoogleLoading = 'auth.google_loading';
  static const authOr = 'auth.or';

  // Auth - Signup
  static const authSignupTitle = 'auth.signup.title';
  static const authSignupWelcome = 'auth.signup.welcome';
  static const authSignupSubtitle = 'auth.signup.subtitle';
  static const authSignupUsernameLabel = 'auth.signup.username_label';
  static const authSignupUsernameHint = 'auth.signup.username_hint';
  static const authSignupEmailLabel = 'auth.signup.email_label';
  static const authSignupEmailHint = 'auth.signup.email_hint';
  static const authSignupPhoneLabel = 'auth.signup.phone_label';
  static const authSignupPhoneHint = 'auth.signup.phone_hint';
  static const authSignupPasswordLabel = 'auth.signup.password_label';
  static const authSignupPasswordHint = 'auth.signup.password_hint';
  static const authSignupConfirmPasswordLabel =
      'auth.signup.confirm_password_label';
  static const authSignupConfirmPasswordHint =
      'auth.signup.confirm_password_hint';
  static const authSignupButton = 'auth.signup.button';
  static const authSignupLodingButton = 'auth.signup.button.loding';

  static const authSignupHaveAccount = 'auth.signup.have_account';
  static const authSignupLoginLink = 'auth.signup.login_link';
  static const authSignupSuccessMsg = 'auth.signup.success_msg';
  static const authSignupEmailExists = 'auth.signup.email_exists';
  static const authSignupAccountNotVerified =
      'auth.signup.account_not_verified';

  // Auth - Verify Email
  static const authVerifyEmailTitle = 'auth.verify_email.title';
  static const authVerifyEmailSubtitle = 'auth.verify_email.subtitle';
  static const authVerifyEmailSentTo = 'auth.verify_email.email_sent_to';
  static const authVerifyEmailCodeLabel = 'auth.verify_email.code_label';
  static const authVerifyEmailCodeHint = 'auth.verify_email.code_hint';
  static const authVerifyEmailResendTimer = 'auth.verify_email.resend_timer';
  static const authVerifyEmailResendButton = 'auth.verify_email.resend_button';
  static const authVerifyEmailButton = 'auth.verify_email.button';
  static const authVerifyEmailSuccessTitle = 'auth.verify_email.success_title';
  static const authVerifyEmailSuccessMsg = 'auth.verify_email.success_msg';
  static const authVerifyEmailResendSuccess =
      'auth.verify_email.resend_success';
  static const authVerifyEmailArgumentsIsEmpty =
      'auth.verify_email.arguments_is_empty';

  // Auth - Forget Password
  static const authForgetPasswordTitle = 'auth.forget_password.title';
  static const authForgetPasswordSubtitle = 'auth.forget_password.subtitle';
  static const authForgetPasswordButton = 'auth.forget_password.button';
  static const authForgetPasswordSuccessMsg =
      'auth.forget_password.success_msg';

  // Auth - Verify Reset Code
  static const authVerifyResetTitle = 'auth.verify_reset.title';
  static const authVerifyResetSubtitle = 'auth.verify_reset.subtitle';
  static const authVerifyResetResendButton = 'auth.verify_reset.resend_button';
  static const authVerifyResetResendTimer = 'auth.verify_reset.resend_timer';
  static const authVerifyResetCodeHint = 'auth.verify_reset.code_hint';
  static const authVerifyResetSuccessMsgSnackbar =
      'auth.verify_reset.success_msg_snackbar';
  static const authVerifyResetArgumentsIsEmpty =
      'auth.verify_reset.arguments_is_empty';
  static const authVerifyResetExpired = 'auth.verify_reset.expired';
  static const authVerifyResetSuccessDialogRecentCode =
      'auth.verify_reset.success_dialog_recent_code';

  // Auth - Reset Password
  static const authResetPasswordTitle = 'auth.reset_password.title';
  static const authResetPasswordSubtitle = 'auth.reset_password.subtitle';
  static const authResetPasswordNewPasswordLabel =
      'auth.reset_password.new_password_label';
  static const authResetPasswordNewPasswordHint =
      'auth.reset_password.new_password_hint';
  static const authResetPasswordConfirmPasswordLabel =
      'auth.reset_password.confirm_password_label';
  static const authResetPasswordConfirmPasswordHint =
      'auth.reset_password.confirm_password_hint';
  static const authResetPasswordMismatch = 'auth.reset_password.mismatch';
  static const authResetPasswordButton = 'auth.reset_password.button';
  static const authResetPasswordSuccessMsg = 'auth.reset_password.success_msg';

  // Home
  static const homeTitleCat = 'home.title_cat';
  static const homeNoItems = 'home.no_items';
  static const homeTitleAllItems = 'home.title_all_items';
  static const homeAllItems = 'home.all_items';
  static const homeNewArrivals = 'home.new_arrivals';
  static const homeFeaturedProducts = 'home.featured_products';
  static const homeCollectionsTitle = 'home.collections_title';
  static const homeCollectionsHeader = 'home.collections_header';
  static const homeCollectionsSubtitle = 'home.collections_subtitle';
  static const homeOffersTitle = 'home.offers_title';
  static const homeOffersSubtitle = 'home.offers_subtitle';
  static const homeOffersViewAll = 'home.offers_view_all';

  // Item Details
  static const itemDetailsTitle = 'item_details.title';
  static const itemDetailsEmptyView = 'item_details.empty_view';
  static const itemDetailsChooseColor = 'item_details.choose_color';
  static const itemDetailsNoColors = 'item_details.no_colors';
  static const itemDetailsNoSizes = 'item_details.no_sizes';
  static const itemDetailsChooseSize = 'item_details.choose_size';
  static const itemDetailsDescription = 'item_details.description';
  static const itemDetailsProductDescription =
      'item_details.product_description';
  static const itemDetailsSelectedVariantDetails =
      'item_details.selected_variant_details';
  static const itemDetailsStockRemaining = 'item_details.stock_remaining';
  static const itemDetailsRecommendedTitle = 'item_details.recommended.title';
  static const itemDetailsRecommendedRetry = 'item_details.recommended.retry';
  static const itemDetailsRecommendedFirstLoadError =
      'item_details.recommended.first_load_error';
  static const itemDetailsRecommendedLoadMoreError =
      'item_details.recommended.load_more_error';
  static const itemDetailsRecommendedEmpty = 'item_details.recommended.empty';
  static const itemDetailsTabDetails = 'item_details.tab.details';
  static const itemDetailsTabRecommended = 'item_details.tab.recommended';

  // Search
  static const productSearchTitle = 'search.products.title';
  static const productSearchHint = 'search.products.hint';
  static const productSearchGuidance = 'search.products.guidance';
  static const productSearchEmpty = 'search.products.empty';
  static const productSearchClear = 'search.products.clear';
  static const productSearchLoadMoreRetry = 'search.products.load_more_retry';
  static const productSearchQueryTooLong = 'search.products.query_too_long';

  // Listing
  static const listingSortNewest = 'listing.sort.newest';
  static const listingSortPriceAsc = 'listing.sort.price_asc';
  static const listingSortPriceDesc = 'listing.sort.price_desc';
  static const listingSortDiscountDesc = 'listing.sort.discount_desc';
  static const listingSortCustomOrder = 'listing.sort.custom_order';
  static const listingSortRelevance = 'listing.sort.relevance';
  static const listingSortTitle = 'listing.sort.title';
  static const listingSearchHint = 'listing.search.hint';
  static const listingSearchTooltip = 'listing.search.tooltip';
  static const listingSearchEmptyProducts = 'listing.search.empty_products';
  static const listingClearSearch = 'listing.search.clear';
  static const listingFilterTitle = 'listing.filter.title';
  static const listingFilterClearAll = 'listing.filter.clear_all';
  static const listingFilterColor = 'listing.filter.color';
  static const listingFilterSize = 'listing.filter.size';
  static const listingFilterPrice = 'listing.filter.price';
  static const listingFilterApply = 'listing.filter.apply';
  static const listingEmptyProducts = 'listing.empty.products';
  static const listingClearFilters = 'listing.empty.clear_filters';
  static const listingProductsCount = 'listing.products_count';
  static const listingPriceRangeUnavailable = 'listing.price_range_unavailable';

  static const listingEmptyColors = 'listing.empty.colors';
  static const listingEmptySizes = 'listing.empty.sizes';
  static const listingRetrySubcategories = 'listing.retry.subcategories';

  // Cart
  static const cartEmptyCart = 'cart.empty_cart';

  static const cartShopNow = 'cart.shop_now';
  static const cartAppbarTitle = 'cart.appbar_title';
  static const cartShippingTo = 'cart.shipping_to';
  static const cartCheckout = 'cart.checkout';
  static const cartCheckoutSavedPrice = 'cart.checkout.saved_price';
  static const cartSnackbarMaxQuantity = 'cart.snackbar.max_quantity';
  static const cartIncreaseQuantity = 'cart.increase_quantity';
  static const cartDecreaseQuantity = 'cart.decrease_quantity';
  static const cartDeleteItem = 'cart.delete_item';
  static const cartSelectItem = 'cart.select_item';
  static const cartItemNeedsVariant = 'cart.item_needs_variant';
  static const cartItemUnavailable = 'cart.item_unavailable';
  static const cartCheckoutBlockedNeedsVariant =
      'cart.checkout_blocked_needs_variant';
  static const cartSelectDeliveryAddress = 'cart.select_delivery_address';
  static const cartSubtotal = 'cart.subtotal';
  static const cartPendingChanges = 'cart.pending_changes';
  static const cartStockChanged = 'cart.stock_changed';
  static const selectVariantFirst = 'cart.select_variant_first';
  static const cartAddSuccess = 'cart.add_success';
  static const cartUpdateSuccess = 'cart.update_success';
  static const cartRemoveSuccess = 'cart.remove_success';
  static const cartRecommendedTitle = 'cart.recommended.title';
  static const cartRecommendedRetry = 'cart.recommended.retry';
  static const cartRecommendedFirstLoadError =
      'cart.recommended.first_load_error';
  static const cartDeleteAll = 'cart.delete_all';

  // Checkout
  static const checkoutAppbarTitle1 = 'checkout.appbar_title_1';
  static const checkoutAppbarTitle2 = 'checkout.appbar_title_2';
  static const checkoutAppbarTitle3 = 'checkout.appbar_title_3';
  static const checkoutPaymentMethodCashOnDelivery =
      'checkout.payment_method.cash_on_delivery';
  static const checkoutPaymentMethodCashOnDeliveryDescription =
      'checkout.payment_method.cash_on_delivery.description';
  static const checkoutPaymentMethodOnline = 'checkout.payment_method.online';
  static const checkoutPaymentMethodOnlineDescription =
      'checkout.payment_method.online.description';
  static const checkoutOrderNoteLabel = 'checkout.order_note.label';
  static const checkoutOrderNoteHint = 'checkout.order_note.hint';

  // Favorites
  static const favoritesBrowseProducts = 'favorites.browse_products';
  static const favoritesEmpty = 'favorites.empty';
  static const favoritesEmptyDescription = 'favorites.empty.description';
  static const favoritesTitle = 'favorites.title';
  static const favoritesClearAll = 'favorites.clear_all';
  static const favoritesClearAllConfirmation =
      'favorites.clear_all.confirmation';
  static const favoritesClearAllSuccess = 'favorites.clear_all.success';
  static const favoritesClearAllRetryMessage =
      'favorites.clear_all.retry_message';
  static const favoritesStatusUnavailable = 'favorites.status.unavailable';
  static const favoritesStatusItemInactive = 'favorites.status.item_inactive';
  static const favoritesStatusVariantInactive =
      'favorites.status.variant_inactive';
  static const favoritesStatusInvalidVariant =
      'favorites.status.invalid_variant';
  static const favoritesPriceAlert = 'favorites.price_alert';
  static const favoritesPriceDropPercent = 'favorites.price_drop_percent';
  static const favoritesPriceDropAmount = 'favorites.price_drop_amount';
  static const favoritesRecommendedTitle = 'favorites.recommended.title';
  static const favoritesRecommendedRetry = 'favorites.recommended.retry';
  static const favoritesRecommendedFirstLoadError =
      'favorites.recommended.first_load_error';
  static const favoritesRecommendedRefreshError =
      'favorites.recommended.refresh_error';
  static const favoritesTabFavorites = 'favorites.tab.favorites';
  static const favoritesTabRecommended = 'favorites.tab.recommended';
  static const favoritesRemoveItem = 'favorites.remove_item';
  static const favoritesRemoveItemConfirmation =
      'favorites.remove_item_confirmation';

  // Errors
  static const errorAppLoading = 'error.app.loading';
  static const errorAppLoginRequired = 'error.app.login_required';
  static const errorAppLoginRequiredButton = 'error.app.login_required_button';
  static const errorAppTryAgain = 'error.app.try_again';
  static const errorAppInvalidArgument = 'error.app.invalid_argument';
  static const errorImageView = 'error.app.invalid_image';

  static const errorAppStartupTitle = 'error.app.startup_title';
  static const errorAppStartupMessage = 'error.app.startup_message';
  static const errorNetworkNoInternet = 'error.network.no_internet';
  static const errorNetworkTimeout = 'error.network.timeout';
  static const errorServerInternal = 'error.server.internal';
  static const errorServerUnavailable = 'error.server.unavailable';
  static const errorUnknown = 'error.unknown';

  // HTTP Errors
  static const errorHttpNoInternet = 'error.http.no_internet';
  static const errorHttpTimeout = 'error.http.timeout';
  static const errorHttpValidation = 'error.http.validation';
  static const errorHttpConflict = 'error.http.conflict';
  static const errorHttpUnauthorized = 'error.http.unauthorized';
  static const errorHttpForbidden = 'error.http.forbidden';
  static const errorHttpNotFound = 'error.http.not_found';
  static const errorHttpTooManyRequests = 'error.http.too_many_requests';
  static const errorHttpServer = 'error.http.server';
  static const errorHttpServerUnavailable = 'error.http.server_unavailable';
  static const errorHttpInvalidData = 'error.http.invalid_data';
  static const errorHttpCancelled = 'error.http.cancelled';
  static const errorHttpBadRequest = 'error.http.bad_request';
  static const errorHttpServerGeneric = 'error.http.server_generic';
  static const errorHttpUnexpected = 'error.http.unexpected';
  static const errorHttpEmpty = 'error.http.empty';
  static const errorHttpLocal = 'error.http.local';
  static const errorHttpMissingServerData = 'error.http.missing_server_data';
  static const errorHttpInvalidCheckoutData =
      'error.http.invalid_checkout_data';
  static const errorHttpItemNotFound = 'error.http.item_not_found';
  static const errorHttpItemNotActive = 'error.http.item_not_active';
  static const errorHttpVariantRequired = 'error.http.variant_required';
  static const errorHttpInvalidVariant = 'error.http.invalid_variant';
  static const errorHttpVariantNotActive = 'error.http.variant_not_active';
  static const errorHttpPriceChanged = 'error.http.price_changed';
  static const errorHttpOutOfStock = 'error.http.out_of_stock';
  static const errorHttpInsufficientQuantity =
      'error.http.insufficient_quantity';
  static const errorHttpCheckoutOutOfStock = 'error.http.checkout_out_of_stock';
  static const errorHttpIdempotencyKeyConflict =
      'error.http.idempotency_key_conflict';
  static const errorHttpPaymentMethodUnavailable =
      'error.http.payment_method_unavailable';
  static const errorHttpOrderNotCancelable = 'error.http.order_not_cancelable';
  static const errorHttpOrderNoteRequired = 'error.http.order_note_required';
  static const errorHttpOrderNoteAlreadySubmitted =
      'error.http.order_note_already_submitted';
  static const errorHttpOrderNoteNotAllowed =
      'error.http.order_note_not_allowed';
  static const errorHttpCartMaxQty = 'error.http.cart_max_qty';
  static const errorHttpUserNotFound = 'error.http.user_not_found';
  static const errorHttpPhoneRequired = 'error.http.phone_required';
  static const errorHttpPhoneVerificationRequired =
      'error.http.phone_verification_required';
  static const errorHttpInvalidPhone = 'error.http.invalid_phone';
  static const errorHttpPhoneNotVerified = 'error.http.phone_not_verified';
  static const errorHttpPhoneAlreadyInUse = 'error.http.phone_already_in_use';
  static const errorHttpAddressNotFound = 'error.http.address_not_found';
  static const errorHttpAddressNotOwned = 'error.http.address_not_owned';
  static const errorHttpOtpInvalid = 'error.http.otp_invalid';
  static const errorHttpOtpExpired = 'error.http.otp_expired';
  static const errorHttpOtpAttemptsExceeded =
      'error.http.otp_attempts_exceeded';
  static const errorHttpOtpResendCooldown = 'error.http.otp_resend_cooldown';
  static const errorHttpOtpResendLimitExceeded =
      'error.http.otp_resend_limit_exceeded';
  static const errorHttpOtpRateLimited = 'error.http.otp_rate_limited';

  // Auth Errors
  static const errorAuthUserNotFound = 'error.auth.user_not_found';
  static const errorAuthInvalidCredentials = 'error.auth.invalid_credentials';
  static const errorAuthAccountNotVerified = 'error.auth.account_not_verified';
  static const errorAuthEmailExists = 'error.auth.email_exists';
  static const errorAuthUsernameExists = 'error.auth.username_exists';
  static const errorAuthPhoneExists = 'error.auth.phone_exists';
  static const errorAuthEmailOrPhoneExists = 'error.auth.email_or_phone_exists';
  static const errorAuthInvalidCode = 'error.auth.invalid_code';
  static const errorAuthCodeExpired = 'error.auth.code_expired';
  static const errorAuthCodeResentFailed = 'error.auth.code_resent_failed';
  static const errorAuthInvalidToken = 'error.auth.invalid_token';
  static const errorAuthRateLimitExceeded = 'error.auth.rate_limit_exceeded';
  static const errorAuthCodeAttemptsExhausted =
      'error.auth.code_attempts_exhausted';
  static const errorAuthCodeResendCooldown = 'error.auth.code_resend_cooldown';
  static const errorAuthEmailDeliveryFailed =
      'error.auth.email_delivery_failed';
  static const errorAuthValidationError = 'error.auth.validation_error';
  static const errorAuthCacheTokenFailed = 'error.auth.cache_token_failed';
  static const errorAuthCacheUserFailed = 'error.auth.cache_user_failed';
  static const errorAuthGoogleSignInFailed = 'error.auth.google_sign_in_failed';
  static const errorAuthGoogleVerificationFailed =
      'error.auth.google_verification_failed';
  static const errorAuthGoogleConflict = 'error.auth.google_conflict';
  static const errorAuthGoogleTokenMissing = 'error.auth.google_token_missing';

  // Validation
  static const validationRequired = 'validation.required';
  static const validationEmailInvalid = 'validation.email_invalid';
  static const validationPhoneInvalid = 'validation.phone_invalid';
  static const validationPasswordShort = 'validation.password_short';
  static const validationUsernameShort = 'validation.username_short';
  static const validationLengthMax = 'validation.length_max';
  static const validationLengthMin = 'validation.length_min';
  static const validationUsernameInvalid = 'validation.username_invalid';
  static const validationPasswordInvalid = 'validation.password_invalid';
  static const validationPasswordLengthMin = 'validation.password_length_min';
  static const validationInvalidSpecialChar = 'validation.invalid_special_char';
  static const validationPhoneInvalidCountry =
      'validation.phone_invalid_country';

  // Addresses
  static const addressesTitle = 'addresses.title';
  static const addressesAddNewAddress = 'addresses.add_new_address';
  static const addressesEditAddress = 'addresses.edit_address';
  static const addressesUpdateAddress = 'addresses.update_address';
  static const addressesSaveAddress = 'addresses.save_address';
  static const addressesErrorLoadingCities = 'addresses.error_loading_cities';
  static const addressesStreet1Label = 'addresses.street1_label';
  static const addressesStreet1Hint = 'addresses.street1_hint';
  static const addressesStreet2Label = 'addresses.street2_label';
  static const addressesStreet2Hint = 'addresses.street2_hint';
  static const addressesPhoneLabel = 'addresses.phone_label';
  static const addressesPhoneHint = 'addresses.phone_hint';
  static const addressesCityLabel = 'addresses.city_label';
  static const addressesAreaLabel = 'addresses.area_label';
  static const addressesEmpty = 'addresses.empty';
  static const addressesLoadingCities = 'addresses.loading_cities';
  static const addressesLoadingAreas = 'addresses.loading_areas';
  static const addressesSelectCity = 'addresses.select_city';
  static const addressesSelectArea = 'addresses.select_area';
  static const phoneVerificationInvalidSession =
      'phoneVerificationInvalidSession';

  // Orders
  static const ordersSummary = 'orders.summary';
  static const ordersSubtotal = 'orders.subtotal';
  static const ordersDeliveryFee = 'orders.delivery_fee';
  static const ordersTotal = 'orders.total';
  static const ordersYouSaved = 'orders.you_saved';
  static const ordersProductPrice = 'orders.product_price';
  static const ordersDiscount = 'orders.discount';
  static const ordersTotalItems = 'orders.total_items';
  static const ordersQuantity = 'orders.quantity';
  static const ordersDetails = 'orders.details';
  static const ordersDeliveryInformation = 'orders.delivery_information';
  static const ordersOrderId = 'orders.order_id';
  static const ordersOrderedAt = 'orders.ordered_at';
  static const ordersBuyAgain = 'orders.buy_again';
  static const ordersPayment = 'orders.payment';
  static const ordersPaymentMethod = 'orders.payment_method';
  static const ordersPaymentStatus = 'orders.payment_status';
  static const ordersPaymentStatusUnpaid = 'orders.payment_status.unpaid';
  static const ordersPaymentStatusPaid = 'orders.payment_status.paid';
  static const ordersPaymentStatusFailed = 'orders.payment_status.failed';
  static const ordersPaymentStatusRefunded = 'orders.payment_status.refunded';
  static const ordersPaymentMethodCashOnDelivery =
      'orders.payment_method.cash_on_delivery';
  static const ordersPaymentMethodOnline = 'orders.payment_method.online';
  static const ordersPaymentMethodUnknown = 'orders.payment_method.unknown';
  static const ordersPaymentStatusUnknown = 'orders.payment_status.unknown';
  static const ordersDeliveredAt = 'orders.delivered_at';
  static const ordersCancelledAt = 'orders.cancelled_at';
  static const ordersRejectedAt = 'orders.rejected_at';
  static const ordersReturnedAt = 'orders.returned_at';
  static const ordersUpdatedAt = 'orders.updated_at';
  static const ordersCancelOrder = 'orders.cancel_order';
  static const ordersCancelConfirm = 'orders.cancel_confirm';
  static const ordersCancelReasonLabel = 'orders.cancel_reason_label';
  static const ordersCancelReasonHint = 'orders.cancel_reason_hint';
  static const ordersCancelSuccess = 'orders.cancel_success';
  static const ordersSubmitNote = 'orders.submit_note';
  static const ordersSendNote = 'orders.send_note';
  static const ordersNoteHint = 'orders.note_hint';
  static const ordersNoteRequired = 'orders.note_required';
  static const ordersNoteSuccess = 'orders.note_success';
  static const ordersProductUnavailable = 'orders.product_unavailable';
  static const ordersMyOrders = 'orders.my_orders';
  static const ordersTabAll = 'orders.tab.all';
  static const ordersTabPending = 'orders.tab.pending';
  static const ordersTabCompleted = 'orders.tab.completed';
  static const ordersTabCancelled = 'orders.tab.cancelled';
  static const ordersEmptyTitle = 'orders.empty.title';
  static const ordersFilteredEmptyTitle = 'orders.empty.filtered_title';
  static const ordersEmptyAction = 'orders.empty.action';
  static const ordersOrderNumber = 'orders.order_number';
  static const ordersItemsCount = 'orders.items_count';
  static const ordersStatusPending = 'orders.status.pending';
  static const ordersStatusProcessing = 'orders.status.processing';
  static const ordersStatusDelivered = 'orders.status.delivered';
  static const ordersStatusCancelled = 'orders.status.cancelled';
  static const ordersStatusRejected = 'orders.status.rejected';
  static const ordersStatusReturned = 'orders.status.returned';
  static const ordersStatusUnknown = 'orders.status.unknown';
  static const ordersRefreshFailed = 'orders.refresh_failed';

  // Account
  static const accountTitle = 'account.title';
  static const accountShopping = 'account.shopping';
  static const accountAppAndHelp = 'account.app_and_help';
  static const accountGuestTitle = 'account.guest_title';
  static const accountGuestMessage = 'account.guest_message';
  static const accountLogin = 'account.login';
  static const accountLogoutServerWarning = 'account.logout_server_warning';
  static const accountMyOrders = 'account.my_orders';
  static const accountAddresses = 'account.addresses';
  static const accountSettings = 'account.settings';
  static const accountContactUs = 'account.contact_us';
  static const accountLogout = 'account.logout';
  static const accountLogoutConfirm = 'account.logout_confirm';

  // Settings
  static const settingsTitle = 'settings.title';
  static const settingsAppPreferences = 'settings.app_preferences';
  static const settingsPrivacyAndData = 'settings.privacy_and_data';
  static const settingsDebug = 'settings.debug';
  static const settingsLanguage = 'settings.language';
  static const settingsTheme = 'settings.theme';
  static const settingsContactUs = 'settings.contact_us';
  static const settingsLogout = 'settings.logout';
  static const settingsLogoutConfirm = 'settings.logout_confirm';
  static const settingsAboutWhatsapp = 'settings.about_whatsapp';
  static const settingsAboutPhone = 'settings.about_phone';
  static const settingsAboutWhatsappConfirm = 'settings.about_whatsapp_confirm';
  static const settingsAboutPhoneConfirm = 'settings.about_phone_confirm';
  static const settingsAboutSocialMedia = 'settings.about_social_media';
  static const settingsFacebook = 'settings.facebook';
  static const settingsInstagram = 'settings.instagram';
  static const settingsCopySuccess = 'settings.copy_success';
  static const settingsLaunchFailed = 'settings.launch_failed';
  static const settingsLanguageArabic = 'settings.language_arabic';
  static const settingsLanguageEnglish = 'settings.language_english';
  static const settingsThemeDark = 'settings.theme_dark';
  static const settingsThemeLight = 'settings.theme_light';
  static const settingsThemeModeLight = 'theme_mode.light';
  static const settingsThemeModeDark = 'theme_mode.dark';
  static const settingsClearRecentlyViewed = 'settings.clear_recently_viewed';
  static const settingsClearRecentlyViewedMessage =
      'settings.clear_recently_viewed_message';
  static const settingsRecentlyViewedClearedSuccess =
      'settings.recently_viewed_cleared_success';
  static const settingsDebugReset = 'settings.debug_reset';
  static const settingsDebugResetConfirm = 'settings.debug_reset_confirm';
  static const settingsDebugSimulateTerminalSessionExpiry =
      'settings.debug_simulate_terminal_session_expiry';

  // Language
  static const languageChooseLanguage = 'language.choose_language';
  static const languageArabic = 'language.arabic';
  static const languageEnglish = 'language.english';

  // Addresses extra
  static const addressesSelectAreaFirst = 'addresses.select_area_first';
  static const addressesAddressSelected = 'addresses.address_selected';
  static const addressesCity = 'addresses.city';
  static const addressesArea = 'addresses.area';
  static const addressesStreet1 = 'addresses.street_1';
  static const addressesStreet2 = 'addresses.street_2';
  static const addressesPhone = 'addresses.phone';
  static const addressesSelect = 'addresses.select';
  static const addressesChange = 'addresses.change';
  static const addressesEdit = 'addresses.edit';
  static const addressesDelete = 'addresses.delete';
  static const addressesDeleteConfirm = 'addresses.delete_confirm';
  static const addressesDeleteSuccess = 'addresses.delete_success';
  static const addressesContinueVerification =
      'addresses.continue_verification';
  static const addressesVerificationPending = 'addresses.verification_pending';

  // Checkout extra
  static const checkoutOnlinePaymentUnavailable =
      'checkout.online_payment_unavailable';
  static const checkoutSelectPaymentMethod = 'checkout.select_payment_method';
  static const checkoutSelectDeliveryAddress =
      'checkout.select_delivery_address';
  static const checkoutCartEmpty = 'checkout.cart_empty';
  static const checkoutCartNeedsReview = 'checkout.cart_needs_review';
  static const checkoutCartPendingChanges = 'checkout.cart_pending_changes';
  static const checkoutCartStockChanged = 'checkout.cart_stock_changed';
  static const checkoutOrderConfirmed = 'checkout.order_confirmed';
  static const checkoutPaymentMethodLabel = 'checkout.payment_method_label';
  static const checkoutSubtotal = 'checkout.subtotal';
  static const checkoutDeliveryFee = 'checkout.delivery_fee';
  static const checkoutTotal = 'checkout.total';
  static const checkoutConfirmOrder = 'checkout.confirm_order';
  static const checkoutSelectedAddress = 'checkout.selected_address';
  static const checkoutChooseOrAddAddress = 'checkout.choose_or_add_address';

  // Phone Verification
  static const phoneVerificationTitle = 'phone_verification.title';
  static const phoneVerificationSubtitle = 'phone_verification.subtitle';
  static const phoneVerificationContinueWithoutVerification =
      'phone_verification.continue_without_verification';

  static const phoneVerificationCodeHint = 'phone_verification.code_hint';
  static const phoneVerificationVerifyButton =
      'phone_verification.verify_button';
  static const phoneVerificationResendTimer = 'phone_verification.resend_timer';
  static const phoneVerificationResendSuccess =
      'phone_verification.resend_success';
  static const phoneVerificationExpired = 'phone_verification.expired';
  static const phoneVerificationAttemptsRemaining =
      'phone_verification.attempts_remaining';
  static const phoneVerificationRequired =
      'phone_verification.required_message';
  static const phoneVerificationCancelled = 'phone_verification.cancelled';
  static const phoneVerificationCancelTitle = 'phone_verification.cancel_title';
  static const phoneVerificationCancelAction =
      'phone_verification.cancel_action';
  static const phoneVerificationClose = 'phone_verification.close';
  static const phoneVerificationLimited = 'phone_verification.limited';
  static const phoneVerificationSavingNotice =
      'phone_verification.saving_notice';
  static const phoneVerificationInvalidSessionKey =
      'phone_verification.invalid_session';

  // Navigation
  static const navCart = 'nav.cart';
  static const navHome = 'nav.home';
  static const navFavorites = 'nav.favorites';
  static const navAccount = 'nav.account';

  //theme mode

  // Recently Viewed
  static const recentlyViewedTitle = 'recently_viewed.title';
  static const recentlyViewedViewAll = 'recently_viewed.view_all';
  static const recentlyViewedEmpty = 'recently_viewed.empty';

  // Recommended Section
  static const homeRecommendedTitle = 'home.recommended.title';
  static const homeRecommendedRetry = 'home.recommended.retry';
  static const homeRecommendedFirstLoadError =
      'home.recommended.first_load_error';
  static const homeRecommendedLoadMoreError =
      'home.recommended.load_more_error';
}
