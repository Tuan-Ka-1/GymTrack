import '../../data/database/app_database.dart';

abstract class ExerciseRepository {
  Stream<List<ExerciseEntry>> watchAllExercises({bool includeArchived});
  Future<List<ExerciseEntry>> getAllExercises({bool includeArchived});
  Future<ExerciseEntry?> getExerciseById(int id);
  Future<int> createExercise({
    required String name,
    required String muscleGroup,
    required String equipment,
    String? description,
    String exerciseType = 'Weight & Reps',
  });
  Future<bool> updateExercise(ExerciseEntry entry);
  Future<int> archiveExercise(int id);
  Future<int> unarchiveExercise(int id);
}
