import 'package:get/get.dart';

enum MainTab { cart, home, favorites, account }

/// Owns the selected destination for one Home shell route.
class HomeStore extends GetxController {
  final Rx<MainTab> _selectedTab = MainTab.home.obs;

  MainTab get selectedTab => _selectedTab.value;
  int get selectedIndex => _selectedTab.value.index;
  bool get isCartSelected => _selectedTab.value == MainTab.cart;
  bool get isHomeSelected => _selectedTab.value == MainTab.home;


  void selectCart() => _selectedTab.value = MainTab.cart;
  void selectHome() => _selectedTab.value = MainTab.home;
  void selectFavorites() => _selectedTab.value = MainTab.favorites;
  void selectAccount() => _selectedTab.value = MainTab.account;
  void resetToHome() => selectHome();
}
