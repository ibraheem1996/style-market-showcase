import 'package:flutter_test/flutter_test.dart';
import 'package:my_project/features/home/presentation/store/home_store.dart';

void main() {
  test('switches between main tabs and resets to home', () {
    final store = HomeStore();

    expect(store.selectedTab, MainTab.home);

    store.selectCart();
    expect(store.selectedTab, MainTab.cart);

    store.selectFavorites();
    expect(store.selectedTab, MainTab.favorites);

    store.selectAccount();
    expect(store.selectedTab, MainTab.account);

    store.resetToHome();
    expect(store.selectedTab, MainTab.home);
  });
}
