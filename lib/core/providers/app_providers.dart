import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';

import '../../data/database/app_database.dart';
import '../../data/repositories/workout_repository_impl.dart';
import '../../data/repositories/exercise_repository_impl.dart';
import '../../data/repositories/body_repository_impl.dart';
import '../../data/repositories/settings_repository_impl.dart';
import '../../domain/repositories/workout_repository.dart';
import '../../domain/repositories/exercise_repository.dart';
import '../../domain/repositories/body_repository.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../features/exercises/data/exercise_catalog_loader.dart';
import '../../features/exercises/data/exercise_catalog_sync.dart';
import '../../features/exercises/domain/exercise_catalog.dart';
import '../../l10n/app_localizations.dart';
import '../../services/notification_service.dart';

// -------------------------------------------------------------
// CORE & DATABASE PROVIDERS
// -------------------------------------------------------------
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider must be overridden in ProviderScope',
  );
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

// -------------------------------------------------------------
// REPOSITORY PROVIDERS
// -------------------------------------------------------------
final workoutRepositoryProvider = Provider<WorkoutRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return WorkoutRepositoryImpl(db);
});

final exerciseRepositoryProvider = Provider<ExerciseRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return ExerciseRepositoryImpl(db);
});

final bodyRepositoryProvider = Provider<BodyRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return BodyRepositoryImpl(db);
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final db = ref.watch(databaseProvider);
  return SettingsRepositoryImpl(prefs, db);
});

final exerciseCatalogProvider = FutureProvider<ExerciseCatalog>((ref) async {
  return ExerciseCatalogLoader.loadFromAsset();
});

final exerciseCatalogSyncProvider = Provider<ExerciseCatalogSync>((ref) {
  final db = ref.watch(databaseProvider);
  final prefs = ref.watch(sharedPreferencesProvider);
  return ExerciseCatalogSync(db, prefs);
});

// -------------------------------------------------------------
// SETTINGS STATE NOTIFIERS
// -------------------------------------------------------------
class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    return ThemeMode.dark;
  }

  Future<void> toggleTheme() async {
    final nextMode = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    state = nextMode;
    await ref
        .read(settingsRepositoryProvider)
        .setDarkMode(nextMode == ThemeMode.dark);
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);

class WeightUnitNotifier extends Notifier<String> {
  @override
  String build() => 'kg';

  Future<void> setUnit(String unit) async {
    state = unit;
    await ref.read(settingsRepositoryProvider).setWeightUnit(unit);
  }
}

final weightUnitProvider = NotifierProvider<WeightUnitNotifier, String>(
  WeightUnitNotifier.new,
);

class LanguageNotifier extends Notifier<String> {
  @override
  String build() {
    try {
      final prefs = ref.watch(sharedPreferencesProvider);
      final saved = prefs.getString(AppConstants.keyLanguage);
      if (saved != null && (saved == 'en' || saved == 'vi')) {
        return saved;
      }
    } catch (_) {}

    try {
      final platformLocale =
          WidgetsBinding.instance.platformDispatcher.locale.languageCode;
      if (platformLocale == 'vi') return 'vi';
    } catch (_) {}
    return 'en';
  }

  Future<void> setLanguage(String lang) async {
    if (state == lang) return;
    state = lang;
    await ref.read(settingsRepositoryProvider).setLanguage(lang);
    await rescheduleWorkoutReminders(ref, language: lang);
  }
}

final languageProvider = NotifierProvider<LanguageNotifier, String>(
  LanguageNotifier.new,
);

