import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtrack/data/database/app_database.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;

void main() {
  test('Drift migration v1 to v3 preserves data and applies schema upgrades correctly', () async {
    // 1. Create in-memory SQLite database at schema v1
    final rawDb = sqlite.sqlite3.openInMemory();

    // Set user_version to 1
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
    // Insert v1 data: custom exercise, plan, workout day, workout exercise, session, sets, body measurement
    rawDb.execute('''
      INSERT INTO exercises (id, name, muscle_group, equipment, is_custom, created_at, updated_at)
      VALUES (1, 'Custom Lateral Raise', 'Shoulders', 'Dumbbell', 1, $nowEpoch, $nowEpoch);
    ''');

    rawDb.execute('''
      INSERT INTO workout_plans (id, name, description, is_active, created_at, updated_at)
      VALUES (1, 'V1 Plan', 'Plan created on schema v1', 1, $nowEpoch, $nowEpoch);
    ''');

    rawDb.execute('''
      INSERT INTO workout_days (id, workout_plan_id, name, order_index)
      VALUES (1, 1, 'Day 1', 0);
    ''');

    rawDb.execute('''
      INSERT INTO workout_exercises (id, workout_day_id, exercise_id, order_index, target_sets, target_min_reps, target_max_reps, rest_seconds)
      VALUES (1, 1, 1, 0, 4, 10, 15, 60);
    ''');

    rawDb.execute('''
      INSERT INTO workout_sessions (id, workout_day_id, plan_name, day_name, started_at, finished_at, duration_minutes, total_volume)
      VALUES (1, 1, 'V1 Plan', 'Day 1', $nowEpoch, $nowEpoch + 3600000, 60, 500.0);
    ''');

    rawDb.execute('''
      INSERT INTO exercise_sessions (id, workout_session_id, exercise_id, exercise_name, order_index, rest_seconds)
      VALUES (1, 1, 1, 'Custom Lateral Raise', 0, 60);
    ''');

    rawDb.execute('''
      INSERT INTO workout_sets (id, exercise_session_id, set_number, weight, reps, completed, created_at)
      VALUES (1, 1, 1, 10.0, 12, 1, $nowEpoch), (2, 1, 2, 12.0, 10, 1, $nowEpoch);
    ''');

    rawDb.execute('''
      INSERT INTO body_measurements (id, date, body_weight, notes)
      VALUES (1, $nowEpoch, 72.5, 'V1 weight log');
    ''');

    // 2. Open this raw database with Drift AppDatabase (target schema v3)
    final db = AppDatabase(NativeDatabase.opened(rawDb));

    // 3. Verify upgraded schema version is 3
    final versionResult = await db
        .customSelect('PRAGMA user_version')
        .getSingle();
    expect(versionResult.read<int>('user_version'), equals(3));

    // 4. Verify existing data preserved
    final exercises = await db.select(db.exercises).get();
    expect(exercises.length, equals(1));
    final ex = exercises.first;
    expect(ex.id, equals(1));
    expect(ex.name, equals('Custom Lateral Raise'));
    expect(ex.isCustom, isTrue);

    // 5. Verify v2 and v3 added columns defaults: isArchived is false, v3 columns are null
    expect(ex.isArchived, isFalse);
    expect(ex.catalogKey, isNull);
    expect(ex.instructions, isNull);
    expect(ex.tips, isNull);
    expect(ex.secondaryMuscles, isNull);
    expect(ex.imageAsset, isNull);

    // 6. Verify plans and days preserved
    final plans = await db.select(db.workoutPlans).get();
    expect(plans.first.name, equals('V1 Plan'));

    final days = await db.select(db.workoutDays).get();
    expect(days.first.name, equals('Day 1'));

    // 7. Verify session and sets preserved
    final sessions = await db.select(db.workoutSessions).get();
    expect(sessions.first.planName, equals('V1 Plan'));
    expect(sessions.first.totalVolume, equals(500.0));

    final sets = await db.select(db.workoutSets).get();
    expect(sets.length, equals(2));
    expect(sets.first.weight, equals(10.0));

    // 8. Verify FK exercise in exerciseSessions is now setNull on delete
    // Delete the exercise
    await (db.delete(db.exercises)..where((t) => t.id.equals(1))).go();

    final exSessionsAfter = await db.select(db.exerciseSessions).get();
    expect(exSessionsAfter.length, equals(1));
    // exerciseId was set to null because of ON DELETE SET NULL migration
    expect(exSessionsAfter.first.exerciseId, isNull);
    // exerciseName snapshot is still intact
    expect(exSessionsAfter.first.exerciseName, equals('Custom Lateral Raise'));

    // Sets are still intact
    final setsAfter = await db.select(db.workoutSets).get();
    expect(setsAfter.length, equals(2));

    await db.close();
  });
}
