// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../constants/app_pref_key.dart';
import '../storage/prefs_storage.dart';

//! Language controller for localization
class Languages extends GetxController {
  Languages(this._prefs);
  final PrefsStorage _prefs;

  final Rx<Locale> _language = const Locale('ar').obs;

  Locale get language => _language.value;

  bool get isArabic => language.languageCode == Language.arabic.code;
  bool get isEnglish => language.languageCode == Language.english.code;

  /// Applies a supported locale immediately and persists it for later launches.
  Future<bool> changeLanguage(String languageCode) async {
    if (!_isSupported(languageCode)) return false;

    final nextLocale = Locale(languageCode);
    Get.locale = nextLocale;
    _language.value = nextLocale;
    return _prefs.setString(AppStorageKey.language, languageCode);
  }

  void resetToDeviceLocale() {
    final deviceLocale = _deviceLocale();
    Get.locale = deviceLocale;
    _language.value = deviceLocale;
  }

  @override
  void onInit() {
    super.onInit();
    final savedLanguage = _prefs.getString(AppStorageKey.language);
    _language.value = _isSupported(savedLanguage)
        ? Locale(savedLanguage!)
        : _deviceLocale();
  }

  Locale _deviceLocale() {
    final deviceLanguage =
        WidgetsBinding.instance.platformDispatcher.locale.languageCode;
    return Locale(
      deviceLanguage == Language.english.code
          ? Language.english.code
          : Language.arabic.code,
    );
  }

  bool _isSupported(String? languageCode) {
    return languageCode == Language.english.code ||
        languageCode == Language.arabic.code;
  }
}

enum Language {
  english,
  arabic;

  String get code {
    switch (this) {
      case Language.english:
        return "en";
      case Language.arabic:
        return "ar";
    }
  }
}
