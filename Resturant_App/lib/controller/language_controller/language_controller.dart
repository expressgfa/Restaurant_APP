import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:resturantapp/constant/all_controller.dart';
import 'package:resturantapp/utils/shared_pref.dart';
import 'package:resturantapp/utils/translations/ar_AR.dart';
import 'package:resturantapp/utils/translations/en_US.dart';
import 'package:resturantapp/utils/translations/es_ES.dart';
import 'package:resturantapp/utils/translations/zh-CHT.dart';
import 'package:resturantapp/utils/translations/zh_CN.dart';

class LanguageController extends GetxController {
  static LanguageController instance = Get.find<LanguageController>();

  RxString selectedLanguage = "English".obs;

  List<String> languageList = [
    'Arabic',
    'English',
    'Chinese (Simplified)',
    'Chinese (Traditional)',
    'Spanish',
  ];

  RxInt currentIndex = 0.obs;

  changedLanguage(String value, int index) async {
    selectedLanguage.value = value;
    languageController.onLanguageChanged(selectedLanguage.value, index);
  }

  void onLanguageChanged(String lang, int index) async {
    currentIndex.value = index;
    log(" currentIndex.value ${currentIndex.value}");
    Localization().selectedLocale(lang);
    await LocalSharedPrefDatabase.setLanguageIndex(index);
    // Get.back();
  }

  void getLanguage() async {
    languageController.currentIndex.value = await LocalSharedPrefDatabase.getLanguageIndex() ?? 1;
    log("Index From SharedPreference ${languageController.currentIndex.value}");

    ///
    if (languageController.currentIndex.value == 0) {
      Localization().selectedLocale('Arabic');
    } else if (languageController.currentIndex.value == 1) {
      Localization().selectedLocale('English');
    } else if (languageController.currentIndex.value == 2) {
      Localization().selectedLocale('Chinese (Simplified)');
    } else if (languageController.currentIndex.value == 3) {
      Localization().selectedLocale('Chinese (Traditional)');
    } else if (languageController.currentIndex.value == 4) {
      Localization().selectedLocale('Spanish');
    } else {
      Localization().selectedLocale('English');
    }
  }

  @override
  void onInit() {
    super.onInit();
  }
}

class Localization extends Translations {
  //
  @override
  Map<String, Map<String, String>> get keys => {
        'ar_AR': arabic,
        'en_US': english,
        'zh_CN': chinese,
        'zh_CHT': chineseTraditional,
        'es_ES': spanish,
      };

  static Locale currentLocale = const Locale('en', 'US');
  static Locale fallBackLocale = const Locale('zh', 'CN');

  final List<String> languages = [
    'Arabic',
    'English',
    'Chinese (Simplified)',
    'Chinese (Traditional)',
    'Spanish',
  ];

  final List<Locale> locales = [
    const Locale('ar', 'AR'),
    const Locale('en', 'US'),
    const Locale('zh', 'CN'),
    const Locale('zh', 'CHT'),
    const Locale('es', 'ES'),
  ];

  void selectedLocale(String lang) {
    final locale = _getLocaleFromLanguage(lang);
    currentLocale = locale;
    Get.updateLocale(currentLocale);
  }

  Locale _getLocaleFromLanguage(String lang) {
    for (int i = 0; i < languages.length; i++) {
      if (lang == languages[i]) {
        return locales[i];
      }
    }
    return Get.locale!;
  }
}
