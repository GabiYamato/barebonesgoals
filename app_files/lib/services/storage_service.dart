import 'package:shared_preferences/shared_preferences.dart';
import '../models/tracker_data.dart';
import '../models/app_settings.dart';

class StorageService {
  static const String _storageKey = 'tracker_data';
  static const String _settingsKey = 'app_settings';

  static Future<TrackerData> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);

    if (jsonString == null || jsonString.isEmpty) {
      return TrackerData.empty();
    }

    try {
      return TrackerData.fromJsonString(jsonString);
    } catch (e) {
      return TrackerData.empty();
    }
  }

  static Future<void> saveData(TrackerData data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, data.toJsonString());
  }

  static Future<void> clearData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }

  static Future<AppSettings> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_settingsKey);

    if (jsonString == null || jsonString.isEmpty) {
      return AppSettings();
    }

    try {
      return AppSettings.fromJsonString(jsonString);
    } catch (e) {
      return AppSettings();
    }
  }

  static Future<void> saveSettings(AppSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_settingsKey, settings.toJsonString());
  }
}
