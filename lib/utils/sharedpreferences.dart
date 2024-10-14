import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {
  static SharedPreferences? _prefs;

  static Future<void> _initPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Save a string value to SharedPreferences.
  static Future<void> saveString(String key, String value) async {
    try {
      await _initPrefs();
      await _prefs?.setString(key, value);
    } catch (e) {
      print("Error saving string to SharedPreferences: $e");
    }
  }

  /// Retrieve a string value from SharedPreferences.
  static Future<String?> getString(String key) async {
    try {
      await _initPrefs();
      return _prefs?.getString(key);
    } catch (e) {
      print("Error retrieving string from SharedPreferences: $e");
      return null;
    }
  }

  /// Save an integer value to SharedPreferences.
  static Future<void> saveInt(String key, int value) async {
    try {
      await _initPrefs();
      await _prefs?.setInt(key, value);
    } catch (e) {
      print("Error saving int to SharedPreferences: $e");
    }
  }

  // Save a double value to SharedPreferences.
  static Future<void> saveDouble(String key, double value) async {
    try {
      await _initPrefs();
      await _prefs?.setDouble(key, value);
    } catch (e) {
      print("Error saving double to SharedPreferences: $e");
    }
  }

  /// Retrieve a double value from SharedPreferences.
  static Future<double?> getDouble(String key) async {
    try {
      await _initPrefs();
      return _prefs?.getDouble(key);
    } catch (e) {
      print("Error retrieving double from SharedPreferences: $e");
      return null;
    }
  }

  /// Retrieve an integer value from SharedPreferences.
  static Future<int?> getInt(String key) async {
    try {
      await _initPrefs();
      return _prefs?.getInt(key);
    } catch (e) {
      print("Error retrieving int from SharedPreferences: $e");
      return null;
    }
  }

  /// Save a boolean value to SharedPreferences.
  static Future<void> saveBool(String key, bool value) async {
    try {
      await _initPrefs();
      await _prefs?.setBool(key, value);
    } catch (e) {
      print("Error saving bool to SharedPreferences: $e");
    }
  }

  /// Retrieve a boolean value from SharedPreferences.
  static Future<bool?> getBool(String key) async {
    try {
      await _initPrefs();
      return _prefs?.getBool(key);
    } catch (e) {
      print("Error retrieving bool from SharedPreferences: $e");
      return null;
    }
  }

  //// Check if a key exists in SharedPreferences.
  static Future<bool> containsKey(String key) async {
    try {
      await _initPrefs();
      return _prefs?.containsKey(key) ?? false;
    } catch (e) {
      print("Error checking if key exists in SharedPreferences: $e");
      return false;
    }
  }

  /// Remove a value from SharedPreferences.
  static Future<void> removeData(String key) async {
    try {
      await _initPrefs();
      await _prefs?.remove(key);
    } catch (e) {
      print("Error removing data from SharedPreferences: $e");
    }
  }

  /// Clear all values from SharedPreferences.
  static Future<void> clearData() async {
    try {
      await _initPrefs();
      await _prefs?.clear();
    } catch (e) {
      print("Error clearing SharedPreferences: $e");
    }
  }
}