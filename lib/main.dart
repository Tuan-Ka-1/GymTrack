import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/constants/app_constants.dart';
import 'core/providers/app_providers.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/language_resolver.dart';
import 'data/database/app_database.dart';
import 'data/repositories/settings_repository_impl.dart';
import 'features/exercises/data/exercise_catalog_loader.dart';
import 'features/exercises/data/exercise_catalog_sync.dart';
import 'l10n/app_localizations.dart';
import 'routing/app_router.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();

  // Initialize offline local storage & notifications
  final prefs = await SharedPreferences.getInstance();
  final notificationService = NotificationService();
  await notificationService.initialize();

  // Create database & seed default exercise library and starter routine on first run
  final db = AppDatabase();
  final catalog = await ExerciseCatalogLoader.loadFromAsset();
  await db.seedDatabaseIfEmpty(catalog: catalog);

  // Sync catalog updates if catalogVersion has increased
  final catalogSync = ExerciseCatalogSync(db, prefs);
  await catalogSync.syncIfNeeded(catalog: catalog);

  // Schedule workout reminders if enabled
  final repo = SettingsRepositoryImpl(prefs, db);
  final savedLang = prefs.getString(AppConstants.keyLanguage);
  String? platformLocale;
  try {
    platformLocale =
        WidgetsBinding.instance.platformDispatcher.locale.languageCode;
  } on Object catch (e) {
    if (kDebugMode) {
      debugPrint('main: unable to inspect platformDispatcher locale: $e');
    }
  }
  final languageCode = resolveLanguageCode(
    saved: savedLang,
    platformLanguageCode: platformLocale,
  );
  await rescheduleWorkoutReminders(
    repo: repo,
    notifications: notificationService,
    languageCode: languageCode,
  );

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
    final languageCode = ref.watch(languageProvider);

    return MaterialApp.router(
      title: 'GymTrack',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      locale: Locale(languageCode),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: appRouter,
    );
  }
}
