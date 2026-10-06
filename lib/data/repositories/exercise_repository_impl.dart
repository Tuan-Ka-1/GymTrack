import 'package:drift/drift.dart';

import '../../domain/repositories/exercise_repository.dart';
import '../database/app_database.dart';

class ExerciseRepositoryImpl implements ExerciseRepository {
  final AppDatabase _db;

  ExerciseRepositoryImpl(this._db);

  @override
  Stream<List<ExerciseEntry>> watchAllExercises({
    bool includeArchived = false,
  }) => _db.watchAllExercises(includeArchived: includeArchived);

  @override
  Future<List<ExerciseEntry>> getAllExercises({bool includeArchived = false}) =>
      _db.getAllExercises(includeArchived: includeArchived);

  @override
  Future<ExerciseEntry?> getExerciseById(int id) => _db.getExerciseById(id);

  @override
  Future<int> createExercise({
    required String name,
    required String muscleGroup,
    required String equipment,
    String? description,
    String exerciseType = 'Weight & Reps',
  }) {
    return _db.insertExercise(
      ExercisesCompanion.insert(
        name: name,
        muscleGroup: muscleGroup,
        equipment: equipment,
        description: Value(description),
        exerciseType: Value(exerciseType),
        isCustom: const Value(true),
        isArchived: const Value(false),
      ),
    );
  }

  @override
  Future<bool> updateExercise(ExerciseEntry entry) => _db.updateExercise(entry);

  @override
  Future<int> archiveExercise(int id) => _db.archiveExercise(id);

  @override
  Future<int> unarchiveExercise(int id) => _db.unarchiveExercise(id);
}
