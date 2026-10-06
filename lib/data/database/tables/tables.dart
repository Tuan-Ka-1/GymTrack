import 'package:drift/drift.dart';

@DataClassName('ExerciseEntry')
class Exercises extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get muscleGroup => text()();
  TextColumn get equipment => text()();
  TextColumn get exerciseType =>
      text().withDefault(const Constant('Weight & Reps'))();
  TextColumn get description => text().nullable()();
  TextColumn get catalogKey => text().nullable().unique()();
  TextColumn get secondaryMuscles => text().nullable()();
  TextColumn get instructions => text().nullable()();
  TextColumn get tips => text().nullable()();
  TextColumn get imageAsset => text().nullable()();
  BoolColumn get isCustom => boolean().withDefault(const Constant(false))();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('WorkoutPlanEntry')
class WorkoutPlans extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get description => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('WorkoutDayEntry')
class WorkoutDays extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get workoutPlanId =>
      integer().references(WorkoutPlans, #id, onDelete: KeyAction.cascade)();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  IntColumn get dayOfWeek => integer().nullable()(); // 1 = Mon ... 7 = Sun
  IntColumn get orderIndex => integer().withDefault(const Constant(0))();
}

@DataClassName('WorkoutExerciseEntry')
class WorkoutExercises extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get workoutDayId =>
      integer().references(WorkoutDays, #id, onDelete: KeyAction.cascade)();
  IntColumn get exerciseId => integer().nullable().references(
    Exercises,
    #id,
    onDelete: KeyAction.setNull,
  )();
  IntColumn get orderIndex => integer().withDefault(const Constant(0))();
  IntColumn get targetSets => integer().withDefault(const Constant(3))();
  IntColumn get targetMinReps => integer().withDefault(const Constant(8))();
  IntColumn get targetMaxReps => integer().withDefault(const Constant(12))();
  IntColumn get restSeconds => integer().withDefault(const Constant(90))();
}

@DataClassName('WorkoutSessionEntry')
class WorkoutSessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get workoutDayId => integer().nullable().references(
    WorkoutDays,
    #id,
    onDelete: KeyAction.setNull,
  )();
  TextColumn get planName => text().nullable()();
  TextColumn get dayName =>
      text().withDefault(const Constant('Workout Session'))();
  DateTimeColumn get startedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get finishedAt => dateTime().nullable()();
  TextColumn get notes => text().nullable()();
  IntColumn get durationMinutes => integer().withDefault(const Constant(0))();
  RealColumn get totalVolume => real().withDefault(const Constant(0.0))();
}

@DataClassName('ExerciseSessionEntry')
class ExerciseSessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get workoutSessionId =>
      integer().references(WorkoutSessions, #id, onDelete: KeyAction.cascade)();
  IntColumn get exerciseId => integer().nullable().references(
    Exercises,
    #id,
    onDelete: KeyAction.setNull,
  )();
  TextColumn get exerciseName => text()();
  IntColumn get orderIndex => integer().withDefault(const Constant(0))();
  IntColumn get restSeconds => integer().nullable()();
  TextColumn get notes => text().nullable()();
}

@DataClassName('WorkoutSetEntry')
class WorkoutSets extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get exerciseSessionId => integer().references(
    ExerciseSessions,
    #id,
    onDelete: KeyAction.cascade,
  )();
  IntColumn get setNumber => integer()();
  RealColumn get weight => real().withDefault(const Constant(0.0))();
  IntColumn get reps => integer().withDefault(const Constant(0))();
  RealColumn get rpe => real().nullable()();
  IntColumn get rir => integer().nullable()();
  IntColumn get restSeconds => integer().nullable()();
  BoolColumn get completed => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('BodyMeasurementEntry')
class BodyMeasurements extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get date => dateTime().withDefault(currentDateAndTime)();
  RealColumn get bodyWeight => real()();
  RealColumn get bodyFat => real().nullable()();
  RealColumn get chest => real().nullable()();
  RealColumn get waist => real().nullable()();
  RealColumn get arm => real().nullable()();
  RealColumn get thigh => real().nullable()();
  TextColumn get notes => text().nullable()();
}