Future<void> rescheduleWorkoutReminders(dynamic ref, {String? language}) async {
  final repo = ref.read(settingsRepositoryProvider) as SettingsRepository;
  final enabled = await repo.getReminderEnabled();
  final notificationService =
      ref.read(notificationServiceProvider) as NotificationService;
  if (enabled) {
    await notificationService.requestPermissions();
    final days = await repo.getReminderDays();
    final hour = await repo.getReminderHour();
    final minute = await repo.getReminderMinute();
    final lang = language ?? (ref.read(languageProvider) as String);
    final l10n = lookupAppLocalizations(Locale(lang));
    await notificationService.scheduleWorkoutReminders(
      daysOfWeek: days,
      hour: hour,
      minute: minute,
      title: l10n.settingsReminderNotificationTitle,
      body: l10n.settingsReminderNotificationBody,
    );
  } else {
    await notificationService.cancelWorkoutReminders();
  }
}

class AutoFillPreviousNotifier extends Notifier<bool> {
  @override
  bool build() {
    final repo = ref.read(settingsRepositoryProvider);
    repo.getAutoFillPrevious().then((value) {
      state = value;
    });
    return AppConstants.defaultAutoFillPrevious;
  }

  Future<void> setEnabled(bool enabled) async {
    state = enabled;
    await ref.read(settingsRepositoryProvider).setAutoFillPrevious(enabled);
  }
}

final autoFillPreviousProvider =
    NotifierProvider<AutoFillPreviousNotifier, bool>(
      AutoFillPreviousNotifier.new,
    );

// -------------------------------------------------------------
// STREAM PROVIDERS
// -------------------------------------------------------------
final exercisesStreamProvider = StreamProvider<List<ExerciseEntry>>((ref) {
  final repo = ref.watch(exerciseRepositoryProvider);
  return repo.watchAllExercises(includeArchived: false);
});

final workoutPlansStreamProvider = StreamProvider<List<WorkoutPlanEntry>>((
  ref,
) {
  final repo = ref.watch(workoutRepositoryProvider);
  return repo.watchWorkoutPlans();
});

final workoutHistoryStreamProvider = StreamProvider<List<WorkoutSessionEntry>>((
  ref,
) {
  final repo = ref.watch(workoutRepositoryProvider);
  return repo.watchCompletedWorkoutHistory();
});

final bodyMeasurementsStreamProvider =
    StreamProvider<List<BodyMeasurementEntry>>((ref) {
      final repo = ref.watch(bodyRepositoryProvider);
      return repo.watchBodyMeasurements();
    });

final allTimePRsProvider = FutureProvider<List<PersonalRecordItem>>((ref) {
  final repo = ref.watch(workoutRepositoryProvider);
  return repo.getAllTimePRs();
});

// -------------------------------------------------------------
// REST TIMER STATE NOTIFIER (Section 12)
// -------------------------------------------------------------
class RestTimerState {
  final int remainingSeconds;
  final int totalSeconds;
  final bool isRunning;
  final String? exerciseName;
  // Absolute end time in milliseconds since epoch (UTC). 0 if not running.
  final int endAtMillis;

  const RestTimerState({
    required this.remainingSeconds,
    required this.totalSeconds,
    required this.isRunning,
    this.exerciseName,
    this.endAtMillis = 0,
  });

  RestTimerState copyWith({
    int? remainingSeconds,
    int? totalSeconds,
    bool? isRunning,
    String? exerciseName,
    int? endAtMillis,
  }) {
    return RestTimerState(
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      totalSeconds: totalSeconds ?? this.totalSeconds,
      isRunning: isRunning ?? this.isRunning,
      exerciseName: exerciseName ?? this.exerciseName,
      endAtMillis: endAtMillis ?? this.endAtMillis,
    );
  }
}

class RestTimerNotifier extends Notifier<RestTimerState> {
  Timer? _ticker;
  int? _scheduledNotificationId;
  DateTime Function() _clock = DateTime.now;
  late NotificationService _notificationService;

  @visibleForTesting
  void setClock(DateTime Function() clock) {
    _clock = clock;
  }

  @visibleForTesting
  void updateRemainingFromEndAt() {
    _updateRemainingFromEndAt();
  }

  @override
  RestTimerState build() {
    _notificationService = ref.read(notificationServiceProvider);
    ref.onDispose(() {
      _ticker?.cancel();
      _cancelScheduledNotification();
    });
    return const RestTimerState(
      remainingSeconds: 0,
      totalSeconds: 90,
      isRunning: false,
    );
  }

