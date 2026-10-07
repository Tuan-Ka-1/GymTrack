import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtrack/core/constants/app_constants.dart';
import 'package:gymtrack/core/providers/app_providers.dart';
import 'package:gymtrack/core/utils/formatters.dart';
import 'package:gymtrack/data/database/app_database.dart';
import 'package:gymtrack/features/exercises/data/exercise_catalog_loader.dart';
import 'package:gymtrack/features/exercises/domain/exercise_display_helper.dart';
import 'package:gymtrack/features/settings/presentation/settings_screen.dart';
import 'package:gymtrack/l10n/app_localizations.dart';
import 'package:gymtrack/services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MockNotificationService extends NotificationService {
  _MockNotificationService() : super.test();

  int scheduleWorkoutRemindersCalls = 0;
  String? lastTitle;
  String? lastBody;

  @override
  Future<void> scheduleWorkoutReminders({
    required List<int> daysOfWeek,
    required int hour,
    required int minute,
    String title = 'Time to workout 💪',
    String body = 'Your scheduled workout is waiting!',
  }) async {
    scheduleWorkoutRemindersCalls++;
    lastTitle = title;
    lastBody = body;
  }

  @override
  Future<void> cancel(int id) async {}

  @override
  Future<bool> requestPermissions() async => true;
}

