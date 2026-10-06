import 'package:drift/drift.dart';

import '../../domain/repositories/workout_repository.dart';
import '../database/app_database.dart';

class WorkoutRepositoryImpl implements WorkoutRepository {
  final AppDatabase _db;

  WorkoutRepositoryImpl(this._db);

  @override
  Stream<List<WorkoutPlanEntry>> watchWorkoutPlans() => _db.watchWorkoutPlans();

  @override
  Future<List<WorkoutPlanEntry>> getWorkoutPlans() => _db.getWorkoutPlans();

  @override
  Future<WorkoutPlanEntry?> getActiveWorkoutPlan() =>
      _db.getActiveWorkoutPlan();

  @override
  Future<int> createWorkoutPlan(String name, String? description) {
    return _db.insertWorkoutPlan(
      WorkoutPlansCompanion.insert(
        name: name,
        description: Value(description),
        isActive: const Value(true),
      ),
    );
  }

  @override
  Future<bool> updateWorkoutPlan(WorkoutPlanEntry plan) =>
      _db.updateWorkoutPlan(plan);

  @override
  Future<int> deleteWorkoutPlan(int id) => _db.deleteWorkoutPlan(id);

  @override
  Stream<List<WorkoutDayEntry>> watchDaysForPlan(int planId) =>
      _db.watchDaysForPlan(planId);

  @override
  Future<List<WorkoutDayEntry>> getDaysForPlan(int planId) =>
      _db.getDaysForPlan(planId);

  @override
  Future<int> createWorkoutDay(
    int planId,
    String name,
    int? dayOfWeek,
    int orderIndex,
  ) {
    return _db.insertWorkoutDay(
      WorkoutDaysCompanion.insert(
        workoutPlanId: planId,
        name: name,
        dayOfWeek: Value(dayOfWeek),
        orderIndex: Value(orderIndex),
      ),
    );
  }

  @override
  Future<bool> updateWorkoutDay(WorkoutDayEntry day) =>
      _db.updateWorkoutDay(day);

  @override
  Future<int> deleteWorkoutDay(int dayId) => _db.deleteWorkoutDay(dayId);

  @override
  Stream<List<WorkoutExerciseEntry>> watchExercisesForDay(int dayId) =>
      _db.watchExercisesForDay(dayId);

  @override
  Future<List<WorkoutExerciseEntry>> getExercisesForDay(int dayId) =>
      _db.getExercisesForDay(dayId);

  @override
  Future<int> addExerciseToDay(
    int dayId,
    int exerciseId,
    int orderIndex, {
    int targetSets = 3,
    int targetMinReps = 8,
    int targetMaxReps = 12,
    int restSeconds = 90,
  }) {
    return _db.addExerciseToDay(
      WorkoutExercisesCompanion.insert(
        workoutDayId: dayId,
        exerciseId: Value(exerciseId),
        orderIndex: Value(orderIndex),
        targetSets: Value(targetSets),
        targetMinReps: Value(targetMinReps),
        targetMaxReps: Value(targetMaxReps),
        restSeconds: Value(restSeconds),
      ),
    );
  }

  @override
  Future<int> removeExerciseFromDay(int id) => _db.removeExerciseFromDay(id);

  @override
  Future<bool> updateWorkoutExercise(WorkoutExerciseEntry exercise) =>
      _db.updateWorkoutExercise(exercise);

  @override
  Future<void> reorderExercisesForDay(
    int dayId,
    List<int> exerciseIdsInOrder,
  ) => _db.reorderExercisesForDay(dayId, exerciseIdsInOrder);

  @override
  Future<void> reorderDaysForPlan(int planId, List<int> dayIdsInOrder) =>
      _db.reorderDaysForPlan(planId, dayIdsInOrder);

  @override
  Future<WorkoutSessionEntry?> getActiveWorkoutSession() =>
      _db.getActiveWorkoutSession();

  @override
  Future<int> startWorkoutSession({
    int? workoutDayId,
    String? planName,
    required String dayName,
    List<WorkoutExerciseEntry>? workoutExercises,
    bool autoFillPrevious = false,
  }) {
    return _db.createWorkoutSession(
      workoutDayId: workoutDayId,
      planName: planName,
      dayName: dayName,
      workoutExercises: workoutExercises,
      autoFillPrevious: autoFillPrevious,
    );
  }

  @override
  Future<int> addExerciseToSession(
    int sessionId,
    int exerciseId,
    String exerciseName, {
    bool autoFillPrevious = false,
  }) {
    return _db.addExerciseToSession(
      sessionId,
      exerciseId,
      exerciseName,
      autoFillPrevious: autoFillPrevious,
    );
  }

  @override
  Future<int> addSetToExerciseSession(
    int exerciseSessionId, {
    bool autoFillPrevious = false,
  }) {
    return _db.addSetToExerciseSession(
      exerciseSessionId,
      autoFillPrevious: autoFillPrevious,
    );
  }

  @override
  Future<int> deleteSet(int setId) => _db.deleteSet(setId);

  @override
  Future<bool> updateSet(WorkoutSetEntry setEntry) => _db.updateSet(setEntry);

  @override
  Future<void> finishWorkoutSession(int sessionId, {String? notes}) {
    return _db.finishWorkoutSession(sessionId, notes: notes);
  }

  @override
  Stream<List<WorkoutSessionEntry>> watchCompletedWorkoutHistory() =>
      _db.watchCompletedWorkoutHistory();

  @override
  Future<List<WorkoutSessionEntry>> getCompletedWorkoutHistory() =>
      _db.getCompletedWorkoutHistory();

  @override
  Future<int> deleteWorkoutSession(int sessionId) =>
      _db.deleteWorkoutSession(sessionId);

  @override
  Future<List<ExerciseSessionEntry>> getExerciseSessionsForWorkout(
    int workoutSessionId,
  ) {
    return _db.getExerciseSessionsForWorkout(workoutSessionId);
  }

  @override
  Stream<List<ExerciseSessionEntry>> watchExerciseSessionsForWorkout(
    int workoutSessionId,
  ) {
    return _db.watchExerciseSessionsForWorkout(workoutSessionId);
  }

  @override
  Future<List<WorkoutSetEntry>> getSetsForExerciseSession(
    int exerciseSessionId,
  ) {
    return _db.getSetsForExerciseSession(exerciseSessionId);
  }

  @override
  Stream<List<WorkoutSetEntry>> watchSetsForExerciseSession(
    int exerciseSessionId,
  ) {
    return _db.watchSetsForExerciseSession(exerciseSessionId);
  }

  @override
  Future<List<WorkoutSetEntry>> getPreviousPerformance(int exerciseId) {
    return _db.getPreviousPerformance(exerciseId);
  }

  @override
  Future<List<ExerciseProgressPoint>> getExerciseProgressHistory(
    int exerciseId,
  ) {
    return _db.getExerciseProgressHistory(exerciseId);
  }

  @override
  Future<List<PersonalRecordItem>> getAllTimePRs() => _db.getAllTimePRs();
}
