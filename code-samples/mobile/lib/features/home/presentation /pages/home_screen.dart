// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';
import 'package:my_project/features/cart/presentation/store/cart_store.dart';
import '../../../cart/presentation/pages/cart_page.dart';
import '../../../favorites/presentation/pages/favorites_page.dart';
import '../../../account/presentation/pages/account_page.dart';
import '../controllers/home_controller.dart';
import '../store/home_store.dart';
import '../widgets/main_bottom_navigation_bar.dart';
import 'home_page.dart';

//! Main home screen with bottom navigation bar
class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  //? Screens for bottom navigation

  @override
  Widget build(BuildContext context) {
    return HomeShell(
      homeStore: controller.homeStore,
      pages: const [CartPage(), HomePage(), FavoritesPage(), AccountPage()],
      cartStore: controller.cartStore,
    );
  }
}

/// Keeps Home destinations mounted behind the shared navigation bar.
class HomeShell extends StatelessWidget {
  const HomeShell({
    required this.homeStore,
    required this.pages,
    super.key,
    required this.cartStore,
  }) : assert(pages.length == MainTab.values.length);

  final HomeStore homeStore;
  final List<Widget> pages;
  final CartStore cartStore;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        return IndexedStack(index: homeStore.selectedIndex, children: pages);
      }),
      bottomNavigationBar: MainBottomNavigationBar(
        homeStore: homeStore,
        cartStore: cartStore,
      ),
    );
  }
}
