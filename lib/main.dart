import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/providers/app_providers.dart';
import 'core/theme/app_theme.dart';
import 'data/database/app_database.dart';
import 'data/repositories/settings_repository_impl.dart';
import 'routing/app_router.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize offline local storage & notifications
  final prefs = await SharedPreferences.getInstance();
  final notificationService = NotificationService();
  await notificationService.initialize();

  // Create database & seed default exercise library and starter routine on first run
  final db = AppDatabase();
  await db.seedDatabaseIfEmpty();

  // Schedule workout reminders if enabled
  final repo = SettingsRepositoryImpl(prefs, db);
  final reminderEnabled = await repo.getReminderEnabled();
  if (reminderEnabled) {
    await notificationService.requestPermissions();
    final days = await repo.getReminderDays();
    final hour = await repo.getReminderHour();
    final minute = await repo.getReminderMinute();
    await notificationService.scheduleWorkoutReminders(
      daysOfWeek: days,
      hour: hour,
      minute: minute,
    );
  }

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        databaseProvider.overrideWithValue(db),
      ],
      child: const GymTrackApp(),
    ),
  );
}

class GymTrackApp extends ConsumerWidget {
  const GymTrackApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'GymTrack',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: appRouter,
    );
  }
}
