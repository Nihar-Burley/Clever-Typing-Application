import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// SharedPreferences wrapper for persistent lightweight state.
class AppPreferencesStore {
  const AppPreferencesStore();

  Future<void> writeString(String key, String value) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString(key, value);
  }

  Future<String?> readString(String key) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString(key);
  }

  Future<void> writeBool(String key, bool value) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setBool(key, value);
  }

  Future<bool?> readBool(String key) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getBool(key);
  }

  Future<void> writeJson(String key, Map<String, Object?> value) async {
    await writeString(key, jsonEncode(value));
  }

  Future<Map<String, Object?>?> readJson(String key) async {
    final String? raw = await readString(key);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    final Object decoded = jsonDecode(raw);
    return Map<String, Object?>.from(decoded as Map);
  }

  Future<void> remove(String key) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.remove(key);
  }
}
