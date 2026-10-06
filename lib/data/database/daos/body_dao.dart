part of '../app_database.dart';

/// Body tracking queries and writes.
extension BodyDao on AppDatabase {
  Stream<List<BodyMeasurementEntry>> watchBodyMeasurements() => (select(
    bodyMeasurements,
  )..orderBy([(t) => OrderingTerm.desc(t.date)])).watch();

  Future<List<BodyMeasurementEntry>> getBodyMeasurements() => (select(
    bodyMeasurements,
  )..orderBy([(t) => OrderingTerm.desc(t.date)])).get();

  Future<BodyMeasurementEntry?> getLatestBodyMeasurement() =>
      (select(bodyMeasurements)
            ..orderBy([(t) => OrderingTerm.desc(t.date)])
            ..limit(1))
          .getSingleOrNull();

  Future<int> insertBodyMeasurement(BodyMeasurementsCompanion value) =>
      into(bodyMeasurements).insert(value);

  Future<int> deleteBodyMeasurement(int id) =>
      (delete(bodyMeasurements)..where((t) => t.id.equals(id))).go();
}
