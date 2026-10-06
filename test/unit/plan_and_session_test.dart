import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtrack/data/database/app_database.dart';
import 'package:gymtrack/data/repositories/exercise_repository_impl.dart';
import 'package:gymtrack/data/repositories/workout_repository_impl.dart';

void main() {
  late AppDatabase db;
  late WorkoutRepositoryImpl workoutRepo;
  late ExerciseRepositoryImpl exerciseRepo;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    workoutRepo = WorkoutRepositoryImpl(db);
    exerciseRepo = ExerciseRepositoryImpl(db);
    await db.seedDatabaseIfEmpty();
  });

  tearDown(() async {
    await db.close();
  });

  group('Plan, Reorder, Session & Backup Tests', () {
    test('G.2: Reorder exercises for day and days for plan preserve exact orderIndex', () async {
      final planId = await workoutRepo.createWorkoutPlan(
        'Reorder Test Plan',
        'Testing reordering',
      );

      // Create 3 days
      final day1Id = await workoutRepo.createWorkoutDay(planId, 'Day A', 1, 0);
      final day2Id = await workoutRepo.createWorkoutDay(planId, 'Day B', 2, 1);
      final day3Id = await workoutRepo.createWorkoutDay(planId, 'Day C', 3, 2);

      var days = await workoutRepo.getDaysForPlan(planId);
      expect(days.map((d) => d.id).toList(), equals([day1Id, day2Id, day3Id]));

      // Reorder days: Day C (index 0), Day A (index 1), Day B (index 2)
      await workoutRepo.reorderDaysForPlan(planId, [day3Id, day1Id, day2Id]);
      days = await workoutRepo.getDaysForPlan(planId);
      expect(days.map((d) => d.id).toList(), equals([day3Id, day1Id, day2Id]));
      expect(days[0].orderIndex, equals(0));
      expect(days[1].orderIndex, equals(1));
      expect(days[2].orderIndex, equals(2));

      // Create 3 exercises in Day C
      final exercises = await exerciseRepo.getAllExercises();
      final ex1 = exercises[0];
      final ex2 = exercises[1];
      final ex3 = exercises[2];

      final we1Id = await workoutRepo.addExerciseToDay(day3Id, ex1.id, 0);
      final we2Id = await workoutRepo.addExerciseToDay(day3Id, ex2.id, 1);
      final we3Id = await workoutRepo.addExerciseToDay(day3Id, ex3.id, 2);

      var dayExs = await workoutRepo.getExercisesForDay(day3Id);
      expect(dayExs.map((e) => e.id).toList(), equals([we1Id, we2Id, we3Id]));

      // Reorder exercises: [we2, we3, we1]
      await workoutRepo.reorderExercisesForDay(day3Id, [we2Id, we3Id, we1Id]);
      dayExs = await workoutRepo.getExercisesForDay(day3Id);
      expect(dayExs.map((e) => e.id).toList(), equals([we2Id, we3Id, we1Id]));
      expect(dayExs[0].orderIndex, equals(0));
      expect(dayExs[1].orderIndex, equals(1));
      expect(dayExs[2].orderIndex, equals(2));
    });

    test('G.3: Modifying plan, day name or exercise params does NOT alter old session data', () async {
      final planId = await workoutRepo.createWorkoutPlan(
        'Original Plan Name',
        'Desc',
      );
      final dayId = await workoutRepo.createWorkoutDay(
        planId,
        'Original Day Name',
        1,
        0,
      );
      final exercises = await exerciseRepo.getAllExercises();
      final bench = exercises.firstWhere((e) => e.name == 'Bench Press');

      final weId = await workoutRepo.addExerciseToDay(
        dayId,
        bench.id,
        0,
        targetSets: 3,
        targetMinReps: 8,
        targetMaxReps: 12,
        restSeconds: 90,
      );

      final dayExs = await workoutRepo.getExercisesForDay(dayId);

      // Start and finish a workout session using this plan
      final sessionId = await workoutRepo.startWorkoutSession(
        workoutDayId: dayId,
        planName: 'Original Plan Name',
        dayName: 'Original Plan Name - Original Day Name',
        workoutExercises: dayExs,
      );

      final exSessions = await workoutRepo.getExerciseSessionsForWorkout(
        sessionId,
      );
      final sets = await workoutRepo.getSetsForExerciseSession(
        exSessions.first.id,
      );
      expect(sets.length, equals(3));

      // Complete the sets and finish session
      await workoutRepo.updateSet(
        sets[0].copyWith(weight: 60.0, reps: 10, completed: true),
      );
      await workoutRepo.finishWorkoutSession(sessionId, notes: 'Original note');

      // Now modify plan: rename plan, rename day, change exercise targetSets to 5
      final plan = (await workoutRepo.getWorkoutPlans()).firstWhere(
        (p) => p.id == planId,
      );
      await workoutRepo.updateWorkoutPlan(
        plan.copyWith(name: 'Renamed Plan Name'),
      );

      final day = (await workoutRepo.getDaysForPlan(planId))
          .firstWhere((d) => d.id == dayId);
      await workoutRepo.updateWorkoutDay(
        day.copyWith(name: 'Renamed Day Name'),
      );

      final weEntry = (await workoutRepo.getExercisesForDay(dayId))
          .firstWhere((e) => e.id == weId);
      await workoutRepo.updateWorkoutExercise(
        weEntry.copyWith(targetSets: 5, restSeconds: 180),
      );

      // Verify the old session and its exercise sessions/sets remain unchanged
      final history = await workoutRepo.getCompletedWorkoutHistory();
      final oldSession = history.firstWhere((s) => s.id == sessionId);

      expect(oldSession.planName, equals('Original Plan Name'));
      expect(
        oldSession.dayName,
        equals('Original Plan Name - Original Day Name'),
      );
      expect(oldSession.notes, equals('Original note'));

      final oldExSessions = await workoutRepo.getExerciseSessionsForWorkout(
        sessionId,
      );
      expect(oldExSessions.first.restSeconds, equals(90)); // Unchanged

      final oldSets = await workoutRepo.getSetsForExerciseSession(
        oldExSessions.first.id,
      );
      expect(oldSets.length, equals(3)); // Still 3 sets, not 5
    });

    test('G.4: createWorkoutSession creates targetSets (4 sets) and uncompleted sets are excluded from volume/PR', () async {
      final exercises = await exerciseRepo.getAllExercises();
      final squat = exercises.firstWhere((e) => e.name.contains('Squat'));

      // Plan with an exercise having 4 target sets
      final planId = await workoutRepo.createWorkoutPlan('Hypertrophy', null);
      final dayId = await workoutRepo.createWorkoutDay(planId, 'Leg Day', 1, 0);
      await workoutRepo.addExerciseToDay(
        dayId,
        squat.id,
        0,
        targetSets: 4,
        targetMinReps: 6,
        targetMaxReps: 10,
        restSeconds: 120,
      );

      final dayExs = await workoutRepo.getExercisesForDay(dayId);

      // Start session from plan
      final sessionId = await workoutRepo.startWorkoutSession(
        workoutDayId: dayId,
        planName: 'Hypertrophy',
        dayName: 'Leg Day',
        workoutExercises: dayExs,
      );

      final exSessions = await workoutRepo.getExerciseSessionsForWorkout(
        sessionId,
      );
      expect(exSessions.length, equals(1));
      final sets = await workoutRepo.getSetsForExerciseSession(
        exSessions.first.id,
      );

      // Verify session was initialized with EXACTLY 4 sets (matching targetSets)
      expect(sets.length, equals(4));

      // Tick completed ONLY for Set 1 (100kg x 5) and Set 2 (110kg x 3)
      // Set 3 (120kg x 2) and Set 4 (130kg x 1) are entered but NOT ticked completed
      await workoutRepo.updateSet(
        sets[0].copyWith(weight: 100.0, reps: 5, completed: true),
      );
      await workoutRepo.updateSet(
        sets[1].copyWith(weight: 110.0, reps: 3, completed: true),
      );
      await workoutRepo.updateSet(
        sets[2].copyWith(weight: 120.0, reps: 2, completed: false),
      );
      await workoutRepo.updateSet(
        sets[3].copyWith(weight: 130.0, reps: 1, completed: false),
      );

      // Finish session
      await workoutRepo.finishWorkoutSession(sessionId);

      // Verify Total Volume: ONLY completed sets count: (100 * 5) + (110 * 3) = 500 + 330 = 830 kg
      final history = await workoutRepo.getCompletedWorkoutHistory();
      final session = history.firstWhere((s) => s.id == sessionId);
      expect(session.totalVolume, equals(830.0));

      // Verify Progress points: maxWeight = 110.0, totalVolume = 830.0 (120kg and 130kg must NOT count)
      final progress = await workoutRepo.getExerciseProgressHistory(squat.id);
      expect(progress.length, equals(1));
      expect(progress.first.maxWeight, equals(110.0));
      expect(progress.first.totalVolume, equals(830.0));

      // Verify PR: maxWeight = 110.0
      final prs = await workoutRepo.getAllTimePRs();
      final squatPR = prs.firstWhere((pr) => pr.exerciseName == squat.name);
      expect(squatPR.maxWeight, equals(110.0));
    });

    test('G.6: Import backup JSON from older format without isArchived or v3 columns succeeds', () async {
      // Construct a legacy backup JSON missing isArchived and v3 columns
      final legacyBackup = {
        'version': 1,
        'exportedAt': DateTime.now().toIso8601String(),
        'exercises': [
          {
            'id': 101,
            'name': 'Legacy Dumbbell Curl',
            'muscleGroup': 'Arms',
            'equipment': 'Dumbbell',
            'exerciseType': 'Weight & Reps',
            'description': 'Old curl description',
            'isCustom': true,
            'createdAt': DateTime(2025, 1, 1).toIso8601String(),
            'updatedAt': DateTime(2025, 1, 1).toIso8601String(),
            // NO isArchived, NO catalogKey, NO tips, NO instructions
          },
        ],
        'workoutPlans': [
          {
            'id': 1,
            'name': 'Legacy Plan',
            'description': 'From old version',
            'isActive': true,
            'createdAt': DateTime(2025, 1, 1).toIso8601String(),
            'updatedAt': DateTime(2025, 1, 1).toIso8601String(),
          },
        ],
        'workoutDays': [
          {
            'id': 1,
            'workoutPlanId': 1,
            'name': 'Legacy Day',
            'dayOfWeek': 1,
            'orderIndex': 0,
          },
        ],
        'workoutExercises': [
          {
            'id': 1,
            'workoutDayId': 1,
            'exerciseId': 101,
            'orderIndex': 0,
            'targetSets': 3,
            'targetMinReps': 8,
            'targetMaxReps': 12,
            'restSeconds': 90,
          },
        ],
        'workoutSessions': [
          {
            'id': 1,
            'workoutDayId': 1,
            'planName': 'Legacy Plan',
            'dayName': 'Legacy Day',
            'startedAt': DateTime(2025, 1, 2, 10, 0).toIso8601String(),
            'finishedAt': DateTime(2025, 1, 2, 11, 0).toIso8601String(),
            'notes': 'Old workout notes',
            'durationMinutes': 60,
            'totalVolume': 240.0,
          },
        ],
        'exerciseSessions': [
          {
            'id': 1,
            'workoutSessionId': 1,
            'exerciseId': 101,
            'exerciseName': 'Legacy Dumbbell Curl',
            'orderIndex': 0,
            'restSeconds': 90,
          },
        ],
        'workoutSets': [
          {
            'id': 1,
            'exerciseSessionId': 1,
            'setNumber': 1,
            'weight': 12.0,
            'reps': 10,
            'rpe': null,
            'completed': true,
          },
          {
            'id': 2,
            'exerciseSessionId': 1,
            'setNumber': 2,
            'weight': 12.0,
            'reps': 10,
            'rpe': null,
            'completed': true,
          },
        ],
        'bodyMeasurements': [],
      };

      final jsonString = jsonEncode(legacyBackup);

      // Clear current DB and import legacy backup
      await db.clearAllData();
      await db.importDatabaseFromJson(jsonString);

      // Verify exercise imported with default isArchived=false and null v3 columns
      final importedEx = await exerciseRepo.getExerciseById(101);
      expect(importedEx, isNotNull);
      expect(importedEx!.name, equals('Legacy Dumbbell Curl'));
      expect(importedEx.isArchived, isFalse);
      expect(importedEx.catalogKey, isNull);
      expect(importedEx.instructions, isNull);

      // Verify history and sets restored
      final history = await workoutRepo.getCompletedWorkoutHistory();
      expect(history.length, equals(1));
      expect(history.first.planName, equals('Legacy Plan'));
      expect(history.first.totalVolume, equals(240.0));

      final sets = await workoutRepo.getSetsForExerciseSession(1);
      expect(sets.length, equals(2));
      expect(sets.first.weight, equals(12.0));
    });
  });
}
