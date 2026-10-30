import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:my_project/core/constants/app_pref_key.dart';
import 'package:my_project/core/localization/languages.dart';
import 'package:my_project/core/storage/prefs_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(Get.reset);

  test('restores only supported saved locales', () async {
    SharedPreferences.setMockInitialValues({AppStorageKey.language: 'ar'});
    final prefs = PrefsStorage(await SharedPreferences.getInstance());

    final languages = Get.put(Languages(prefs));

    expect(languages.language, const Locale('ar'));
  });

  testWidgets('normalizes an unsupported saved locale from the device', (
    tester,
  ) async {
    tester.platformDispatcher.localeTestValue = const Locale('ar');
    addTearDown(tester.platformDispatcher.clearLocaleTestValue);
    SharedPreferences.setMockInitialValues({AppStorageKey.language: 'fr'});
    final prefs = PrefsStorage(await SharedPreferences.getInstance());

    final languages = Get.put(Languages(prefs));

    expect(languages.language, const Locale('ar'));
  });

  testWidgets('falls back to Arabic for an unsupported device locale', (
    tester,
  ) async {
    tester.platformDispatcher.localeTestValue = const Locale('fr');
    addTearDown(tester.platformDispatcher.clearLocaleTestValue);
    SharedPreferences.setMockInitialValues({});
    final prefs = PrefsStorage(await SharedPreferences.getInstance());

    final languages = Get.put(Languages(prefs));

    expect(languages.language, const Locale('ar'));
  });

  testWidgets('uses English for an English device locale', (tester) async {
    tester.platformDispatcher.localeTestValue = const Locale('en');
    addTearDown(tester.platformDispatcher.clearLocaleTestValue);
    SharedPreferences.setMockInitialValues({});
    final prefs = PrefsStorage(await SharedPreferences.getInstance());

    final languages = Get.put(Languages(prefs));

    expect(languages.language, const Locale('en'));
  });

  testWidgets('updates immediately and persists only a supported locale', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({AppStorageKey.language: 'en'});
    final prefs = PrefsStorage(await SharedPreferences.getInstance());
    final languages = Get.put(Languages(prefs));
    final changed = await languages.changeLanguage('ar');
    final rejected = await languages.changeLanguage('fr');

    expect(changed, isTrue);
    expect(rejected, isFalse);
    expect(languages.language, const Locale('ar'));
    expect(prefs.getString(AppStorageKey.language), 'ar');
  });
}
