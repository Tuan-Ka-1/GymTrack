import 'package:drift/native.dart';

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:gymtrack/core/utils/formatters.dart';
import 'package:gymtrack/data/database/app_database.dart';
import 'package:gymtrack/data/repositories/workout_repository_impl.dart';
import 'package:gymtrack/data/repositories/exercise_repository_impl.dart';

void main() {
  late AppDatabase db;
  late WorkoutRepositoryImpl workoutRepo;
  late ExerciseRepositoryImpl exerciseRepo;

  setUp(() async {
    // In-memory database for isolated, fast, reliable unit testing
    db = AppDatabase(NativeDatabase.memory());
    workoutRepo = WorkoutRepositoryImpl(db);
    exerciseRepo = ExerciseRepositoryImpl(db);
    await db.seedDatabaseIfEmpty();
  });

  tearDown(() async {
    await db.close();
  });

  group('Database & Repository Integration Tests', () {
    test('Database is properly seeded on first initialization', () async {
      final exercises = await exerciseRepo.getAllExercises();
      expect(exercises.length, greaterThanOrEqualTo(25));

      final plans = await workoutRepo.getWorkoutPlans();
      expect(plans.isNotEmpty, isTrue);

      final pplPlan = plans.first;
      expect(pplPlan.name, contains('PPL'));

      final days = await workoutRepo.getDaysForPlan(pplPlan.id);
      expect(days.length, equals(3));
    });

    test('Can create custom exercise', () async {
      final id = await exerciseRepo.createExercise(
        name: 'Bulgarian Split Squat',
        muscleGroup: 'Legs',
        equipment: 'Dumbbell',
        description: 'Single leg squat with rear foot elevated.',
      );
      expect(id, greaterThan(0));

      final ex = await exerciseRepo.getExerciseById(id);
      expect(ex, isNotNull);
      expect(ex!.name, equals('Bulgarian Split Squat'));
      expect(ex.isCustom, isTrue);
    });

    test('Complete Workout Flow: Start -> Add Sets -> Finish -> Check History & PR', () async {
      final exercises = await exerciseRepo.getAllExercises();
      final benchPress = exercises.firstWhere((e) => e.name == 'Bench Press');

      // 1. Start Workout Session
      final sessionId = await workoutRepo.startWorkoutSession(
        dayName: 'Chest Day',
      );
      expect(sessionId, greaterThan(0));

      // 2. Add Bench Press to Session
      final exSessionId = await workoutRepo.addExerciseToSession(
        sessionId,
        benchPress.id,
        benchPress.name,
      );
      expect(exSessionId, greaterThan(0));

      // 3. Add and update sets: 60kg x 10, 70kg x 8
      final sets = await workoutRepo.getSetsForExerciseSession(exSessionId);
      expect(sets.isNotEmpty, isTrue);

      // Set 1
      await workoutRepo.updateSet(
        sets[0].copyWith(weight: 60.0, reps: 10, completed: true),
      );

      // Add Set 2
      final set2Id = await workoutRepo.addSetToExerciseSession(exSessionId);
      final allSetsNow = await workoutRepo.getSetsForExerciseSession(
        exSessionId,
      );
      final set2 = allSetsNow.firstWhere((s) => s.id == set2Id);
      await workoutRepo.updateSet(
        set2.copyWith(weight: 70.0, reps: 8, completed: true),
      );

      // 4. Finish Workout
      await workoutRepo.finishWorkoutSession(sessionId, notes: 'Felt great!');

      // 5. Verify History
      final history = await workoutRepo.getCompletedWorkoutHistory();
      expect(history.length, equals(1));
      expect(history.first.id, equals(sessionId));
      // Total volume: (60 * 10) + (70 * 8) = 600 + 560 = 1160
      expect(history.first.totalVolume, equals(1160.0));
      expect(history.first.notes, equals('Felt great!'));

      // 6. Verify Progress & PR calculation
      final progressPoints = await workoutRepo.getExerciseProgressHistory(
        benchPress.id,
      );
      expect(progressPoints.length, equals(1));
      expect(progressPoints.first.maxWeight, equals(70.0));
      expect(progressPoints.first.totalVolume, equals(1160.0));

      final prs = await workoutRepo.getAllTimePRs();
      expect(
        prs.any(
          (pr) => pr.exerciseName == 'Bench Press' && pr.maxWeight == 70.0,
        ),
        isTrue,
      );

      // 7. Verify Auto-fill Previous Performance for next session
      final prevSets = await workoutRepo.getPreviousPerformance(benchPress.id);
      expect(prevSets.length, equals(2));
      expect(prevSets[0].weight, equals(60.0));
      expect(prevSets[1].weight, equals(70.0));
    });

    test('Export and Import JSON Backup restores complete state', () async {
      // Export database
      final jsonBackup = await db.exportDatabaseToJson();
      expect(jsonBackup.contains('Bench Press'), isTrue);

      // Clear database
      await db.clearAllData();

      // Restore from backup
      await db.importDatabaseFromJson(jsonBackup);
      final restored = await exerciseRepo.getAllExercises();
      expect(restored.length, greaterThanOrEqualTo(25));
    });

    test('Failed backup import leaves current database unchanged', () async {
      final before = await exerciseRepo.getAllExercises(includeArchived: true);
      final invalidBackup =
          jsonDecode(await db.exportDatabaseToJson()) as Map<String, dynamic>;
      final days = invalidBackup['workoutDays'] as List<dynamic>;
      final firstDay = Map<String, dynamic>.from(days.first as Map);
      firstDay['workoutPlanId'] = -1;
      days[0] = firstDay;

      await expectLater(
        db.importDatabaseFromJson(jsonEncode(invalidBackup)),
        throwsA(isA<FormatException>()),
      );

      final after = await exerciseRepo.getAllExercises(includeArchived: true);
      expect(
        after.map((exercise) => exercise.id).toList(),
        before.map((exercise) => exercise.id).toList(),
      );
      expect((await workoutRepo.getWorkoutPlans()).length, 1);
    });

    test('Archive Exercise preserves history and progress', () async {
      // 1. Create a custom exercise
      final customExId = await exerciseRepo.createExercise(
        name: 'Custom Exercise',
        muscleGroup: 'Chest',
        equipment: 'Dumbbell',
        description: 'A custom exercise for testing',
      );
      expect(customExId, greaterThan(0));

      // 2. Start a workout session with the custom exercise
      final sessionId = await workoutRepo.startWorkoutSession(
        dayName: 'Custom Workout',
      );
      expect(sessionId, greaterThan(0));

      final exSessionId = await workoutRepo.addExerciseToSession(
        sessionId,
        customExId,
        'Custom Exercise',
      );
      expect(exSessionId, greaterThan(0));

      // 3. Add and complete sets
      final sets = await workoutRepo.getSetsForExerciseSession(exSessionId);
      expect(sets.isNotEmpty, isTrue);
      await workoutRepo.updateSet(
        sets[0].copyWith(weight: 50.0, reps: 10, completed: true),
      );

      // Add another set
      final set2Id = await workoutRepo.addSetToExerciseSession(exSessionId);
      final allSetsNow = await workoutRepo.getSetsForExerciseSession(
        exSessionId,
      );
      final set2 = allSetsNow.firstWhere((s) => s.id == set2Id);
      await workoutRepo.updateSet(
        set2.copyWith(weight: 55.0, reps: 8, completed: true),
      );

      // 4. Finish workout
      await workoutRepo.finishWorkoutSession(
        sessionId,
        notes: 'Custom exercise test',
      );

      // 5. Verify history and progress exist before archiving
      var history = await workoutRepo.getCompletedWorkoutHistory();
      expect(history.length, equals(1));
      expect(
        history.first.totalVolume,
        equals(940.0),
      ); // 50*10 + 55*8 = 500 + 440 = 940

      var progressPoints = await workoutRepo.getExerciseProgressHistory(
        customExId,
      );
      expect(progressPoints.length, equals(1));
      expect(progressPoints.first.maxWeight, equals(55.0));
      expect(progressPoints.first.totalVolume, equals(940.0));

      var prs = await workoutRepo.getAllTimePRs();
      expect(
        prs.any(
          (pr) => pr.exerciseName == 'Custom Exercise' && pr.maxWeight == 55.0,
        ),
        isTrue,
      );

      // 6. Archive the custom exercise (soft delete)
      await exerciseRepo.archiveExercise(customExId);

      // 7. Verify the exercise is no longer in the active library
      final activeExercises = await exerciseRepo.getAllExercises(
        includeArchived: false,
      );
      expect(activeExercises.any((e) => e.id == customExId), isFalse);

      // 8. Verify the exercise IS in the archived list
      final allExercises = await exerciseRepo.getAllExercises(
        includeArchived: true,
      );
      final archivedEx = allExercises.firstWhere((e) => e.id == customExId);
      expect(archivedEx.isArchived, isTrue);

      // 9. CRITICAL: History and progress should STILL be accessible and correct
      history = await workoutRepo.getCompletedWorkoutHistory();
      expect(history.length, equals(1));
      expect(history.first.totalVolume, equals(940.0));

      // The exercise sessions should still exist with the exerciseName snapshot
      final exSessions = await workoutRepo.getExerciseSessionsForWorkout(
        sessionId,
      );
      expect(exSessions.length, equals(1));
      expect(exSessions.first.exerciseName, equals('Custom Exercise'));
      // exerciseId should still reference the exercise (soft delete keeps the reference)
      expect(exSessions.first.exerciseId, equals(customExId));

      // Sets should still be there
      final sessionSets = await workoutRepo.getSetsForExerciseSession(
        exSessions.first.id,
      );
      expect(sessionSets.length, equals(2));
      expect(sessionSets.where((s) => s.completed).length, equals(2));

      // Progress should still work using the exerciseName or by querying with includeArchived
      progressPoints = await workoutRepo.getExerciseProgressHistory(customExId);
      expect(progressPoints.length, equals(1));
      expect(progressPoints.first.maxWeight, equals(55.0));
      expect(progressPoints.first.totalVolume, equals(940.0));

      // PRs should still show the custom exercise
      prs = await workoutRepo.getAllTimePRs();
      expect(
        prs.any(
          (pr) => pr.exerciseName == 'Custom Exercise' && pr.maxWeight == 55.0,
        ),
        isTrue,
      );

      // 10. Unarchive should restore to library
      await exerciseRepo.unarchiveExercise(customExId);
      final restoredExercises = await exerciseRepo.getAllExercises(
        includeArchived: false,
      );
      expect(restoredExercises.any((e) => e.id == customExId), isTrue);
    });

    test('Weight unit conversion for Progress: DB keeps kg, UI converts to lb without mutating DB', () async {
      final exercises = await exerciseRepo.getAllExercises();
      final benchPress = exercises.firstWhere((e) => e.name == 'Bench Press');

      // 1. Start Workout Session & complete 1 set 100 kg x 10 reps
      final sessionId = await workoutRepo.startWorkoutSession(
        dayName: 'Chest Day',
      );
      final exSessionId = await workoutRepo.addExerciseToSession(
        sessionId,
        benchPress.id,
        benchPress.name,
      );
      final sets = await workoutRepo.getSetsForExerciseSession(exSessionId);
      await workoutRepo.updateSet(
        sets[0].copyWith(weight: 100.0, reps: 10, completed: true),
      );
      await workoutRepo.finishWorkoutSession(sessionId);

      // Verify DB stores kg raw values
      final history = await workoutRepo.getCompletedWorkoutHistory();
      expect(history.first.totalVolume, equals(1000.0)); // 1000 kg volume

      final progress = await workoutRepo.getExerciseProgressHistory(
        benchPress.id,
      );
      expect(progress.first.maxWeight, equals(100.0)); // 100 kg
      expect(progress.first.totalVolume, equals(1000.0)); // 1000 kg
      expect(progress.first.estimated1RM, closeTo(133.33, 0.01)); // ~133.33 kg

      // 2. Conversion in UI layer with lb unit
      final formattedVolumeLb = Formatters.formatVolume(
        history.first.totalVolume,
        unit: 'lb',
      );
      expect(formattedVolumeLb, equals('2204.6 lb'));

      final formattedWeightLb = Formatters.formatWeight(
        progress.first.maxWeight,
        unit: 'lb',
      );
      expect(formattedWeightLb, equals('220.5 lb'));

      final formatted1RMLb = Formatters.formatWeight(
        progress.first.estimated1RM,
        unit: 'lb',
      );
      expect(formatted1RMLb, equals('293.9 lb'));

      // 3. Changing settings unit does NOT mutate DB values
      final historyAfter = await workoutRepo.getCompletedWorkoutHistory();
      expect(historyAfter.first.totalVolume, equals(1000.0));
      final progressAfter = await workoutRepo.getExerciseProgressHistory(
        benchPress.id,
      );
      expect(progressAfter.first.maxWeight, equals(100.0));
      expect(progressAfter.first.totalVolume, equals(1000.0));
    });

    test('Auto-fill previous setting: when OFF sets start at 0, when ON sets pre-fill from last session', () async {
      final exercises = await exerciseRepo.getAllExercises();
      final squat = exercises.firstWhere((e) => e.name.contains('Squat'));

      // Complete session 1: 80kg x 8, 90kg x 6
      final s1 = await workoutRepo.startWorkoutSession(dayName: 'Leg Day 1');
      final exSession1 = await workoutRepo.addExerciseToSession(
        s1,
        squat.id,
        squat.name,
      );
      final s1Sets = await workoutRepo.getSetsForExerciseSession(exSession1);
      await workoutRepo.updateSet(
        s1Sets[0].copyWith(weight: 80.0, reps: 8, completed: true),
      );
      final s1Set2Id = await workoutRepo.addSetToExerciseSession(exSession1);
      final allS1Sets = await workoutRepo.getSetsForExerciseSession(exSession1);
      final s1Set2 = allS1Sets.firstWhere((s) => s.id == s1Set2Id);
      await workoutRepo.updateSet(
        s1Set2.copyWith(weight: 90.0, reps: 6, completed: true),
      );
      await workoutRepo.finishWorkoutSession(s1);

      // Verify previous performance is 80x8, 90x6
      final prev = await workoutRepo.getPreviousPerformance(squat.id);
      expect(prev.length, equals(2));
      expect(prev[0].weight, equals(80.0));
      expect(prev[1].weight, equals(90.0));

      // Case A: autoFillPrevious = false (Default)
      // When OFF: new sets start empty (weight: 0.0, reps: 0)
      final s2 = await workoutRepo.startWorkoutSession(
        dayName: 'Leg Day 2 (AutoFill OFF)',
        autoFillPrevious: false,
      );
      final exSession2 = await workoutRepo.addExerciseToSession(
        s2,
        squat.id,
        squat.name,
        autoFillPrevious: false,
      );
      final s2Sets = await workoutRepo.getSetsForExerciseSession(exSession2);
      expect(s2Sets.first.weight, equals(0.0));
      expect(s2Sets.first.reps, equals(0));

      final s2Set2Id = await workoutRepo.addSetToExerciseSession(
        exSession2,
        autoFillPrevious: false,
      );
      final allS2Sets = await workoutRepo.getSetsForExerciseSession(exSession2);
      final s2Set2 = allS2Sets.firstWhere((s) => s.id == s2Set2Id);
      expect(s2Set2.weight, equals(0.0));
      expect(s2Set2.reps, equals(0));

      // Case B: autoFillPrevious = true
      // When ON: new sets are pre-filled with previous session values
      final s3 = await workoutRepo.startWorkoutSession(
        dayName: 'Leg Day 3 (AutoFill ON)',
        autoFillPrevious: true,
      );
      final exSession3 = await workoutRepo.addExerciseToSession(
        s3,
        squat.id,
        squat.name,
        autoFillPrevious: true,
      );
      final s3Sets = await workoutRepo.getSetsForExerciseSession(exSession3);
      expect(s3Sets.first.weight, equals(80.0)); // Pre-filled from set 1
      expect(s3Sets.first.reps, equals(8));

      final s3Set2Id = await workoutRepo.addSetToExerciseSession(
        exSession3,
        autoFillPrevious: true,
      );
      final allS3Sets = await workoutRepo.getSetsForExerciseSession(exSession3);
      final s3Set2 = allS3Sets.firstWhere((s) => s.id == s3Set2Id);
      expect(s3Set2.weight, equals(90.0)); // Pre-filled from set 2
      expect(s3Set2.reps, equals(6));
    });
  });
}
