import 'package:drift/drift.dart';

import '../../domain/repositories/body_repository.dart';
import '../database/app_database.dart';

class BodyRepositoryImpl implements BodyRepository {
  final AppDatabase _db;

  BodyRepositoryImpl(this._db);

  @override
  Stream<List<BodyMeasurementEntry>> watchBodyMeasurements() =>
      _db.watchBodyMeasurements();

  @override
  Future<List<BodyMeasurementEntry>> getBodyMeasurements() =>
      _db.getBodyMeasurements();

  @override
  Future<BodyMeasurementEntry?> getLatestBodyMeasurement() =>
      _db.getLatestBodyMeasurement();

  @override
  Future<int> addBodyMeasurement({
    required DateTime date,
    required double bodyWeight,
    double? bodyFat,
    double? chest,
    double? waist,
    double? arm,
    double? thigh,
    String? notes,
  }) {
    return _db.insertBodyMeasurement(
      BodyMeasurementsCompanion.insert(
        date: Value(date),
        bodyWeight: bodyWeight,
        bodyFat: Value(bodyFat),
        chest: Value(chest),
        waist: Value(waist),
        arm: Value(arm),
        thigh: Value(thigh),
        notes: Value(notes),
      ),
    );
  }

  @override
  Future<int> deleteBodyMeasurement(int id) => _db.deleteBodyMeasurement(id);
}
