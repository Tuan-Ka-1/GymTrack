part of '../app_database.dart';

/// Read models for workout history, exercise trends, and personal records.
extension WorkoutDao on AppDatabase {
  Future<List<WorkoutSetEntry>> getPreviousPerformance(int exerciseId) async {
    final previous =
        await (select(exerciseSessions).join([
                innerJoin(
                  workoutSessions,
                  workoutSessions.id.equalsExp(
                    exerciseSessions.workoutSessionId,
                  ),
                ),
              ])
              ..where(
                exerciseSessions.exerciseId.equals(exerciseId) &
                    workoutSessions.finishedAt.isNotNull(),
              )
              ..orderBy([OrderingTerm.desc(workoutSessions.finishedAt)])
              ..limit(1))
            .getSingleOrNull();
    if (previous == null) return [];
    final exerciseSessionId = previous.readTable(exerciseSessions).id;
    return (select(workoutSets)
          ..where((set) => set.exerciseSessionId.equals(exerciseSessionId))
          ..orderBy([(set) => OrderingTerm.asc(set.setNumber)]))
        .get();
  }

  Future<List<ExerciseProgressPoint>> getExerciseProgressHistory(
    int exerciseId,
  ) async {
    final rows =
        await (select(exerciseSessions).join([
                innerJoin(
                  workoutSessions,
                  workoutSessions.id.equalsExp(
                    exerciseSessions.workoutSessionId,
                  ),
                ),
                innerJoin(
                  workoutSets,
                  workoutSets.exerciseSessionId.equalsExp(exerciseSessions.id),
                ),
              ])
              ..where(
                exerciseSessions.exerciseId.equals(exerciseId) &
                    workoutSessions.finishedAt.isNotNull() &
                    workoutSets.completed.equals(true),
              )
              ..orderBy([OrderingTerm.asc(workoutSessions.finishedAt)]))
            .get();

    final grouped = <DateTime, List<WorkoutSetEntry>>{};
    for (final row in rows) {
      final date = row.readTable(workoutSessions).finishedAt!;
      grouped.putIfAbsent(date, () => []).add(row.readTable(workoutSets));
    }
    return grouped.entries.map((entry) {
      final sets = entry.value;
      final maxWeight = sets.fold<double>(
        0,
        (max, set) => set.weight > max ? set.weight : max,
      );
      final estimated1RM = sets.fold<double>(0, (max, set) {
        final estimate = set.weight * (1 + set.reps / 30);
        return estimate > max ? estimate : max;
      });
      return ExerciseProgressPoint(
        date: entry.key,
        maxWeight: maxWeight,
        totalVolume: sets.fold<double>(
          0,
          (sum, set) => sum + set.weight * set.reps,
        ),
        estimated1RM: estimated1RM,
      );
    }).toList();
  }

  Future<List<PersonalRecordItem>> getAllTimePRs() async {
    final allExercises = await select(exercises).get();
    final records = <PersonalRecordItem>[];
    for (final exercise in allExercises) {
      final points = await getExerciseProgressHistory(exercise.id);
      if (points.isEmpty) continue;
      final best = points.reduce((a, b) => b.maxWeight > a.maxWeight ? b : a);
      records.add(
        PersonalRecordItem(
          exerciseName: exercise.name,
          maxWeight: best.maxWeight,
          estimated1RM: best.estimated1RM,
          achievedAt: best.date,
        ),
      );
    }
    records.sort((a, b) => b.achievedAt.compareTo(a.achievedAt));
    return records;
  }
}
