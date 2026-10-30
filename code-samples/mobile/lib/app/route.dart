import '../core/navigation/order_details_route_args.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../core/navigation/items_details_route_args.dart';
import '../features/addresses/presentation/bindings/addresses_bindings.dart';
import '../features/addresses/presentation/pages/addresses_page.dart';
import '../features/addresses/presentation/pages/address_verification_page.dart';
import '../features/recently_viewed/presentation/bindings/recently_viewed_binding.dart';
import '../features/recently_viewed/presentation/pages/recently_viewed_page.dart';

import '../features/app_init/presentation/bindings/app_init_bindings.dart';
import '../features/app_init/presentation/pages/app_init_page.dart';
import '../features/auth/presentation/bindings/auth_bindings.dart';
import '../features/auth/presentation/pages/forget_password_page.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/set_new_password_page.dart';
import '../features/auth/presentation/pages/signup_page.dart';
import '../features/auth/presentation/pages/verify_email_page.dart';
import '../features/auth/presentation/pages/verify_reset_password_page.dart';
import '../features/cart/presentation/pages/cart_page.dart';
import '../features/checkout/presentation/bindings/checkout_bindings.dart';
import '../features/checkout/presentation/pages/checkout_page.dart';
import '../features/orders/presentation/pages/order_details_page.dart';
import '../features/orders/presentation/bindings/order_details_bindings.dart';
import '../features/orders/presentation/pages/my_orders_page.dart';
import '../features/orders/presentation/bindings/my_orders_bindings.dart';
import '../features/favorites/presentation/pages/favorites_page.dart';
import '../features/home/presentation/bindings/home_bindings.dart';
import '../features/home/presentation/pages/home_page.dart';
import '../features/home/presentation/pages/home_screen.dart';
import '../features/listing/presentation/bindings/listing_binding.dart';
import '../features/listing/presentation/pages/listing_page.dart';
import '../features/item_details/presentation/bindings/item_details_bindings.dart';
import '../features/item_details/presentation/page/item_details_page.dart';
import '../features/media_viewer/presentation/bindings/full_image_binding.dart';
import '../features/media_viewer/presentation/pages/full_image_page.dart';
import '../features/onboarding/presentation/bindings/onboarding_bindings.dart';
import '../features/onboarding/presentation/pages/onboarding_page.dart';
import '../features/settings/presentation/bindings/settings_bindings.dart';
import '../features/settings/presentation/pages/about_us_page.dart';
import '../features/settings/presentation/pages/settings_page.dart';
import '../features/search/presentation/bindings/product_search_binding.dart';
import '../features/search/presentation/pages/product_search_page.dart';
import 'middleware.dart';

// Retained for callers that do not compose app-lifetime callbacks.
List<GetPage<dynamic>>? getPages = createAppPages();

