import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../../features/exercises/domain/exercise_catalog.dart';
import 'seed_data.dart';
import 'tables/tables.dart';

part 'app_database.g.dart';
part 'daos/exercise_dao.dart';
part 'daos/workout_dao.dart';
part 'daos/body_dao.dart';

class ExerciseProgressPoint {
  final DateTime date;
  final double maxWeight;
  final double totalVolume;
  final double estimated1RM;

  const ExerciseProgressPoint({
    required this.date,
    required this.maxWeight,
    required this.totalVolume,
    required this.estimated1RM,
  });
}

class PersonalRecordItem {
  final String exerciseName;
  final double maxWeight;
  final double estimated1RM;
  final DateTime achievedAt;

  const PersonalRecordItem({
    required this.exerciseName,
    required this.maxWeight,
    required this.estimated1RM,
    required this.achievedAt,
  });
}

@DriftDatabase(
  tables: [
    Exercises,
    WorkoutPlans,
    WorkoutDays,
    WorkoutExercises,
    WorkoutSessions,
    ExerciseSessions,
    WorkoutSets,
    BodyMeasurements,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: 'gymtrack'));

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await customStatement('PRAGMA foreign_keys = ON');
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.addColumn(exercises, exercises.isArchived);
        // Rebuild this table through Drift's table migration so its
        // exercise FK changes from cascade to set-null without dropping
        // the name snapshot or attached workout sets.
        await m.alterTable(TableMigration(exerciseSessions));
        await m.alterTable(TableMigration(workoutExercises));
      }
      if (from < 3) {
        await m.alterTable(
          TableMigration(
            exercises,
            columnTransformer: {
              exercises.catalogKey: const CustomExpression<String>('NULL'),
              exercises.secondaryMuscles: const CustomExpression<String>(
                'NULL',
              ),
              exercises.instructions: const CustomExpression<String>('NULL'),
              exercises.tips: const CustomExpression<String>('NULL'),
              exercises.imageAsset: const CustomExpression<String>('NULL'),
            },
          ),
        );
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  Future<void> seedDatabaseIfEmpty({ExerciseCatalog? catalog}) async {
    if (await (select(
      exercises,
    )..limit(1)).get().then((rows) => rows.isNotEmpty)) {
      return;
    }
    if (catalog != null) {
      await batch((b) {
        b.insertAll(
          exercises,
          catalog.exercises
              .map(
                (e) => ExercisesCompanion.insert(
                  name: e.getName(locale: 'en'),
                  muscleGroup: e.muscleGroup,
                  equipment: e.equipment,
                  exerciseType: Value(e.exerciseType),
                  catalogKey: Value(e.key),
                  secondaryMuscles: Value(
                    e.secondaryMuscles.isEmpty
                        ? null
                        : jsonEncode(e.secondaryMuscles),
                  ),
                  isCustom: const Value(false),
                  isArchived: const Value(false),
                ),
              )
              .toList(),
        );
      });
    } else {
      await batch((b) {
        b.insertAll(
          exercises,
          SeedData.defaultExercises
              .map(
                (e) => ExercisesCompanion.insert(
                  name: e.name,
                  muscleGroup: e.muscleGroup,
                  equipment: e.equipment,
                  description: Value(e.description),
                ),
              )
              .toList(),
        );
      });
    }
    final planId = await into(workoutPlans).insert(
      WorkoutPlansCompanion.insert(
        name: 'PPL Starter',
        description: const Value('Push, Pull, Legs'),
      ),
    );
    for (final (index, name) in ['Push', 'Pull', 'Legs'].indexed) {
      await into(workoutDays).insert(
        WorkoutDaysCompanion.insert(
          workoutPlanId: planId,
          name: name,
          dayOfWeek: Value(index + 1),
          orderIndex: Value(index),
        ),
      );
    }
  }

  Stream<List<WorkoutPlanEntry>> watchWorkoutPlans() => (select(
    workoutPlans,
  )..orderBy([(t) => OrderingTerm.desc(t.updatedAt)])).watch();
  Future<List<WorkoutPlanEntry>> getWorkoutPlans() => (select(
    workoutPlans,
  )..orderBy([(t) => OrderingTerm.desc(t.updatedAt)])).get();
  Future<WorkoutPlanEntry?> getActiveWorkoutPlan() =>
      (select(workoutPlans)
            ..where((t) => t.isActive.equals(true))
            ..limit(1))
          .getSingleOrNull();
  Future<int> insertWorkoutPlan(WorkoutPlansCompanion value) =>
      into(workoutPlans).insert(value);
  Future<bool> updateWorkoutPlan(WorkoutPlanEntry value) =>
      update(workoutPlans).replace(value);
  Future<int> deleteWorkoutPlan(int id) =>
      (delete(workoutPlans)..where((t) => t.id.equals(id))).go();
  Stream<List<WorkoutDayEntry>> watchDaysForPlan(int id) =>
      (select(workoutDays)
            ..where((t) => t.workoutPlanId.equals(id))
            ..orderBy([(t) => OrderingTerm.asc(t.orderIndex)]))
          .watch();
  Future<List<WorkoutDayEntry>> getDaysForPlan(int id) =>
      (select(workoutDays)
            ..where((t) => t.workoutPlanId.equals(id))
            ..orderBy([(t) => OrderingTerm.asc(t.orderIndex)]))
          .get();
  Future<int> insertWorkoutDay(WorkoutDaysCompanion value) =>
      into(workoutDays).insert(value);
  Future<bool> updateWorkoutDay(WorkoutDayEntry value) =>
      update(workoutDays).replace(value);
  Future<int> deleteWorkoutDay(int id) =>
      (delete(workoutDays)..where((t) => t.id.equals(id))).go();
  Stream<List<WorkoutExerciseEntry>> watchExercisesForDay(int id) =>
      (select(workoutExercises)
            ..where((t) => t.workoutDayId.equals(id))
            ..orderBy([(t) => OrderingTerm.asc(t.orderIndex)]))
          .watch();
  Future<List<WorkoutExerciseEntry>> getExercisesForDay(int id) =>
      (select(workoutExercises)
            ..where((t) => t.workoutDayId.equals(id))
            ..orderBy([(t) => OrderingTerm.asc(t.orderIndex)]))
          .get();
  Future<int> addExerciseToDay(WorkoutExercisesCompanion value) =>
      into(workoutExercises).insert(value);
  Future<int> removeExerciseFromDay(int id) =>
      (delete(workoutExercises)..where((t) => t.id.equals(id))).go();
  Future<bool> updateWorkoutExercise(WorkoutExerciseEntry value) =>
      update(workoutExercises).replace(value);
  Future<void> reorderExercisesForDay(int dayId, List<int> ids) async =>
      transaction(() async {
        for (var i = 0; i < ids.length; i++) {
          await (update(workoutExercises)..where(
                (t) => t.id.equals(ids[i]) & t.workoutDayId.equals(dayId),
              ))
              .write(WorkoutExercisesCompanion(orderIndex: Value(i)));
        }
      });
  Future<void> reorderDaysForPlan(int planId, List<int> ids) async =>
      transaction(() async {
        for (var i = 0; i < ids.length; i++) {
          await (update(workoutDays)..where(
                (t) => t.id.equals(ids[i]) & t.workoutPlanId.equals(planId),
              ))
              .write(WorkoutDaysCompanion(orderIndex: Value(i)));
        }
      });

  Future<WorkoutSessionEntry?> getActiveWorkoutSession() =>
      (select(workoutSessions)
            ..where((t) => t.finishedAt.isNull())
            ..orderBy([(t) => OrderingTerm.desc(t.startedAt)])
            ..limit(1))
          .getSingleOrNull();
  Future<int> createWorkoutSession({
    int? workoutDayId,
    String? planName,
    required String dayName,
    List<WorkoutExerciseEntry>? workoutExercises,
    bool autoFillPrevious = false,
  }) async => transaction(() async {
    final sessionId = await into(workoutSessions).insert(
      WorkoutSessionsCompanion.insert(
        workoutDayId: Value(workoutDayId),
        planName: Value(planName),
        dayName: Value(dayName),
      ),
    );
    if (workoutExercises != null) {
      for (final (index, item) in workoutExercises.indexed) {
        final exercise = item.exerciseId == null
            ? null
            : await getExerciseById(item.exerciseId!);
        if (exercise == null) continue;
        final exSessionId = await into(exerciseSessions).insert(
          ExerciseSessionsCompanion.insert(
            workoutSessionId: sessionId,
            exerciseId: Value(exercise.id),
            exerciseName: exercise.name,
            orderIndex: Value(index),
            restSeconds: Value(item.restSeconds),
          ),
        );
        final prevSets = autoFillPrevious
            ? await getPreviousPerformance(exercise.id)
            : <WorkoutSetEntry>[];
        for (var set = 0; set < item.targetSets; set++) {
          final prev = autoFillPrevious && prevSets.isNotEmpty
              ? (set < prevSets.length ? prevSets[set] : prevSets.last)
              : null;
          await into(workoutSets).insert(
            WorkoutSetsCompanion.insert(
              exerciseSessionId: exSessionId,
              setNumber: set + 1,
              weight: Value(prev?.weight ?? 0.0),
              reps: Value(prev?.reps ?? 0),
            ),
          );
        }
      }
    }
    return sessionId;
  });
  Future<int> addExerciseToSession(
    int sessionId,
    int exerciseId,
    String name, {
    bool autoFillPrevious = false,
  }) async {
    final current = await (select(
      exerciseSessions,
    )..where((t) => t.workoutSessionId.equals(sessionId))).get();
    final id = await into(exerciseSessions).insert(
      ExerciseSessionsCompanion.insert(
        workoutSessionId: sessionId,
        exerciseId: Value(exerciseId),
        exerciseName: name,
        orderIndex: Value(current.length),
      ),
    );
    final prevSets = autoFillPrevious
        ? await getPreviousPerformance(exerciseId)
        : <WorkoutSetEntry>[];
    final prev = prevSets.isNotEmpty ? prevSets.first : null;
    await into(workoutSets).insert(
      WorkoutSetsCompanion.insert(
        exerciseSessionId: id,
        setNumber: 1,
        weight: Value(prev?.weight ?? 0.0),
        reps: Value(prev?.reps ?? 0),
      ),
    );
    return id;
  }

  Future<int> addSetToExerciseSession(
    int id, {
    bool autoFillPrevious = false,
  }) async {
    final existing = await getSetsForExerciseSession(id);
    double initialWeight = 0.0;
    int initialReps = 0;

    if (autoFillPrevious) {
      final exSession = await (select(
        exerciseSessions,
      )..where((t) => t.id.equals(id))).getSingleOrNull();
      if (exSession != null && exSession.exerciseId != null) {
        final prevSets = await getPreviousPerformance(exSession.exerciseId!);
        if (prevSets.isNotEmpty) {
          final prev = existing.length < prevSets.length
              ? prevSets[existing.length]
              : prevSets.last;
          initialWeight = prev.weight;
          initialReps = prev.reps;
        }
      }
    }

    return into(workoutSets).insert(
      WorkoutSetsCompanion.insert(
        exerciseSessionId: id,
        setNumber: existing.length + 1,
        weight: Value(initialWeight),
        reps: Value(initialReps),
      ),
    );
  }

  Future<int> deleteSet(int id) =>
      (delete(workoutSets)..where((t) => t.id.equals(id))).go();
  Future<bool> updateSet(WorkoutSetEntry value) =>
      update(workoutSets).replace(value);
  Future<void> finishWorkoutSession(int id, {String? notes}) async {
    final now = DateTime.now();
    final session = await (select(
      workoutSessions,
    )..where((t) => t.id.equals(id))).getSingle();
    final setRows =
        await (select(workoutSets).join([
              innerJoin(
                exerciseSessions,
                exerciseSessions.id.equalsExp(workoutSets.exerciseSessionId),
              ),
            ])..where(
              exerciseSessions.workoutSessionId.equals(id) &
                  workoutSets.completed.equals(true),
            ))
            .get();
    final volume = setRows.fold<double>(
      0,
      (sum, row) =>
          sum +
          row.readTable(workoutSets).weight * row.readTable(workoutSets).reps,
    );
    await (update(workoutSessions)..where((t) => t.id.equals(id))).write(
      WorkoutSessionsCompanion(
        finishedAt: Value(now),
        notes: Value(notes),
        durationMinutes: Value(now.difference(session.startedAt).inMinutes),
        totalVolume: Value(volume),
      ),
    );
  }

  Stream<List<WorkoutSessionEntry>> watchCompletedWorkoutHistory() =>
      (select(workoutSessions)
            ..where((t) => t.finishedAt.isNotNull())
            ..orderBy([(t) => OrderingTerm.desc(t.finishedAt)]))
          .watch();
  Future<List<WorkoutSessionEntry>> getCompletedWorkoutHistory() =>
      (select(workoutSessions)
            ..where((t) => t.finishedAt.isNotNull())
            ..orderBy([(t) => OrderingTerm.desc(t.finishedAt)]))
          .get();
  Future<int> deleteWorkoutSession(int id) =>
      (delete(workoutSessions)..where((t) => t.id.equals(id))).go();
  Future<List<ExerciseSessionEntry>> getExerciseSessionsForWorkout(int id) =>
      (select(exerciseSessions)
            ..where((t) => t.workoutSessionId.equals(id))
            ..orderBy([(t) => OrderingTerm.asc(t.orderIndex)]))
          .get();
  Stream<List<ExerciseSessionEntry>> watchExerciseSessionsForWorkout(int id) =>
      (select(exerciseSessions)
            ..where((t) => t.workoutSessionId.equals(id))
            ..orderBy([(t) => OrderingTerm.asc(t.orderIndex)]))
          .watch();
  Future<List<WorkoutSetEntry>> getSetsForExerciseSession(int id) =>
      (select(workoutSets)
            ..where((t) => t.exerciseSessionId.equals(id))
            ..orderBy([(t) => OrderingTerm.asc(t.setNumber)]))
          .get();
  Stream<List<WorkoutSetEntry>> watchSetsForExerciseSession(int id) =>
      (select(workoutSets)
            ..where((t) => t.exerciseSessionId.equals(id))
            ..orderBy([(t) => OrderingTerm.asc(t.setNumber)]))
          .watch();
  Future<void> clearAllData() async => transaction(() async {
    await delete(workoutSets).go();
    await delete(exerciseSessions).go();
    await delete(workoutSessions).go();
    await delete(workoutExercises).go();
    await delete(workoutDays).go();
    await delete(workoutPlans).go();
    await delete(bodyMeasurements).go();
    await delete(exercises).go();
  });
  Future<String> exportDatabaseToJson() async {
    final content = <String, dynamic>{
      'schemaVersion': schemaVersion,
      'exercises': (await select(
        exercises,
      ).get()).map((e) => e.toJson()).toList(),
      'workoutPlans': (await select(
        workoutPlans,
      ).get()).map((e) => e.toJson()).toList(),
      'workoutDays': (await select(
        workoutDays,
      ).get()).map((e) => e.toJson()).toList(),
      'workoutExercises': (await select(
        workoutExercises,
      ).get()).map((e) => e.toJson()).toList(),
      'workoutSessions': (await select(
        workoutSessions,
      ).get()).map((e) => e.toJson()).toList(),
      'exerciseSessions': (await select(
        exerciseSessions,
      ).get()).map((e) => e.toJson()).toList(),
      'workoutSets': (await select(
        workoutSets,
      ).get()).map((e) => e.toJson()).toList(),
      'bodyMeasurements': (await select(
        bodyMeasurements,
      ).get()).map((e) => e.toJson()).toList(),
    };
    return const JsonEncoder.withIndent('  ').convert(content);
  }

  Future<void> importDatabaseFromJson(String jsonString) async {
    dynamic decoded;
    try {
      decoded = jsonDecode(jsonString);
    } on FormatException {
      throw const FormatException('The backup file is not valid JSON.');
    }
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Backup must be a JSON object.');
    }
    final version = decoded['schemaVersion'] ?? decoded['version'];
    if (version is! int || version < 1 || version > schemaVersion) {
      throw FormatException('Unsupported backup version: $version.');
    }
    final tables = <String, TableInfo<Table, Object?>>{
      'exercises': exercises,
      'workoutPlans': workoutPlans,
      'workoutDays': workoutDays,
      'workoutExercises': workoutExercises,
      'workoutSessions': workoutSessions,
      'exerciseSessions': exerciseSessions,
      'workoutSets': workoutSets,
      'bodyMeasurements': bodyMeasurements,
    };
    for (final name in tables.keys) {
      if (decoded[name] is! List) {
        throw FormatException('Backup is missing or has invalid "$name" data.');
      }
    }
    try {
      await transaction(() async {
        await clearAllData();
        for (final name in const [
          'exercises',
          'workoutPlans',
          'workoutDays',
          'workoutExercises',
          'workoutSessions',
          'exerciseSessions',
          'workoutSets',
          'bodyMeasurements',
        ]) {
          final rows = decoded[name] as List;
          for (final row in rows) {
            if (row is! Map<String, dynamic>) {
              throw FormatException('Invalid row in "$name".');
            }
            final normalized = _normalizeBackupRow(
              name,
              Map<String, dynamic>.from(row),
            );
            switch (name) {
              case 'exercises':
                await into(
                  exercises,
                ).insert(ExerciseEntry.fromJson(normalized).toCompanion(true));
              case 'workoutPlans':
                await into(workoutPlans).insert(
                  WorkoutPlanEntry.fromJson(normalized).toCompanion(true),
                );
              case 'workoutDays':
                await into(workoutDays).insert(
                  WorkoutDayEntry.fromJson(normalized).toCompanion(true),
                );
              case 'workoutExercises':
                await into(workoutExercises).insert(
                  WorkoutExerciseEntry.fromJson(normalized).toCompanion(true),
                );
              case 'workoutSessions':
                await into(workoutSessions).insert(
                  WorkoutSessionEntry.fromJson(normalized).toCompanion(true),
                );
              case 'exerciseSessions':
                await into(exerciseSessions).insert(
                  ExerciseSessionEntry.fromJson(normalized).toCompanion(true),
                );
              case 'workoutSets':
                await into(workoutSets).insert(
                  WorkoutSetEntry.fromJson(normalized).toCompanion(true),
                );
              case 'bodyMeasurements':
                await into(bodyMeasurements).insert(
                  BodyMeasurementEntry.fromJson(normalized).toCompanion(true),
                );
            }
          }
        }
      });
    } on FormatException {
      rethrow;
    } catch (error) {
      throw FormatException(
        'The backup could not be imported. Existing data was kept. Details: $error',
      );
    }
  }

  Map<String, dynamic> _normalizeBackupRow(
    String table,
    Map<String, dynamic> row,
  ) {
    final normalized = Map<String, dynamic>.from(row);
    if (table == 'exercises') {
      normalized.putIfAbsent('exerciseType', () => 'Weight & Reps');
      normalized.putIfAbsent('isCustom', () => false);
      normalized.putIfAbsent('isArchived', () => false);
      normalized.putIfAbsent(
        'createdAt',
        () => DateTime.now().toIso8601String(),
      );
      normalized.putIfAbsent(
        'updatedAt',
        () => DateTime.now().toIso8601String(),
      );
    }
    if (table == 'workoutSessions') {
      normalized.putIfAbsent('dayName', () => 'Workout Session');
      normalized.putIfAbsent('durationMinutes', () => 0);
      normalized.putIfAbsent('totalVolume', () => 0.0);
    }
    if (table == 'workoutSets') {
      normalized.putIfAbsent('weight', () => 0.0);
      normalized.putIfAbsent('reps', () => 0);
      normalized.putIfAbsent('completed', () => false);
      normalized.putIfAbsent(
        'createdAt',
        () => DateTime.now().toIso8601String(),
      );
    }
    return normalized;
  }
}