void main() {
  setUpAll(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  });

  group('Localization Phase 2 Tests', () {
    test(
      'ARB parity test: en and vi keys match 1:1 and have non-empty values',
      () {
        final enFile = File('lib/l10n/app_en.arb');
        final viFile = File('lib/l10n/app_vi.arb');

        expect(enFile.existsSync(), isTrue);
        expect(viFile.existsSync(), isTrue);

        final Map<String, dynamic> enJson = jsonDecode(
          enFile.readAsStringSync(),
        );
        final Map<String, dynamic> viJson = jsonDecode(
          viFile.readAsStringSync(),
        );

        // Filter out metadata keys like @@locale or @keyName
        final enKeys = enJson.keys.where((k) => !k.startsWith('@')).toSet();
        final viKeys = viJson.keys.where((k) => !k.startsWith('@')).toSet();

        final missingInVi = enKeys.difference(viKeys);
        final missingInEn = viKeys.difference(enKeys);

        expect(
          missingInVi,
          isEmpty,
          reason: 'Keys in app_en.arb but missing in app_vi.arb: $missingInVi',
        );
        expect(
          missingInEn,
          isEmpty,
          reason: 'Keys in app_vi.arb but missing in app_en.arb: $missingInEn',
        );

        // Verify no empty translated strings
        for (final key in viKeys) {
          final val = viJson[key];
          expect(val, isA<String>());
          expect(
            (val as String).trim(),
            isNotEmpty,
            reason: 'Key $key in vi is empty',
          );
        }
      },
    );

    test(
      'Language persistence in SettingsRepository with gymtrack_language key',
      () async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        final db = AppDatabase(NativeDatabase.memory());

        final container = ProviderContainer(
          overrides: [
            databaseProvider.overrideWithValue(db),
            sharedPreferencesProvider.overrideWithValue(prefs),
          ],
        );

        final settingsRepo = container.read(settingsRepositoryProvider);

        // Default language when nothing is saved is null from repo, languageProvider defaults to 'en'
        final savedLang = await settingsRepo.getLanguage();
        expect(savedLang, isNull);
        expect(container.read(languageProvider), equals('en'));

        // Set to 'vi'
        await settingsRepo.setLanguage('vi');
        expect(prefs.getString(AppConstants.keyLanguage), equals('vi'));
        expect(await settingsRepo.getLanguage(), equals('vi'));

        // Set back to 'en'
        await settingsRepo.setLanguage('en');
        expect(prefs.getString(AppConstants.keyLanguage), equals('en'));
        expect(await settingsRepo.getLanguage(), equals('en'));

        container.dispose();
        await db.close();
      },
    );

    test('ExerciseDisplayHelper resolves catalog exercise and custom exercise names across locales', () {
      final catalogFile = File('assets/data/exercise_catalog.json');
      final catalog = ExerciseCatalogLoader.loadFromString(
        catalogFile.readAsStringSync(),
      );

      final catalogExercise = ExerciseEntry(
        id: 1,
        name: 'Bench Press',
        muscleGroup: 'Chest',
        equipment: 'Barbell',
        exerciseType: 'Weight & Reps',
        catalogKey: 'bench_press',
        isCustom: false,
        isArchived: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final customExercise = ExerciseEntry(
        id: 2,
        name: 'My Special Pushup',
        muscleGroup: 'Chest',
        equipment: 'Bodyweight',
        exerciseType: 'Weight & Reps',
        isCustom: true,
        isArchived: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // In Vietnamese locale
      expect(
        ExerciseDisplayHelper.getName(
          catalogExercise,
          catalog: catalog,
          locale: 'vi',
        ),
        equals('Đẩy ngực ngang đòn tạ (Bench Press)'),
      );
      // In English locale
      expect(
        ExerciseDisplayHelper.getName(
          catalogExercise,
          catalog: catalog,
          locale: 'en',
        ),
        equals('Bench Press'),
      );

      // Custom exercise returns original name regardless of locale
      expect(
        ExerciseDisplayHelper.getName(
          customExercise,
          catalog: catalog,
          locale: 'vi',
        ),
        equals('My Special Pushup'),
      );
      expect(
        ExerciseDisplayHelper.getName(
          customExercise,
          catalog: catalog,
          locale: 'en',
        ),
        equals('My Special Pushup'),
      );

      // Muscle group localization
      expect(
        ExerciseDisplayHelper.getLocalizedMuscle('Chest', locale: 'vi'),
        equals('Ngực'),
      );
      expect(
        ExerciseDisplayHelper.getLocalizedMuscle('Chest', locale: 'en'),
        equals('Chest'),
      );
      expect(
        ExerciseDisplayHelper.getLocalizedEquipment('Barbell', locale: 'vi'),
        equals('Đòn tạ'),
      );
      expect(
        ExerciseDisplayHelper.getLocalizedEquipment('Barbell', locale: 'en'),
        equals('Barbell'),
      );
    });

    test(
      'Formatters validateWeight and validateReps provide localized errors',
      () {
        final enL10n = lookupAppLocalizations(const Locale('en'));
        final viL10n = lookupAppLocalizations(const Locale('vi'));

        // Validate weight empty
        expect(
          Formatters.validateWeight('', l10n: enL10n),
          equals('Please enter a value'),
        );
        expect(
          Formatters.validateWeight('', l10n: viL10n),
          equals('Vui lòng nhập giá trị'),
        );

        // Validate weight invalid
        expect(
          Formatters.validateWeight('abc', l10n: enL10n),
          equals('Invalid number'),
        );
        expect(
          Formatters.validateWeight('abc', l10n: viL10n),
          equals('Số không hợp lệ'),
        );

        // Validate reps empty
        expect(
          Formatters.validateReps('', l10n: enL10n),
          equals('Please enter a value'),
        );
        expect(
          Formatters.validateReps('', l10n: viL10n),
          equals('Vui lòng nhập giá trị'),
        );

        // Validate reps too large
        expect(
          Formatters.validateReps('1500', l10n: enL10n),
          equals('Value too large'),
        );
        expect(
          Formatters.validateReps('1500', l10n: viL10n),
          equals('Giá trị quá lớn'),
        );
      },
    );

    test(
      'Reminder rescheduling updates title & body in matching language',
      () async {
        SharedPreferences.setMockInitialValues({
          'gymtrack_reminder_enabled': true,
          'gymtrack_reminder_days': ['1', '3', '5'],
          'gymtrack_reminder_hour': 18,
          'gymtrack_reminder_minute': 0,
          AppConstants.keyLanguage: 'vi',
        });
        final prefs = await SharedPreferences.getInstance();
        final mockNotifier = _MockNotificationService();
        final db = AppDatabase(NativeDatabase.memory());

        final container = ProviderContainer(
          overrides: [
            databaseProvider.overrideWithValue(db),
            sharedPreferencesProvider.overrideWithValue(prefs),
            notificationServiceProvider.overrideWithValue(mockNotifier),
          ],
        );

        await rescheduleWorkoutReminders(container);

        expect(mockNotifier.scheduleWorkoutRemindersCalls, equals(1));
        expect(mockNotifier.lastTitle, equals('Đến giờ tập rồi 💪'));
        expect(
          mockNotifier.lastBody,
          equals('Buổi tập đã lên lịch đang chờ bạn!'),
        );

        // Switch language to en and reschedule
        await container.read(languageProvider.notifier).setLanguage('en');
        expect(mockNotifier.scheduleWorkoutRemindersCalls, equals(2));
        expect(mockNotifier.lastTitle, equals('Time to workout 💪'));
        expect(
          mockNotifier.lastBody,
          equals('Your scheduled workout is waiting!'),
        );

        container.dispose();
        await db.close();
      },
    );

    testWidgets(
      'Language switch in Settings immediately updates UI without restart',
      (tester) async {
        SharedPreferences.setMockInitialValues({
          AppConstants.keyLanguage: 'en',
        });
        final prefs = await SharedPreferences.getInstance();
        final db = AppDatabase(NativeDatabase.memory());

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              databaseProvider.overrideWithValue(db),
              sharedPreferencesProvider.overrideWithValue(prefs),
            ],
            child: Consumer(
              builder: (context, ref, _) {
                final lang = ref.watch(languageProvider);
                return MaterialApp(
                  locale: Locale(lang),
                  localizationsDelegates:
                      AppLocalizations.localizationsDelegates,
                  supportedLocales: AppLocalizations.supportedLocales,
                  home: const SettingsScreen(),
                );
              },
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Initially in English
        expect(find.text('Settings'), findsOneWidget);
        expect(find.text('Preferences'), findsOneWidget);
        expect(find.text('Dark Mode'), findsOneWidget);

        // Tap Tiếng Việt button segment
        final viButton = find.text('Tiếng Việt');
        expect(viButton, findsOneWidget);
        await tester.tap(viButton);
        await tester.pumpAndSettle();

        // Immediate UI update to Vietnamese
        expect(find.text('Cài đặt'), findsOneWidget);
        expect(find.text('Tuỳ chọn'), findsOneWidget);
        expect(find.text('Giao diện tối'), findsOneWidget);
        expect(find.text('Settings'), findsNothing);

        // Verify persisted to shared preferences
        expect(prefs.getString(AppConstants.keyLanguage), equals('vi'));

        await db.close();
      },
    );

    testWidgets(
      'Text scaling (1.3x) with Vietnamese locale does not throw overflow',
      (tester) async {
        SharedPreferences.setMockInitialValues({
          AppConstants.keyLanguage: 'vi',
        });
        final prefs = await SharedPreferences.getInstance();
        final db = AppDatabase(NativeDatabase.memory());

        // Set reasonable size for phone screen test
        await tester.binding.setSurfaceSize(const Size(400, 800));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              databaseProvider.overrideWithValue(db),
              sharedPreferencesProvider.overrideWithValue(prefs),
            ],
            child: MediaQuery(
              data: const MediaQueryData(textScaler: TextScaler.linear(1.3)),
              child: const MaterialApp(
                locale: Locale('vi'),
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                home: SettingsScreen(),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.text('Cài đặt'), findsOneWidget);

        await db.close();
      },
    );
  });
}
