import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtrack/data/database/app_database.dart';
import 'package:gymtrack/features/exercises/data/exercise_catalog_loader.dart';
import 'package:gymtrack/features/exercises/data/exercise_catalog_sync.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;

void main() {
  test('Drift migration v1 to v3 with legacy seed data + custom exercise + plan + history -> migration + catalog sync', () async {
    // 1. Create in-memory SQLite database at schema v1
    final rawDb = sqlite.sqlite3.openInMemory();
    rawDb.execute('PRAGMA user_version = 1;');

    // Create schema v1 tables
    rawDb.execute('''
      CREATE TABLE exercises (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        muscle_group TEXT NOT NULL,
        equipment TEXT NOT NULL,
        exercise_type TEXT NOT NULL DEFAULT 'Weight & Reps',
        description TEXT,
        is_custom INTEGER NOT NULL DEFAULT 0,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      );
    ''');

    rawDb.execute('''
      CREATE TABLE workout_plans (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      );
    ''');

    rawDb.execute('''
      CREATE TABLE workout_days (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        workout_plan_id INTEGER NOT NULL REFERENCES workout_plans(id) ON DELETE CASCADE,
        name TEXT NOT NULL,
        day_of_week INTEGER,
        order_index INTEGER NOT NULL DEFAULT 0
      );
    ''');

    rawDb.execute('''
      CREATE TABLE workout_exercises (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        workout_day_id INTEGER NOT NULL REFERENCES workout_days(id) ON DELETE CASCADE,
        exercise_id INTEGER REFERENCES exercises(id) ON DELETE CASCADE,
        order_index INTEGER NOT NULL DEFAULT 0,
        target_sets INTEGER NOT NULL DEFAULT 3,
        target_min_reps INTEGER NOT NULL DEFAULT 8,
        target_max_reps INTEGER NOT NULL DEFAULT 12,
        rest_seconds INTEGER NOT NULL DEFAULT 90
      );
    ''');

    rawDb.execute('''
      CREATE TABLE workout_sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        workout_day_id INTEGER REFERENCES workout_days(id) ON DELETE SET NULL,
        plan_name TEXT,
        day_name TEXT NOT NULL DEFAULT 'Workout Session',
        started_at INTEGER NOT NULL,
        finished_at INTEGER,
        notes TEXT,
        duration_minutes INTEGER NOT NULL DEFAULT 0,
        total_volume REAL NOT NULL DEFAULT 0.0
      );
    ''');

    rawDb.execute('''
      CREATE TABLE exercise_sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        workout_session_id INTEGER NOT NULL REFERENCES workout_sessions(id) ON DELETE CASCADE,
        exercise_id INTEGER REFERENCES exercises(id) ON DELETE CASCADE,
        exercise_name TEXT NOT NULL,
        order_index INTEGER NOT NULL DEFAULT 0,
        rest_seconds INTEGER NOT NULL DEFAULT 90,
        notes TEXT
      );
    ''');

    rawDb.execute('''
      CREATE TABLE workout_sets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        exercise_session_id INTEGER NOT NULL REFERENCES exercise_sessions(id) ON DELETE CASCADE,
        set_number INTEGER NOT NULL,
        weight REAL NOT NULL DEFAULT 0.0,
        reps INTEGER NOT NULL DEFAULT 0,
        rpe REAL,
        rir INTEGER,
        rest_seconds INTEGER,
        completed INTEGER NOT NULL DEFAULT 0,
        created_at INTEGER NOT NULL
      );
    ''');

    rawDb.execute('''
      CREATE TABLE body_measurements (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date INTEGER NOT NULL,
        body_weight REAL NOT NULL,
        body_fat REAL,
        chest REAL,
        waist REAL,
        arm REAL,
        thigh REAL,
        notes TEXT
      );
    ''');

    final nowEpoch = DateTime.now().millisecondsSinceEpoch;

    // Insert legacy seed exercise "Squat" (id=1) and "One Arm Dumbbell Row" (id=2) and "Bench Press" (id=3)
    rawDb.execute('''
      INSERT INTO exercises (id, name, muscle_group, equipment, is_custom, created_at, updated_at)
      VALUES 
        (1, 'Squat', 'Legs', 'Barbell', 0, $nowEpoch, $nowEpoch),
        (2, 'One Arm Dumbbell Row', 'Back', 'Dumbbell', 0, $nowEpoch, $nowEpoch),
        (3, 'Bench Press', 'Chest', 'Barbell', 0, $nowEpoch, $nowEpoch);
    ''');

    // Insert a custom exercise with conflicting name "Leg Press" (id=4)
    rawDb.execute('''
      INSERT INTO exercises (id, name, muscle_group, equipment, is_custom, created_at, updated_at)
      VALUES (4, 'Leg Press', 'Legs', 'Machine', 1, $nowEpoch, $nowEpoch);
    ''');

    // Insert workout plan using exercise id 1 ("Squat")
    rawDb.execute('''
      INSERT INTO workout_plans (id, name, description, is_active, created_at, updated_at)
      VALUES (1, 'V1 Plan', 'Plan created on schema v1', 1, $nowEpoch, $nowEpoch);
    ''');

    rawDb.execute('''
      INSERT INTO workout_days (id, workout_plan_id, name, order_index)
      VALUES (1, 1, 'Leg Day', 0);
    ''');

    rawDb.execute('''
      INSERT INTO workout_exercises (id, workout_day_id, exercise_id, order_index, target_sets, target_min_reps, target_max_reps, rest_seconds)
      VALUES (1, 1, 1, 0, 4, 10, 15, 60);
    ''');

    // Insert completed session with exercise id 1 ("Squat")
    rawDb.execute('''
      INSERT INTO workout_sessions (id, workout_day_id, plan_name, day_name, started_at, finished_at, duration_minutes, total_volume)
      VALUES (1, 1, 'V1 Plan', 'Leg Day', $nowEpoch, $nowEpoch + 3600000, 60, 500.0);
    ''');

    rawDb.execute('''
      INSERT INTO exercise_sessions (id, workout_session_id, exercise_id, exercise_name, order_index, rest_seconds)
      VALUES (1, 1, 1, 'Squat', 0, 60);
    ''');

    rawDb.execute('''
      INSERT INTO workout_sets (id, exercise_session_id, set_number, weight, reps, completed, created_at)
      VALUES (1, 1, 1, 100.0, 5, 1, $nowEpoch);
    ''');

    // 2. Open DB with Drift AppDatabase -> triggers migration v1 -> v3
    final db = AppDatabase(NativeDatabase.opened(rawDb));
    final versionResult = await db
        .customSelect('PRAGMA user_version')
        .getSingle();
    expect(versionResult.read<int>('user_version'), equals(3));

    // 3. Load catalog JSON file from disk for testing
    final catalogFile = File('assets/data/exercise_catalog.json');
    expect(catalogFile.existsSync(), isTrue);
    final catalog = ExerciseCatalogLoader.loadFromString(
      catalogFile.readAsStringSync(),
    );

    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final syncer = ExerciseCatalogSync(db, prefs);

    // 4. Perform sync
    await syncer.syncIfNeeded(catalog: catalog, force: true);

    // 5. Verify backfill of legacy exercise rows:
    // "Squat" should now have catalogKey "squat", id remains 1!
    final squatRow = await (db.select(
      db.exercises,
    )..where((t) => t.id.equals(1))).getSingle();
    expect(squatRow.id, equals(1));
    expect(squatRow.catalogKey, equals('squat'));
    expect(squatRow.isCustom, isFalse);

    // "One Arm Dumbbell Row" matched alias of "dumbbell_row", id remains 2!
    final rowRow = await (db.select(
      db.exercises,
    )..where((t) => t.id.equals(2))).getSingle();
    expect(rowRow.id, equals(2));
    expect(rowRow.catalogKey, equals('dumbbell_row'));
    expect(rowRow.isCustom, isFalse);

    // "Bench Press" should have catalogKey "bench_press", id remains 3!
    final benchRow = await (db.select(
      db.exercises,
    )..where((t) => t.id.equals(3))).getSingle();
    expect(benchRow.id, equals(3));
    expect(benchRow.catalogKey, equals('bench_press'));

    // Custom exercise "Leg Press" (id=4) MUST NOT be overwritten or assigned catalogKey
    final customLegPress = await (db.select(
      db.exercises,
    )..where((t) => t.id.equals(4))).getSingle();
    expect(customLegPress.id, equals(4));
    expect(customLegPress.isCustom, isTrue);
    expect(customLegPress.catalogKey, isNull);

    // There should ALSO be a catalog Leg Press with catalogKey 'leg_press' and isCustom = false!
    final catalogLegPress = await (db.select(
      db.exercises,
    )..where((t) => t.catalogKey.equals('leg_press'))).getSingle();
    expect(catalogLegPress.id, isNot(equals(4)));
    expect(catalogLegPress.isCustom, isFalse);

    // Verify Workout plan still points to exercise 1 ("Squat")
    final planExercises = await (db.select(
      db.workoutExercises,
    )..where((t) => t.workoutDayId.equals(1))).get();
    expect(planExercises.length, equals(1));
    expect(planExercises.first.exerciseId, equals(1));

    // Verify workout history session still intact
    final historySessions = await db.select(db.workoutSessions).get();
    expect(historySessions.first.planName, equals('V1 Plan'));
    expect(historySessions.first.totalVolume, equals(500.0));

    final exSessions = await db.select(db.exerciseSessions).get();
    expect(exSessions.first.exerciseId, equals(1));
    expect(exSessions.first.exerciseName, equals('Squat'));

    await db.close();
  });
}
