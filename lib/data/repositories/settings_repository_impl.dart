import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';
import '../../domain/repositories/settings_repository.dart';
import '../database/app_database.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SharedPreferences _prefs;
  final AppDatabase _db;

  SettingsRepositoryImpl(this._prefs, this._db);

  @override
  Future<bool> getDarkMode() async {
    return _prefs.getBool(AppConstants.keyDarkMode) ??
        AppConstants.defaultDarkMode;
  }

  @override
  Future<void> setDarkMode(bool value) async {
    await _prefs.setBool(AppConstants.keyDarkMode, value);
  }

  @override
  Future<String> getWeightUnit() async {
    return _prefs.getString(AppConstants.keyWeightUnit) ??
        AppConstants.defaultWeightUnit;
  }

  @override
  Future<void> setWeightUnit(String unit) async {
    await _prefs.setString(AppConstants.keyWeightUnit, unit);
  }

  @override
  Future<String?> getLanguage() async {
    return _prefs.getString(AppConstants.keyLanguage);
  }

  @override
  Future<void> setLanguage(String languageCode) async {
    await _prefs.setString(AppConstants.keyLanguage, languageCode);
  }

  @override
  Future<int> getDefaultRestTime() async {
    return _prefs.getInt(AppConstants.keyDefaultRestTime) ??
        AppConstants.defaultRestSeconds;
  }

  @override
  Future<void> setDefaultRestTime(int seconds) async {
    await _prefs.setInt(AppConstants.keyDefaultRestTime, seconds);
  }

  @override
  Future<bool> getReminderEnabled() async {
    return _prefs.getBool(AppConstants.keyReminderEnabled) ?? false;
  }

  @override
  Future<void> setReminderEnabled(bool enabled) async {
    await _prefs.setBool(AppConstants.keyReminderEnabled, enabled);
  }

  @override
  Future<int> getReminderHour() async {
    return _prefs.getInt(AppConstants.keyReminderHour) ??
        18; // Default 18:00 (6 PM)
  }

  @override
  Future<int> getReminderMinute() async {
    return _prefs.getInt(AppConstants.keyReminderMinute) ?? 0;
  }

  @override
  Future<void> setReminderTime(int hour, int minute) async {
    await _prefs.setInt(AppConstants.keyReminderHour, hour);
    await _prefs.setInt(AppConstants.keyReminderMinute, minute);
  }

  @override
  Future<List<int>> getReminderDays() async {
    final list = _prefs.getStringList(AppConstants.keyReminderDays);
    if (list == null || list.isEmpty) {
      return [1, 3, 5]; // Default Mon, Wed, Fri
    }
    return list.map((e) => int.parse(e)).toList();
  }

  @override
  Future<void> setReminderDays(List<int> days) async {
    await _prefs.setStringList(
      AppConstants.keyReminderDays,
      days.map((e) => e.toString()).toList(),
    );
  }

  @override
  Future<bool> getAutoFillPrevious() async {
    return _prefs.getBool(AppConstants.keyAutoFillPrevious) ??
        AppConstants.defaultAutoFillPrevious;
  }

  @override
  Future<void> setAutoFillPrevious(bool enabled) async {
    await _prefs.setBool(AppConstants.keyAutoFillPrevious, enabled);
  }

  @override
  Future<String> exportBackupJson() => _db.exportDatabaseToJson();

  @override
  Future<void> importBackupJson(String jsonString) =>
      _db.importDatabaseFromJson(jsonString);

  @override
  Future<void> clearAllData() => _db.clearAllData();
}