List<GetPage<dynamic>> createAppPages({
  void Function()? onSessionReady,
  Future<void> Function()? beforeLogout,
}) => [
  GetPage(
    name: RouteName.appInit,
    page: () => const AppInitPage(),
    binding: AppInitBindings(onSessionReady: onSessionReady),
    transition: Transition.noTransition,
    transitionDuration: Duration.zero,
  ),

  //! Onboarding (Initial route)
  GetPage(
    name: RouteName.onboarding,
    page: () => const OnboardingPage(),
    binding: OnboardingBindings(),
    middlewares: [OnboardingMiddleware()],
  ),

  //! Auth
  GetPage(
    name: RouteName.login,
    page: () => const LoginPage(),
    binding: BindingLogin(),
    middlewares: [LoginMiddleware()],
  ),

  GetPage(
    name: RouteName.signUp,
    page: () => const SignupPage(),
    binding: BindingSignUp(),
  ),

  GetPage(
    name: RouteName.verifyCodeChekEmail,
    page: () => const VerifyEmailPage(),
    binding: BindingVerifyEmail(),
  ),
  GetPage(
    name: RouteName.forgetPassword,
    page: () => const ForgetPasswordPage(),
    binding: BindingForgetPassword(),
  ),
  GetPage(
    name: RouteName.verifyCodeRestPassword,
    page: () => const VerifyResetPasswordPage(),
    binding: BindingVerifyResetPassword(),
  ),
  GetPage(
    name: RouteName.setNewPassword,
    page: () => const SetNewPasswordPage(),
    binding: BindingSetNewPassword(),
  ),

  //! Home
  GetPage(
    name: RouteName.homeScreen,
    page: () => const HomeScreen(),
    binding: BindingHomeScreen(beforeLogout: beforeLogout),
  ),
  GetPage(name: RouteName.home, page: () => const HomePage()),
  GetPage(
    name: RouteName.listing,
    page: () => const ListingPage(),
    binding: ListingBinding(),
  ),
  GetPage(
    name: RouteName.itemDetails,
    page: () {
      final arguments = Get.arguments;

      final args = arguments is ItemsDetailsRouteArgs
          ? arguments
          : ItemsDetailsRouteArgs.invalid();

      return ItemDetailsPage(controllerTag: args.controllerTag);
    },
    binding: BindingItemDetails(),
  ),
  GetPage(
    name: RouteName.productSearch,
    page: () => const ProductSearchPage(),
    binding: ProductSearchBinding(),
  ),

  //! Favorites
  GetPage(name: RouteName.favorites, page: () => const FavoritesPage()),

  //! Cart
  GetPage(name: RouteName.cart, page: () => const CartPage()),

  //! Checkout
  GetPage(
    name: RouteName.checkOut,
    page: () => const CheckoutPage(),
    binding: CheckoutBindings(),
  ),

  //! Order Details
  GetPage(
    name: RouteName.orderDetails,
    page: () {
      final args = Get.arguments;
      return OrderDetailsPage(
        routeArgs: args is OrderDetailsRouteArgs ? args : null,
      );
    },
    binding: OrderDetailsBindings(),
  ),

  //! My Orders
  GetPage(
    name: RouteName.myOrders,
    page: () => const MyOrdersPage(),
    binding: MyOrdersBindings(),
  ),

  //! Addresses
  GetPage(
    name: RouteName.addresses,
    page: () => const AddressesPage(),
    binding: AddressRouteBinding(),
  ),
  GetPage(
    name: RouteName.addressVerification,
    page: () => const AddressVerificationPage(),
    binding: AddressVerificationRouteBinding(),
  ),

  //! Settings
  GetPage(
    name: RouteName.settings,
    page: () => const SettingsPage(),
    binding: SettingsRouteBinding(),
  ),
  GetPage(
    name: RouteName.aboutUs,
    page: () => const AboutUsPage(),
    binding: AboutUsBindings(),
  ),

  GetPage(
    name: RouteName.fullImage,
    page: () => const FullImagePage(),
    binding: FullImageBinding(),
  ),

  //! Recently Viewed
  GetPage(
    name: RouteName.recentlyViewed,
    page: () => const RecentlyViewedPage(),
    binding: RecentlyViewedBinding(),
  ),
];

class RouteName {
  //! Initial
  static const String appInit = "/appInit";
  static const String onboarding = "/";

  //! Auth
  static const String login = "/login";
  static const String loginFlow = "$login?entry=flow";
  static const String signUp = "/signUp";
  static const String forgetPassword = "/forgetPassword";
  static const String verifyCodeRestPassword = "/verifyCodeRestPassword";
  static const String setNewPassword = "/setNewPassword";
  static const String verifyCodeChekEmail = "/verifyCodeChekEmail";

  //! Home
  static const String home = "/home";
  static const String homeScreen = "/homeScreen";
  static const String listing = "/listing";
  static const String productSearch = "/productSearch";

  //! Features

  static const String fullImage = "/fullImage";
  static const String itemDetails = "/itemDetails";
  static const String favorites = "/favorites";
  static const String cart = "/cart";
  static const String checkOut = "/checkOut";
  static const String orderDetails = "/orderDetails";
  static const String myOrders = "/myOrders";
  static const String addresses = "/addresses";
  static const String addressVerification = "/addressVerification";
  static const String settings = "/settings";
  static const String aboutUs = "/aboutUs";
  static const String recentlyViewed = "/recentlyViewed";
}
