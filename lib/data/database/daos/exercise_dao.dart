part of '../app_database.dart';

/// Exercise library queries kept separate from workout/session persistence.
extension ExerciseDao on AppDatabase {
  Stream<List<ExerciseEntry>> watchAllExercises({
    bool includeArchived = false,
  }) =>
      (select(exercises)
            ..where(
              (t) => includeArchived
                  ? const Constant(true)
                  : t.isArchived.equals(false),
            )
            ..orderBy([(t) => OrderingTerm.asc(t.name)]))
          .watch();

  Future<List<ExerciseEntry>> getAllExercises({bool includeArchived = false}) =>
      (select(exercises)
            ..where(
              (t) => includeArchived
                  ? const Constant(true)
                  : t.isArchived.equals(false),
            )
            ..orderBy([(t) => OrderingTerm.asc(t.name)]))
          .get();

  Future<ExerciseEntry?> getExerciseById(int id) =>
      (select(exercises)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<int> insertExercise(ExercisesCompanion value) =>
      into(exercises).insert(value);

  Future<bool> updateExercise(ExerciseEntry value) =>
      update(exercises).replace(value);

  Future<int> archiveExercise(int id) =>
      (update(exercises)..where((t) => t.id.equals(id))).write(
        const ExercisesCompanion(isArchived: Value(true)),
      );

  Future<int> unarchiveExercise(int id) =>
      (update(exercises)..where((t) => t.id.equals(id))).write(
        const ExercisesCompanion(isArchived: Value(false)),
      );
}
