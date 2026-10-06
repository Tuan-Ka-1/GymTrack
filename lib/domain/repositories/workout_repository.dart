import '../../data/database/app_database.dart';

abstract class WorkoutRepository {
  // Plans & Days
  Stream<List<WorkoutPlanEntry>> watchWorkoutPlans();
  Future<List<WorkoutPlanEntry>> getWorkoutPlans();
  Future<WorkoutPlanEntry?> getActiveWorkoutPlan();
  Future<int> createWorkoutPlan(String name, String? description);
  Future<bool> updateWorkoutPlan(WorkoutPlanEntry plan);
  Future<int> deleteWorkoutPlan(int id);

  Stream<List<WorkoutDayEntry>> watchDaysForPlan(int planId);
  Future<List<WorkoutDayEntry>> getDaysForPlan(int planId);
  Future<int> createWorkoutDay(
    int planId,
    String name,
    int? dayOfWeek,
    int orderIndex,
  );
  Future<bool> updateWorkoutDay(WorkoutDayEntry day);
  Future<int> deleteWorkoutDay(int dayId);

  Stream<List<WorkoutExerciseEntry>> watchExercisesForDay(int dayId);
  Future<List<WorkoutExerciseEntry>> getExercisesForDay(int dayId);
  Future<int> addExerciseToDay(
    int dayId,
    int exerciseId,
    int orderIndex, {
    int targetSets,
    int targetMinReps,
    int targetMaxReps,
    int restSeconds,
  });
  Future<int> removeExerciseFromDay(int id);

  // Update workout exercise parameters
  Future<bool> updateWorkoutExercise(WorkoutExerciseEntry exercise);

  // Reorder exercises and days
  Future<void> reorderExercisesForDay(int dayId, List<int> exerciseIdsInOrder);
  Future<void> reorderDaysForPlan(int planId, List<int> dayIdsInOrder);

  // Active Workout Session
  Future<WorkoutSessionEntry?> getActiveWorkoutSession();
  Future<int> startWorkoutSession({
    int? workoutDayId,
    String? planName,
    required String dayName,
    List<WorkoutExerciseEntry>? workoutExercises,
    bool autoFillPrevious = false,
  });
  Future<int> addExerciseToSession(
    int sessionId,
    int exerciseId,
    String exerciseName, {
    bool autoFillPrevious = false,
  });
  Future<int> addSetToExerciseSession(
    int exerciseSessionId, {
    bool autoFillPrevious = false,
  });
  Future<int> deleteSet(int setId);
  Future<bool> updateSet(WorkoutSetEntry setEntry);
  Future<void> finishWorkoutSession(int sessionId, {String? notes});

  // History
  Stream<List<WorkoutSessionEntry>> watchCompletedWorkoutHistory();
  Future<List<WorkoutSessionEntry>> getCompletedWorkoutHistory();
  Future<int> deleteWorkoutSession(int sessionId);
  Future<List<ExerciseSessionEntry>> getExerciseSessionsForWorkout(
    int workoutSessionId,
  );
  Stream<List<ExerciseSessionEntry>> watchExerciseSessionsForWorkout(
    int workoutSessionId,
  );
  Future<List<WorkoutSetEntry>> getSetsForExerciseSession(
    int exerciseSessionId,
  );
  Stream<List<WorkoutSetEntry>> watchSetsForExerciseSession(
    int exerciseSessionId,
  );

  // Previous performance & PR
  Future<List<WorkoutSetEntry>> getPreviousPerformance(int exerciseId);
  Future<List<ExerciseProgressPoint>> getExerciseProgressHistory(
    int exerciseId,
  );
  Future<List<PersonalRecordItem>> getAllTimePRs();
}
