import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {
  SharedPreferencesHelper._();

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  static Future<void> setBool(String key, bool value) async {
    await init();
    await _prefs?.setBool(key, value);
  }

  static Future<bool?> getBool(String key) async {
    await init();
    return _prefs?.getBool(key);
  }

  static Future<void> setString(String key, String value) async {
    await init();
    await _prefs?.setString(key, value);
  }

  static Future<String?> getString(String key) async {
    await init();
    return _prefs?.getString(key);
  }
}