  void startTimer({required int seconds, String? exerciseName}) {
    _ticker?.cancel();
    _cancelScheduledNotification();

    final now = _clock().millisecondsSinceEpoch;
    final endAt = now + (seconds * 1000);

    state = RestTimerState(
      remainingSeconds: seconds,
      totalSeconds: seconds,
      isRunning: true,
      exerciseName: exerciseName,
      endAtMillis: endAt,
    );

    // Schedule local notification for when rest timer finishes
    _scheduleRestTimerNotification(endAt, exerciseName);

    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateRemainingFromEndAt();
    });
  }

  void _updateRemainingFromEndAt() {
    if (!state.isRunning || state.endAtMillis == 0) {
      _ticker?.cancel();
      return;
    }

    final now = _clock().millisecondsSinceEpoch;
    final remaining = ((state.endAtMillis - now) / 1000).ceil();

    if (remaining <= 0) {
      final endAt = state.endAtMillis;
      final exName = state.exerciseName;
      // Timer finished
      stopTimer();

      // Chỉ bắn thông báo tức thì nếu thời điểm hết giờ vừa xảy ra (trong vòng 2.5s).
      // Nếu đã quá hạn từ lâu (app quay lại từ nền, notification đã lên lịch đã bắn),
      // chỉ dọn timer, không bắn thông báo mới để tránh thông báo trùng.
      final overdueMillis = now - endAt;
      if (overdueMillis <= 2500) {
        final lang = ref.read(languageProvider);
        final l10n = lookupAppLocalizations(Locale(lang));
        _notificationService.showRestTimerFinished(
          title: l10n.restTimerNotificationTitle,
          body: exName != null
              ? l10n.restTimerNotificationBodyWithExercise(exName)
              : l10n.restTimerNotificationBodyDefault,
        );
      }
    } else {
      state = state.copyWith(remainingSeconds: remaining);
    }
  }

  void _scheduleRestTimerNotification(int endAtMillis, String? exerciseName) {
    // Use a fixed ID for rest timer notifications
    _scheduledNotificationId = 999;
    final lang = ref.read(languageProvider);
    final l10n = lookupAppLocalizations(Locale(lang));

    _notificationService.scheduleRestTimerAt(
      notificationId: _scheduledNotificationId!,
      endAtMillis: endAtMillis,
      title: l10n.restTimerNotificationTitle,
      body: exerciseName != null
          ? l10n.restTimerNotificationBodyWithExercise(exerciseName)
          : l10n.restTimerNotificationBodyDefault,
    );
  }

  void _cancelScheduledNotification() {
    if (_scheduledNotificationId != null) {
      _notificationService.cancel(_scheduledNotificationId!);
      _scheduledNotificationId = null;
    }
  }

  void addSeconds(int seconds) {
    if (!state.isRunning && state.remainingSeconds == 0) return;

    final now = _clock().millisecondsSinceEpoch;
    final baseMillis = state.endAtMillis > now ? state.endAtMillis : now;
    final newEndAt = baseMillis + (seconds * 1000);
    final remaining = ((newEndAt - now) / 1000).ceil();

    state = state.copyWith(
      remainingSeconds: remaining,
      totalSeconds: state.totalSeconds + seconds,
      endAtMillis: newEndAt,
    );

    // Reschedule notification for new end time
    _cancelScheduledNotification();
    _scheduleRestTimerNotification(newEndAt, state.exerciseName);
  }

  void stopTimer() {
    _ticker?.cancel();
    _ticker = null;
    _cancelScheduledNotification();
    state = state.copyWith(
      remainingSeconds: 0,
      isRunning: false,
      endAtMillis: 0,
    );
  }
}

final restTimerProvider = NotifierProvider<RestTimerNotifier, RestTimerState>(
  RestTimerNotifier.new,
);
