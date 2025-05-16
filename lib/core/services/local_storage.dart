import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static setInt(String key, int value) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setInt(key, value);
  }

  static Future<int?> getInt(String key) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getInt(key);
  }

  static Future<void> setString(Map<String, String> values) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    for (var entry in values.entries) {
      await pref.setString(entry.key, entry.value);
    }
  }

  static Future<String?> getString(String key) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getString(key);
  }

  static Future<bool?> getBool(String key) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getBool(key);
  }

  static setBool(String key, bool value) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setBool(key, value);
  }

  static Future<void> remove(List keys) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    for (var key in keys) {
      await pref.remove(key);
    }
  }
}
