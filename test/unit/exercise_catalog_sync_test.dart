import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtrack/data/database/app_database.dart';
import 'package:gymtrack/data/repositories/exercise_repository_impl.dart';
import 'package:gymtrack/data/repositories/workout_repository_impl.dart';
import 'package:gymtrack/features/exercises/data/exercise_catalog_loader.dart';
import 'package:gymtrack/features/exercises/data/exercise_catalog_sync.dart';
import 'package:gymtrack/features/exercises/domain/exercise_catalog.dart';
import 'package:gymtrack/features/exercises/domain/exercise_display_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late AppDatabase db;
  late ExerciseCatalog catalog;
  late ExerciseCatalogSync sync;
  late SharedPreferences prefs;
  late ExerciseRepositoryImpl exerciseRepo;
  late WorkoutRepositoryImpl workoutRepo;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    exerciseRepo = ExerciseRepositoryImpl(db);
    workoutRepo = WorkoutRepositoryImpl(db);

    final catalogFile = File('assets/data/exercise_catalog.json');
    expect(catalogFile.existsSync(), isTrue);
    catalog = ExerciseCatalogLoader.loadFromString(
      catalogFile.readAsStringSync(),
    );

    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    sync = ExerciseCatalogSync(db, prefs);
  });

  tearDown(() async {
    await db.close();
  });

  group('Exercise Catalog Sync & Domain Tests', () {
    test(
      'Catalog contains all required Phase 1 exercises (minimum 41 exercises)',
      () {
        expect(catalog.exercises.length, greaterThanOrEqualTo(41));

        // Chest
        expect(catalog.findByKey('bench_press'), isNotNull);
        expect(catalog.findByKey('dumbbell_bench_press'), isNotNull);
        expect(catalog.findByKey('incline_bench_press'), isNotNull);
        expect(catalog.findByKey('incline_dumbbell_press'), isNotNull);
        expect(catalog.findByKey('decline_bench_press'), isNotNull);
        expect(catalog.findByKey('cable_fly'), isNotNull);
        expect(catalog.findByKey('pec_deck'), isNotNull);
        expect(catalog.findByKey('push_up'), isNotNull);

        // Back
        expect(catalog.findByKey('pull_up'), isNotNull);
        expect(catalog.findByKey('chin_up'), isNotNull);
        expect(catalog.findByKey('lat_pulldown'), isNotNull);
        expect(catalog.findByKey('barbell_row'), isNotNull);
        expect(catalog.findByKey('dumbbell_row'), isNotNull);
        expect(catalog.findByKey('seated_cable_row'), isNotNull);
        expect(catalog.findByKey('t_bar_row'), isNotNull);
        expect(catalog.findByKey('chest_supported_row'), isNotNull);
        expect(catalog.findByKey('straight_arm_pulldown'), isNotNull);

        // Shoulders
        expect(catalog.findByKey('overhead_press'), isNotNull);
        expect(catalog.findByKey('dumbbell_shoulder_press'), isNotNull);
        expect(catalog.findByKey('arnold_press'), isNotNull);
        expect(catalog.findByKey('lateral_raise'), isNotNull);
        expect(catalog.findByKey('cable_lateral_raise'), isNotNull);
        expect(catalog.findByKey('front_raise'), isNotNull);
        expect(catalog.findByKey('rear_delt_fly'), isNotNull);
        expect(catalog.findByKey('face_pull'), isNotNull);

        // Legs
        expect(catalog.findByKey('squat'), isNotNull);
        expect(catalog.findByKey('front_squat'), isNotNull);
        expect(catalog.findByKey('leg_press'), isNotNull);
        expect(catalog.findByKey('romanian_deadlift'), isNotNull);
        expect(catalog.findByKey('deadlift'), isNotNull);
        expect(catalog.findByKey('bulgarian_split_squat'), isNotNull);
        expect(catalog.findByKey('leg_extension'), isNotNull);
        expect(catalog.findByKey('leg_curl'), isNotNull);
        expect(catalog.findByKey('calf_raise'), isNotNull);

        // Biceps
        expect(catalog.findByKey('barbell_curl'), isNotNull);
        expect(catalog.findByKey('dumbbell_curl'), isNotNull);
        expect(catalog.findByKey('hammer_curl'), isNotNull);
        expect(catalog.findByKey('incline_dumbbell_curl'), isNotNull);
        expect(catalog.findByKey('preacher_curl'), isNotNull);
        expect(catalog.findByKey('cable_curl'), isNotNull);

        // Triceps
        expect(catalog.findByKey('triceps_pushdown'), isNotNull);
        expect(catalog.findByKey('rope_pushdown'), isNotNull);
        expect(catalog.findByKey('skull_crusher'), isNotNull);
        expect(catalog.findByKey('overhead_triceps_extension'), isNotNull);
        expect(catalog.findByKey('close_grip_bench_press'), isNotNull);
        expect(catalog.findByKey('dumbbell_triceps_extension'), isNotNull);
      },
    );

    test('Sync is idempotent: running 3 times results in identical count and no duplicate rows', () async {
      await db.seedDatabaseIfEmpty(catalog: catalog);
      final initialExercises = await exerciseRepo.getAllExercises();
      final initialCount = initialExercises.length;

      // Run sync 1st time
      await sync.syncIfNeeded(catalog: catalog, force: true);
      final count1 = (await exerciseRepo.getAllExercises()).length;
      expect(count1, equals(initialCount));

      // Run sync 2nd time
      await sync.syncIfNeeded(catalog: catalog, force: true);
      final count2 = (await exerciseRepo.getAllExercises()).length;
      expect(count2, equals(initialCount));

      // Run sync 3rd time
      await sync.syncIfNeeded(catalog: catalog, force: true);
      final count3 = (await exerciseRepo.getAllExercises()).length;
      expect(count3, equals(initialCount));
    });

    test('Sync does not delete any exercises and does not overwrite custom exercises with same name', () async {
      // Create custom exercise named "Bench Press"
      final customId = await exerciseRepo.createExercise(
        name: 'Bench Press',
        muscleGroup: 'Chest',
        equipment: 'Barbell',
        description: 'My custom bench press',
        instructions: 'Push hard',
        tips: 'Keep elbows tucked',
      );

      // Seed & sync catalog
      await sync.syncIfNeeded(catalog: catalog, force: true);

      // Custom exercise must remain untouched
      final customEx = await exerciseRepo.getExerciseById(customId);
      expect(customEx, isNotNull);
      expect(customEx!.isCustom, isTrue);
      expect(customEx.catalogKey, isNull);
      expect(customEx.instructions, equals('Push hard'));
      expect(customEx.tips, equals('Keep elbows tucked'));

      // Catalog Bench Press must exist alongside the custom exercise
      final allBench = (await exerciseRepo.getAllExercises())
          .where((e) => e.name == 'Bench Press')
          .toList();
      expect(allBench.length, equals(2));
      final catalogBench = allBench.firstWhere((e) => !e.isCustom);
      expect(catalogBench.catalogKey, equals('bench_press'));
    });

    test(
      'Search with diacritics / without diacritics, and filter matching',
      () async {
        await db.seedDatabaseIfEmpty(catalog: catalog);
        final all = await exerciseRepo.getAllExercises();
        final benchPress = all.firstWhere((e) => e.catalogKey == 'bench_press');
        final squat = all.firstWhere((e) => e.catalogKey == 'squat');

        // Search by English name
        expect(
          ExerciseDisplayHelper.matchesQuery(
            benchPress,
            'bench',
            catalog: catalog,
          ),
          isTrue,
        );

        // Search by Vietnamese name with diacritics
        expect(
          ExerciseDisplayHelper.matchesQuery(
            benchPress,
            'đẩy ngực',
            catalog: catalog,
          ),
          isTrue,
        );

        // Search by Vietnamese without diacritics (accent-insensitive)
        expect(
          ExerciseDisplayHelper.matchesQuery(
            benchPress,
            'day nguc',
            catalog: catalog,
          ),
          isTrue,
        );

        // Search Squat by Vietnamese "gánh đùi" / "ganh dui"
        expect(
          ExerciseDisplayHelper.matchesQuery(
            squat,
            'gánh đùi',
            catalog: catalog,
          ),
          isTrue,
        );
        expect(
          ExerciseDisplayHelper.matchesQuery(
            squat,
            'ganh dui',
            catalog: catalog,
          ),
          isTrue,
        );

        // Search non-matching
        expect(
          ExerciseDisplayHelper.matchesQuery(
            squat,
            'swimming',
            catalog: catalog,
          ),
          isFalse,
        );
      },
    );

    test(
      'Create and edit custom exercise persists instructions and tips',
      () async {
        final id = await exerciseRepo.createExercise(
          name: 'My Special Squat',
          muscleGroup: 'Legs',
          equipment: 'Barbell',
          description: 'Special variant',
          instructions: 'Step 1: Unrack\nStep 2: Squat down',
          tips: 'Stay tight',
        );

        var ex = await exerciseRepo.getExerciseById(id);
        expect(ex, isNotNull);
        expect(ex!.name, equals('My Special Squat'));
        expect(ex.instructions, contains('Step 1: Unrack'));
        expect(ex.tips, equals('Stay tight'));

        // Edit exercise
        final updated = ex.copyWith(
          name: 'My Special Squat v2',
          instructions: const Value(
            'Step 1: Unrack carefully\nStep 2: Squat deep',
          ),
          tips: const Value('Stay tight and breathe'),
        );
        await exerciseRepo.updateExercise(updated);

        ex = await exerciseRepo.getExerciseById(id);
        expect(ex!.name, equals('My Special Squat v2'));
        expect(ex.instructions, contains('Squat deep'));
        expect(ex.tips, equals('Stay tight and breathe'));
      },
    );

    test('Can add catalog exercise to Workout Day and retrieve it', () async {
      await db.seedDatabaseIfEmpty(catalog: catalog);
      final plans = await workoutRepo.getWorkoutPlans();
      final plan = plans.first;
      final days = await workoutRepo.getDaysForPlan(plan.id);
      final pushDay = days.first;

      final allExercises = await exerciseRepo.getAllExercises();
      final bench = allExercises.firstWhere(
        (e) => e.catalogKey == 'bench_press',
      );

      // Add to push day
      await workoutRepo.addExerciseToDay(pushDay.id, bench.id, 0);

      final dayExercises = await workoutRepo.getExercisesForDay(pushDay.id);
      expect(dayExercises.length, equals(1));
      expect(dayExercises.first.exerciseId, equals(bench.id));
    });
  });
}
