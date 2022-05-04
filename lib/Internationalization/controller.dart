import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LanguageController extends GetxController {
  void changeLanguage({
    required String languageCode,
    String? countryCode,
  }) {
    print(languageCode.toString() + 'this is language code');
    Get.updateLocale(Locale(languageCode, countryCode));
  }
}
