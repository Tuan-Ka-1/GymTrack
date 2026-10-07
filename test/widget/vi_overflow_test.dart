import 'dart:io';

import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtrack/core/constants/app_constants.dart';
import 'package:gymtrack/core/providers/app_providers.dart';
import 'package:gymtrack/data/database/app_database.dart';
import 'package:gymtrack/data/repositories/body_repository_impl.dart';
import 'package:gymtrack/data/repositories/workout_repository_impl.dart';
import 'package:gymtrack/features/body/presentation/body_tracking_screen.dart';
import 'package:gymtrack/features/exercises/data/exercise_catalog_loader.dart';
import 'package:gymtrack/features/exercises/domain/exercise_catalog.dart';
import 'package:gymtrack/features/exercises/presentation/exercise_detail_screen.dart';
import 'package:gymtrack/features/exercises/presentation/exercise_library_screen.dart';
import 'package:gymtrack/features/history/presentation/history_screen.dart';
import 'package:gymtrack/features/history/presentation/workout_history_detail_screen.dart';
import 'package:gymtrack/features/home/presentation/home_screen.dart';
import 'package:gymtrack/features/progress/presentation/progress_screen.dart';
import 'package:gymtrack/features/settings/presentation/settings_screen.dart';
import 'package:gymtrack/features/workout/presentation/active_workout_screen.dart';
import 'package:gymtrack/features/workout/presentation/plan_detail_screen.dart';
import 'package:gymtrack/features/workout/presentation/widgets/exercise_picker_dialog.dart';
import 'package:gymtrack/features/workout/presentation/workout_plans_screen.dart';
import 'package:gymtrack/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late ExerciseCatalog catalog;

  setUpAll(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    final catalogFile = File('assets/data/exercise_catalog.json');
    catalog = ExerciseCatalogLoader.loadFromString(
      catalogFile.readAsStringSync(),
    );
    ExerciseCatalogLoader.setCache(catalog);
  });

  Widget wrapWithVietnameseLocale({
    required Widget child,
    required List<dynamic> overrides,
    required Size surfaceSize,
  }) {
    return ProviderScope(
      overrides: overrides.cast(),
      child: MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(1.3)),
        child: MaterialApp(
          locale: const Locale('vi'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: child,
        ),
      ),
    );
  }

  final testSizes = [const Size(400, 800), const Size(360, 640)];

  group('Vietnamese UI Text Overflow Tests (textScaler 1.3)', () {
    for (final size in testSizes) {
      final sizeName = '${size.width.toInt()}x${size.height.toInt()}';

      testWidgets('SettingsScreen ($sizeName) no overflow', (tester) async {
        SharedPreferences.setMockInitialValues({
          AppConstants.keyLanguage: 'vi',
        });
        final prefs = await SharedPreferences.getInstance();
        final db = AppDatabase(NativeDatabase.memory());

        await tester.binding.setSurfaceSize(size);
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(
          wrapWithVietnameseLocale(
            surfaceSize: size,
            overrides: [
              databaseProvider.overrideWithValue(db),
              sharedPreferencesProvider.overrideWithValue(prefs),
            ],
            child: const SettingsScreen(),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.text('Cài đặt'), findsOneWidget);
        await db.close();
      });

      testWidgets('HomeScreen ($sizeName) no overflow', (tester) async {
        SharedPreferences.setMockInitialValues({
          AppConstants.keyLanguage: 'vi',
        });
        final prefs = await SharedPreferences.getInstance();
        final db = AppDatabase(NativeDatabase.memory());

        await tester.binding.setSurfaceSize(size);
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(
          wrapWithVietnameseLocale(
            surfaceSize: size,
            overrides: [
              databaseProvider.overrideWithValue(db),
              sharedPreferencesProvider.overrideWithValue(prefs),
              workoutHistoryStreamProvider.overrideWith(
                (ref) => Stream.value([]),
              ),
              allTimePRsProvider.overrideWith((ref) => Future.value([])),
            ],
            child: const HomeScreen(),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.text('GymTrack'), findsOneWidget);
        await db.close();
      });

      testWidgets(
        'ActiveWorkoutScreen ($sizeName) no overflow with exercises & sets',
        (tester) async {
          SharedPreferences.setMockInitialValues({
            AppConstants.keyLanguage: 'vi',
          });
          final prefs = await SharedPreferences.getInstance();
          final db = AppDatabase(NativeDatabase.memory());
          final repo = WorkoutRepoTestHelper(db);
          await db.seedDatabaseIfEmpty(catalog: catalog);

          final sessionId = await repo.startWorkoutSession(
            dayName: 'Ngực & Tay sau',
          );
          final bench = (await db.select(db.exercises).get()).firstWhere(
            (e) => e.catalogKey == 'bench_press',
          );
          final exSessionId = await repo.addExerciseToSession(
            sessionId,
            bench.id,
            bench.name,
          );
          await repo.addSetToExerciseSession(exSessionId);

          await tester.binding.setSurfaceSize(size);
          addTearDown(() => tester.binding.setSurfaceSize(null));

          await tester.pumpWidget(
            wrapWithVietnameseLocale(
              surfaceSize: size,
              overrides: [
                databaseProvider.overrideWithValue(db),
                sharedPreferencesProvider.overrideWithValue(prefs),
                workoutRepositoryProvider.overrideWithValue(repo),
                exerciseCatalogProvider.overrideWith(
                  (ref) => Future.value(catalog),
                ),
              ],
              child: ActiveWorkoutScreen(sessionId: sessionId),
            ),
          );
          await tester.pumpAndSettle();

          expect(tester.takeException(), isNull);
          // Clean up timer
          final container = ProviderScope.containerOf(
            tester.element(find.byType(ActiveWorkoutScreen)),
          );
          container.read(restTimerProvider.notifier).stopTimer();
          await db.close();
        },
      );

      testWidgets('ExerciseLibraryScreen ($sizeName) no overflow', (
        tester,
      ) async {
        SharedPreferences.setMockInitialValues({
          AppConstants.keyLanguage: 'vi',
        });
        final prefs = await SharedPreferences.getInstance();
        final db = AppDatabase(NativeDatabase.memory());
        await db.seedDatabaseIfEmpty(catalog: catalog);
        final allExercises = await db.select(db.exercises).get();

        await tester.binding.setSurfaceSize(size);
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(
          wrapWithVietnameseLocale(
            surfaceSize: size,
            overrides: [
              databaseProvider.overrideWithValue(db),
              sharedPreferencesProvider.overrideWithValue(prefs),
              exercisesStreamProvider.overrideWith(
                (ref) => Stream.value(allExercises),
              ),
              exerciseCatalogProvider.overrideWith(
                (ref) => Future.value(catalog),
              ),
            ],
            child: const ExerciseLibraryScreen(),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        await db.close();
      });

      testWidgets(
        'ExerciseDetailScreen ($sizeName) no overflow with long instructions',
        (tester) async {
          SharedPreferences.setMockInitialValues({
            AppConstants.keyLanguage: 'vi',
          });
          final prefs = await SharedPreferences.getInstance();
          final db = AppDatabase(NativeDatabase.memory());
          await db.seedDatabaseIfEmpty(catalog: catalog);
          final allExercises = await db.select(db.exercises).get();
          final longExercise = allExercises.firstWhere(
            (e) => e.catalogKey == 'bench_press',
          );

          await tester.binding.setSurfaceSize(size);
          addTearDown(() => tester.binding.setSurfaceSize(null));

          await tester.pumpWidget(
            wrapWithVietnameseLocale(
              surfaceSize: size,
              overrides: [
                databaseProvider.overrideWithValue(db),
                sharedPreferencesProvider.overrideWithValue(prefs),
                exerciseCatalogProvider.overrideWith(
                  (ref) => Future.value(catalog),
                ),
              ],
              child: ExerciseDetailScreen(exercise: longExercise),
            ),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);

          await db.close();
        },
      );

      testWidgets('ExercisePickerDialog ($sizeName) no overflow', (
        tester,
      ) async {
        SharedPreferences.setMockInitialValues({
          AppConstants.keyLanguage: 'vi',
        });
        final prefs = await SharedPreferences.getInstance();
        final db = AppDatabase(NativeDatabase.memory());
        await db.seedDatabaseIfEmpty(catalog: catalog);
        final allExercises = await db.select(db.exercises).get();

        await tester.binding.setSurfaceSize(size);
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(
          wrapWithVietnameseLocale(
            surfaceSize: size,
            overrides: [
              databaseProvider.overrideWithValue(db),
              sharedPreferencesProvider.overrideWithValue(prefs),
              exercisesStreamProvider.overrideWith(
                (ref) => Stream.value(allExercises),
              ),
              exerciseCatalogProvider.overrideWith(
                (ref) => Future.value(catalog),
              ),
            ],
            child: Builder(
              builder: (ctx) => ElevatedButton(
                onPressed: () => ExercisePickerDialog.show(ctx),
                child: const Text('Open'),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.text('Chọn bài tập'), findsOneWidget);
        await db.close();
      });

      testWidgets('HistoryScreen ($sizeName) no overflow', (tester) async {
        SharedPreferences.setMockInitialValues({
          AppConstants.keyLanguage: 'vi',
        });
        final prefs = await SharedPreferences.getInstance();
        final db = AppDatabase(NativeDatabase.memory());
        final repo = WorkoutRepoTestHelper(db);

        final sessionId = await repo.startWorkoutSession(
          dayName: 'Ngực & Tay sau',
        );
        final bench = await db
            .into(db.exercises)
            .insertReturning(
              ExercisesCompanion.insert(
                name: 'Bench Press',
                muscleGroup: 'Chest',
                equipment: 'Barbell',
                exerciseType: const Value('Weight & Reps'),
                catalogKey: const Value('bench_press'),
              ),
            );
        final exSessionId = await repo.addExerciseToSession(
          sessionId,
          bench.id,
          bench.name,
        );
        final set1 = (await repo.getSetsForExerciseSession(exSessionId)).first;
        await repo.updateSet(
          set1.copyWith(weight: 80, reps: 10, completed: true),
        );
        await repo.finishWorkoutSession(
          sessionId,
          notes: 'Ghi chú buổi tập mẫu tiếng Việt rất dài',
        );

        await tester.binding.setSurfaceSize(size);
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(
          wrapWithVietnameseLocale(
            surfaceSize: size,
            overrides: [
              databaseProvider.overrideWithValue(db),
              sharedPreferencesProvider.overrideWithValue(prefs),
              workoutRepositoryProvider.overrideWithValue(repo),
              exerciseCatalogProvider.overrideWith(
                (ref) => Future.value(catalog),
              ),
            ],
            child: const HistoryScreen(),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        await db.close();
      });

      testWidgets('WorkoutHistoryDetailScreen ($sizeName) no overflow', (
        tester,
      ) async {
        SharedPreferences.setMockInitialValues({
          AppConstants.keyLanguage: 'vi',
        });
        final prefs = await SharedPreferences.getInstance();
        final db = AppDatabase(NativeDatabase.memory());
        final repo = WorkoutRepoTestHelper(db);

        final sessionId = await repo.startWorkoutSession(
          dayName: 'Ngực & Tay sau',
        );
        final bench = await db
            .into(db.exercises)
            .insertReturning(
              ExercisesCompanion.insert(
                name: 'Bench Press',
                muscleGroup: 'Chest',
                equipment: 'Barbell',
                exerciseType: const Value('Weight & Reps'),
                catalogKey: const Value('bench_press'),
              ),
            );
        final exSessionId = await repo.addExerciseToSession(
          sessionId,
          bench.id,
          bench.name,
        );
        final set1 = (await repo.getSetsForExerciseSession(exSessionId)).first;
        await repo.updateSet(
          set1.copyWith(weight: 80, reps: 10, completed: true),
        );
        await repo.finishWorkoutSession(
          sessionId,
          notes: 'Ghi chú buổi tập mẫu tiếng Việt rất dài',
        );

        await tester.binding.setSurfaceSize(size);
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(
          wrapWithVietnameseLocale(
            surfaceSize: size,
            overrides: [
              databaseProvider.overrideWithValue(db),
              sharedPreferencesProvider.overrideWithValue(prefs),
              workoutRepositoryProvider.overrideWithValue(repo),
              exerciseCatalogProvider.overrideWith(
                (ref) => Future.value(catalog),
              ),
            ],
            child: WorkoutHistoryDetailScreen(sessionId: sessionId),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        await db.close();
      });

      testWidgets('ProgressScreen ($sizeName) no overflow', (tester) async {
        SharedPreferences.setMockInitialValues({
          AppConstants.keyLanguage: 'vi',
        });
        final prefs = await SharedPreferences.getInstance();
        final db = AppDatabase(NativeDatabase.memory());
        final repo = WorkoutRepoTestHelper(db);

        await tester.binding.setSurfaceSize(size);
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(
          wrapWithVietnameseLocale(
            surfaceSize: size,
            overrides: [
              databaseProvider.overrideWithValue(db),
              sharedPreferencesProvider.overrideWithValue(prefs),
              workoutRepositoryProvider.overrideWithValue(repo),
              workoutHistoryStreamProvider.overrideWith(
                (ref) => Stream.value([]),
              ),
              exercisesStreamProvider.overrideWith((ref) => Stream.value([])),
              exerciseCatalogProvider.overrideWith(
                (ref) => Future.value(catalog),
              ),
            ],
            child: const ProgressScreen(),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.text('Tiến độ & Phân tích'), findsOneWidget);
        await db.close();
      });

      testWidgets('BodyTrackingScreen ($sizeName) no overflow', (tester) async {
        SharedPreferences.setMockInitialValues({
          AppConstants.keyLanguage: 'vi',
        });
        final prefs = await SharedPreferences.getInstance();
        final db = AppDatabase(NativeDatabase.memory());
        final bodyRepo = BodyRepositoryImpl(db);

        await bodyRepo.addBodyMeasurement(
          date: DateTime.now(),
          bodyWeight: 75.5,
          bodyFat: 14.5,
          waist: 78.0,
          chest: 102.0,
          arm: 37.5,
          thigh: 59.0,
          notes: 'Đo buổi sáng chưa ăn sáng',
        );

        await tester.binding.setSurfaceSize(size);
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(
          wrapWithVietnameseLocale(
            surfaceSize: size,
            overrides: [
              databaseProvider.overrideWithValue(db),
              sharedPreferencesProvider.overrideWithValue(prefs),
              bodyRepositoryProvider.overrideWithValue(bodyRepo),
            ],
            child: const BodyTrackingScreen(),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.text('Theo dõi thể trạng'), findsOneWidget);
        await db.close();
      });

      testWidgets('WorkoutPlansScreen ($sizeName) no overflow', (tester) async {
        SharedPreferences.setMockInitialValues({
          AppConstants.keyLanguage: 'vi',
        });
        final prefs = await SharedPreferences.getInstance();
        final db = AppDatabase(NativeDatabase.memory());
        final repo = WorkoutRepoTestHelper(db);
        await db.seedDatabaseIfEmpty(catalog: catalog);

        final plans = await repo.getWorkoutPlans();

        await tester.binding.setSurfaceSize(size);
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(
          wrapWithVietnameseLocale(
            surfaceSize: size,
            overrides: [
              databaseProvider.overrideWithValue(db),
              sharedPreferencesProvider.overrideWithValue(prefs),
              workoutRepositoryProvider.overrideWithValue(repo),
              workoutPlansStreamProvider.overrideWith(
                (ref) => Stream.value(plans),
              ),
              exerciseCatalogProvider.overrideWith(
                (ref) => Future.value(catalog),
              ),
            ],
            child: const WorkoutPlansScreen(),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        await db.close();
      });

      testWidgets('PlanDetailScreen ($sizeName) no overflow', (tester) async {
        SharedPreferences.setMockInitialValues({
          AppConstants.keyLanguage: 'vi',
        });
        final prefs = await SharedPreferences.getInstance();
        final db = AppDatabase(NativeDatabase.memory());
        final repo = WorkoutRepoTestHelper(db);
        await db.seedDatabaseIfEmpty(catalog: catalog);

        final plans = await repo.getWorkoutPlans();
        final plan = plans.first;

        await tester.binding.setSurfaceSize(size);
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(
          wrapWithVietnameseLocale(
            surfaceSize: size,
            overrides: [
              databaseProvider.overrideWithValue(db),
              sharedPreferencesProvider.overrideWithValue(prefs),
              workoutRepositoryProvider.overrideWithValue(repo),
              exerciseCatalogProvider.overrideWith(
                (ref) => Future.value(catalog),
              ),
            ],
            child: PlanDetailScreen(planId: plan.id),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        await db.close();
      });
    }
  });
}

class WorkoutRepoTestHelper extends WorkoutRepositoryImpl {
  WorkoutRepoTestHelper(super.db);
}
