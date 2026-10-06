class AppConstants {
  static const String appName = 'GymTrack';
  static const String appVersion = '1.0.0';

  // Default values
  static const int defaultRestSeconds = 90;
  static const String defaultWeightUnit = 'kg'; // 'kg' or 'lb'
  static const bool defaultDarkMode = true;
  static const bool defaultAutoFillPrevious =
      false; // Previous performance auto-fill

  // Storage keys
  static const String keyDarkMode = 'gymtrack_dark_mode';
  static const String keyWeightUnit = 'gymtrack_weight_unit';
  static const String keyDefaultRestTime = 'gymtrack_default_rest_time';
  static const String keyReminderEnabled = 'gymtrack_reminder_enabled';
  static const String keyReminderHour = 'gymtrack_reminder_hour';
  static const String keyReminderMinute = 'gymtrack_reminder_minute';
  static const String keyReminderDays = 'gymtrack_reminder_days';
  static const String keyAutoFillPrevious = 'gymtrack_auto_fill_previous';
  static const String keyDatabaseSeeded = 'gymtrack_db_seeded_v1';

  // Muscle groups
  static const List<String> muscleGroups = [
    'Chest',
    'Back',
    'Shoulders',
    'Legs',
    'Biceps',
    'Triceps',
    'Core',
    'Full Body',
    'Cardio',
  ];

  // Equipment types
  static const List<String> equipmentTypes = [
    'Barbell',
    'Dumbbell',
    'Machine',
    'Cable',
    'Bodyweight',
    'Kettlebell',
    'Other',
  ];
}
