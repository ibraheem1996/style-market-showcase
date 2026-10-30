import 'ar/common_ar.dart';
import 'ar/app_shell_ar.dart';
import 'ar/auth_ar.dart';
import 'ar/onboarding_ar.dart';
import 'ar/home_ar.dart';
import 'ar/item_details_ar.dart';
import 'ar/cart_ar.dart';
import 'ar/checkout_ar.dart';
import 'ar/favorites_ar.dart';
import 'ar/errors_ar.dart';
import 'ar/recently_viewed_ar.dart';
import 'ar/validation_ar.dart';
import 'ar/addresses_ar.dart';
import 'ar/orders_ar.dart';
import 'ar/account_ar.dart';
import 'ar/settings_ar.dart';
import 'ar/language_ar.dart';
import 'ar/phone_verification_ar.dart';
import 'ar/listing_ar.dart';
import 'ar/search_ar.dart';

final Map<String, String> ar = {
  ...commonAr,
  ...appShellAr,
  ...authAr,
  ...onboardingAr,
  ...homeAr,
  ...itemDetailsAr,
  ...cartAr,
  ...checkoutAr,
  ...favoritesAr,
  ...errorsAr,
  ...validationAr,
  ...addressesAr,
  ...ordersAr,
  ...accountAr,
  ...settingsAr,
  ...languageAr,
  ...recentlyViewedAr,
  ...phoneVerificationAr,
  ...listingAr,
  ...searchAr,
};
