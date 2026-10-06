abstract class SettingsRepository {
  Future<bool> getDarkMode();
  Future<void> setDarkMode(bool value);

  Future<String> getWeightUnit();
  Future<void> setWeightUnit(String unit);

  Future<int> getDefaultRestTime();
  Future<void> setDefaultRestTime(int seconds);

  Future<bool> getReminderEnabled();
  Future<void> setReminderEnabled(bool enabled);

  Future<int> getReminderHour();
  Future<int> getReminderMinute();
  Future<void> setReminderTime(int hour, int minute);

  Future<List<int>> getReminderDays();
  Future<void> setReminderDays(List<int> days);

  Future<bool> getAutoFillPrevious();
  Future<void> setAutoFillPrevious(bool enabled);

  Future<String> exportBackupJson();
  Future<void> importBackupJson(String jsonString);
  Future<void> clearAllData();
}
