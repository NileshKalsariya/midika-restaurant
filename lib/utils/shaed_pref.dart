import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: camel_case_types
class Shared_Preferences {
  static SharedPreferences? prefs;

  /// set uid
  static Future prefSetUID(String value) async {
    prefs = await SharedPreferences.getInstance();
    debugPrint('uid set in pref set ::: $value');
    prefs!.setString('uid', value);
  }

  static Future<String?> prefGetUID() async {
    prefs = await SharedPreferences.getInstance();
    return prefs!.getString('uid');
  }

  static Future prefLoginTrue() async {
    prefs = await SharedPreferences.getInstance();
    debugPrint('set login true');
    prefs!.setBool('login', true);
  }

  static Future prefLoginFalse() async {
    prefs = await SharedPreferences.getInstance();
    debugPrint('set login false');
    prefs!.setBool('login', false);
  }

  static Future<bool?> prefGetLoginBool() async {
    prefs = await SharedPreferences.getInstance();
    return prefs!.getBool('login');
  }

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
}
