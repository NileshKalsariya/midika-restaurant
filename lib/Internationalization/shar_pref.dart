import 'package:shared_preferences/shared_preferences.dart';

// ignore: camel_case_types
class Shared_Preferences {
  static SharedPreferences? prefs;

  ///set default language
  static Future prefSetLanguage(String value) async {
    prefs = await SharedPreferences.getInstance();
    prefs!.setString('language', value);
  }

  static Future<String?> prefGetLanguage() async {
    prefs = await SharedPreferences.getInstance();
    return prefs!.getString('language');
  }

  static Future clearAllPref() async {
    prefs = await SharedPreferences.getInstance();
    prefs!.clear();
  }

  static Future<String?> prefGetUID() async {
    prefs = await SharedPreferences.getInstance();
    return prefs!.getString('uid');
  }
}
